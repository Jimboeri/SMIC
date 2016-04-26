*******************************************************************************
* PROGRAM 'MEDSALES'
* JIM WEST
* CIRCA 1990

local cSrc_cd, dSrc_dt, cTitle
memvar getlist
begin sequence
  
  select 1
  if !net_use('student', .f.,, 'stdarc')
    break
  endif
  
  select 2
  if !net_use('newleads', .f.,, 'media')
    break
  endif
  
  simhead(memvar->pscr_title)
  @5,5 say '          ****** PRINT LISTS OF SALES PER ADVERT ******'
  
  cSrc_cd = '   '
  dSrc_dt = ctod('  /  /  ')
  @6,0 SAY 'Enter source code for report ' get cSrc_cd picture '!!!'
  @8,0 SAY 'Enter source date for report   ' get dSrc_dt picture '@d'
  read
  
  @9,0 say 'ANALYSIS OF '+ cSrc_cd + ' ' + dtoc(dSrc_dt)
  
  if make_sure(10)
    select newleads
    dbseek(cSrc_cd + dtos(dSrc_dt))
    @18,10 SAY 'Printing sales report for ' + cSrc_cd + ' ' + dtoc(dSrc_dt)
    if openprn()
      break
    endif
    cTitle = 'LIST OF SALES FOR  ' + cSrc_cd + '   ' + dtoc(dSrc_dt)
    while cSrc_cd = newleads->source_cd .and. dSrc_dt = newleads->source_dt;
          .and. !eof()
      select Student
      if dbseek(newleads->archiv)
        if memvar->pline > 55
          prntitle(cTitle, 'N')
        endif
        ? trim(Student->title) + ' ' + substr(Student->name,1,1) + ' ';
            + Student->surname
        ? Student->address1 + '         Phone (H) ' + Student->phone_h
        ? Student->address2 + '         Phone (W) ' + Student->phone_w
        ? trim(Student->address3) + ' ' + Student->p_code
        ? ' '
        memvar->pline += 5
      endif
      select Newleads
      dbskip()
    enddo (lead for the advert)
  endif (yesno = y)
end sequence
shutprn()
et_close('student')
et_close('newleads')
RETURN

* EOF
