*******************************************************************************
*
*  ADVCHANG - CHANGES ALL SOURCE CODE AND DATES TO A NEW ADVERT
*
*  OBTAINS BOTH OLD AND NEW ADVERTS TO VALIDATE
*  PERFORMS A SERIAL READ THROUGH THE LEADS BASES WITH MEDIA.NTX AS
*  A SECONDARY INDEX
*
*******************************************************************************

local cSrc_cd1, dSrc_dt1, cSrc_cd2, dSrc_dt2
memvar getlist

select 1
if !net_use('adverts', .f.,, 'advmedia')
  return
endif

select 2
if !net_use('newleads', .f.,, 'media')
  close databases
  return
endif

simhead(memvar->pscr_title)
cSrc_cd1 = space(3)
dSrc_dt1 = ctod('  /  /  ')
cSrc_cd2 = space(3)
dSrc_dt2 = ctod('  /  /  ')

@5,10 SAY 'Enter source code and date to be changed'
@7,10 SAY 'Source code ' get cSrc_cd1 picture '!!!'
@8,10 SAY 'Source date ' get dSrc_dt1 picture '@d'
@12,10 SAY 'Enter source code and date to be changed to:'
@14,10 SAY 'Source code ' get cSrc_cd2 picture '!!!'
@15,10 SAY 'Source date ' get dSrc_dt2 picture '@d'
read

select Adverts
if !dbseek(cSrc_cd1 + dtos(dSrc_dt1))
  @20,10 say 'Advert - ' + cSrc_cd1 + ' ' + DTOC(dSrc_dt1) + ' was not found - Please try again'
  close databases
  inkey(20)
  return
endif

if !dbseek(cSrc_cd2 + dtos(dSrc_dt2))
  @20,10 SAY 'Advert - ' + cSrc_cd2 + ' ' + DTOC(dSrc_dt2) + ' was not found - Please try again'
  close databases
  inkey(20)
  return
endif

select newleads
while dbseek(cSrc_cd1 + dtos(dSrc_dt1))
  @19,35 say newleads->archiv
  reclock('Newleads')
  newleads->source_cd := cSrc_cd2
  newleads->source_dt := dSrc_dt2
  dbunlock()
enddo

select adverts
if !dbseek(cSrc_cd1 + dtos(dSrc_dt1))
  reclock('Adverts')
  dbdelete()
  dbunlock()
endif

close databases
return

* EOF
