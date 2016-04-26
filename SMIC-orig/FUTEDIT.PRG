*******************************************************************************
* FUTURES EDIT PROGRAM
* Author - Jim West
* 04/10/87

local cFull_name, nMargin, nCalc_type
memvar getlist

if !net_use('futoptn', .f.,, 'futoptn')
  return
endif

findfut()

if !eof()
  if !rlock()
    @23,10 say center('Future in use - Please try later')
    inkey(10)
  else
    @6,1 clear
    @5,19 say futoptn->fut_optn
    @5,40 say futoptn->exp_date
    cFull_name = futoptn->full_name
    nMargin    = futoptn->margin
    nCalc_type = futoptn->calc_type
    @10,1 say 'Full name : ' get cFull_name valid !empty(cFull_name)
    @13,1 say 'Margin    : ' get nMargin picture '99999999.9999';
        valid val_margin()
    @16,1 say 'Enter calculation type' get nCalc_type picture '99';
        valid val_calc_type()
    *
    read
    nMargin = abs(nMargin)
    futoptn->full_name := cFull_name
    futoptn->margin    := nMargin
    futoptn->calc_type := nCalc_type
    dbunlock()
  endif (rec locked)
endif (not eof)
close databases
return
* eof
