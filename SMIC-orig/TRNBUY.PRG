*******************************************************************************
* PROGRAM 'TRNBUY'
* AUTHOR JIM WEST
* 9/2/88

LOCAL cScr, nAt_best, nOrd_ch, cOrig_col, cShr, nQty, lLive_bear, cDeliver
local nShrpos, nValue, nBrok, nHand, nMst, nTotal, lBuy_ok, lAddrec, nPrice
*LOCAL , nORD_CH, nAT_BEST

memvar aOrd_ch, aAt_best, getlist

private aOrd_ch := {'Buy shares now', 'Place buy order, (lower price)'}
private aAt_best := {'Buy shares at best', 'Set maximum price for buying'}

begin sequence
  
  cOrig_col = setcolor()
  
  select share
  
  save screen to cScr
  findshr()
  restore screen from cScr
  
  cShr = Share->share
  nQty := 0
  
  if !eof()
    select Student
    reclock('student')
    @7,1 clear to 23,78
    @7,1 to 23,78
    @8,30 say 'SHARE PURCHASE SCREEN'
    select Bear
    dbseek(Student->std_code + 'T' + cShr)
    if !eof()
      lLive_bear = .F.
      while bear->std_code = Student->std_code .and. bear->type = 'T' .and.;
            bear->share = cShr .and. !eof()
        if date() <= bear->deliv_dt
          lLive_bear = .T.
        endif
        dbskip()
      enddo
      if lLive_bear
        @7,1 SAY 'Share ' + cSHR
        @12,1 SAY 'You have SHORT SOLD these shares'
        cDeliver = ' '
        while !(cDeliver $ 'BD')
          @13,0 clear
          wait 'Do you want to Buy more or Deliver your short sale (B/D) ' TO cDeliver
          store upper(cDeliver) to cDeliver
        enddo
        if cDeliver = 'D'
          select Student
          dbunlock()
          break
        endif
      endif (live bear)
      @8,2 clear to 22,77
    endif (found bear record)
    select Share
    if share->suspend != ' ' .and. share->suspend != 'N'
      disp_msg(20, , 'This is not a share or it has been suspended')
      inkey(10)
    else
      @10,5 say 'SHARE   : ' + share->share + '  ' + share->full_name
      @12,5 say 'PRICE   : ' + str(share->price)
      @13,5 say 'VOLUME  : ' + str(share->volume)
      @12,40 say 'Cash available        ' + str(Student->cash)
      nShrpos = Student->cash / (share->price/100) / 100
      nShrpos = int(nShrpos) * 100
      if nShrpos > share->volume
        nShrpos = share->volume
      endif
      if nShrpos < 0
        nShrpos = 0
      endif
      nValue = (nShrpos * share->price) / 100
      nBrok = broker(nValue)
      nHand = handle(nShrpos)
      nMst = mst(nValue)
      nTotal = nValue + nBrok + nMst + nHand
      if nTotal > Student->cash
        nShrpos -= 100
      endif
      @13,40 say 'Approx shares available ' + str(nShrpos,10,0)
      setcolor(memvar->ach_col3)
      nOrd_ch = achoice(15, 40, 16, 72, aOrd_ch, .t., 'ESC_UDF')
      setcolor(Corig_col)
      @15,40 CLEAR TO 16,76
      if nORD_CH = 1
        lBuy_ok = .F.
        while !lBuy_ok
          @16,5 say 'QUANTITY REQUIRED' get nQty picture '999999999'
          read
          nQty = abs(nQty)
          IF !(nQty > share->volume)
            lBuy_ok = .t.
          else
            disp_msg(21, , "CANNOT BUY MORE THAN YESTERDAY'S VOLUME")
            nQty = 0
          endif
        enddo
        lAddrec = .T.
        IF nQTY > 0
          nValue = (nQty * share->price) / 100
          nBrok = broker(nValue)
          nHand = handle(nQty)
          nMst = mst(nValue)
          nTotal = nValue + nBrok + nMst + nHand
          select Student
          if nTotal > Student->cash
            if nTotal < (Student->cash + memvar->povrdrft_lm)
              if !make_sure(20,20,'DO YOU WANT TO GO INTO OVERDRAFT ? ')
                lAddrec = .F.
              endif
            else
              lAddrec = .F.
              disp_msg(20,, 'TRANSACTION VALUE TOTAL EXCEDES CASH AVAILABLE')
              inkey(10)
            endif
          endif
          if lAddrec
            Student->cash := Student->cash - nTotal
            Student->last_tran := date()
            Student->wk_unact := 0
            if Student->lec_stat = 'A'
              Student->lec_stat := ' '
            endif
            select transact
            dbappend()
            reclock('Transaction')
            transacT->std_code := Student->std_code
            transacT->type = 'T'
            transact->share := cShr
            transact->trn_type := 'BUY'
            transact->qty := nQty
            transact->price := sHare->price / 100
            transact->brokerage := nBrok
            transact->tax := nMst
            transact->handle := nHand
            transact->value := nTotal * -1
            transact->trn_dt := date()
            transact->cost_hold := 0
            dbunlock()
            select portfol
            dbseek(Student->std_code + 'T' + cShr)
            IF !FOUND()
              dbappend()
              RECLOCK('Portfolio')
              portfol->STD_CODE := Student->STD_CODE
              portfol->SHARE := cSHR
              portfol->TYPE := 'T'
              portfol->QTY := nQTY
              portfol->COST_HOLD := nTOTAL
              portfol->PURCH_DT := DATE()
            else
              reclock('Portfolio')
              portfol->qty := portfol->qty + nQty
              portfol->cost_hold := portfol->cost_hold + nTotal
            endif (rec found)
            dbunlock()
          endif (lAddrec)
        endif
      elseif nOrd_ch = 2
        * place order
        @16,10 say 'ORDER ENTRY'
        @17,5 say 'QUANTITY REQUIRED ' get nQty picture '99999999'
        read
        @17,24 say str(nQty,8,0)
        if (nQty * Share->price / 100) > Student->cash
          disp_msg(20, , 'ORDER WILL ONLY BE EXECUTED IF THERE IS SUFFICIENT CASH')
        endif
        if nQty > 0
          @15,38 SAY 'How would you like the order executed ?'
          setcolor(memvar->ach_col3)
          nAt_best = get_arr(aAt_best, 17, 38)
          setcolor(cOrig_col)
          if nAt_best = 1
            buy_order(nQTY, 0)
          else
            nPrice = Share->PRICE / 100
            @18,5 say 'MAXIMUM PRICE ' get nPrice
            read
            buy_order(nQty, nPrice)
          endif
        endif
      endif
    endif (share not suspended)
  endif
end sequence
select Student
dbunlock()
return

* EOF

*******************************************************************************
* PROCEDURE BUY_ORDER
*******************************************************************************
static procedure buy_order( nQty, nPrice)
select order
dbappend()
reclock('order')
order->std_code := Student->std_code
order->share := Share->share
order->trn_type := 'BUY'
order->qty := nQty
order->exp_dt := date() + 7
if nPrice = 0
  order->at_best := 'Y'
else
  order->at_best := 'N'
  order->price := nPrice
endif
dbunlock()
return

* EOF
