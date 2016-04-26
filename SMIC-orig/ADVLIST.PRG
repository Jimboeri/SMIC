*******************************************************************************
* PROGRAM 'ADVLIST' PRINTS LIST OF ADVERTS
* JIM WEST

local lFull_report, dStart, dEnd, cTitle
memvar getlist

if !net_use('adverts', .f.,, 'advmedia')
  return
endif

simhead(memvar->pscr_title)
@7,30 say 'ADVERTS LIST'

lFull_report = make_sure(10,,'DO YOU WANT A FULL REPORT ? (Y/N) ')

dStart = ctod('  /  /  ')
dEnd = date()
if !lFull_report
  @12,0 SAY 'Enter start advert date for report ' get dStart picture '@d'
  @13,0 SAY 'Enter end advert date for report   ' get dEnd picture '@d'
  read
endif
begin sequence
  if !make_sure(14) .or. openprn()
    break
  endif
  @4,0 clear
  @7,5 say 'PRINTING THE ADVERTS LIST'
  cTitle = 'LIST OF ADVERTS FROM ' + DTOC(dStart) + ' TO ' + DTOC(dEnd)
  select adverts
  dbgotop()
  while !eof()
    if (adverts->source_dt >= dStart .and. adverts->source_dt <= dEnd);
          .or. lFull_report
      if memvar->pline > 55
        prntitle(cTitle,'N')
        ? 'SRCE  DATE    GEN        COST   DESCRIPTION'
        ? ' '
      endif
      ? adverts->source_cd , adverts->source_dt , '  ' , adverts->ld_gen ,;
          '  ' , adverts->cost , ' ' ,  trim(adverts->descriptn)
      ? ' '
      memvar->pline += 2
    endif
    dbskip()
  enddo (eof)
end sequence
shutprn()
@20,5 say 'ADVERTS LIST REPORT FINISHED'
close databases
return

*eof
