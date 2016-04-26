*******************************************************************************
* PROGRAM 'STDWEEK' CHANGES ORIGINAL AND CURRENT CASH IN PORTFOLIO
* AUTHOR JIM WEST (E.T.)
* 1/2/88

local nExtra
memvar getlist

select 2
if !net_use('student', .f.,, 'names')
  return
endif

simhead(memvar->pscr_title)
findstd()
if eof()
  close database
  return
endif
if !rlock()
  @23,10 say 'Student already in use - Please try later'
  inkey(10)
  close databases
  return
endif
simhead(memvar->pscr_title)
@3,1 clear
@6,1 say 'Title: ' + Student->title
@6,15 say 'First name: ' + Student->name
@7,15 say 'Surname:    ' + Student->surname
@5,5 say 'Account no. ' + Student->std_code
@5,50 say 'Archive no ' + Student->archiv
@9,10 say 'Initial value ' + str(Student->initl_val,12,2)
@10,10 say 'Cash on hand  ' + str(Student->cash,12,2)
nExtra = 0
@14,10 SAY '(negative to reduce the value)'
@13,10 SAY 'How much should the value change ? ' get nExtra;
    picture '99999999.99'
read
if !empty(nExtra)
  if nExtra + Student->cash < 0
    disp_msg(16,,'Cannot reduce the cash below 0')
    inkey(30)
  else
    Student->initl_val := Student->initl_val + nExtra
    Student->cash := Student->cash + nExtra
    if !empty(Student->week_1)
      Student->week_1 := Student->week_1 + nExtra
    endif
    if !empty(Student->week_2)
      Student->week_2 := Student->week_2 + nExtra
    endif
    if !empty(Student->week_3)
      Student->week_3 := Student->week_3 + nExtra
    endif
    if !empty(Student->week_4)
      Student->week_4 := Student->week_4 + nExtra
    endif
    Student->fut_cash := Student->fut_cash + (nExtra / 4)
    @16,10
    wait 'Value of portfolio has changed by ' + ltrim(str(nExtra))
  endif
endif
dbunlock()
close database
return
* eof
