*******************************************************************************
* PROGRAM 'RSALES'
* JIM WEST
* CIRCA 1988

local dStart, dEnd, nSt_cd, nEnd_cd, cRep, cTitle, nCol
memvar getlist, pLine

if !net_use('student', .f.,, 'names')
  return
endif

simhead(memvar->pscr_title)
? '          ****** PRINT LISTS OF SALES PER AGENT OR SALESPERSON ******'
? ' '
cRep = '  '
@6,0 clear
@6,0 say 'Enter sales person code or agent code' get cRep picture '!!'
read
if !empty(cRep)
  @10,0 say 'SALESPERSON/AGENT CODE = '
  @10,25 say cRep
endif
*
dStart = ctod('00/00/00')
dEnd = date()
nSt_cd = 0
nEnd_cd = 9999
@11,0 clear
@12,0 say 'Enter start date for report ' get dStart picture '@D'
@13,0 say 'Enter end date for report   ' get dEnd picture '@D'
@15,0 say 'Enter start postal code     ' get nSt_cd picture '9999'
@16,0 say 'Enter end postal code       ' get nEnd_cd picture '9999'
read
*

begin sequence
  if wmake_sure()
    dbgotop()
    @18,10 say 'Printing sales report for ' + cRep
    if openprn()
      break
    endif
    cTitle = 'LIST OF SALES FOR SALESPERSON/AGENT ' + cRep + '   ' +;
        dtoc(dStart) + ' TO ' + dtoc(dEnd)
    while !eof()
      if Student->rep = cRep .or. cRep = '  '
        if (Student->sold_crs_1 >= dStart .and. Student->sold_crs_1 <= dEnd);
              .and. (val(Student->p_code) >= nSt_cd .and.;
              val(Student->p_code) <= nEnd_cd)
          if pline > 55
            prntitle(cTitle,'Y')
            if nSt_cd != 0 .or. nEnd_cd != 9999
              ? 'POSTAL CODES ' + str(nSt_cd,4,0) + ' TO '  + str(nEnd_cd,4,0)
              ? ' '
            endif
            pline = 8
            ? 'NAME                                                             UNACT   WK SM     REP  PHONE(W)          PHONE(H)'
            ? ' '
          endif
          ? trim(Student->surname) + ' ' + trim(Student->name)
          nCol = 60 - pcol()
          ?? replicate(' ',nCol) + str(Student->wk_unact,8,0) +;
              str(Student->wk_smltn,8,0) + '  ' + Student->rep + '      ' +;
              Student->phone_w + '   ' + Student->phone_h
          pline++
        endif
      endif
      dbskip()
    enddo
    shutprn()
  endif (yesno = 'y')
  
end sequence
dbcloseall()
return
*EOF
