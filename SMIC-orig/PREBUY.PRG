*******************************************************************************
* PROGRAM 'PREBUY' - PERFORM PREDATED BUYS
* AUTHOR JIM WEST
* 9/2/88

local cType, cScr, lLive_bear, cDeliver, nPrice, dTrans, nShr_pos
local nValue, nBrok, nHand, nMst, nTotal, nQty, lAdd_rec
memvar getlist

cType = 'T'             // only TWIN trans

begin sequence
  save screen to cScr
  findshr()
  restore screen from cScr
  release cScr
  
  if !eof()
    select Student
    if !rlock()
      wait_msg(15,'Student already in use - Please try later',,,20)
      break
    endif
    @7,1 clear to 23,78
    @7,1 to 23,78
    @8,24 say 'PREDATED SHARE PURCHASE SCREEN'
    select Bear
    if dbseek(student->std_code + 'T' + Share->share)
      lLive_bear = .F.
      while bear->std_code = student->std_code .and. bear->type = 'T';
            .and. bear->share = Share->share .and. !eof()
        if date() <= bear->deliv_dt
          lLive_bear = .T.
        endif
        dbskip()
      enddo
      if lLive_bear
        @7,1 say 'Share ' + Share->share
        @12,1 say 'You have SHORT SOLD these shares'
        cDeliver = ' '
        while !(cDeliver $ 'BD')
          @13,0 say 'Do you want to Buy more or Deliver your short sale (B/D) '
          cDeliver = upper(chr(inkey(0)))
        enddo
        if cDeliver = 'D'
          select Student
          dbunlock()
          break
        endif
      endif (live bear)
      @9,2 clear to 22,77
    endif (found bear record)
    select share
    if share->suspend != ' ' .and. share->suspend != 'N'
      wait_msg(20, 'This is not a share or it has been suspended',,,20)
    else
      nPrice = share->price
      dTrans = ctod('  /  /  ')
      @10,5 say 'SHARE   : ' + share->share + '  ' + share->full_name
      @12,5 say 'PRICE   :        ' get nPrice
      @13,5 say 'Transaction date : ' get dTrans
      @12,40 SAY 'Cash available        ' + STR(student->CASH)
      nShr_pos = student->CASH / (nPrice/100) / 100
      nShr_pos = INT(nShr_pos) * 100
      if nShr_pos < 0
        nShr_pos = 0
      endif
      nValue = (nShr_pos * nPrice) / 100
      nBrok = broker(nValue)
      nHand = handle(nShr_pos)
      nMst = mst(nValue)
      nTotal = nValue + nBrok + nMst + nHand
      if nTotal > student->cash
        nShr_pos = nShr_pos - 100
      endif
      nQty = 0
      @13,40 say 'Approx shares available ' + str(nShr_pos,10,0)
      
      @16,5 say 'QUANTITY REQUIRED' get nQty picture '999999999'
      read
      nQty = abs(nQty)
      lAdd_rec = .t.
      if nQty > 0
        nValue = (nQty * nPrice) / 100
        nBrok = broker(nValue)
        nHand = handle(nQty)
        nMst = mst(nValue)
        nTotal = nValue + nBrok + nMst + nHand
        select Student
        if nTotal > student->cash
          if nTotal < student->cash + memvar->povrdrft_lm
            if !make_sure(20,20,'DO YOU WANT TO GO INTO OVERDRAFT ? ')
              lAdd_rec = .f.
            endif
          else
            lAdd_rec = .f.
            wait_msg(20, 'TRANSACTION VALUE TOTAL EXCEDES CASH AVAILABLE',,,20)
          endif
        endif
        if lAdd_rec
          student->cash := student->cash - nTotal
          if dTrans > student->last_tran
            student->last_tran := dTrans
          endif
          student->wk_unact := 0
          if student->lec_stat = 'A'
            student->lec_stat := ' '
          endif
          select Transact
          dbappend()
          reclock('Transaction')
          transact->std_code  := student->std_code
          transact->type      := cType
          transact->share     := Share->share
          transact->trn_type  := 'BUY'
          transact->qty       := nQty
          transact->price     := nPrice / 100
          transact->brokerage := nBrok
          transact->tax       := nMst
          transact->handle    := nHand
          transact->value     := nTotal * -1
          transact->trn_dt    := dTrans
          transact->cost_hold := 0
          dbunlock()
          select Portfol
          if !dbseek(student->std_code + cType + Share->share)
            dbappend()
            reclock('Portfolio')
            portfol->std_code  := student->std_code
            portfol->share     := Share->share
            portfol->type      := cType
            portfol->qty       := nQty
            portfol->cost_hold := nTotal
            portfol->purch_dt  := dTrans
          else
            reclock('Portfolio')
            portfol->qty       := portfol->qty + nQty
            portfol->cost_hold := portfol->cost_hold + nTotal
          endif (rec found)
          dbunlock()
        endif (lAdd_rec)
      endif
    endif (share not suspended)
  endif
end sequence
select Student
dbunlock()
return

* EOF
