*******************************************************************************
* PROGRAM  'LDOLD'
* AUTHOR J. WEST
* 7/12/87

local cSrc_cd, dSrc_dt, lSold, nCnt
memvar getlist, cField

simhead(memvar->pscr_title)

begin sequence
  select 1
  if !net_use('newleads', .f.,, 'media', 'rleads', 'archives')
    break
  endif
  
  select 2
  if !net_use('adverts', .f.,, 'advmedia')
    break
  endif
  
  select 5
  if !net_use('account', .f.,, 'acccode')
    break
  endif
  
  select 3
  if !net_use('student', .f.,, 'stdarc')
    break
  endif
  
  select 4
  if !net_use('oldleads', .f.,, 'oldarc')
    break
  endif
  
  @3,0 say center('ADVERT ANALYSIS PROGRAM')
  cSrc_cd = '   '
  dSrc_dt = ctod('  /  /  ')
  @6,0 say 'Enter source code for report ' get cSrc_cd picture '!!!'
  @8,0 say 'Enter source date for report   ' get dSrc_dt picture '@d'
  READ
  
  select Adverts
  if !dbseek(cSrc_cd + dtos(dSrc_dt)) .or. Adverts->ld_gen = 'K'
    disp_msg(20, 'Advert does not exist or leads already moved')
    inkey(10)
    break
  endif
  
  if !wmake_sure(12,,'Are you sure you want to move the leads to the old leads file (Y/N) ?')
    break
  endif
  @3,0 clear
  @10,5 say 'PRINTING ADVERT ANALYSIS FOR ' + cSrc_cd + ' ' + DTOC(dSrc_dt)
  prn_medanal (cSrc_cd, dSrc_dt, .t.)
  
  select newleads
  dbseek(cSrc_cd + dtos(dSrc_dt))
  while newleads->source_cd = cSrc_cd .and.;
        newleads->source_dt = dSrc_dt .and. !eof()
    lSold = .F.
    select Student
    if dbseek(Newleads->archiv)
      lSold = .T.
    endif
    if Newleads->killed != 'Y'
      select oldleads
      dbappend()
      for nCnt = 1 to fcount()
        cField = fieldname(nCnt)
        select newleads
        if fieldpos(cField) != 0
          select oldleads
          cField = 'NEWLEADS->' + cField
          fieldput(nCnt, &cField)
        endif
        select oldleads
      next
    endif
    select newleads
    if !lSold
      reclock('Leads')
      dbdelete()
      dbunlock()
    endif
    select newleads
    dbskip()
  enddo
end sequence
shutprn()
select oldleads
dbunlock()
dbcloseall()
return

*EOF
