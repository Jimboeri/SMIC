*******************************************************************************
* 'STDSUSP' PROGRAM TO SUSPENT STUDENTS
* 29/3/88
* JIM WEST

local dSusp_dt := ctod('  /  /  ')
local nRecno, cGroup
memvar getlist

begin sequence
  
  select 1
  if !net_use('student', .f.,, 'names', 'stdgroup')
    break
  endif
  
  simhead(memvar->pscr_title)
  findstd()
  
  if Student->status != 'C' .or. Student->group_no != '01'
    disp_msg(20,,'STUDENT NOT CURRENT', 'MAY NOT BE SUSPENDED')
    inkey(10)
    break
  endif
  if Student->group_no != '01'
    disp_msg(20,,'STUDENT NOT GROUP LEADER', 'MAY NOT BE SUSPENDED')
    inkey(10)
    break
  endif
  if !rlock()
    @23,10 SAY 'Student already being used - Please try later'
    inkey(10)
    break
  endif
  @3,0 clear
  @3,20 say 'SUSPENSION OF A STUDENT'
  @6,10 say trim(Student->title) + ' ' + trim(Student->name) + ' ' +;
      trim(Student->surname)
  @8,10 say 'Phone (W) ' + Student->phone_w + ' (H) ' + Student->phone_h
  @10,10 SAY 'Address ' + Student->address1
  @11,18 say Student->address2
  @12,18 say Student->address3
  @13,18 say Student->p_code
  if wmake_sure(15,,'Do you want to suspend this student (Y/N) ?')
    @18,10 say 'Date to reinstate ' get dSusp_dt
    read
    Student->status := 'S'
    Student->last_tran := date()
    Student->susp_dt := dSusp_dt
    dbunlock()
    if !empty(Student->group_cd)
      nRecno = recno()
      cGroup = Student->group_cd
      dbsetorder(2)
      dbgoto(nRecno)
      dbskip()
      while Student->group_cd = cGroup .and. !eof()
        reclock('Student')
        Student->status    := 'S'
        Student->last_tran := date()
        Student->susp_dt   := dSusp_dt
        dbunlock()
        dbskip()
      enddo
      dbsetorder(1)
    endif
  endif
end sequence
dbcloseall()
return
* eof
