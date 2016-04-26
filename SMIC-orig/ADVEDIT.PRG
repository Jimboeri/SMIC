*******************************************************************************
* ADVERT EDIT PROGRAM
* Author - Jim West
* 04/10/87

local cSrc_cd, dSrc_dt, cLd_gen, cDescr, nCost
memvar getlist

if !net_use('adverts', .f.,, 'advmedia')
  return
endif

cSrc_cd := 'XXX'
while !empty(cSrc_cd)
  simhead(memvar->pscr_title)
  @3,1 SAY space(24) + 'ADVERT EDIT SCREEN '
  cSrc_cd = space(3)
  dSrc_dt = ctod('  /  /  ')
  @5,1 say 'Source code : ' get cSrc_cd picture '!!!'
  @5,40 say 'Source Date:  ' get dSrc_dt picture '@D'
  @10,5 say 'Enter source code and date or hit enter to return to menu'
  read
  if !empty(cSrc_cd)
    if !dbseek(cSrc_cd + dtos(dSrc_dt))
      @23,10 say 'ADVERT DOES NOT EXIST'
      inkey(10)
    else
      if !rlock()
        @23,10 say 'Advert in use - Please try later'
        inkey(10)
      else
        @6,1 clear
        @5,16 say cSrc_cd
        @5,55 say dSrc_dt
        cLd_gen = Adverts->ld_gen
        cDescr = Adverts->descriptn
        nCost := Adverts->cost
        @10,1 say 'Lead generator : ' get cLd_gen picture '!'
        @10,40 say 'Cost : ' get nCost picture '@B'
        @15,1 say 'Description : ' get cDescr picture '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
        *
        read
        Adverts->cost := nCost
        Adverts->ld_gen := cLd_gen
        Adverts->descriptn := cDescr
        dbunlock()
      endif
    endif
  endif
enddo
et_close('Adverts')
return
* eof
