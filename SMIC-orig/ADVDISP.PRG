*******************************************************************************
* Program 'ADVDISP'
* JIM WEST

local cSrc_cd, cTemp
memvar getlist

if !net_use('adverts', .f.,, 'advmedia')
  return
endif

simhead(memvar->pscr_title)
cSrc_cd = space(3)
@3,0 clear
@4,0 say 'OR RETURN TO EXIT'
@3,0 say 'ENTER SOURCE CODE TO SEARCH FOR ' get cSrc_cd picture '!!!'
read
@3,33 say cSrc_cd
while !empty(cSrc_cd)
  cSrc_cd = trim(cSrc_cd)
  if !dbseek(cSrc_cd)
    disp_msg(14,, 'ADVERT DOES NOT EXIST  -   ' + cSrc_cd)
    inkey(10)
  else
    while Adverts->source_cd = cSrc_cd
      @5,0 clear
      list next 12 Adverts->source_cd, Adverts->source_dt, Adverts->ld_gen,;
      trim(Adverts->descriptn) for Adverts->source_cd = cSrc_cd
      @22,0 clear
      if Adverts->source_cd = cSrc_cd
        cTemp = ' '
        accept 'HIT "ENTER" TO CONTINUE LIST, OR 9 TO EXIT ' TO cTemp
        if cTemp = '9'
          cSrc_cd = '@#@'
        endif
      else
        ? '  *****  END OF LIST  ******'
        wait
      endif (SOURCE_CD = cSrc_cd)
    enddo (SOURCE_CD = cSrc_cd)
  endif (eof())
  cSrc_cd := space(3)
  @3,0 clear
  @4,0 say 'OR RETURN TO EXIT'
  @3,0 say 'ENTER SOURCE CODE TO SEARCH FOR ' get cSrc_cd picture '!!!'
  read
  @3,33 say cSrc_cd
enddo (cSrc_cd != '')
et_close('Adverts')
return
* eof
