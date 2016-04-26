*******************************************************************************
* PROGRAM 'BEARSL'
* AUTHOR JIM WEST
* 9/88

local cType, cOrig_col, nShr_pos, nValue, nBrok, nHand, nMst, nTotal
local nVol, dDelivery, lValid, cScr, nPrice, nSell_val, nCover
memvar getlist

cType = 'T'

begin sequence
  
  select Student
  if !rlock()
    wait_msg(20,'Student already in use - Please try later',,,20)
    break
  endif
  
  @4,1 clear to 22,78
  @4,1 to 22,78
  cOrig_col = setcolor(memvar->yell_black)
  @5,20 say 'BEAR SALE SCREEN'
  @6,10 say 'STUDENT : ' + trim(Student->title) + ' ' + trim(Student->name);
      + ' ' + trim(Student->surname)
  setcolor(cOrig_col)
  select share
  findshr()
  if !eof()
    select Share
    @8,10 say share->share
    @9,10 say share->full_name
    @10,10 say 'Yesterdays Price ' + str(share->price)
    @10,49 say 'Yesterdays volume ' + str(share->volume)
    @11,10 say 'Available cash' + str(Student->cash)
    nShr_pos = Student->cash / (share->price/100) / 100
    nShr_pos = int(nShr_pos) * 100
    if nShr_pos > share->volume
      nShr_pos = share->volume
    endif
    if nShr_pos < 0
      nShr_pos = 0
    endif
    nValue = (nShr_pos * share->price) / 100
    nBrok = broker(nValue)
    nHand = handle(nShr_pos)
    nMst = mst(nValue)
    nTotal = nValue + nBrok + nMst + nHand
    if nTotal > Student->cash
      nShr_pos -= 100
    endif
    @11,49 SAY 'Available Volume  ' + str(nShr_pos,10,0)
    nVol = 0
    dDelivery = date() + 14
    @14,10 say 'Enter volume of transaction ' get nVol picture '9999999999'
    @16,10 say 'And delivery date           ' get dDelivery picture '@d'
    read
    nVol = abs(nVol)
    lValid = .f.
    while !lValid
      lValid = .T.
      if nVol > share->volume
        lValid = .F.
        cScr = SAVESECTOR(19,10,24,70)
        disp_msg(19,,'Cannot sell more than yesterdays volume')
        nVol = 0
        @14,10 say 'Enter volume of transaction ' get nVol picture '9999999999'
        read
        restscreen(cScr)
      endif
      if nVol != 0
        if dDelivery <= date()
          lValid = .f.
          cScr = savesector(19,10,24,70)
          disp_msg(19,, 'Delivery date cannot be prior to today')
          @16,10 say 'And delivery date           ' get dDelivery picture '@d'
          read
          restsector(cScr)
        endif
      endif
    enddo (validation)
    if nVol != 0
      nPrice = (nVol * share->price) / 100
      nBrok = broker(nPrice)
      nHand = handle(nVol)
      nMst = mst(nPrice)
      nTotal = nPrice + nBrok + nHand + nMst
      nSell_val = nPrice - nBrok - nHand
      nCover = nTotal
      select Student
      if nCover > student->cash
        disp_msg(20,, 'Cover necessary is greater than available cash', 'Try less volume')
        inkey(60)
      else
        Student->cash := student->cash - nCover
        Student->last_tran := date()
        Student->wk_unact := 0
        if student->lec_stat = 'A'
          Student->lec_stat := ' '
        endif
        select Bear
        dbappend()
        reclock('Bear')
        bear->std_code  := Student->std_code
        bear->type      := 'T'                   // 'TWIN'
        bear->share     := share->share
        bear->qty       := nVol
        bear->sell_val  := nSell_val
        bear->cov_hld   := nCover
        bear->deliv_dt  := dDelivery
        dbunlock()
        select Transact
        dbappend()
        reclock('Transaction')
        transact->std_code   := Student->std_code
        transact->type       := cType
        transact->share      := share->share
        transact->trn_type   := 'SSL'
        transact->qty        := nVol
        transact->price      := share->price / 100
        transact->brokerage  := nBrok
        transact->handle     := nHand
        transact->value      := nSell_val
        transact->trn_dt     := date()
        transact->cost_hold  := nTotal
        dbunlock()
      endif
    endif
  endif
end sequence
select student
dbunlock()
return
*EOF
