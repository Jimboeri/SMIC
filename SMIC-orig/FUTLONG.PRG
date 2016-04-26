*******************************************************************************
* FUTLONG - Handles all futures transactions
* 01/89
* Author - E.T. aka. Jim west

local nQty, nMarg1, nVal1, nAvail, nCost, lAdd_rec, nOrig_qty, nOrig_marg
local nOrig_init, nProfit

memvar getlist

if memvar->pLst_f_updt != date()
  wait_msg(20, 'FUTURE PRICES NOT YET CAPTURED TODAY', 'PLEASE TRY LATER',,20)
  return
endif

begin sequence
  
  select Student
  if !rlock()
    wait_msg(20, 'Student already in use - Please try later',,,20)
    break
  endif
  
  select 10
  if !net_use('futtrans', .f.,, 'futtrans')
    break
  endif
  
  select 11
  if !net_use('futport', .f.,, 'futport')
    break
  endif
  
  select 12
  if !net_use('futoptn', .f.,, 'futoptn')
    break
  endif
  
  findfut()
  if !eof()
    if futoptn->f_or_o = 'F'
      if futoptn->expired != 'E'
        draw_box(7,1,23,78)
        @8,5 say futoptn->fut_optn + ' - ' + futoptn->full_name
        nQty = 0
        nMarg1 = futoptn->margin
        nVal1 = futval(futoptn->offer, futoptn->calc_type)
        @10,10 say 'Value of a contract           = ' + str(nVal1,14,2)
        @11,10 say 'Margin necessary per contract = ' + str(nMarg1,14,2)
        @12,10 say 'Cash available                = ' +;
            str(student->fut_cash,14,2)
        select futport
        dbseek(student->std_code + futoptn->fut_optn)
        if !found() .or. futport->qty > 0
          if found()
            @13,10 SAY 'Contracts already held        = ' +;
                str(futport->qty,14,0)
          endif
          @14,40 say 'Contracts available = ' +;
              str(int(student->fut_cash / nMarg1),6,0)
          @16,10 say 'Number of contracts required ' get nQty picture '9999999'
          read
          nQty = abs(nQty)
          nCost = nQty * nMarg1
          select Student
          lAdd_rec = .T.
          if nQty = 0
            lAdd_rec = .F.
          endif
          if nCost > student->fut_cash
            if nCost < Student->fut_cash + Student->povrdrft_lm
              if make_sure(19,20,'DO YOU WANT TO GO INTO OVERDRAFT ? ')
                lAdd_rec = .F.
              endif
            else
              lAdd_rec = .F.
              wait_msg(20, 'TRANSACTION VALUE TOTAL EXCEDES CASH AVAILABLE',,,20)
            endif
          endif
          if lAdd_rec
            select futport
            if !dbseek(student->std_code + futoptn->fut_optn)
              dbappend()
              reclock('Future portfolio')
              futport->std_code  := student->std_code
              futport->fut_optn  := futoptn->fut_optn
              futport->qty       := 0
              futport->margin    := 0
              futport->int_value := 0
              dbunlock()
            endif
            reclock('Future portfolio')
            futport->qty       := futport->qty + nQty
            futport->margin    := futport->margin + (nMarg1 * nQty)
            futport->int_value := futport->int_value - (nVal1 * nQty)
            dbunlock()
            select Student
            student->fut_cash  := student->fut_cash - (nMarg1 * nQty)
            student->last_tran := date()
            student->wk_unact  := 0
            if Student->lec_stat = 'A'
              student->lec_stat := ' '
            endif
            select futtrans
            dbappend()
            reclock('Future transactions')
            futtrans->std_code  := student->std_code
            futtrans->fut_optn  := futoptn->fut_optn
            futtrans->trn_type  := 'FLN'
            futtrans->qty       := nQty
            futtrans->margin    := nMarg1 * nQty
            futtrans->int_value := nVal1 * nQty * -1
            futtrans->trn_dt    := date()
            dbunlock()
          endif (lAdd_rec)
        else
          * cover short
          select futport
          @13,10 say 'Contracts held' + str(abs(futport->qty),14,2)
          @14,10 say 'Number of contract required ' get nQty picture '9999999'
          read
          nQty = abs(nQty)
          if nQty != 0
            if nQty < futport->qty
              wait_msg(20, 'CANNOT COVER MORE CONTRACTS THAN YOU ALREADY HAVE',,,20)
            else
              nOrig_qty = futport->qty * -1
              nOrig_marg = futport->margin * nQty / nOrig_qty
              nOrig_init = futport->int_value * nQty / nOrig_qty
              reclock('Future portfolio')
              futport->qty       := futport->qty + nQty
              futport->margin    := futport->margin - nOrig_marg
              futport->int_value := futport->int_value + nOrig_init
              if futport->qty = 0
                select futport
                dbdelete()
              endif
              dbunlock()
              nProfit = nOrig_init - (nVal1 * nQty)
              select Student
              student->fut_cash  := student->fut_cash + nOrig_marg + nProfit
              student->last_tran := date()
              student->wk_unact  := 0
              if student->lec_stat = 'A'
                student->lec_stat := ' '
              endif
              select futtrans
              dbappend()
              reclock('Future transactions')
              futtrans->std_code  := student->std_code
              futtrans->fut_optn  := futoptn->fut_optn
              futtrans->trn_type  := 'FSC'
              futtrans->qty       := nQty
              futtrans->margin    := nOrig_marg
              futtrans->int_value := nOrig_init
              futtrans->trn_dt    := date()
              futtrans->profit    := nProfit
              dbunlock()
            endif (nQty > qty)
          endif (nQty != 0)
        endif (long/short trans)
      else
        wait_msg(20, 'This future has expired',,,20)
      endif (expired = 'E')
    endif (f_or_o = F)
  endif (future found)
end sequence
select Student
dbunlock()
et_close('Futtrans')
et_close('Futoptn')
et_close('Futport')
return

* EOF
