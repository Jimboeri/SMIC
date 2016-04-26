*******************************************************************************
* 'STDSUSP1' PROGRAM TO SUSPENT STUDENTS 
* CALLED FROM TWIN
* 5/91
* JIM WEST

local nOrig, dSusp_dt, nRecord, cGroup
memvar getlist

select Student
nOrig = recno()
draw_box(8,10,22,70)
@10,32 say 'Student suspension'
if Student->group_no = '01'
  if !rlock()
    wait_msg(16, 'Student already being used - Please try later',,,20)
  else
    if make_sure(12,,'Do you want to suspend this student (Y/N) ?')
      dSusp_dt = ctod('  /  /  ')
      @12,20 say 'Reinstatement date ' get dSusp_dt
      read
      Student->status := 'S'
      Student->last_tran := date()
      Student->susp_dt := dSusp_dt
    endif
    dbunlock()
  endif (rec lock)
  if Student->group_cd != '     '
    nRecord = recno()
    cGroup = student->group_cd
    dbsetorder(4)
    goto nRecord
    dbskip()
    while student->group_cd = cGroup .and. !eof()
      reclock('Student')
      Student->status := 'S'
      Student->last_tran := date()
      Student->susp_dt := dSusp_dt
      dbunlock()
      dbskip()
    enddo
    dbsetorder(2)               // names
  endif
  select Student
  goto nOrig
endif (group leader)

return
* EOF