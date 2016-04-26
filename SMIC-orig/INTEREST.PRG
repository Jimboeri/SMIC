*******************************************************************************
* PROCEDURE 'INTEREST' CALCULATES INTEREST ON OVERDRAFT OR BALANCE
* 16/2/88
* AUTHOR JIM WEST

local nInterest, nLending, nInt_val, nFut_int, nRec

wopen(8,10,12,70)
wcenter()
wbox(0)
setcursor(0)
@0,0 say center('CALCULATING INTEREST')

begin sequence

select 1
if !net_use('transact', .f.,, 'trancode')
  break
endif

select 2
if !net_use('student', .f.,, 'names', 'stdcode')
  break
endif

select 3
if !net_use('bear', .f.,, 'bear')
  break
endif

select 4
if !net_use('param', .f.)
  break
endif

nInterest = param->interest
nLending = param->lending

select student

nrec = 0
while !eof()
  nRec++
  @1,0 say replicate('±', nRec / lastrec() * 60)
  tts_on()
  if student->cash != 0 .and. student->status = 'C'
    select transact
    dbappend()
    reclock('Transaction')
    if student->cash > 0
      nInt_val = ((student->cash * nInterest) / 100) * 7 / 365
      transact->trn_type := 'INT'
      transact->price    := student->cash
      transact->value    := nInt_val
      transact->qty      := nInterest * 100
    else
      nInt_val = ((student->cash * nLending) / 100) * 7 / 365
      transact->trn_type := 'OVD'
      transact->price    := student->cash
      transact->value    := nInt_val
      transact->qty      := nLending * 100
    endif
    transact->std_code  := student->std_code
    transact->type      := 'T'
    transact->share     := space(9)
    transact->brokerage := 0
    transact->tax       := 0
    transact->handle    := 0
    transact->cost_hold := 0
    transact->trn_dt    := date()
    dbunlock()
    select student
    reclock('Student')
    Student->cash := Student->cash + nInt_val
    if Student->fut_cash > 0
      nFut_int = ((Student->fut_cash * nInterest) / 100) * 7 / 365
    else
      nFut_int = ((Student->fut_cash * nLending) / 100) * 7 / 365
    endif
    Student->fut_cash := Student->fut_cash + nFut_int
    dbunlock()
  endif
  dbcommitall()
  tts_off()
  dbskip()
enddo

select Student
dbsetorder(2)           // stdcode

select bear
dbgotop()
nRec = 0
while !eof()
  nRec++
  tts_on()
  @2,0 say replicate('±', nRec / lastrec() * 60)
  select student
  if dbseek(Bear->std_code)
    select transact
    dbappend()
    reclock('Transaction')
    nInt_val = ((bear->cov_hld * nInterest) / 100) * 7 / 365
    transact->trn_type := 'SIN'
    transact->type     := 'T'
    transact->price    := bear->cov_hld
    transact->value    := nInt_val
    transact->qty      := nInterest * 100
    transact->std_code := bear->std_code
    transact->share    := bear->share
    transact->trn_dt   := date()
    dbunlock()
    select student
    reclock('Student')
    student->cash := Student->cash + nInt_val
    dbunlock()
  endif
  dbcommitall()
  tts_off()
  select bear
  dbskip()
enddo

select param
reclock()
param->lst_int := date()
dbunlock()
end sequence
et_close('Transact')
et_close('Student')
et_close('Bear')
et_close('Param')
wclose()

return
* eof

