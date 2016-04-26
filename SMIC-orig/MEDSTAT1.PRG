*******************************************************************************
* PROGRAM 'MEDSTAT1' PRINTS STATS PER ADVERT

local  nAdv_cost, nSale_cst, nLead_cst, cLead_gen, nCnt1, nCnt2, dStart, dEnd
local cTitle
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
  
  * INITIALIZE VARIABLES
  /* NOTE - THE 2 DIM ARRAY HOLD ALL COUNTER USING THE FOLLOWING LOGIC
  
  FIRST DIMENSION
  1 = TOTAL
  2 = POSTED
  3 = PHONED IN
  4 = FAXED IN
  5 = MALE
  6 = FEMALE
  7 = WHITE
  8 = ASIAN
  9 = BLACK
  10 = SALARIED
  11 = SELF EMPLOYED
  
  SECOND DIMENSION
  1 = LEADS
  2 = INTERVIEWS
  3 = SALES
  */
  
  private a_Adv[11][3], a_Tot[11][3]
  for nCnt1 = 1 to 11
    for nCnt2 = 1 to 3
      a_Adv[nCnt1, nCnt2] = 0
      a_Tot[nCnt1, nCnt2] = 0
    next
  next
  
  nAdv_cost := nSale_cst := nLead_cst := 0
  
  simhead(memvar->pScr_title)
  @4,20 say 'MEDIA STATISTICS SUMMARY PROGRAM'
  
  cLead_gen = ' '
  @7,0 say 'Or space for all adverts'
  @6,0 say 'Enter lead generated code ' get cLead_gen picture '!'
  read
  
  dStart = ctod('  /  /  ')
  dEnd = date()
  @12,0 say 'Enter start source date for report ' get dStart picture '@d'
  @14,0 say 'Enter end source date for report   ' get dEnd picture'@d'
  read
  if openprn() .or. !make_sure(10)
    break
  endif
  memvar->lPr_esc = .t.
  @4,0 clear
  @7,5 say 'PRINTING THE MEDIA SUMMARY - THIS WILL TAKE SOME TIME'
  cTitle = 'MEDIA STATISTICS SUMMARY '
  if !empty(dStart)
    cTitle += 'FROM ' + dtoc(dStart) + ' '
  endif
  cTitle += 'TO ' + dtoc(dEnd) + ' '
  if cLead_gen != ' '
    cTitle += '(Lead generator ' + cLead_gen + ')'
  else
    cTitle += '(All Lead generators)'
  endif
  select Adverts
  dbgotop()
  while !eof()
    @12,5 say adverts->source_cd
    @12,20 say adverts->source_dt
    if cLead_gen = ' ' .or. adverts->ld_gen = cLead_gen
      if (adverts->source_dt >= dStart .and. adverts->source_dt <= dEnd)
        select newleads
        dbseek(adverts->source_cd + dtos(adverts->source_dt))
        while newleads->source_cd = adverts->source_cd .and.;
              adverts->source_dt = newleads->source_dt .and. !eof()
          select Student
          if dbseek(newleads->archiv)
            lStd_fnd = .t.
          else
            lStd_fnd = .f.
          endif
          select newleads
          medproc1(1)         // TOTAL LEADS
          do case
            case newleads->lead_gen_c = 'P'
              medproc1(2)         // POSTED LEADS
            case newleads->lead_gen_c = 'T'
              medproc1(3)         // PHONED LEADS
            case newleads->lead_gen_c = 'F'
              medproc1(4)         // FAXED LEADS
          endcase
          do case
            case newleads->sex = 'M'
              medproc1(5)         // male
            case newleads->sex = 'F'
              medproc1(6)         // female
          endcase
          do case
            case newleads->race = 'W'
              medproc1(7)         // white
            case newleads->race = 'A'
              medproc1(8)         // Asian
            case newleads->race = 'B'
              medproc1(9)         // Black
          endcase
          do case
            case newleads->self_emp != 'Y'
              medproc1(10)         // Salaried
            case newleads->self_emp = 'Y'
              medproc1(11)         // Self employed
          endcase
          select newleads
          dbskip()
        enddo (source_dt >= dStart)
      endif (adverts->source_dt = source_dt)
    endif
    select Adverts
    if a_Adv[1, 1] != 0 .OR. Adverts->cost != 0
      if memvar->pline > 52
        prntitle(cTitle,'Y')
      endif
      ? adverts->source_cd , ' ' , adverts->source_dt ,;
          '  Total       Post      Phone        Fax       Male     Female      White      Asian      Black     Salary   Self_emp'
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
      pr_line(' ')
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
    select Adverts
    dbskip()
  enddo (eof)
  prntitle(cTitle,'Y')
  ? 'OVERALL          Total       Post      Phone        Fax       Male     Female      White      Asian      Black     Salary   Self_emp'
  ? 'Leads      '
  for nCnt1 = 1 to 11
    ?? STR(a_Tot[nCnt1,1],11,0)
  next
  ? 'Intview    '
  for nCnt1 = 1 TO 11
    ?? STR(a_Tot[nCnt1,2],11,0)
  next
  ? 'Sales      '
  for nCnt1 = 1 TO 11
    ?? STR(a_Tot[nCnt1,3],11,0)
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
shutprn()
dbcloseall()
return

*EOF
