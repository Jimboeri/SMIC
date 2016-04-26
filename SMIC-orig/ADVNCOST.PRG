*******************************************************************************
* PROGRAM 'ADVNCOST' PRINTS LIST OF ADVERTS WITH 0 PRICE
* JIM WEST

local cFull_rep, dStart, cTitle
memvar getlist

if !net_use('adverts', .f.,, 'advmedia')
  return
endif

simhead(memvar->pScr_title)
@7,20 say 'NO PRICE ADVERTS LIST'

cFull_rep = 'x'
while 'N' != cFull_rep .and. 'Y' != cFull_rep
  @9,0 clear
  wait 'DO YOU WANT A FULL REPORT ? (Y/N) ' TO cFull_rep
  cFull_rep := upper(cFull_rep)
enddo
dStart = ctod('  /  /  ')
if cFull_rep = 'N'
  @12,0 say 'Enter start advert date for report ' get dStart
  read
endif
if !make_sure()
  dbcloseall()
  return
endif
begin sequence
  openprn()
  @4,0 clear
  @7,5 say 'PRINTING THE NO COST ADVERTS LIST'
  cTitle = 'NO PRICE ADVERTS LIST'
  while !eof()
    if adverts->source_dt >= dStart .or. cFull_rep = 'Y'
      if adverts->cost = 0
        if memvar->pline > 55
          prntitle(cTitle,'N')
          pr_line('SRCE  DATE  GEN         COST      DESCRIPTION')
          pr_line(' ')
        endif
        pr_line(adverts->source_cd + ' ' + dtoc(adverts->source_dt) + ' ' +;
            adverts->ld_gen + '   [  ' + str(adverts->cost) + '  ]   ' +;
            trim(adverts->descriptn))
        pr_line(' ')
      endif
    endif
    dbskip()
  enddo (eof)
end sequence
shutprn()
dbcloseall()
return

*EOF
