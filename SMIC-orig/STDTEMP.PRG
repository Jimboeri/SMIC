*******************************************************************************
* 'STDACTIV' - PRINTS OUT ACTIVE STUDENTS
* JIM WEST
* 8/89

select 9
if !net_use('student', .f.,,'names')
  return
endif

clear

dStart := dEnd := ctod('  /  /  ')
@10,20 say 'Starting date ' get dStart
@11,20 say 'Ending   date ' get dEnd
read

cTitle = 'SHARE STUDENT SALES FROM ' + dtoc(dStart) + ' TO ' + dtoc(dEnd)

begin sequence
  if openprn()
    break
  endif
  pr_proc()
  select student
  dbclosearea()
  cTitle = 'SHARE STUDENT SALES (FINISHED STUDENT FILE) FROM ' + dtoc(dStart) + ' TO ' + dtoc(dEnd)
  
  select 9
  net_use('finished')
  pr_proc()
  dbcloseall()
  
end sequence
closeprn()
dbcloseall()
return

* eof

procedure pr_proc
pLine = 200
dbgotop()
while !eof()
  @15,10 clear to 15,68
  @15,10 say trim(title) + ' ' + trim(name) + ' ' + trim(surname)
  if sold_ss >= dStart .and. sold_ss <= dEnd
    if pline > 58
      prntitle(cTitle, 'Y')
      ? 'NAME                                                   ADDRESS                               PHONE NUMBERS'
      ? ' '
    endif
    ? trim(title) + ' ' + trim(name) + ' ' + trim(surname)
    mcol = 55 - pcol()
    ?? replicate(' ',mcol) + address1 + '             Ph(w) ' + phone_w
    ? 'Share student sold on ' + dtoc(sold_ss) + SPACE(25) + ADDRESS2 + '             Ph(h) ' + PHONE_H
    ? space(55) + P_CODE + ' ' + ADDRESS3
    ? ' '
    pline += 4
  endif
  dbskip()
enddo
return
