*******************************************************************************
* PROGRAM 'TRNSELL'
* AUTHOR JIM WEST
* 9/2/88

local cType, cShr, nQty := 0, nPrice, dTrans, nValue, nBrok, nHand, lQty_ok
local lSell_ok, nTotal, nCst_hold
memvar getlist

begin sequence
  
  cType = 'T'
  
  select portfol
  if !dbseek(student->std_code + cType)
    wait_msg(19, 'Student does not hold any shares.',,,20)
    break
  endif
  
  @7,1 clear to 23,78
  @7,1 to 23,78
  @8,20 say 'SHARE SELL SCREEN'
  cShr = findport(student->std_code + cType)
  
  if !empty(cShr)
    select Student
    if !rlock()
      wait_msg(19, 'Student already in use - Please try later',,,20)
      break
    endif
    select Share
    dbseek(portfol->share)
    nPrice = share->price
    dTrans = ctod('  /  /  ')
    @9,5 say 'SHARE   : ' + share->share + '  ' + share->full_name
    @11,3 say '   No. of             Cost of        Ave. Purchase     Yesterdays'
    @12,3 say 'Shares held           Holding           Price            Volume'
    @13,6 say str(portfol->qty,8,0)
    @13,20 say str(portfol->cost_hold,12,2)
    @13,40 say str((portfol->cost_hold / portfol->qty),8,2)
    @13,56 say share->volume
    @15,25 say 'Current          Current             %'
    @16,25 say '  Value           Price            Change'
    @15,5 say 'Transaction date'
    @16,5 get dTrans
    @17,40 get nPrice
    read
    nValue = (portfol->qty * nPrice) / 100
    @17,20 say str(nValue,12,2)
    if portfol->cost_hold != 0
      @17,56 say str(((nValue / portfol->cost_hold) * 100) - 100,10,2)
    endif
    lSell_ok = .T.
    lQty_ok = .F.
    while !lQty_ok
      @19,5 say 'QUANTITY TO SELL ' get nQty picture '99999999'
      read
      if nQty = 0
        lSell_ok = .F.
        lQty_ok = .T.
      endif
      if nQty > portfol->qty
        wait_msg(20, 'CANNOT SELL MORE SHARES THAN YOU ALREADY HAVE')
      else
        lQty_ok = .T.
      endif
    enddo
    if lSell_ok
      nValue = (nQty * nPrice) / 100
      nBrok = broker(nValue)
      nHand = handle(nQty)
      nTotal = nValue - nBrok - nHand
      select Student
      student->cash := student->cash + nTotal
      student->last_tran := date()
      student->wk_unact := 0
      if student->lec_stat = 'A'
        student->lec_stat := ' '
      endif
      select transact
      dbappend()
      reclock('Transaction')
      transact->std_code  := student->std_code
      transact->type      := cType
      transact->share     := cShr
      transact->trn_type  := 'SEL'
      transact->qty       := nQty
      transact->price     := nPrice / 100
      transact->brokerage := nBrok
      transact->tax       := 0
      transact->handle    := nHand
      transact->value     := nTotal
      transact->trn_dt    := dTrans
      if nQty = portfol->qty
        nCst_hold = portfol->cost_hold
      else
        nCst_hold = portfol->cost_hold * nQty / portfol->qty
      endif
      transact->cost_hold := nCst_hold
      dbunlock()
      select Portfol
      reclock('Portfolio')
      if portfol->qty - nQty = 0
        dbdelete()
      else
        portfol->qty := portfol->qty - nQty
        portfol->cost_hold := portfol->cost_hold - nCst_hold
      endif (shares left)
      dbunlock()
    endif (lSell_ok)
  endif (cShr != space)
end sequence
select Student
dbunlock()
RETURN

* EOF
