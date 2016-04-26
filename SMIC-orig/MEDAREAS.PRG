*******************************************************************************
* PROGRAM 'MEDAREAS' PRINTS MEDIA AREA SUMMARY
* AUTHOR E.T.
* 26/11/87

local dStart, dEnd, cLead_gen, nInx, cTitle, nPost_num
memvar lStd_fnd, getlist
memvar aStot, aSch, aSgood, aSdist, aSstud, aSbl, aSunall, aSsld
memvar aTtot, aTch, aTgood, aTdist, aTstud, aTbl, aTunall, aTsld

#define MAX_NO  9

private aStot[MAX_NO], aSch[MAX_NO], aSgood[MAX_NO], aSdist[MAX_NO]
private aSstud[MAX_NO], aSbl[MAX_NO], aSunall[MAX_NO], aSsld[MAX_NO]

private aTtot[MAX_NO], aTch[MAX_NO], aTgood[MAX_NO], aTdist[MAX_NO]
private aTstud[MAX_NO], aTbl[MAX_NO], aTunall[MAX_NO], aTsld[MAX_NO]

begin sequence
  select 1
  if !net_use('student', .f.,, 'stdarc')
    break
  endif
  
  select 2
  if !net_use('newleads', .f.,, 'media')
    break
  endif
  
  select 3
  if !net_use('adverts', .f.,, 'advmedia')
    break
  endif
  
  simhead(memvar->pscr_title)
  @7,20 say 'MEDIA AREA ANALYSIS PROGRAM'
  
  dStart = ctod('  /  /  ')
  dEnd = date()
  cLead_gen = ' '
  @10,0 say 'Enter start sales date for report ' get dStart picture '@d'
  @11,0 say 'Enter end sales date for report   ' get dEnd picture '@d'
  @14,0 say 'Or space for all adverts'
  @13,0 say 'Enter lead generated code ' get cLead_gen picture '!'
  read
  
  if !make_sure(10)
    break
  endif
  
  afill(aStot, 0)
  afill(aSch, 0)
  afill(aSgood, 0)
  afill(aSdist, 0)
  afill(aSstud, 0)
  afill(aSbl, 0)
  afill(aSunall, 0)
  afill(aSsld, 0)
  
  afill(aTtot, 0)
  afill(aTch, 0)
  afill(aTgood, 0)
  afill(aTdist, 0)
  afill(aTstud, 0)
  afill(aTbl, 0)
  afill(aTunall, 0)
  afill(aTsld, 0)
  
  if openprn() .or. !make_sure(10,,;
        'PRINTING THE MEDIA AREA SUMMARY - THIS WILL TAKE SOME TIME',;
        'CONTINUE (Y/N) ?')
    break
  endif
  memvar->lPr_esc = .t.
  @4,0 clear
  @7,5 say 'PRINTING THE MEDIA AREA SUMMARY - THIS WILL TAKE SOME TIME'
  cTitle = 'MEDIA AREA SUMMARY '
  if dStart != ctod('  /  /  ')
    cTitle += 'FROM ' + dtoc(dStart)
  endif
  cTitle += ' TO ' + dtoc(dEnd)
  if cLead_gen != ' '
    cTitle += '(Lead generator ' + cLead_gen + ')'
  else
    cTitle += '(All Lead generators)'
  endif
  select adverts
  dbgotop()
  while !eof()
    @12,5 say Adverts->source_cd
    if Adverts->source_dt >= dStart .and.;
          Adverts->source_dt <= dEnd .and. (cLead_gen = ' ' .or.;
          cLead_gen = Adverts->ld_gen)
      select Newleads
      dbseek(Adverts->source_cd + dtos(Adverts->source_dt))
      while newleads->source_cd = Adverts->source_cd .and.;
            adverts->source_dt = newleads->source_dt .and. !eof()
        select Student
        if dbseek(newleads->archiv)
          lStd_fnd = .t.
        else
          lStd_fnd = .f.
        endif
        select newleads
        nPost_num = val(substr(newleads->p_code,1,4))
        do case
          case (nPost_num > 1400 .and. nPost_num < 2800)
            med_1_count(1)
          case (nPost_num > 399 .and. nPost_num < 1000)
            med_1_count(2)
          case (nPost_num > 2899 .and. nPost_num < 4900)
            med_1_count(3)
          case (nPost_num > 6699 .and. nPost_num < 8300)
            med_1_count(4)
          case (nPost_num > 4899 .and. nPost_num < 6700)
            med_1_count(5)
          case (nPost_num > 9299 .and. nPost_num < 10000);
                .OR. (nPost_num > 8299 .and. nPost_num < 9000)
            med_1_count(6)
          case (nPost_num > 0 .and. nPost_num < 400);
                .OR. (nPost_num > 999 .and. nPost_num < 1400);
                .OR. (nPost_num > 2799 .and. nPost_num < 2900)
            med_1_count(7)
          otherwise
            med_1_count(8)
        endcase
        select newleads
        dbskip()
      enddo (source_cd = Adverts->source_cd)
      for nInx = 1 to MAX_NO - 1
        aStot[MAX_NO]   += aStot[nInx]
        aSch[MAX_NO]    += aSch[nInx]
        aSgood[MAX_NO]  += aSgood[nInx]
        aSdist[MAX_NO]  += aSdist[nInx]
        aSstud[MAX_NO]  += aSstud[nInx]
        aSbl[MAX_NO]    += aSbl[nInx]
        aSunall[MAX_NO] += aSunall[nInx]
        aSsld[MAX_NO]   += aSsld[nInx]
      next
      if aStot[MAX_NO] > 0
        if memvar->pline > 55
          prntitle(cTitle,'Y')
        endif
        ? ' ' + Adverts->source_cd + ' ' + DTOC(adverts->source_dt) + ' - ';
            + adverts->descriptn
        ?? memvar->pr_compress
        ? '                     Total    Charged       Good      Unall      Black   Std/Free    Distant       Sold        Good %      GL/Sld'
        for nInx = 1 to MAX_NO
          med_2_print(nInx, 'aS') // sub totals
          aTtot[nInx] += aStot[nInx]
          aTch[nInx] += aSch[nInx]
          aTgood[nInx] += aSgood[nInx]
          aTdist[nInx] += aSdist[nInx]
          aTstud[nInx] += aSstud[nInx]
          aTbl[nInx] += aSbl[nInx]
          aTunall[nInx] += aSunall[nInx]
          aTsld[nInx] += aSsld[nInx]
        next
        ? ' '
        memvar->pLine += 13
        
        afill(aStot, 0)
        afill(aSch, 0)
        afill(aSgood, 0)
        afill(aSdist, 0)
        afill(aSstud, 0)
        afill(aSbl, 0)
        afill(aSunall, 0)
        afill(aSsld, 0)
      endif (t_tot > 0
    endif
    select Adverts
    dbskip()
  enddo (eof)
  aTtot[MAX_NO] = 0
  aTch[MAX_NO] = 0
  aTgood[MAX_NO] = 0
  aTdist[MAX_NO] = 0
  aTstud[MAX_NO] = 0
  aTbl[MAX_NO] = 0
  aTunall[MAX_NO] = 0
  aTsld[MAX_NO] = 0
  for nInx = 1 TO MAX_NO-1
    aTtot[MAX_NO]   += aTtot[nInx]
    aTch[MAX_NO]    += aTch[nInx]
    aTgood[MAX_NO]  += aTgood[nInx]
    aTdist[MAX_NO]  += aTdist[nInx]
    aTstud[MAX_NO]  += aTstud[nInx]
    aTbl[MAX_NO]    += aTbl[nInx]
    aTunall[MAX_NO] += aTunall[nInx]
    aTsld[MAX_NO]   += aTsld[nInx]
  next
  prntitle(cTitle,'Y')
  ? '       TOTALS'
  ? '                     Total    Charged       Good      Unall      Black   Std/Free    Distant       Sold        Good %      GL/Sld'
  for nInx = 1 to MAX_NO
    MED_2_PRINT(nInx, 'aT')
  next
  
end sequence
shutprn()
dbcloseall()
return

*eof

*******************************************************************************
* PROCEDURE MED_1_COUNT
*           TOTAL ARRAY FIELDS ACCORDING TO AREA
*******************************************************************************
static procedure med_1_count ( nNtx )
local cMcd1, cMcd2, cSp2
cMcd1 = substr(newleads->misc_cd,1,1)
cMcd2 = substr(newleads->misc_cd,2,1)
cSp2 = substr(newleads->salespsn,2,1)
memvar->aStot[nNtx]++
do case
  case cMcd1 = 'Y'
    memvar->aSch[nNtx]++
  case cMcd1 = 'D'
    memvar->aSdist[nNtx]++
  case cMcd1 = 'S' .or. cMcd1 = 'F'
    memvar->aSstud[nNtx]++
  case cMcd1 = 'B'
    memvar->aSbl[nNtx]++
endcase
if cMcd2 = 'G'
  memvar->aSgood[nNtx]++
endif
if cSp2 = ' '
  memvar->aSunall[nNtx]++
endif
if memvar->lStd_fnd
  memvar->aSsld[nNtx]++
endif
return
*eof

*******************************************************************************
* PROCEDURE MED_2_PRINT
*           PRINTS A LINE OF TOTALS
*******************************************************************************
static procedure med_2_print (nNtx, cType)
local nTot, nGood, nSold, cField
do case
  case nNtx = 1
    ? 'Johannesburg   '
  case nNtx = 2
    ? 'Northern TVL   '
  case nNtx = 3
    ? 'Natal          '
  case nNtx = 4
    ? 'Cape Town      '
  case nNtx = 5
    ? 'Eastern Cape   '
  case nNtx = 6
    ? 'O F S & N. Cape'
  case nNtx = 7
    ? 'Pretoria       '
  case nNtx = 8
    ? 'Other          '
  case nNtx = 9
    ? ' TOTAL         '
  otherwise
    ? '               '
endcase
cField = cType + 'TOT[' + ltrim(str(nNtx)) + ']'
?? ' ' + str(&cField,10,0)
nTot = &cField
cField = cType + 'CH[' + ltrim(str(nNtx)) + ']'
?? ' ' + str(&cField,10,0)
cField = cType + 'GOOD[' + ltrim(str(nNtx)) + ']'
?? ' ' + str(&cField,10,0)
nGood = &cField
cField = cType + 'UNALL[' + ltrim(str(nNtx)) + ']'
?? ' ' + str(&cField,10,0)
cField = cType + 'BL[' + ltrim(str(nNtx)) + ']'
?? ' ' + str(&cField,10,0)
cField = cType + 'STUD[' + ltrim(str(nNtx)) + ']'
?? ' ' + str(&cField,10,0)
cField = cType + 'DIST[' + ltrim(str(nNtx)) + ']'
?? ' ' + str(&cField,10,0)
cField = cType + 'SLD[' + ltrim(str(nNtx)) + ']'
?? ' ' + str(&cField,10,0)
nSold = &cField
percent(nTot, nGood)
ratios(nGood, nSold)
return
*eof
