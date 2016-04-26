*******************************************************************************
*
* TRNORDER - EXECUTES ANY POSSIBLE ORDERS EACH MORNING
*
*
*******************************************************************************

local nSel_tot, nSel_ex, nBuy_tot, nBuy_ex, nStp_tot, nStp_ex, nStp_up
local nQty, lExecute, nPrice, nBrok, nTotal, nHand, nCost_hold, nValue, nMst
local lDelete, nRec
memvar cMessage

#define EOL     chr(13) + chr(10)

nSel_tot := nSel_ex := nBuy_tot := nBuy_ex := nStp_tot := nStp_ex := nStp_up := 0

wopen(8,10,11,70)
wcenter()
wbox(0)
setcursor(0)
@0,0 say center('EXECUTING ALL ORDERS POSSIBLE')

begin sequence
  select 1
  if !net_use('student', .f.,, 'stdcode')
    break
  endif
  
  select 2
  if !net_use('transact', .f.,, 'trancode')
    break
  endif
  
  select 3
  if !net_use('portfol', .f.,, 'portfol')
    break
  endif
  
  select 4
  if !net_use('share', .f.,, 'shrname')
    break
  endif
  
  select 5
  if !net_use('order', .f.,, 'order')
    break
  endif
  
  select order
  nRec = 0
  while !eof()
    nRec++
    @1,0 say replicate('±', nRec / lastrec() * 60)
    tts_on()
    reclock('order')
    do case
      case order->trn_type = 'SEL'
        nSel_tot++
        Select Share
        if dbseek(order->share)
          select Portfol
          if !dbseek(order->std_code + 'T' + order->share)
            select Order
            dbdelete()
          else
            if portfol->qty < Order->qty
              Order->qty := portfol->qty
            endif
            nQty = Order->qty
            if nQty > Share->volume
              nQty = Share->volume
            endif
            if nQty > 0
              lExecute = .t.
              if Order->price != 0
                if Order->price*100 > Share->price
                  lExecute = .f.
                endif
              endif
              if lExecute
                nSel_ex++
                select Student
                if dbseek(order->std_code)
                  reclock('student')
                  nPrice = (nQty * Share->price) / 100
                  nBrok = broker(nPrice)
                  nHand = handle(nQty)
                  nTotal = nPrice - nBrok - nHand
                  Student->cash := Student->cash + nTotal
                  Student->last_tran := date()
                  Student->wk_unact := 0
                  if Student->lec_stat = 'A'
                    Student->lec_stat := ' '
                  endif
                  select Transact
                  dbappend()
                  reclock('Transaction')
                  Transact->std_code  := order->std_code
                  Transact->type      := 'T'
                  Transact->share     := Order->share
                  Transact->trn_type  := 'SEL'
                  Transact->qty       := nQty
                  Transact->price     := Share->price / 100
                  Transact->brokerage := nBrok
                  Transact->tax       := 0
                  Transact->handle    := nHand
                  Transact->value     := nTotal
                  Transact->trn_dt    := date()
                  if nQty = portfol->qty
                    nCost_hold = portfol->cost_hold
                  else
                    nCost_hold = portfol->cost_hold * nQty / portfol->qty
                  endif
                  Transact->cost_hold := nCost_hold
                  dbunlock()
                  select Portfol
                  reclock('portfol')
                  if portfol->qty - nQty = 0
                    dbdelete()
                  else
                    reclock('portfol')
                    portfol->qty       := portfol->qty - nQty
                    portfol->cost_hold := portfol->cost_hold - nCost_hold
                  endif (shares left)
                  dbunlock()
                  select Order
                  if order->qty - nQty = 0
                    dbdelete()
                  else
                    Order->qty := order->qty - nQty
                  endif (shares left)
                endif (student found)
              endif (execute order)
            endif (portfolio rec found)
          endif (volume available)
        endif (share found)
      case order->trn_type = 'BUY'
        nBuy_tot++
        Select Share
        if dbseek(order->share)
          if share->volume > 0
            nQty = Order->qty
            if nQty > Share->volume
              nQty = Share->volume
            endif
            lExecute = .T.
            if Order->price != 0
              if Order->price*100 < Share->price
                lExecute = .F.
              endif
            endif
            if lExecute
              nBuy_ex++
              select Student
              if dbseek(Order->std_code)
                reclock('student')
                nValue = (nQty * Share->price) / 100
                nBrok = broker(nValue)
                nHand = handle(nQty)
                nMst = mst(nValue)
                nTotal = nValue + nBrok + nMst + nHand
                while nTotal > Student->cash .and. nQty > 0
                  nQty = nQty - 100
                  if nQty < 0
                    nQty = 0
                  endif
                  nValue = (nQty * Share->price) / 100
                  nBrok = broker(nValue)
                  nHand = handle(nQty)
                  nMst = mst(nValue)
                  nTotal = nValue + nBrok + nMst + nHand
                enddo
                if nQty > 0
                  Student->cash      := Student->cash - nTotal
                  Student->last_tran := date()
                  Student->wk_unact  := 0
                  if Student->lec_stat = 'A'
                    Student->lec_stat := ' '
                  endif
                  select Transact
                  dbappend()
                  reclock('Transaction')
                  Transact->std_code  := Order->std_code
                  Transact->type      := 'T'
                  Transact->share     := order->share
                  Transact->trn_type  := 'BUY'
                  Transact->qty       := nQty
                  Transact->price     := Share->price / 100
                  Transact->brokerage := nBrok
                  Transact->tax       := nMst
                  Transact->handle    := nHand
                  Transact->value     := nTotal * -1
                  Transact->trn_dt    := date()
                  Transact->cost_hold := 0
                  dbunlock()
                  select Portfol
                  if !dbseek(Order->std_code + 'T' + order->share)
                    dbappend()
                    reclock('Portfolio')
                    portfol->std_code  := Order->std_code
                    portfol->type      := 'T'
                    portfol->share     := order->share
                    portfol->qty       := nQty
                    portfol->cost_hold := nTotal
                    portfol->purch_dt  := date()
                  else
                    reclock('Portfolio')
                    portfol->qty := portfol->qty + nQty
                    portfol->cost_hold := portfol->cost_hold + nTotal
                  endif (rec found)
                  dbunlock()
                  select Order
                  if nQty = order->qty
                    dbdelete()
                  else
                    Order->qty := order->qty - nQty
                  endif
                endif (shares available)
              endif (studend found)
            endif (LeXECUTE)
          endif (volume exists)
        endif (share found)
      case order->trn_type = 'STP'
        nStp_tot++
        Select Share
        if dbseek(order->share)
          select Portfol
          if !dbseek(Order->std_code + 'T' + order->share)
            select Order
            dbdelete()
          else
            if Order->price * 100 < Share->PRICE
              select Student
              dbseek(Order->std_code)
              if found() .and. student->stp_ls_lev != 0
                if ((Share->price - (Order->price*100)) / sHARE->price * 100);
                      > Student->stp_ls_lev
                  nStp_up++
                  select Order
                  Order->price := ((Share->price -;
                      (Share->price * Student->stp_ls_lev / 100)) / 100)
                  Order->exp_dt := date() + 365
                endif
              endif
            endif
            if portfol->qty < Order->qty
              Order->qty := portfol->qty
            endif
            nQty = Order->qty
            if nQty > Share->volume
              nQty = Share->volume
            endif
            if nQty > 0
              if Order->price * 100 > Share->price
                nStp_ex++
                select Student
                if dbseek(Order->std_code)
                  reclock('student')
                  nPrice = (nQty * Share->price) / 100
                  nBrok = broker(nPrice)
                  nHand = handle(nQty)
                  nTotal = nPrice - nBrok - nHand
                  Student->cash := student->cash + nTotal
                  Student->last_tran := date()
                  Student->wk_unact := 0
                  if Student->lec_stat = 'A'
                    Student->lec_stat := ' '
                  endif
                  dbunlock()
                  select Transact
                  dbappend()
                  reclock('Transaction')
                  Transact->std_code  := Order->std_code
                  Transact->type      := 'T'
                  Transact->share     := order->share
                  Transact->trn_type  := 'SEL'
                  Transact->qty       := nQty
                  Transact->price     := Share->price / 100
                  Transact->brokerage := nBrok
                  Transact->tax       := 0
                  Transact->handle    := nHand
                  Transact->value     := nTotal
                  Transact->trn_dt    := date()
                  if nQty = portfol->qty
                    nCost_hold = portfol->cost_hold
                  else
                    nCost_hold = portfol->cost_hold * nQty / portfol->qty
                  endif
                  Transact->cost_hold := NcOST_HOLD
                  dbunlock()
                  select Portfol
                  reclock('portfol')
                  if portfol->qty - nQty = 0
                    dbdelete()
                  else
                    portfol->qty := portfol->qty - nQty
                    portfol->cost_hold := portfol->cost_hold - nCost_hold
                  endif (shares left)
                  dbunlock()
                  select Order
                  if Order->qty - nQty = 0
                    dbdelete()
                  else
                    Order->qty := Order->qty - nQty
                  endif (shares left)
                  dbunlock()
                endif (student found)
              endif (execute order)
              select Student
            endif (portfolio rec found)
          endif (volume available)
        endif (share found)
    endcase
    select Order
    lDelete = .f.
    if order->exp_dt <= date() .or. order->qty = 0
      lDelete = .t.
    endif
    Select Share
    if !dbseek(order->share)
      lDelete = .t.
    endif
    select Order
    if lDelete
      dbdelete()
    endif
    dbunlock()
    tts_off()
    dbskip()
  enddo
  
  if net_use('param', .f.)
    reclock('param')
    param->lst_order := date()
    dbunlock()
  endif
end sequence
et_close('Student')
et_close('Share')
et_close('Transact')
et_close('Portfol')
et_close('Order')
et_close('Param')
wclose()
cMessage += 'Sell orders               = ' + ltrim(str(nSel_tot)) + EOL
cMessage += 'Sell orders executed      = ' + ltrim(str(nSel_ex)) + EOL
cMessage += 'Buy orders                = ' + ltrim(str(nBuy_tot)) + EOL
cMessage += 'Buy orders executed       = ' + ltrim(str(nBuy_ex)) + EOL
cMessage += 'Stop loss orders          = ' + ltrim(str(nStp_tot)) + EOL
cMessage += 'Stop loss orders executed = ' + ltrim(str(nStp_ex)) + EOL
cMessage += 'Stop loss orders upgraded = ' + ltrim(str(nStp_up)) + EOL

return

* eof()
