*******************************************************************************
* PROGRAM 'ADVADD'
* AUTHOR JIM WEST (E.T.)
* 1/10/87

local cSrc_cd, dSrc_dt, cLd_gen, cDescr, nCost
memvar getlist

if !net_use('adverts', .f.,, 'advmedia')
  return
endif

cSrc_cd := 'QQQ'
while !empty(cSrc_cd)
  simhead(memvar->pscr_title)
  @3,1 say center('Initial data capture of a new advert')
  cSrc_cd = space(3)
  dSrc_dt := ctod('  /  /  ')
  @5,1 say 'Source code : ' get cSrc_cd picture '!!!'
  @5,40 say 'Source Date:  ' get dSrc_dt picture '@d' when !empty(cSrc_cd);
      valid !empty(dSrc_dt)
  @10,5 say 'Enter source code and date or hit enter to return to menu'
  read
  if !empty(cSrc_cd)
    if dbseek(cSrc_cd + dtos(dSrc_dt))
      @23,10 say 'ADVERT ALREADY EXISTS'
      inkey(10)
    else
      @6,1 clear
      @5,16 say cSrc_cd
      @5,55 say dSrc_dt
      cLd_gen := ' '
      cDescr := space(50)
      nCost := 0
      @10,1 say 'Lead generator : ' GET cLd_gen PICTURE '!'
      @10,40 say 'Cost : ' GET nCost PICTURE '@B'
      @15,1 say 'Description : ' GET cDescr PICTURE '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
      *
      read
      dbappend()
      reclock('Adverts')
      Adverts->source_cd := cSrc_cd
      Adverts->source_dt := dSrc_dt
      Adverts->cost      := nCost
      Adverts->ld_gen    := cLd_gen
      Adverts->descriptn := cDescr
      dbunlock()
    endif (rec not found)
  endif (source_cd != space)
enddo (source_cd != space)
close databases
return
* eof
