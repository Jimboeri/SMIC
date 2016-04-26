*******************************************************************************
* PROGRAM 'STDWEEK' GIVES EXTRA TIME TO A STUDENT
* AUTHOR JIM WEST (E.T.)
* 1/2/88

local nSim_len, nExtra
memvar getlist

select 2
if !net_use('student', .f., , 'names')
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

@3,1 clear
@6,1 SAY 'Title: ' + Student->title
@6,15 SAY 'First name: ' + Student->name
@7,15 SAY 'Surname:    ' + Student->surname
@5,5 SAY 'Account no. ' + Student->std_code
@5,50 SAY 'Archive no ' + Student->archiv
nSim_len := Student->simln_len
@9,10 SAY 'Duration of simulation ' + str(Student->simln_len,4,0)
@10,10 SAY 'Weeks on TWIN          ' + str(Student->wk_smltn,4,0)
@11,10 SAY 'Weeks unactive         ' + str(Student->wk_unact,4,0)
nExtra = 0
@13,10 SAY 'How many more weeks on TWIN ? ' get nExtra picture '9999'
read
nExtra = abs(nExtra)
if nExtra + student->simln_len > 999
  wait_msg(17,'Cannot add that much !!!')
else
  if nExtra > 0
    nSim_len += nExtra
    Student->simln_len := nSim_len
    if Student->status = 'F'
      @16,0
      wait 'Student has been given ' + ltrim(str(nExtra)) +;
          ' extra weeks and has been reclasified as current'
      Student->status := 'C'
    else
      @16,0
      wait 'Student has been given ' + ltrim(str(nExtra)) +;
          ' extra weeks on TWIN'
    endif
  endif
endif
dbunlock()
close database
return
* eof
