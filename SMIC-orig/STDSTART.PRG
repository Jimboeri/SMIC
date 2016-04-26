*******************************************************************************
* PROGRAM STDSTART - STARTS NEW STUDENTS
* 11/3/88
* JIM WEST

local cTitle, cShr

simhead(memvar->pScr_title)
cTitle = 'Students started on ' + DTOC(DATE())

select 1
if !net_use('share', .f.,, 'shrname')
  return
endif
cShr = 'JSE-OVER '
dbseek(cShr)

select 2
if !net_use('transact', .f.,, 'trancode')
  dbcloseall()
  return
endif

select 3
if !net_use('student', .f.,, 'names')
  dbcloseall()
  return
endif

select student
if make_sure(10,, 'Are you SURE you want to start the new students')
  if make_sure(15,, 'Are you 100% SURE !!!!!!!!')
    if !flock()
      disp_msg(20,, 'Student file already in use - Please try later')
      inkey(10)
      dbcloseall()
      return
    endif
    
    openprn()
    while !eof()
      @18,30 say student->surname
      if student->status = 'N'
        if student->start_dt <= date()
          Student->start_indx := SHARE->PRICE
          Student->status     := 'C'
          Student->cash       := Student->initl_val
          Student->wk_smltn   := 1
          Student->wk_unact   := 1
          Student->perc_chang := 0
          Student->week_1     := 0
          Student->week_2     := 0
          Student->week_3     := 0
          Student->week_4     := 0
          Student->mnth_chang := 0
          if memvar->pline > 55
            prntitle(cTitle,'Y')
            pr_line('Archive   Acc no  Name                                                Rep   Phone (W)')
            pr_line(' ')
          endif
          pr_line(Student->archiv + '   ' + Student->std_code + '   ' +;
              Student->surname + ' ' + Student->name + ' ' + Student->rep + ' ' +;
              Student->phone_w + ' ' + Student->phone_h)
          select transact
          dbappend()
          reclock('Transaction')
          transact->std_code := Student->std_code
          transact->type     := 'T'
          transact->trn_type := 'BF '
          transact->value    := Student->cash
          transact->trn_dt   := date()
          dbunlock()
          select Student
        endif (date for new Student)
      endif (new student)
      dbskip()
    enddo (END OF STUDENT FILE)
    shutprn()
  endif
endif
dbcloseall()
return

*EOF
