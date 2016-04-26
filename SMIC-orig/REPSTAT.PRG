*******************************************************************************
* PROGRAM 'REPSTAT'
* JIM WEST
* CIRCA 1989

local nAd_cost, dStart, dEnd, cType, cTitle, cRep, cTemp_rep, nSales_pr
local cBranch, dSold_1, dSold_2, lFnd_std, cMisc_cd1, cMisc_cd2, nStd_amt
local nCnt, nPrint

memvar aY_ctr, aD_ctr, aS_ctr, aB_ctr, aF_ctr
memvar aR_ctr, aBig_tot, aInt_tot, aFull_tot
memvar aPart_tot, aGood_ld, aPoor_ld, aAlloc_tot
memvar aCash_tot, aAdv, aGall, aRep
memvar getlist, pLine

#define MAX_NO  8

PUBLIC aY_ctr[MAX_NO], aD_ctr[MAX_NO], aS_ctr[MAX_NO], aB_ctr[MAX_NO], aF_ctr[MAX_NO]
PUBLIC aR_ctr[MAX_NO], aBig_tot[MAX_NO], aInt_tot[MAX_NO], aFull_tot[MAX_NO]
PUBLIC aPart_tot[MAX_NO], aGood_ld[MAX_NO], aPoor_ld[MAX_NO], aAlloc_tot[MAX_NO]
PUBLIC aCash_tot[MAX_NO], aAdv[MAX_NO], aGall[MAX_NO], aRep[MAX_NO]

select 1
if !net_use('newleads', .f.,, 'rleads')
  return
endif

select 2
if !net_use('student', .f.,, 'stdarc')
  close databases
  return
endif

select 3
if !net_use('account', .f.,, 'acccode')
  close databases
  return
endif

simhead(memvar->pscr_title)

@3,1 say '          ****** PRINT STATISTICS BY AGENT OR SALESPERSON ******'

nAd_cost = 0
@7,0 clear
@7,10 say 'Enter cost per good lead  ' get nAd_cost picture '9999999.99'

dStart = CTOD('00/00/00')
dEnd = date()
@9,10 say 'Enter start date for report ' get dStart picture '@D'
@10,10 say 'Enter end date for report   ' get dEnd picture '@D'
read
*
cType = 'X'
while 'N' != cType .and. 'S' != cType
  @12,0 clear
  wait 'Is this for the NSM or the Sales managers ? (N/S) ' to cType
  cType = upper(cType)
enddo

if wmake_sure(15)
  @19,10 say 'Printing salesman statistics '
  openprn()
  memvar->lPr_esc = .t.
  cTitle = 'SALES REPRESENTATIVE STATISTICS FROM ' + dtoc(dStart) + ' TO ';
      + dtoc(dEnd)
  
  select Newleads
  while empty(newleads->salespsn)
    dbskip()
  enddo
  if cType = 'N'
    cTemp_rep = substr(newleads->salespsn,1,1)
  else
    cTemp_rep = newleads->salespsn
  endif
  while !eof()
    nSales_pr = 1
    afill(aY_ctr, 0)
    afill(aD_ctr, 0)
    afill(aS_ctr, 0)
    afill(aB_ctr, 0)
    afill(aF_ctr, 0)
    afill(aR_ctr, 0)
    afill(aBig_tot, 0)
    afill(aInt_tot, 0)
    afill(aFull_tot, 0)
    afill(aPart_tot, 0)
    afill(aGood_ld, 0)
    afill(aPoor_ld, 0)
    afill(aAlloc_tot, 0)
    afill(aCash_tot, 0)
    afill(aAdv, 0)
    afill(aGall, 0)
    afill(aRep, '  ')
    
    while nSales_pr < MAX_NO + 1
      if cType = 'N'
        cRep = substr(newleads->salespsn,1,1)
      else
        cRep = newleads->salespsn
      endif
      @19,50 say cRep
      cBranch = substr(newleads->salespsn,1,1)
      aRep[nSales_pr] := cRep
      while cRep = cTemp_rep .and. !eof()
        dSold_1 = ctod('  /  /  ')
        dSold_2 = ctod('  /  /  ')
        lFnd_std = .F.
        select Student
        if dbseek(newleads->archiv)
          dSold_1 = Student->sold_crs_1
          dSold_2 = Student->sold_crs_2
          lFnd_std = .t.
        endif
        select Newleads
        if (newleads->alloc_dt >= dStart .and. newleads->alloc_dt <= dEnd);
         .or. (dSold_1 >= dStart .and. dSold_1 <= dEnd)
          cMisc_cd1 = substr(newleads->misc_cd,2,1)
          cMisc_cd2 = substr(newleads->misc_cd,2,1)
          do case
            case 'Y'=cMisc_cd1
              aY_ctr[nSales_pr]++
            case 'D'=cMisc_cd1
              aD_ctr[nSales_pr]++
            case 'S'=cMisc_cd1
              aS_ctr[nSales_pr]++
            case 'B'=cMisc_cd1
              aB_ctr[nSales_pr]++
            case 'F'=cMisc_cd1
              aF_ctr[nSales_pr]++
            case 'R'=cMisc_cd1
              aR_ctr[nSales_pr]++
          endcase
          if cMisc_cd2 = 'G'
            aGood_ld[nSales_pr]++
            if (newleads->alloc_dt >= dStart .and. newleads->alloc_dt <= dEnd)
              aGall[nSales_pr]++
            endif
          endif
          if cMisc_cd2 = 'P'
            aPoor_ld[nSales_pr]++
          endif
          if 'Y'=newleads->intview
            aInt_tot[nSales_pr]++
          endif
          if !empty(dSold_1) .and. !empty(dSold_2)
            aFull_tot[nSales_pr]++
          else
            if !empty(dSold_1) .or. !empty(dSold_2)
              aPart_tot[nSales_pr]++
            endif
          endif
          if !empty(dSold_1) .or. !empty(dSold_2)
            nStd_amt = 0
            if lFnd_std
              select Account
              dbseek(Student->std_code + 'T')
              while Student->std_code = account->std_code .and.;
               account->type = 'T' .and. !eof()
                if account->cr_dr = 'C' .and. account->comment != 'C'
                  nStd_amt += account->amount
                endif
                dbskip()
              enddo
            endif (STUDENT FOUND)
            aCash_tot[nSales_pr] += nStd_amt
          endif (SALE MADE)
          select Newleads
          aBig_tot[nSales_pr]++
          if (newleads->alloc_dt >= dStart .and. newleads->alloc_dt <= dEnd)
            aAlloc_tot[nSales_pr]++
          endif
        endif
        dbskip()
        if cType = 'N'
          cTemp_rep = substr(newleads->salespsn,1,1)
        else
          cTemp_rep = newleads->salespsn
        endif
      enddo (REPS LEADS)
      if aBig_tot[nSales_pr] != 0 .or. aAlloc_tot[nSales_pr] != 0
        nSales_pr++
      else
        aRep[nSales_pr] = '  '
      endif
      if eof()
        nSales_pr = MAX_NO + 2
      endif
      if cType = 'S' .and. (cBranch != substr(newleads->salespsn,1,1))
        nSales_pr = MAX_NO + 2
      endif
    enddo (8 SALES REPS)
    if aRep[1] != space(2)
      if pLine > 40
        prntitle(cTitle,'Y')
      endif
      ? 'SALES REP' + space(19)
      nCnt = 1
      for nCnt = 1 to MAX_NO
        if aRep[nCnt] != '  '
          ?? aRep[nCnt] + '        '
          if len(aRep[nCnt]) = 1
            ?? ' '
          endif
        endif
      next
      ? ' '
      
      ? 'CHARGED           = '
      prt_line(aY_ctr)
      
      ? 'DISTANT           = '
      prt_line(aD_ctr)
      
      ? 'STUDENTS          = '
      prt_line(aS_ctr)
      
      ? 'BLACKS            = '
      prt_line(aB_ctr)
      
      ? 'FREE              = '
      prt_line(aF_ctr)
      
      ? 'REFERRALS         = '
      prt_line(aR_ctr)
      ? ' '
      
      ? 'GOOD LEADS        = '
      prt_line(aGood_ld)
      
      ? 'ALLOC GOOD LEADS  = '
      for nCnt = 1 to MAX_NO
        if aRep[nCnt] != '  '
          ?? aGall[nCnt]
        endif
        aAdv[nCnt] = aGall[nCnt] * nAd_cost
      next
      
      ? 'POOR LEADS        = '
      prt_line(aPoor_ld)
      
      ? 'TOTAL LEADS       = '
      prt_line(aBig_tot)
      
      ? 'ALLOCATED LEADS   = '
      prt_line(aAlloc_tot)
      ? ' '
      
      ? 'NO. OF INTERVIEWS = '
      prt_line(aInt_tot)
      
      ? 'FULL SALES        = '
      prt_line(aFull_tot)
      
      ? 'PART SALES        = '
      prt_line(aPart_tot)
      
      ? 'TOTAL SALES       = '
      for nCnt = 1 to MAX_NO
        if aRep[nCnt] != '  '
          ?? (aPart_tot[nCnt] + aFull_tot[nCnt])
        endif
      next
      
      ? 'GOOD LDS TO SALES = '
      for nCnt = 1 to MAX_NO
        if aRep[nCnt] != '  '
          if aPart_tot[nCnt] + aFull_tot[nCnt] != 0
            nPrint = aGall[nCnt] / (aPart_tot[nCnt] + aFull_tot[nCnt])
          else
            nPrint = 0
          endif
          ?? str(nPrint,10,2)
        endif
      next
      ? ' '
      
      ? 'BANKING           = '
      prt_line(aCash_tot)
      
      ? 'COST OF ADVERTS   = '
      prt_line(aAdv)
      
      ? 'COMMISION         = '
      for nCnt = 1 to MAX_NO
        if aRep[nCnt] != '  '
          ?? str((aCash_tot[nCnt]*35/100),10,2)
        endif
      next
      
      ? 'CONTRIBUTION      = '
      for nCnt = 1 to MAX_NO
        if aRep[nCnt] != '  '
          ?? str(((aCash_tot[nCnt]*65/100) - aAdv[nCnt]),10,2)
        endif
      next
      
      ? 'ADVERT PERCENTAGE = '
      for nCnt = 1 to MAX_NO
        if aRep[nCnt] != '  '
          if aCash_tot[nCnt] != 0
            nPrint = aAdv[nCnt] / aCash_tot[nCnt] * 100
          else
            nPrint = 0
          endif
          ?? str(nPrint,10,2)
        endif
      next
      ? ' '
      ? ' '
      ? ' '
      pline += 30
    endif
    if cType = 'S' .and. (cBranch != substr(newleads->salespsn,1,1))
      nSales_pr = MAX_NO + 2
      PLINE = 90
    endif
  enddo (END OF LEADS FILE
  ? '****** END OF REPORT *******'
  ? ' '
  ? 'N.B. All figures calculated on allocated GOOD leads'
  shutprn()
endif (YESNO = 'Y')
close databases
return

*EOF

*******************************************************************************
static procedure prt_line (aArr)
local nCnt
memvar aRep
for nCnt = 1 to MAX_NO
  if aRep[nCnt] != '  '
    ?? str(aArr[nCnt],10,2)
  endif
next
return
* eop
