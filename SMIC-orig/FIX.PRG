use student exclusive
clear
while !eof()
  @3,3 say Student->surname
  if student->wk_smltn < 0
    student->wk_smltn := student->wk_smltn + 52
  endif
  dbskip()
enddo

close all

quit
