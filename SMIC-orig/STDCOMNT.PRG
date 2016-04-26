*******************************************************************************
* STDCOMNT - UPDATES STUDENT COMMENT (MEMO) FIELDS
* JIM WEST
* 2/90

local mComment

if !net_use('student', .f.,, 'names')
  return
endif

simhead(memvar->pscr_title)
findstd()

if !eof()
  @3,0 clear
  mComment = Student->comment
  @4,50 say 'Comment for'
  @5,50 say trim(Student->title) + ' ' + trim(Student->name)
  @6,50 say Student->surname
  @8,50 say '^W ends the edit'
  @10,50 say '^B reformats screen'
  @6,4 clear to 18,46
  @6,4 to 18,46
  mComment = memoedit(mComment, 7, 5, 17, 45, .T.)
  reclock('Header')
  Student->comment := mComment
  dbunlock()
endif
close databases

return

* EOF