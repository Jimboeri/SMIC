*******************************************************************************
* PROGRAM 'MEDSTAT' PRINTS STATS PER ADVERT
*
* PRINTS SALES STATISTICS PER ADVERT, CAN BE RUN AUTOMATICALLY
*
*******************************************************************************

local nCnt1, nCnt2, nAdv_cost, nSale_cst, nLead_cst, cLd_gen, lCont
local dStart, dEnd, cTitle, dSold1, dSold2, cCd1, cCd2
memvar a_Adv, a_Tot, getlist, lStd_fnd

begin sequence
  
  select 1
  if !net_use('adverts', .f.,, 'advmedia')
    break
  endif
  
  select 2
  if !net_use('newleads', .f.,, 'media')
    break
  endif
  
  select 3
  if !net_use('student', .f.,, 'stdarc')
    break
  endif
  
  simhead(memvar->pscr_title)
  @4,20 say 'MEDIA STATISTICS SUMMARY PROGRAM'
  
  * INITIALIZE VARIABLES
  /* NOTE - THE 2 DIM ARRAY HOLDS ALL COUNTERS USING THE FOLLOWING LOGIC
  
  FIRST DIMENSION
  1 = TOTAL
  2 = WITHIN 4 WEEKS
  3 = WITHIN 5 TO 8 WEEKS
  4 = UNALLOCATED
  5 = BLACK
  6 = DISTANT
  7 = FREE
  8 = STUDENTS
  9 = CHARGED
  10 = GOOD
  11 = POOR
  
  SECOND DIMENSION
  1 = LEADS
  2 = INTERVIEWS
  3 = SALES
  */
  
  PRIVATE a_Adv[11][3], a_Tot[11][3]
  for nCnt1 = 1 to 11
    for nCnt2 = 1 to 3
      a_Adv[nCnt1, nCnt2] = 0
      a_Tot[nCnt1, nCnt2] = 0
    next
  next
  
  nAdv_cost := nSale_cst := nLead_cst := 0
  
  cLd_gen = ' '
  @7,0 say 'Or space for all adverts'
  @6,0 say 'Enter lead generated code ' get cLd_gen picture '!'
  read
  
  dStart = ctod('  /  /  ')
  dEnd = date()
  @12,0 say 'Enter start source date for report ' GET dStart PICTURE '@D'
  @14,0 say 'Enter end source date for report   ' GET dEnd PICTURE'@D'
  read
  lCont = make_sure(10)
  
  if !lCont
    break
  endif
  @4,0 clear
  @7,5 say 'PRINTING THE MEDIA SUMMARY - THIS WILL TAKE SOME TIME'
  cTitle = 'MEDIA STATISTICS SUMMARY '
  if !empty(dStart)
    cTitle = cTitle + 'FROM ' + dtoc(dStart)
  endif
  cTitle = cTitle + ' TO ' + dtoc(dEnd) + ' '
  if cLd_gen != ' '
    cTitle = cTitle + '(Lead generator ' + cLd_gen + ')'
  else
    cTitle = cTitle + '(All Lead generators)'
  endif
  openprn()
  memvar->lPr_esc = .t.
  set alternate to medstat.txt
  set alternate on
  select Adverts
  dbgotop()
  while !eof()
    @12,5 say Adverts->source_cd
    @12,20 say Adverts->source_dt
    if cLd_gen = ' ' .or. adverts->ld_gen = cLd_gen
      if (adverts->source_dt >= dStart .and. adverts->source_dt <= dEnd)
        select newleads
        dbseek(adverts->source_cd + dtos(adverts->source_dt))
        while newleads->source_cd = Adverts->source_cd .and.;
              dtoc(Adverts->source_dt) = dtoc(newleads->source_dt) .and. !eof()
          select Student
          if dbseek(newleads->archiv)
            dSold1 = Student->sold_crs_1
            dSold2 = Student->sold_crs_2
            lStd_fnd = .T.
          else
            dSold1 = ctod('  /  /  ')
            dSold2 = ctod('  /  /  ')
            lStd_fnd = .F.
          endif
          select newleads
          medproc1(1)         // TOTAL LEADS
          do case
            case newleads->date_rcvd < newleads->source_dt + 30
              medproc1(2)     // within 4 weeks
            case newleads->date_rcvd < newleads->source_dt + 60
              medproc1(3)     // within 5 - 8 weeks
          endcase
          cCd1 = substr(newleads->misc_cd,1,1)
          do case
            case cCd1 = 'B'
              medproc1(5)     // BLACK
            case cCd1 = 'D'
              medproc1(6)     // DISTANT
            case cCd1 = 'F'
              medproc1(7)     // FREE
            case cCd1 = 'S'
              medproc1(8)     // STUDENT
            case cCd1 = 'Y'
              medproc1(9)     // CHARGE
          endcase
          cCd2 = substr(newleads->misc_cd,2,1)
          do case
            case cCd2 = 'G'
              medproc1(10)     // good
            case cCd2 = 'P'
              medproc1(11)     // poor
          endcase
          if substr(newleads->salespsn,2,1) = ' '
            medproc1(4)     // unallocated
          endif
          dbskip()
        enddo (Adverts->source_dt = source_dt)
        
        select Adverts
        if a_Adv[1, 1] != 0 .OR. Adverts->cost != 0
          if memvar->pline > 55
            prntitle(cTitle,'Y')
          endif
          ? Adverts->source_cd , ' ' , Adverts->source_dt ,;
              '  Total    4 Weeks  5-8 Weeks    Unalloc      Black       Dist       Free       Stud    Charged       Good       Poor'
          ? 'Leads      '
          for nCnt1 = 1 to 11
            ?? str(a_Adv[nCnt1,1],11,0)
          next
          ? 'Intview    '
          for nCnt1 = 1 to 11
            ?? str(a_Adv[nCnt1,2],11,0)
          next
          ? 'Sales      '
          for nCnt1 = 1 TO 11
            ?? str(a_Adv[nCnt1,3],11,0)
          next
          ? '  Description ' + adverts->descriptn
          nAdv_cost = nAdv_cost + adverts->cost
          if a_Adv[10, 1] != 0
            nLead_cst = adverts->cost / a_Adv[10, 1]
          else
            nLead_cst = 0
          endif
          ? '  Cost of advert = ' + str(adverts->cost,10,2) +;
              '  Cost per Good Lead = ' + str(nLead_cst,10,2)
          IF a_Adv[1, 3] != 0
            nSale_cst = adverts->cost / a_Adv[1, 3]
            ?? '  Cost per Sale = ' + str(nSale_cst,10,2)
          endif
          IF a_Adv[1, 3] != 0
            ?? '   Good leads per sale = '
            RATIOS(a_Adv[10, 1], a_Adv[1, 3])
          endif
          IF a_Adv[1, 1] > 0
            RECLOCK('ADVERTS')
            Adverts->good_ld := a_Adv[10, 1]
            Adverts->total_ld := a_Adv[1, 1]
            Adverts->sales := a_Adv[1, 3]
            Adverts->lst_updt := date()
            dbunlock()
          endif
          pr_line(' ')
          ? ' '
          memvar->pline += 8
          for nCnt1 = 1 to 11
            for nCnt2 = 1 to 3
              a_Tot[nCnt1, nCnt2] += a_Adv[nCnt1, nCnt2]
            next
          next
        endif
        for nCnt1 = 1 to 11
          for nCnt2 = 1 to 3
            a_Adv[nCnt1, nCnt2] := 0
          next
        next
        nSale_cst := nLead_cst := 0
      endif (dates correct)
    endif (ld_gen correct)
    select adverts
    dbskip()
  enddo (eof)
  prntitle(cTitle,'Y')
  ? 'OVERALL          Total    4 Weeks  5-8 Weeks    Unalloc      Black       Dist       Free       Stud    Charged       Good       Poor'
  ? 'Leads      '
  for nCnt1 = 1 to 11
    ?? str(a_Tot[nCnt1,1],11,0)
  next
  ? 'Intview    '
  for nCnt1 = 1 TO 11
    ?? str(a_Tot[nCnt1,2],11,0)
  next
  ? 'Sales      '
  for nCnt1 = 1 TO 11
    ?? str(a_Tot[nCnt1,3],11,0)
  next
  ? ' '
  if a_Tot[10, 1] != 0
    nLead_cst = nAdv_cost / a_Tot[10, 1]
  else
    nLead_cst = 0
  endif
  ? '    Cost of advertising = ' , nAdv_cost , '    Cost per Good Lead = ', nLead_cst
  if a_Tot[1, 3] != 0
    nSale_cst = nAdv_cost / a_Tot[1, 3]
    ?? '    Cost per Sale = ' , nSale_cst
  endif
  ? ' '
  ? ' '
  ? memvar->pr_reset
  ? '***** END OF MEDIA LEADS SUMMARY *****'
end sequence
set alternate off
close alternate
shutprn()
dbcloseall()

if net_use('param', .f.)
  reclock('Parameter')
  param->lst_medst := date()
  memvar->plst_medst := date()
  dbunlock()
  dbclosearea()
endif

return

*EOF

*******************************************************************************
* MEDPROC1 - USED TO INCREMENT ARRAY ELEMENTS
*
*******************************************************************************
procedure medproc1 ( nNtx)
memvar->a_Adv[nNtx, 1]++
if newleads->intview = 'Y'
  memvar->a_Adv[nNtx, 2]++
endif
if memvar->lStd_fnd
  memvar->a_Adv[nNtx, 3]++
endif
return
