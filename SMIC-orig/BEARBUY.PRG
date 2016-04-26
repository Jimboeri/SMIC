*******************************************************************************
* PROGRAM 'BEARBUY'
* AUTHOR JIM WEST
* 9/2/88

local cType, cOrig_col, nQty, lBuy_ok, cScr, nValue, nBrok, nMst, nHand
local nTotal, dDeliv, nBr_cov, nBr_sel
memvar getlist

cType = 'T'

select Student
begin sequence
  if !rlock()
    disp_msg(20, 'Student already in use - Please try later',,,20)
    break
  endif
  
  @4,1 clear to 23,78
  @4,1 to 23,78
  cOrig_col = setcolor(memvar->yell_black)
  @5,20 say 'BEAR SALE DELIVERY SCREEN'
  @6,10 say 'STUDENT : ' + trim(Student->title) + ' ' + trim(Student->name);
      + ' ' + trim(Student->surname)
  setcolor(cOrig_col)
  select bear
  if !dbseek(Student->std_code + cType)
    wait_msg(13, 'Student has not short sold any shares',,,20)
    break
  endif
  findbear(Student->std_code + cType)
  if !eof()
    select Share
    dbseek(Bear->share)
    nQty = 0
    @7,3 say 'SHARE   : ' + bear->share + '  ' + share->full_name
    @9,3 say 'PRICE   : ' + str(share->price)
    @9,40 say 'Cover held        ' + str(Bear->sell_val + Bear->cov_hld)
    @10,40 say 'Ave cover price   ' +;
        str((Bear->sell_val + Bear->cov_hld)/Bear->qty)
    @11,3 say 'VOLUME  : ' + str(share->volume)
    @11,40 say 'Volume short sold ' + str(Bear->qty)
    @14,10 say 'SHARES TO DELIVER' get nQty picture '999999999'
    read
    lBuy_ok = .f.
    while !lBuy_ok
      lBuy_ok = .t.
      nQty = abs(nQty)
      IF (nQty > share->volume)
        lBuy_ok = .f.
        cScr = savesector(19,10,24,70)
        disp_msg(20,, "CANNOT BUY MORE THAN YESTERDAY'S VOLUME")
        @14,10 say 'SHARES TO DELIVER' get nQty picture '999999999'
        read
        restsector(cScr)
      endif
      IF nQty > Bear->qty
        lBuy_ok = .f.
        cScr = savesector(19,10,24,70)
        disp_msg(20,, 'CANNOT BUY MORE THAN YOU HAVE SHORT SOLD')
        @14,10 say 'SHARES TO DELIVER' get nQty picture '999999999'
        read
        restscreen(cScr)
      endif
    enddo
    if nQty > 0
      nValue = (nQty * share->price) / 100
      nBrok = broker(nValue)
      nHand = handle(nQty)
      nMst = mst(nValue)
      nTotal = nValue + nBrok + nMst + nHand
      select Bear
      reclock('Bear')
      dDeliv = bear->deliv_dt
      if nQty = bear->qty
        nBr_cov = bear->cov_hld
        nBr_sel = bear->sell_val
        dbdelete()
      else
        nBr_cov = bear->cov_hld * nQty / bear->qty
        nBr_sel = bear->sell_val * nQty / bear->qty
        Bear->cov_hld := bear->cov_hld - nBr_cov
        bear->sell_val := bear->sell_val - nBr_sel
        bear->qty := bear->qty - nQty
      endif
      dbunlock()
      select Student
      Student->cash := Student->cash + nBr_cov + nBr_sel - nTotal
      Student->last_tran := date()
      Student->wk_unact := 0
      if student->lec_stat = 'A'
        Student->lec_stat := ' '
      endif
      select transact
      dbappend()
      reclock('Transaction')
      transact->std_code  := Student->std_code
      transact->type      := cType
      transact->share     := bear->share
      transact->trn_type  := 'SDV'
      transact->qty       := nQty
      transact->price     := Share->price / 100
      transact->brokerage := nBrok
      transact->tax       := nMst
      transact->handle    := nHand
      transact->value     := nTotal * -1
      transact->trn_dt    := date()
      transact->cost_hold := nBr_sel
      dbunlock()
    endif
  endif (share = space)
end sequence
select Student
dbunlock()
return
* EOF
