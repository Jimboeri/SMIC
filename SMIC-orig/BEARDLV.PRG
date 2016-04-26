*******************************************************************************
* BEARDLV
* AUTHOR JIM WEST
* 09/88

local nBr_tot, nBr_ex, nBr_cov, lDel, nQty, nValue, nBrok, nMst, nHand
local nTotal, nBr_sel, nCover, nDiff
memvar cMessage
nBr_tot := nBr_ex := nBr_cov := 0

#define EOL     chr(13) + chr(10)

wopen(8,10,11,70)
wcenter()
wbox(0)
setcursor(0)
@0,0 say center('CHECKING FOR BEAR SALES TO BE DELIVERED')

begin sequence
  select 1
  if !net_use('student', .f.,, 'stdcode')
    break
  endif
  
  select 2
  if !net_use('bear', .f.,, 'bear')
    break
  endif
  
  select 4
  if !net_use('transact', .f.,, 'trancode')
    break
  endif
  
  select 3
  if !net_use('share', .f.,, 'shrname')
    break
  endif
  
  select Bear
  dbgotop()
  while !eof()
    nBr_tot++
    tts_on()
    @1,0 say replicate('±', nBr_tot / lastrec() * 60)
    lDel = .F.
    select Share
    dbseek(bear->share)
    select Student
    dbseek(bear->std_code)
    select Bear
    if bear->deliv_dt < date()
      if Share->volume > 0
        nBr_ex++
        nQty = bear->qty
        if Share->volume < nQty
          nQty = Share->volume
        endif
        nValue = (nQty * Share->price) / 100
        nBrok = broker(nValue)
        nHand = handle(nQty)
        nMst = mst(nValue)
        nTotal = nValue + nBrok + nMst + nHand
        if nQty = bear->qty
          nCover = bear->cov_hld
          nBr_sel = bear->sell_val
          select Bear
          reclock('Bear')
          dbdelete()
          lDel = .t.
        else
          nCover = bear->cov_hld * nQty / bear->qty
          nBr_sel = bear->sell_val * nQty / bear->qty
          reclock('Bear')
          Bear->cov_hld := bear->cov_hld - nCover
          Bear->sell_val := bear->sell_val - nBr_sel
          Bear->qty := bear->qty - nQty
        endif
          dbunlock()
        select Student
        reclock('Student')
        Student->cash := Student->cash + nCover + nBr_sel - nTotal
        dbunlock()
        select Transact
        dbappend()
        reclock('Transaction')
        Transact->std_code  := bear->std_code
        Transact->type      := bear->type
        Transact->share     := bear->share
        Transact->trn_type  := 'FDV'
        Transact->qty       := nQty
        Transact->price     := Share->price / 100
        Transact->brokerage := nBrok
        Transact->tax       := nMst
        Transact->handle    := nHand
        Transact->value     := nTotal * -1
        Transact->trn_dt    := date()
        Transact->cost_hold := nBr_sel
        dbunlock()
      endif
    endif
    if !lDel
      select Bear
      nValue = (bear->qty * Share->price) / 100
      nQty = bear->qty
      nBrok = 0
      nMst = 0
      nHand = 0
      nBrok = broker(nValue)
      nHand = handle(nQty)
      nMst = mst(nValue)
      nTotal = nValue + nBrok + nMst + nHand
      nCover = bear->cov_hld
      if nTotal > bear->cov_hld
        nDiff = nTotal - bear->cov_hld
        if nDiff > 1
          nBr_cov++
          reclock('Bear')
          Bear->cov_hld := nTotal
          dbunlock()
          select Student
          reclock('Student')
          Student->cash := Student->cash - nDiff
          dbunlock()
          select Transact
          dbappend()
          reclock('Transaction')
          Transact->std_code  := bear->std_code
          Transact->type      := bear->type
          Transact->share     := bear->share
          Transact->trn_type  := 'SCV'
          Transact->qty       := Bear->qty
          Transact->price     := Share->price / 100
          Transact->value     := nDiff
          Transact->trn_dt    := date()
          Transact->cost_hold := nCover
          dbunlock()
        endif
        select Bear
      endif
    endif
    dbcommitall()
    tts_off()
    select Bear
    dbskip()
  enddo
  
  if net_use('param', .f.)
    reclock('Parameter')
    param->lst_bear := date()
    memvar->plst_bear := date()
    dbunlock()
  endif
end sequence
et_close('Student')
et_close('Param')
et_close('Bear')
et_close('Transact')
wclose()

cMessage += 'Bear sales                     = ' + ltrim(str(nBr_tot)) + EOL
cMessage += 'Bear sales executed            = ' + ltrim(str(nBr_ex))
cMessage += 'Bear sales needing extra cover = ' + ltrim(str(nBr_cov))

return

* eof
