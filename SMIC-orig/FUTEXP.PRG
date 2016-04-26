*******************************************************************************
* FUTEXP - AUTOMATICALLY EXPIRES FUTURES
* JIM WEST
* 3/89

local nTot_exp, nTot_fut, nValue, nQty, nInitial, nProfit, nMargin
local nRec, lDel
memvar cMessage
nTot_exp := nTot_fut := 0

wopen(8,10,12,70)
wcenter()
wbox(0)
setcursor(0)
@0,0 say center('CHECKING FOR EXPIRED FUTURES')

begin sequence
  
  select 1
  if !net_use('futoptn', .f.,, 'futoptn')
    break
  endif
  
  select 2
  if !net_use('futport', .f.,, 'futport')
    break
  endif
  
  select 3
  if !net_use('futtrans', .f.,, 'futtrans')
    break
  endif
  
  select 4
  if !net_use('student', .f.,, 'stdcode')
    break
  endif
  
  select futoptn
  while !eof()
    nTot_fut++
    @1,0 say replicate('±', nTot_fut / lastrec() * 60)
    tts_on()
    if futoptn->expired != 'E'
      if futoptn->exp_date < date()
        nTot_exp++
        reclock('Futures')
        futoptn->expired := 'E'
        dbunlock()
        select futport
        dbgotop()
        nRec = 0
        while !eof()
          nRec++
          @2,0 say replicate('±', nRec / lastrec() * 60)
          if futport->fut_optn = futoptn->fut_optn
            select Student
            dbseek(futport->std_code)
            select futport
            if futport->qty < 0
              nValue = futval(futoptn->offer, futoptn->calc_type)
              nQty = futport->qty
              nMargin = futport->margin
              nInitial = futport->int_value
              reclock('Future portfolio')
              dbdelete()
              dbunlock()
              nProfit = (nValue * nQty) + nInitial
              select Student
              reclock('Student')
              Student->fut_cash := Student->fut_cash + nMargin + nProfit
              dbunlock()
              select futtrans
              dbappend()
              reclock('Future transactions')
              futtrans->std_code  := Student->std_code
              futtrans->fut_optn  := futoptn->fut_optn
              futtrans->trn_type  := 'FLA'
              futtrans->qty       := nQty
              futtrans->margin    := nMargin
              futtrans->int_value := nInitial
              futtrans->trn_dt    := date()
              futtrans->profit    := nProfit
              dbunlock()
            else
              nValue = futval(futoptn->bid, futoptn->calc_type)
              nQty = futport->qty
              nMargin = futport->margin
              nInitial = futport->int_value
              reclock('Future portfolio')
              dbdelete()
              dbunlock()
              nProfit = (nValue * nQty) + nInitial
              select Student
              reclock('Student')
              Student->fut_cash := Student->fut_cash + nMargin + nProfit
              dbunlock()
              select futtrans
              dbappend()
              reclock('Future transactions')
              futtrans->std_code  := Student->std_code
              futtrans->fut_optn  := futoptn->fut_optn
              futtrans->trn_type  := 'FSA'
              futtrans->qty       := nQty
              futtrans->margin    := nMargin
              futtrans->int_value := nInitial
              futtrans->trn_dt    := date()
              futtrans->profit    := nProfit
              dbunlock()
            endif
          endif
          select futport
          dbskip()
        enddo (portfolio records)
        @2,0 clear
      endif (out of date)
    else
      if futoptn->exp_date < date() - 20
        lDel = .t.
        select futport
        nRec = 0
        while !eof()
          nRec++
          @2,0 say replicate('±', nRec / lastrec() * 60)
          if futport->fut_optn = futoptn->fut_optn
            lDel = .f.
            exit
          endif
          dbskip()
        enddo
        @2,0 clear
        select futoptn
        if lDel
          reclock('futoptn')
          dbdelete()
          dbunlock()
        endif
      endif
    endif (expired)
    dbcommitall()
    tts_off()
    select futoptn
    dbskip()
  enddo
end sequence
et_close('Futoptn')
et_close('Futport')
et_close('Futtrans')
et_close('Student')
wclose()

cMessage += 'Existing futures = ' + str(nTot_fut) + chr(13) + chr(10)
cMessage += 'Futures expired  = ' + str(nTot_exp) + chr(13) + chr(10)

return

*eof
