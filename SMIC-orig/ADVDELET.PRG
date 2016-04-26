*******************************************************************************
* Program 'ADVDELET' - ADVERT DELETION PROGRAM
* JIM WEST

local cSrc_cd, dSrc_dt
memvar getlist

select 1
if !net_use('newleads', .f.,, 'media')
  return
endif

select 2
if !net_use('adverts', .f.,, 'advmedia')
  close databases
  return
endif

cSrc_cd = 'XXX'
while !empty(cSrc_cd)
  
  * Display title at the top of the screen and set up screen
  simhead(memvar->pscr_title)
  @3,20 say  'Deletion of an advert'
  cSrc_cd = space(3)
  dSrc_dt = ctod('  /  /  ')
  @5,1 say 'Source code : ' get cSrc_cd picture '!!!'
  @5,40 say 'Source Date:  ' get dSrc_dt picture '@D'
  @10,5 say 'Enter source code and date or hit enter to return to menu'
  read
  if !empty(cSrc_cd)
    if !dbseek(cSrc_cd + dtos(dSrc_dt))
      disp_msg(20,,'ADVERT DOES NOT EXIST')
      inkey(10)
    else
      select newleads
      if dbseek(cSrc_cd + dtos(dSrc_dt))
        disp_msg(20,,'ADVERT STILL EXISTS ON LEAD FILE',;
            'CANNOT DELETE')
        inkey(5)
        select Adverts
      else
        select Adverts
        reclock('Adverts')
        @6,1 clear
        @5,16 say cSrc_cd
        @5,55 say dSrc_dt
        @8,1 say 'Lead generator : ' + Adverts->ld_gen
        @8,40 say 'Cost : ' + str(Adverts->cost)
        @10,1 say 'Description : ' + Adverts-> descriptn
        *
        if make_sure(16,,'DELETE ADVERT ?')
          select Adverts
          dbdelete()
          disp_msg(20,,'RECORD IS NOW MARKED FOR DELETION')
          inkey(10)
        endif
        dbunlock()
      endif
    endif
  endif
enddo
close databases
return
* eof
