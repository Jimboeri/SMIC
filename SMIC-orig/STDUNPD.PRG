*******************************************************************************
* 'STDUNPD' PROGRAM TO SUSPEND UNPAID STUDENTS
* 29/3/88
* JIM WEST

local nJSE_inx, nRecord, cGroup

if !net_use('share', .f.,, 'shrname')
  return
endif
dbseek('JSE-OVER')
nJSE_inx = Share->price
dbclosearea()

select 2
if !net_use('transact', .f.,, 'trancode')
  return
endif

select 1
if !net_use('student', .f.,, 'names', 'stdgroup')
  close databases
  return
endif

simhead(memvar->pscr_title)
findstd()

if Student->status != 'C' .and. Student->status != 'N'
  disp_msg(20,,'STUDENT NOT CURRENT - MAY NOT BE SUSPENDED')
  inkey(10)
elseif Student->group_no != '01'
  disp_msg(20,,'STUDENT NOT GROUP LEADER', 'MAY NOT BE SUSPENDED')
  inkey(10)
else
  if !rlock()
    disp_msg(20,, 'Student already being used - Please try later')
    inkey(10)
  else
    @3,0 clear
    @3,20 say 'SUSPENSION OF AN UNPAID STUDENT'
    @6,10 say trim(Student->title) + ' ' + trim(Student->name) + ' ' +;
        trim(Student->surname)
    @8,10 say 'Phone (W) ' + Student->phone_w + ' (H) ' + Student->phone_h
    @10,10 SAY 'Address ' + Student->address1
    @11,18 say Student->address2
    @12,18 say Student->address3
    @13,18 say Student->p_code
    if make_sure(15,,'Do you want to suspend this student (Y/N) ? ')
      if Student->sold_els = ctod('  /  /  ')
        Student->status := 'U'
        Student->last_tran := date()
        dbunlock()
        if Student->group_cd != '     '
          nRecord = recno()
          cGroup = Student->group_cd
          dbsetorder(2)
          dbgoto(nRecord)
          dbskip()
          while Student->group_cd = cGroup .and. !eof()
            reclock('Student')
            Student->status := 'U'
            Student->last_tran := date()
            dbunlock()
            dbskip()
          enddo
          dbsetorder(1)
        endif
      else
        Student->status = 'F'
        Student->last_tran := date()
        dbunlock()
        select Transact
        dbappend()
        reclock()
        Transact->std_code := Student->std_code
        Transact->type     := 'T'
        Transact->trn_type := 'FIN'
        Transact->qty      := nJSE_inx
        Transact->trn_dt   := date()
        dbunlock()
      endif
    endif
  endif (rec lock)
endif (status = 'C')
close database
return
* eof
