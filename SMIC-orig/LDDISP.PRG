*******************************************************************************
* Program 'LDDISP'
* Jim West

local cOrig_col, cSurname, nCnt, cRep, nKey, cAddr
memvar getlist

#include 'inkey.ch'

simhead(memvar->pscr_title)
cOrig_COL = setcolor(memvar->scr_heading)
@2,30 say 'DISPLAY LEADS BY SURNAME'
setcolor(cOrig_COL)
cSurname = 'X'
select newleads
dbsetorder(3)
while !empty(cSurname)
  cSurname = space(30)
  @3,0 clear
  @4,20 say 'Surname ' get cSurname picture '@!'
  read
  @4,29 say cSurname
  if !empty(cSurname)
    cSurname = trim(cSurname)
    nCnt = 5
    @5,0 clear
    select reps
    dbgotop()
    while !eof()
      select newleads
      dbseek(reps->salespsn + cSurname)
      while reps->salespsn = newleads->salespsn .and.;
          newleads->surname = cSurname .and. !eof()
        if !empty(newleads->address3)
          cAddr = newleads->address3
        else
          cAddr = newleads->address2
        endif
        @nCnt,1 say newleads->archiv + ' ' + newleads->title + ' ' +;
            newleads->initls + ' ' + newleads->surname + ' ' + cAddr +;
            ' ' + newleads->salespsn
        nCnt++
        if nCnt > 22
          @23,20 say 'Esc to end or any key to continue'
          nKey = inkey(600)
          if nKey = K_ESC
            select reps
            dbgobottom()
            exit
          endif
          nCnt = 5
          @5,0 clear
        endif
        select newleads
        dbskip()
      enddo
      select reps
      dbskip()
    enddo
    if lastkey() != K_ESC
      @nCnt, 1 say 'Any key to continue'
      inkey(600)
    endif
  endif
enddo
select newleads
dbsetorder(1)
return
* eof
