*******************************************************************************
* 'STDUNACT' - PRINTS UNACTIVE STUDENTS
* JIM WEST
* 4/88

local cType, cBranch, cTitle, cLine
memvar getlist, pLine

draw_box(4,2,20,76)
@5,20 say 'PRINTING UNACTIVE STUDENTS'

begin sequence
if !net_use('Student',,,'names')
  break
endif

cType = ' '
@7,10 say "For 'A'll student or by 'B'ranch "
while !(cType $ 'AB')
  cType = upper(chr(inkey(0)))
enddo

cBranch = ' '
if cType = 'B'
  @10,10 say 'Enter branch code for printout ' get cBranch picture '!'
  read
endif

if !wmake_sure(13,,'Do you wish to continue ? ') .or. openprn()
break
endif
  dbgotop()
  cTitle = 'STUDENTS WHO HAVE NEVER TRANSACTED'
  while !eof()
    if Student->status = 'C'
      @17,10 clear to 17,68
      @17,10 say trim(Student->title) + ' ' + trim(Student->name) + ' ';
       + trim(Student->surname)
      if Student->wk_unact = Student->wk_smltn
        if (cType = 'A') .or. (cBranch = substr(Student->rep,1,1))
          if pline > 58
            prntitle(CtITLE, 'y')
            pr_line('NAME                                                             UNACT   WK SM     REP  PHONE(W)          PHONE(H)')
            pr_line(' ')
          endif
          cLine = trim(Student->surname) + ' ' + trim(Student->name)
          cLine += space(60 - len(cLine))
          cLine += str(Student->wk_unact,8,0) + str(Student->wk_smltn,8,0) +;
           '  ' + Student->rep + '      ' + Student->phone_w + '   ' +;
           Student->phone_h
pr_line(cLine)
        endif
      endif
    endif
    dbskip()
  enddo
  
  dbgotop()
  cTitle = 'STUDENTS WHO HAVE NOT TRANSACTED FOR A MONTH'
  pLine = 90
  while !eof()
    if Student->status = 'C'
      @17,10 clear to 17,68
      @17,10 say trim(Student->title) + ' ' + trim(Student->name) + ' ' +;
       trim(Student->surname)
      if Student->wk_unact > 4 .and. (Student->wk_smltn != Student->wk_unact)
        if (cType = 'A') .or. (cBranch = substr(Student->rep,1,1))
          if pLine > 58
            prntitle(cTitle, 'Y')
            pr_line('NAME                                                             UNACT   WK SM     REP  PHONE(W)          PHONE(H)')
            pr_line(' ')
          endif
          cLine = trim(Student->surname) + ' ' + trim(Student->name)
          cLine += space(60 - len(cLine))
          cLine += str(Student->wk_unact,8,0) + str(Student->wk_smltn,8,0) +;
           '  ' + Student->rep + '      ' + Student->phone_w + '   ' +;
            Student->phone_h
          pr_line(cLine)
        endif
      endif
    endif
    dbskip()
  enddo
end sequence
shutprn()
et_close('Student')
return
* eof
