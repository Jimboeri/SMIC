*******************************************************************************
* PROGRAM 'RLEADS'
* JIM WEST
* CIRCA 1987

parameters dDate1, dDate2

local cAddress, cPhone, lAuto, cType, cRep, lYes_no
local cWk_mth, cRep_2, cTitle
local nGrand_tot, nRef_cnt, nFree_cnt, nBlack_cnt, nStd_cnt, nDist_cnt
local nChrg_cnt, nNew_ld, nGood_all, nAlloc_tot, nPoor_ld, nGood_ld
local nPart_sl, nFull_sl, nInt_tot
local dSold1, dSold2
local cMisc_cd1, cMisc_cd2

memvar dDate1, dDate2, getlist, cBranch
memvar aRep_sl, aRep, aRep_ld, dStart, dEnd
memvar nB_sales, nBld_unall, nBld_rcvd, nBld_all, nIndex
memvar pLine, pPage

select 1
if !net_use('student', .f.,, 'stdarc')
  return
endif

select 4
if !net_use('repstats', .f.,, 'repstats')
  close databases
  return
endif

select 3
if !net_use('reps', .f.,, 'reps')
  close databases
  return
endif

select 2
if !net_use('newleads', .f.,, 'rleads')
  close databases
  return
endif

simhead(memvar->pscr_title)
cAddress = '                         '
cPhone = '               '
lAuto = .F.

if empty(dDate1) .and. empty(dDate2)
  cType = ' '
  while !(cType $ 'AS')
    @5,0 clear
    wait 'Do you want to print this report for All the reps or a Single rep (A/S) ? ';
        to cType
    cType = upper(cType)
  enddo
  if cType = 'S'
    cRep = space(2)
    @8,0 clear
    @8,0 say 'Enter sales person code or agent code' get cRep picture '!!'
    read
    dbseek(cRep)
  endif
  dStart = ctod('  /  /  ')
  dEnd = date()
  @11,0 clear
  @12,0 say 'Enter start date for report ' get dStart picture '@D'
  @13,0 say 'Enter end date for report   ' get dEnd picture '@D'
  read
  *
  lYes_no = wmake_sure(10)
else
  dStart = dDate1
  dEnd = dDate2
  lYes_no = .T.
  cType = 'A'
  lAuto = .T.
  if dEnd > dStart + 14
    cWk_mth = 'M'
  else
    cWk_mth = 'W'
  endif
endif

begin sequence
  if !lYes_no
    break
  endif
  memvar->lPr_esc = .t.
  private aRep[20], aRep_ld[20], aRep_sl[20]
  set alternate to rleads.txt
  set alternate on
  set consol off
  while !eof()
    nIndex = 1
    afill(aRep, '  ')
    afill(aRep_ld, 0)
    afill(aRep_sl, 0)
    nBld_rcvd := nBld_all := nBld_unall := nB_sales := 0
    cBranch = substr(Newleads->salespsn,1,1)
    while cBranch = substr(Newleads->salespsn,1,1) .and. !eof()
      if cType = 'A'
        cRep = Newleads->salespsn
      endif
      @10,0 say 'SALESPERSON/AGENT CODE = '
      @10,25 say cRep
      cRep_2 = substr(cRep,2,1)
      *
      @17,0 clear
      select Reps
      if dbseek(cRep)
        @18,10 say 'Printing sales report for ' + trim(reps->name)
        cTitle = 'LIST OF LEADS FOR ' + trim(reps->name) + ' (' + cRep +;
            ')  FROM ' + dtoc(dStart) + ' TO ' + dtoc(dEnd)
      else
        @18,10 SAY 'Printing sales report for ' + cRep
        cTitle = 'LIST OF LEADS FOR SALESPERSON/AGENT ' + cRep + ' FROM ' +;
            dtoc(dStart) + ' TO ' + dtoc(dEnd)
      endif
      select Newleads
      pLine = 70
      pPage = 0
      nChrg_cnt := nDist_cnt := nStd_cnt := nBlack_cnt := nFree_cnt := nRef_cnt := nGrand_tot := 0
      nInt_tot := nFull_sl := nPart_sl := nGood_ld := nPoor_ld := nAlloc_tot := nGood_all := nNew_ld := 0
      while Newleads->salespsn = cRep
        select Student
        if dbseek(Newleads->archiv)
          dSold1 = Student->sold_crs_1
          dSold2 = Student->sold_crs_2
        else
          dSold1 := dSold2 := ctod('  /  /  ')
        endif
        select Newleads
        if (Newleads->alloc_dt >= dStart .and. Newleads->alloc_dt <= dEnd);
              .or. (dSold1 >= dStart .and. dSold1 <= dEnd)
          if pLine > 57
            prntitle(cTitle,'Y')
            pLine = 6
            ? '                                                                       ' +;
                '                 SOLD     SOLD'
            ? 'NEW ALLOC-DT ARCHIV            NAME                           ADDRESS3 ' +;
                '                 MOD 1    MOD 2   SRC CHGE  INT PHONE'
            ? ' '
          endif
          if Newleads->address3 = space(20)
            cAddress = Newleads->address2
          else
            cAddress = Newleads->address3
          endif
          if Newleads->phone_w = space(15)
            cPhone = Newleads->phone_h
          else
            cPhone = Newleads->phone_w
          endif
          if Newleads->date_rcvd >= dStart .and. Newleads->date_rcvd <= dEnd
            ? ' * '
          else
            ? '   '
          endif
          if cRep_2 = ' '
            ?? ' ' + dtoc(Newleads->date_rcvd) + ' '
          else
            ?? ' ' + dtoc(Newleads->alloc_dt) + ' '
          endif
          ?? Newleads->archiv, Newleads->title, Newleads->initls,;
              Newleads->surname, cAddress, dSold1, dSold2, Newleads->source_cd,;
              Newleads->misc_cd, ' ', Newleads->intview, cPhone
          ? space(30) + memoline(Newleads->mem_comnt,50,1)
          pLine += 2
          cMisc_cd1 = substr(Newleads->misc_cd,1,1)
          cMisc_cd2 = substr(Newleads->misc_cd,2,1)
          do case
            case 'Y'=cMisc_cd1
              nChrg_cnt++
            case 'D'=cMisc_cd1
              nDist_cnt++
            case 'S'=cMisc_cd1
              nStd_cnt++
            case 'B'=cMisc_cd1
              nBlack_cnt++
            case 'F'=cMisc_cd1
              nFree_cnt++
            case 'R'=cMisc_cd1
              nRef_cnt++
          endcase
          if cMisc_cd2 = 'G'
            nGood_ld++
            if (Newleads->alloc_dt >= dStart .and. Newleads->alloc_dt <= dEnd)
              nGood_all++
            endif
            if (Newleads->date_rcvd >= dStart .and. Newleads->date_rcvd <= dEnd)
              nNew_ld++
            endif
          endif
          if cMisc_cd2 = 'P'
            nPoor_ld++
          endif
          if Newleads->intview = 'Y'
            nInt_tot++
          endif
          if !empty(dSold1) .and. !empty(dSold2)
            nFull_sl++
          else
            if !empty(dSold1) .or. !empty(dSold2)
              nPart_sl++
            endif
          endif
          nGrand_tot++
          if (Newleads->alloc_dt >= dStart .and. Newleads->alloc_dt <= dEnd)
            nAlloc_tot++
          endif
        endif
        dbskip()
      enddo
      if nGrand_tot != 0
        if pLine > 50
          prntitle(cTitle,'Y')
        endif
        ? 'CHARGED    = ' + str(nChrg_cnt,10,0) + space(18) +;
            'NO. OF INTERVIEWS = ' + str(nInt_tot,10,0)
        ? 'DISTANT    = ' + str(nDist_cnt,10,0) + space(18) +;
            'FULL SALES        = ' + str(nFull_sl,10,0)
        ? 'STUDENTS   = ' + str(nStd_cnt,10,0) + space(18) +;
            'PART SALES        = ' + str(nPart_sl,10,0)
        ? 'BLACKS     = ' + str(nBlack_cnt,10,0) + space(18) +;
            'TOTAL SALES       = ' + str((nFull_sl + nPart_sl),10,0)
        ? 'FREE       = ' + str(nFree_cnt,10,0) + space(18) +;
            'ALLOCATED LEADS   = ' + str(nAlloc_tot,10,0)
        ? 'REFERRALS  = ' + str(nRef_cnt,10,0) + space(18) +;
            'TOTAL LEADS       = ' + str(nGrand_tot,10,0)
        ? ' '
        ? 'GOOD LEADS = '  + str(nGood_ld,10,0) + space(18) +;
            'RCVD GD LDS = '  + str(nNew_ld,10,0)
        ? 'ALLOC GD LD= '  + str(nGood_all,10,0) + space(18) +;
            'POOR LEADS = '  + str(nPoor_ld,10,0)
        ? ' '
        ? 'TOTAL ALLOCATED GOOD LEADS TO SALES '
        if nFull_sl + nPart_sl = 0
          ?? 'This figure is too disgusting to print'
        else
          ?? str(nGood_all/(nFull_sl + nPart_sl),10,2)
        endif
        ?? chr(12)
        aRep[nIndex] = cRep
        aRep_ld[nIndex] = nGood_all
        aRep_sl[nIndex] = (nFull_sl + nPart_sl)
        nIndex++
        nBld_rcvd += nNew_ld
        if substr(cRep,2,1) != ' '
          nBld_all += nGood_all
        else
          nBld_unall += nGood_all
        endif
        nB_sales += (nFull_sl + nPart_sl)
        if lAuto
          select repstats
          if !dbseek(cRep + cWk_mth + dtos(dEnd))
            dbappend()
            reclock('repstats')
            repstats->rep := cRep
            repstats->wk_mth := cWk_mth
            repstats->end_dt := dEnd
            dbunlock()
          endif
          reclock('repstats')
          repstats->sales := (nFull_sl + nPart_sl)
          repstats->good_leads := nGood_all
          repstats->gl_rcvd := nNew_ld
          dbunlock()
        endif
        select Newleads
      endif
      if cType = 'S'
        dbgobottom()
        dbskip()
      endif
    enddo
    if nBld_all != 0 .or. nBld_rcvd != 0
      set alternate off
      set print on
      ppage = 0
      rleadsbr()
      ?? chr(12)
      set print off
      set alternate on
      ppage = 0
      rleadsbr()
      ?? chr(12)
    endif
    select Newleads
  enddo
  set alternate off
  close alternate
  set consol on
  if lAuto
    if net_use('param', .f.)
      reclock('param')
      param->lst_rleads := date()
      memvar->plst_rleads := date()
      dbunlock()
      dbclosearea()
    endif
  endif
end sequence
dbcloseall()
return

*EOF

*******************************************************************************
static procedure rleadsbr
local cTitle, nCnt
memvar cBranch, dStart, dEnd
memvar aRep_sl, aRep, aRep_ld
memvar nB_sales, nBld_unall, nBld_rcvd, nBld_all, nIndex

cTitle = 'Branch report for '
do case
  case cBranch = 'C'
    cTitle = cTitle + 'Cape town'
  case cBranch = 'D'
    cTitle = cTitle + 'Durban'
  case cBranch = 'J'
    cTitle = cTitle + 'Johannesburg'
  case cBranch = 'P'
    cTitle = cTitle + 'Pretoria'
  otherwise
    cTitle = cTitle + cBranch
endcase
cTitle += ' FROM ' + dtoc(dStart) + ' TO ' + dtoc(dEnd)
prntitle(cTitle,'N')
? 'SALES RECEIVED               = ' + str(nB_sales)
? 'GOOD LEADS STILL UNALLOCATED = ' + str(nBld_unall)
? ' '
? space(40) + 'Good leads           Good leads'
? space(40) + ' Received            Allocated'
? ' '
? 'No. of leads  ' + space(23) + str(nBld_rcvd,12,0) + space(9) +;
    str(nBld_all,12,0)
? ' '
if nB_sales != 0
  ? 'Leads to sales' + space(23) + str((nBld_rcvd/nB_sales),12,2) +;
      space(9) + str((nBld_all/nB_sales),12,2)
  ? ' '
endif
? ' '
nCnt = 1
select Reps
for nCnt = 1 to nIndex-1
  if substr(aRep[nCnt],2,1) != ' '
    ? aRep[nCnt]
    if dbseek(aRep[nCnt])
      ?? space(2) + reps->name
    endif
    ? '    Leads allocated ' + str(aRep_ld[nCnt],12,0)
    ? '    Sales made      ' + str(aRep_sl[nCnt],12,0)
    ? '          Leads to sales ratio '
    if aRep_sl[nCnt] != 0
      ?? str((aRep_ld[nCnt]/aRep_sl[nCnt]),12,2)
    else
      ?? '       NO SALES FOR THIS PERIOD'
    endif
    ? ' '
  endif
next
return

* eof
