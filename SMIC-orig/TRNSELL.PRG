*******************************************************************************
* PROGRAM 'TRNSELL'
* AUTHOR JIM WEST
* 9/2/88

local cOrig_col, cShare, aOrd_ch, nOrd_ch, cType, nAt_best := 0
local nQty, nValue, lSell_ok, lQty_ok, nPrice, nBrok, nHand, nTotal
local nCost_hold
local aAt_best := {'Sell shares at best', 'Set minimum price for selling'}
memvar getlist

cShare = space(9)

cType = 'T'

aOrd_ch := {'Sell shares now', 'Place sell order, (higher price)'}
if memvar->mpw_lev > 7
  aadd(aOrd_ch, 'Set stop loss level')
endif
nOrd_ch = 0

nAt_best = 0

cOrig_col = setcolor()
nQty = 0

begin sequence
  
  select portfol
  if !dbseek(student->std_code + cType)
    wait_msg(19, 'Student does not hold any shares.',,,20)
    break
  endif
  
  @7,1 clear to 23,78
  @7,1 to 23,78
  @8,20 say 'SHARE SELL SCREEN'
  cShare = findport(student->std_code + cType)
  
  if !empty(cShare)
    select student
    reclock('Student')
    select Share
    dbseek(portfol->share)
    @9,5 say 'SHARE   : ' + share->share + '  ' + share->full_name
    @11,3 say '   No. of             Cost of        Ave. Purchase     Yesterdays'
    @12,3 say 'Shares held           Holding           Price            Volume'
    @13,6 say str(portfol->qty,8,0)
    @13,20 say str(portfol->cost_hold,12,2)
    @13,40 say str((portfol->cost_hold / portfol->qty),8,2)
    @13,56 say share->volume
    @15,25 say 'Current          Current             %'
    @16,25 say '  Value           Price            Change'
    nValue = (portfol->qty * share->price) / 100
    @17,20 say str(nValue,12,2)
    @17,40 say str((share->price / 100),8,2)
    if portfol->cost_hold != 0
      @17,56 say str(((nValue / portfol->cost_hold) * 100) - 100,10,2)
    endif
    setcolor(memvar->ach_col3)
    if cType = 'T'        && TWIN
      nOrd_ch = get_arr(aOrd_ch, 19, 40)
    else
      nOrd_ch = 1
    endif
    setcolor(cOrig_col)
    @19,40 clear to 21,72
    do case
      case nOrd_ch = 1
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
            wait_msg(20,'CANNOT SELL MORE SHARES THAN YOU ALREADY HAVE',,,20)
          else
            if nQty > share->volume
              wait_msg(20,'QUANTITY CHOSEN EXCEDES YESTERDAYS VOLUME',,,10)
            else
              lQty_ok = .T.
            endif
          endif
        enddo
        if lSell_ok
          nPrice = (nQty * Share->PRICE) / 100
          nBrok = BROKER(nPrice)
          nHand = HANDLE(nQty)
          nTotal = nPrice - nBrok - nHand
          select student
          student->cash := student->cash + nTotal
          student->last_tran := date()
          student->wk_unact := 0
          if student->lec_stat = 'A'
            student->lec_stat := ' '
          endif
          select transact
          dbappend()
          reclock('Transaction')
          transact->std_code := student->std_code
          transact->type := cType
          transact->share := cShare
          transact->trn_type := 'SEL'
          transact->qty := nQty
          transact->price := Share->price / 100
          transact->brokerage := nBrok
          transact->tax := 0
          transact->handle := nHand
          transact->value := nTotal
          transact->trn_dt := date()
          if nQty = portfol->qty
            nCost_hold = portfol->cost_hold
          else
            nCost_hold = portfol->cost_hold * nQty / portfol->qty
          endif
          transact->cost_hold := nCost_hold
          dbunlock()
          select Portfol
          reclock('Portfolio')
          if portfol->qty - nQty = 0
            dbdelete()
          else
            portfol->qty := portfol->qty - nQty
            portfol->cost_hold := portfol->cost_hold - nCost_hold
          endif (shares left)
          dbunlock()
        endif (lSell_ok)
      case nOrd_ch = 2
        * PLACE SELL ORDER
        lQty_ok = .F.
        while !lQty_ok
          @19,5 say 'QUANTITY TO ORDER ' get nQty picture '99999999'
          read
          @19,24 say str(nQty,8,0)
          if nQty <= portfol->qty
            lQty_ok = .T.
          else
            wait_msg(20,, 'CANNOT SELL MORE SHARES THAN YOU ALREADY HAVE',,,20)
            nQty = 0
          endif
        enddo
        if nQty > 0
          @19,38 SAY 'How would you like the order executed ?'
          nAt_best = get_arr(aAt_best, 21, 38)
          if nAt_best = 1
            sell_order(nQty, 0)
          else
            nPrice = Share->price / 100
            @20,5 say 'MINIMUM PRICE ' get nPrice
            read
            sell_order(nQty, nPrice)
          endif
        endif
      case nOrd_ch = 3
        * PLACE STOP_LOSS ORDER
        lQty_ok = .F.
        nQty = portfol->qty
        while !lQty_ok
          @19,5 say 'QUANTITY ' get nQty picture '99999999'
          read
          @19,15 say str(nQty,8,0)
          IF nQty <= portfol->qty
            lQty_ok = .T.
          else
            wait_msg(20,, 'CANNOT SELL MORE SHARES THAN YOU ALREADY HAVE',,,20)
            nQty = 0
          endif
        enddo
        IF nQty > 0
          nPrice = Share->PRICE / 100
          @20,5 say 'STOP LOSS PRICE ' get nPrice
          read
          if nPrice != 0
            select order
            dbappend()
            reclock('order')
            order->std_code := student->std_code
            order->share := Share->share
            order->trn_type := 'STP'
            order->qty := nQty
            order->exp_dt := date() + 365
            order->price := nPrice
          endif
          dbunlock()
        endif
    endcase
  endif (cShare != SPACE)
end sequence
select student
dbunlock()
return

* EOF

*******************************************************************************
* PROCEDURE SELL_ORDER
*******************************************************************************
procedure sell_order ( nQty, nPrice)
select order
dbappend()
reclock('order')
order->std_code := student->std_code
order->share := Share->share
order->trn_type := 'SEL'
order->qty := nQty
order->exp_dt := date() + 7
if nPrice = 0
  order->at_best := 'Y'
ELSE
  order->at_best := 'N'
  order->price := nPrice
endif
dbunlock()
return

* EOF
