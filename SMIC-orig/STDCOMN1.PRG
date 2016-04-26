*******************************************************************************
* STDCOMN1 - UPDATES STUDENT COMMENT (MEMO) FIELDS
* CALLED FROM TWIN
* JIM WEST
* 5/91

local mComment

if !eof()
  @4,2 clear to 20,77
  @4,2 to 20,77
  mComment = student->comment
  @5,50 say 'Comment for'
  @6,50 say trim(student->title) + ' ' + trim(student->name)
  @7,50 say trim(student->surname)
  @9,50 say '^W ends the edit'
  @11,50 say '^B reformats screen'
  @6,4 clear to 18,46
  @6,4 to 18,46
  mComment = MEMOEDIT(mComment, 7, 5, 17, 45, .T.)
  reclock('Student')
  student->comment := mComment
  dbunlock()
endif

return

* EOF