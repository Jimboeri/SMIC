*******************************************************************************
* 'STDRESET' DELETES STUDENT PORTFOLIO AND STARTS FROM SCRATCH
* JIM WEST
* 01-90

simhead(memvar->pscr_title)

select 1
if !net_use('portfol', .f.,, 'portfol')
  return
endif

select 2
if !net_use('transact', .f.,, 'trancode')
  close databases
  return
endif

select 3
if !net_use('share', .f.,, 'shrname')
  close databases
  return
endif

select 4
if !net_use('student', .f.,, 'names')
  close databases
  return
endif

findstd()

if !eof()
  @5,10 say trim(Student->title) + ' ' + trim(Student->name) + ' ';
      + Student->surname
  @7,10 say Student->address1
  @8,10 say Student->address2
  @9,10 say trim(Student->address3) + ' ' + Student->p_code
  @7,45 say 'Phone (W) ' + Student->phone_w
  @8,45 say 'Phone (H) ' + Student->phone_h
  if make_sure(11,10,;
        'Are you SURE you want to reset this students portfolio ?')
    select Share
    dbseek('JSE-OVER ')
    select Student
    reclock('Student')
    Student->start_indx := Share->PRICE
    Student->status     := 'C'
    Student->cash       := Student->initl_val
    Student->fut_cash   := Student->initl_val / 4
    Student->perc_chang := 0
    Student->week_1     := 0
    Student->week_2     := 0
    Student->week_3     := 0
    Student->week_4     := 0
    Student->mnth_chang := 0
    dbunlock()
    select Portfol
    dbseek(Student->std_code + 'T')
    while Student->std_code = portfol->std_code .and. portfol->type = 'T';
          .and. !eof()
      reclock('Portfolio')
      dbdelete()
      dbunlock()
      dbskip()
    enddo
    select Transact
    dbseek(Student->std_code)
    while Student->std_code = transact->std_code .and. !eof()
      reclock('Transaction')
      dbdelete()
      dbunlock()
      dbskip()
    enddo
    dbappend()
    reclock('Transaction')
    Transact->std_code := Student->std_code
    Transact->type     := 'T'
    Transact->trn_type := 'BF '
    Transact->value    := Student->cash
    Transact->trn_dt   := date()
    dbunlock()
  endif
endif (Student found)
close databases
return

*eof()
