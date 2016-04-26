*******************************************************************************
* PROGRAM 'FUTDISP'
* AUTHOR JIM WEST
* 9/2/88

local cTitle, nRow, nVal, nVal1, nTemp_val, nTot_cost, nValue

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
  
  @0,0 clear to 24,79
  @0,0 to 24,79
  cTitle = 'FUTURES PORTFOLIO OF ' + trim(Student->title) + ' ' +;
   trim(Student->name) + ' ' + trim(Student->surname)
  @1,((80-len(cTitle))/2) say cTitle
  @3,1 say '              NO OF   LONG/  COST OF       INITIAL       CURRENT       PROFIT'
  @4,1 say 'FUTURE        FUTURES SHORT  MARGIN         VALUE         VALUE        /LOSS'
  @5,1 say replicate('Ä',78)
  select futport
  dbseek(Student->std_code)
  nRow = 6
  nTot_cost := 0
  nValue = 0
  while futport->std_code = Student->std_code .and. !eof()
    select futoptn
    dbseek(futport->fut_optn)
    @nRow,1 say futport->fut_optn
    @nRow,16 say str(int(futport->qty),5,0)
    IF futport->qty > 0
      @nRow,25 say 'L'
    else
      @nRow,25 say 'S'
    endif
    @nRow,28 say str(futport->margin,9,2)
    @nRow,37 say str(futport->int_value)
    if futport->qty > 0
      nVal = futoptn->bid
    ELSE
      nVal = futoptn->offer
    endif
    nVal1 = futval(nVal, futoptn->CALC_TYPE)
    @nRow,54 say str((nVal1 * futport->qty),12,2)
    nTemp_val = (futport->int_value + (nVal1 * futport->qty))
    @nRow,68 say str(nTemp_val,10,2)
    nTot_cost = nTot_cost + futport->margin
    nValue += nTemp_val + futport->margin
    nRow++
    select futport
    dbskip()
    if nRow > 19
      @nRow + 1,0 say ' '
      wait 'PORTFOLIO CONTINUES  -  PRESS A KEY TO CONTINUE'
      @6,1 clear to 23,78
      nRow = 6
    endif
  enddo
  nRow++
  @nRow,1 say replicate('Ä',78)
  nRow++
  @nRow,12 say 'Tot Margin'
  @nRow,27 say str(nTot_cost,10,2)
  @nRow,56 say str(nValue,10,2)
  if nTot_cost != 0
    @nRow,71 say str((nValue / nTot_cost * 100) - 100,7,2)
  endif
  nRow++
  @nRow,1 say 'PORTFOLIO        Cash'
  @nRow,27 say str(Student->fut_cash,10,2)
  @nRow,42 say 'Total value'
  @nRow,56 say str(nValue + Student->fut_cash,10,2)
  @nRow,71 say str(((nValue + Student->fut_cash) / Student->initl_val * 400);
   - 100,7,2)
  * FUTURE CASH = INITL_VAL / 4
  if memvar->plst_f_updt != date()
    @20,10 say 'FUTURE PRICES NOT YET CAPTURED TODAY - LAST ON ' +;
     dtoc(memvar->plst_f_updt)
  endif
  inkey(300)
end sequence
select Student
dbunlock()
et_close('Futtrans')
et_close('Futoptn')
et_close('Futport')
* EOF
