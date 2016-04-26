*******************************************************************************
* PROGRAM  'MEDRDIG' - for reader digest
* AUTHOR J. WEST
* 7/12/87

local nCnt, nNtx1, nNtx2, cSrc_cd, dSrc_dt, cAddress, cHead, nPostal
local nLead_cost, nSale_cost
memvar aStat1, aStat2, aStat3, nBank_tot, nRev_tot, getlist, lStd_fnd
memvar lNames, cTitle, dSold1, dSold2

private aStat1[8,9], aStat2[11,3], aStat3[11,3], nBank_tot, nRev_tot
nBank_tot := nRev_tot := 0

begin sequence
  
  select 1
  if !net_use('student', .f.,, 'stdarc')
    break
  endif
  
  select 4
  if !net_use('account', .f.,, 'acccode')
    break
  endif
  
  select 3
  if !net_use('adverts', .f.,, 'advmedia')
    break
  endif
  
  select 2
  if !net_use('newleads', .f.,, 'media')
    break
  endif
  
  simhead(memvar->pscr_title)
  @3,20 SAY 'ADVERT ANALYSIS PROGRAM'
  
  for nNtx1 = 1 to 8
    for nNtx2 = 1 to 9
      aStat1[nNtx1, nNtx2] = 0
    next
  next
  
  * MEANING OF ARRAY INDICES
  *  First index  Second index
  *  1 Total            1 Johannesburg
  *  2 Charged          2 Pretoria
  *  3 Good             3 Free state
  *  4 Distant          4 Northern Tvl
  *  5 Students         5 Cape Town
  *  6 Black            6 Natal
  *  7 Unallocated      7 Eastern Cape
  *  8 Sold             8 Other
  *                     9 Total
  
  for nNtx1 = 1 to 11
    for nNtx2 = 1 to 3
      aStat2[nNtx1, nNtx2] = 0
    next
  next
  
  * MEANING OF ARRAY INDICES
  *  First index  Second index
  *  1 Total      1 Leads
  *  2 Rec within 4 weeks 2 Interviews
  *  3 Rec within 5 - 8 weeks     3 Sales
  *  4 Unallocated
  *  5 Black
  *  6 Distant
  *  7 Free
  *  8 Students
  *  9 Charged
  * 10 Good
  * 11 Poor
  
  for nNtx1 = 1 to 11
    for nNtx2 = 1 to 3
      aStat3[nNtx1, nNtx2] = 0
    next
  next
  
  * MEANING OF ARRAY INDICES
  *  First index  Second index
  *  1 Total      1 Leads
  *  2 Postal     2 Interviews
  *  3 Telephone  3 Sales
  *  4 Faxed
  *  5 Male
  *  6 Female
  *  7 White
  *  8 Asian
  *  9 Black
  * 10 Worker
  * 11 Self employed
  
  cSrc_cd = '   '
  dSrc_dt = ctod('  /  /  ')
  @6,0 say 'Enter source code for report ' get cSrc_cd picture '!!!'
  @8,0 say 'Enter source date for report   ' get dSrc_dt picture '@d'
  read
  
  select Adverts
  if !dbseek(cSrc_cd + dtos(dSrc_dt))
    disp_msg(20,, 'ERROR - Advert does not exist on Advert database')
    break
  else
    select newleads
    lNames = .F.
    if make_sure(9,,'Do you want a list of all the names (Y/N)? ')
      lNames = .T.
    endif
    
    @11,0 say 'analysis of '+ cSrc_cd + ' ' + dtoc(dSrc_dt)
    if !make_sure(15,20)
      break
    endif
    @3,0 clear
    @10,5 say 'PRINTING ADVERT ANALYSIS FOR ' + cSrc_cd + ' ' + DTOC(dSrc_dt)
    if openprn()
      break
    endif
    memvar->lPr_esc := .t.
    nCnt = 0
    while nCnt < 8
      nCnt++
      @15,5 SAY 'Pass = ' + LTRIM(str(nCnt))
      cTitle = 'ADVERT ANALYSIS FOR ' + cSrc_cd + ' ' + dtoc(dSrc_dt)
      if dbseek(cSrc_cd + dtos(dSrc_dt))
        cHead = 'N'
        while cSrc_cd = newleads->source_cd .and.;
              dSrc_dt = newleads->source_dt .and. !eof()
          select Student
          if dbseek(newleads->archiv)
            dSold1 = student->sold_crs_1
            dSold2 = student->sold_crs_2
            lStd_fnd = .T.
          else
            dSold1 = ctod('  /  /  ')
            dSold2 = ctod('  /  /  ')
            lStd_fnd = .f.
          endif
          select newleads
          nPostal = val(substr(newleads->p_code,1,4))
          do case
            case nCnt = 1
              pstat1()    // STATISTICS GATHERED ON FIRST PASS
              if cHead = 'N'
                cTitle = 'ZONE 1 ' + cTitle
                cHead = 'Y'
              endif
              if (nPostal > 0 .and. nPostal < 200)
                pstat2(nCnt)
              endif
            case nCnt = 2
              IF cHead = 'N'
                cTitle = 'ZONE 2 ' + cTitle
                cHead = 'Y'
              endif
              if (nPostal > 1399 .and. nPostal < 1800)
                pstat2(nCnt)
              endif
            case nCnt = 3
              IF cHead = 'N'
                cTitle = 'ZONE 3 ' + cTitle
                cHead = 'Y'
              ENDIF
              IF (nPostal > 1999 .and. nPostal < 2400)
                pstat2(nCnt)
              endif
            case nCnt = 4
              IF cHead = 'N'
                cTitle = 'ZONE 4 ' + cTitle
                cHead = 'Y'
              endif
              IF (nPostal > 3999 .and. nPostal < 4500)
                pstat2(nCnt)
              endif
            case nCnt = 5
              IF cHead = 'N'
                cTitle = 'ZONE 5 ' + cTitle
                cHead = 'Y'
              endif
              IF (nPostal > 7099 .and. nPostal < 8100)
                pstat2(nCnt)
              endif
            case nCnt = 6
              IF cHead = 'N'
                cTitle = 'ZONE 6 ' + cTitle
                cHead = 'Y'
              endif
              IF (nPostal > 5999 .and. nPostal < 6300)
                pstat2(nCnt)
              endif
            case nCnt = 7
              IF cHead = 'N'
                cTitle = 'ZONE 7 ' + cTitle
                cHead = 'Y'
              endif
              IF (nPostal > 5199 .and. nPostal < 5300)
                pstat2(nCnt)
              endif
            case nCnt = 8
              IF cHead = 'N'
                cTitle = 'ZONE 8 ' + cTitle
                cHead = 'Y'
              endif
              IF (nPostal > 9299 .and. nPostal < 9400)
                pstat2(nCnt)
              endif
          endcase
          select newleads
          dbskip()
        enddo (source_cd = srce_cd)
        memvar->pline = 90
      endif
    enddo (nCnt < 5)
    for nNtx1 = 1 to 8
      aStat1[nNtx1, 9] = 0
      for nNtx2 = 1 TO 8
        aStat1[nNtx1, 9] += aStat1[nNtx1, nNtx2]
      next
    next
    
    cTitle = 'TOTALS - ADVERT ANALYSIS FOR ' + cSrc_cd + ' ' + dtoc(dSrc_dt)
    if memvar->pline > 55
      prntitle(cTitle,'Y')
    endif
    ? '    ' + cSrc_cd + ' ' + DTOC(dSrc_dt) + '   ' + Adverts->DESCRIPTN
    ?? memvar->pr_compress
    ? '                        Total    Charged       Good    Distant   Std/Free      Black      Unall       Sold        Good %       GL/Sld'
    ? 'ZONE 1            '
    pr_line1(1)
    ? 'ZONE 2            '
    pr_line1(2)
    ? 'ZONE 3            '
    pr_line1(3)
    ? 'ZONE 4            '
    pr_line1(4)
    ? 'ZONE 5            '
    pr_line1(5)
    ? 'ZONE 6            '
    pr_line1(6)
    ? 'ZONE 7            '
    pr_line1(7)
    ? 'ZONE 8            '
    pr_line1(8)
    ? 'Total             '
    pr_line1(9)
    ? ' '
    ? ' '
    ? '                 Total    4 Weeks  5-8 Weeks    Unalloc      Black       Dist       Free       Stud    Charged       Good       Poor'
    ? 'Leads      '
    pr_line2(1)
    ? 'Intviews   '
    pr_line2(2)
    ? 'Sales      '
    pr_line2(3)
    ? ' '
    ? ' '
    ? 'OVERALL          Total       Post      Phone        Fax       Male     Female      White      Asian      Black     Salary   Self_emp'
    ? 'Leads      '
    pr_line3(1)
    ? 'Intview    '
    pr_line3(2)
    ? 'Sales      '
    pr_line3(3)
    ? ' '
    ? ' '
    select Adverts
    dbseek(cSrc_cd + dtos(dSrc_dt))
    if aStat1[3,9] != 0
      nLead_cost = adverts->cost / aStat1[3,9]
    else
      nLead_cost = 99999999
    endif
    ? '    Cost of advert = ' , adverts->cost ,;
        '    Cost per Good Lead = ', nLead_cost
    if aStat1[8, 9] != 0
      nSale_cost = adverts->cost / aStat1[8, 9]
      ?? '    Cost per Sale = ' , nSale_cost
    endif
    ? ' '
    ? 'Total banking from sales = ' + str(nBank_tot,12,2)
    if aStat1[8, 9] != 0
      ?? '  Banking per Sale = ' + str((nBank_tot / aStat1[8, 9]),10,2)
    endif
    if nBank_tot > 0
      ?? '  Percentage cost of advert = ' + str((Adverts->cost/nBank_tot*100),6,2) + '%'
    endif
    ? ' '
    ? 'Total banking written from sales = ' + str(nRev_tot,12,2)
    if aStat1[8, 9] != 0
      ?? '  Average selling price = ' + str((nRev_tot / aStat1[8, 9]),10,2)
    endif
  endif
end sequence
shutprn()
dbcloseall()
return

*EOF

*******************************************************************************
static procedure pstat1

local cCd1, cCd2, cSp1, cARC, cSTD

stat_add(memvar->aStat2[1])
stat_add(memvar->aStat3[1])

do case
  case newleads->date_rcvd < newleads->source_dt + 30
    stat_add(memvar->aStat2[2])
  case newleads->date_rcvd < newleads->source_dt + 60
    stat_add(memvar->aStat2[3])
endcase
cCd1 = substr(newleads->misc_cd,1,1)
cCd2 = substr(newleads->misc_cd,2,1)
cSp1 = substr(newleads->salespsn,2,1)
do case
  case cSp1 = ' '
    stat_add(memvar->aStat2[4])
  case cCd1 = 'B'
    stat_add(memvar->aStat2[5])
  case cCd1 = 'D'
    stat_add(memvar->aStat2[6])
  case cCd1 = 'F'
    stat_add(memvar->aStat2[7])
  case cCd1 = 'S'
    stat_add(memvar->aStat2[8])
  case cCd1 = 'Y'
    stat_add(memvar->aStat2[9])
endcase
do case
  case cCd2 = 'G'
    stat_add(memvar->aStat2[10])
  case cCd2 = 'P'
    stat_add(memvar->aStat2[11])
endcase

do case
  case newleads->lead_gen_c = 'P'
    stat_add(memvar->aStat3[2])
  case newleads->lead_gen_c = 'T'
    stat_add(memvar->aStat3[3])
  case newleads->lead_gen_c = 'F'
    stat_add(memvar->aStat3[4])
endcase
do case
  case newleads->sex = 'M'
    stat_add(memvar->aStat3[5])
  case newleads->sex = 'F'
    stat_add(memvar->aStat3[6])
endcase
do case
  case newleads->race = 'W'
    stat_add(memvar->aStat3[7])
  case newleads->race = 'A'
    stat_add(memvar->aStat3[8])
  case newleads->race = 'B'
    stat_add(memvar->aStat3[9])
endcase
do case
  case newleads->self_emp != 'Y'
    stat_add(memvar->aStat3[10])
  case newleads->self_emp = 'Y'
    stat_add(memvar->aStat3[11])
endcase
if memvar->lStd_fnd
  select Student
  if dbseek(newleads->archiv)
    select Account
    dbseek(Student->std_code + 'T')
    while account->std_code = Student->std_code .and. account->type = 'T';
          .and. !eof()
      if account->cr_dr = 'C' .and. account->comment != 'C'
        memvar->nBank_tot += account->amount
      endif
      if account->cr_dr = 'D'
        memvar->nRev_tot += account->amount
      endif
      dbskip()
    enddo
  endif
endif
select newleads
return
* EOP

*******************************************************************************
static procedure pstat2 ( nNtx)
LOCAL cAddress, cCd1, cCd2, cSp2
if memvar->lNames
  if memvar->pline > 58
    prntitle(memvar->cTitle,'Y')
    memvar->pline = 6
    ? '                                                                      ' +;
        '                 SOLD     SOLD             FOLLOW'
    ? 'SP ALLOC-DT ARCHIV            NAME                           ADDRESS  ' +;
        '                 MOD 1    MOD 2  CHGE SRCE  DATE    INT'
    ? ' '
  endif
  if newleads->address3 = space(25)
    cAddress = newleads->address2
  else
    cAddress = newleads->address3
  endif
  ? newleads->salespsn, newleads->alloc_dt, newleads->archiv, newleads->title,;
      newleads->initls, newleads->surname, cAddress, memvar->dSold1,;
      memvar->dSold2, newleads->misc_cd, newleads->source_cd,;
      newleads->follow_dt,newleads->intview
  memvar->pline++
endif

memvar->aStat1[1, nNtx]++
cCd1 = substr(newleads->misc_cd,1,1)
cCd2 = substr(newleads->misc_cd,2,1)
cSp2 = substr(newleads->salespsn,2,1)
do case
  case cCd1 = 'Y'
    memvar->aStat1[2, nNtx]++
  case cCd1 = 'D'
    memvar->aStat1[4, nNtx]++
  case cCd1 = 'S' .OR. cCd1 = 'F'
    memvar->aStat1[5, nNtx]++
  case cCd1 = 'B'
    memvar->aStat1[6, nNtx]++
endcase
if cCd2 = 'G'
  memvar->aStat1[3, nNtx]++
endif
if cSp2 = ' '
  memvar->aStat1[7, nNtx]++
endif
if memvar->lStd_fnd
  memvar->aStat1[8, nNtx]++
endif
return

* EOP

*******************************************************************************
static procedure stat_add (aArray)
aArray[1]++
if newleads->intview = 'Y'
  aArray[2]++
endif
if memvar->lStd_fnd
  aArray[3]++
endif
return

* EOP

*******************************************************************************
static procedure pr_line1( nNtx)
local nCnt
for nCnt = 1 to 8
  ?? str(memvar->aStat1[nCnt, nNtx],11,0)
next
percent(memvar->aStat1[1, nNtx], memvar->aStat1[3, nNtx])
ratios(memvar->aStat1[2, nNtx], memvar->aStat1[8, nNtx])
return
* EOP

*******************************************************************************
static procedure pr_line2 (nNtx)
local nCnt
for nCnt = 1 to 11
  ?? str(memvar->aStat2[nCnt, nNtx],11,0)
next
return
* EOP

*******************************************************************************
static procedure pr_line3 (nNtx)
local nCnt
for nCnt = 1 to 11
  ?? str(memvar->aStat3[nCnt, nNtx],11,0)
next
return
* EOP

