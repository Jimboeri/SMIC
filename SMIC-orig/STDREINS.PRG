*******************************************************************************
* 'STDREINS' PROGRAM TO REINSTATE STUDENTS
* 29/3/88
* JIM WEST

local nRecord, cGroup_cd, nOrig_recno, nOdd, nEven, nCnt, nTemp,  lTraded
local nTot_cost, nTot_value, nTot_profit, nLast, nShr_val, nPerc_prof
local nBr_cover, nBr_sell, nBr_buy, nBr_prof, nPort_val
local nBroker, nHand, nMst

begin sequence
  select 1
  if !net_use('student', .f.,, 'names', 'stdgroup')
    break
  endif
  
  select 2
  if !net_use('share', .f.,, 'shrname')
    break
  endif
  
  select 4
  if !net_use('portfol', .f.,, 'portfol')
    break
  endif
  
  select 5
  if !net_use('shrdescr', .f.,, 'shrdescr')
    break
  endif
  
  select 8
  if !net_use('bear', .f.,, 'bear')
    break
  endif
  
  select student
  simhead(memvar->pscr_title)
  findstd()
  
  if Student->status != 'S' .and. Student->status != 'U'
    disp_msg(20,,'STUDENT NOT SUSPENDED', 'MAY NOT BE REINSTATED')
    inkey(10)
    break
  elseif Student->group_no != '01'
    disp_msg(20,,'STUDENT NOT GROUP LEADER', 'MAY NOT BE REINSTATED')
    inkey(10)
    break
  endif
  @3,0 clear
  @3,20 say 'REINSTATMENT OF A STUDENT'
  @6,10 say trim(Student->title) + ' ' + trim(Student->name) + ' ' +;
      trim(Student->surname)
  @8,10 say 'Phone (W) ' + Student->phone_w + ' (H) ' + Student->phone_h
  @10,10 say 'Address ' + Student->address1
  @11,18 say Student->address2
  @12,18 say Student->address3
  @13,18 say Student->p_code
  if !make_sure(17,15,'Do you want to reinstate this student (Y/N) ?')
    break
  endif
  nOrig_recno = RECNO()
  nOdd = 0
  nEven = 0
  dbskip()
  nCnt = 1
  while nCnt < 11 .and. !eof()
    if Student->status = 'C'
      nTemp = (Student->wk_smltn + 1) / 2
      nTemp = nTemp - int(nTemp)
      if nTemp = 0
        nEven++
      else
        nOdd++
      endif
      nCnt++
    endif
    dbskip()
  enddo
  goto nOrig_recno
  dbskip(-1)
  nCnt = 1
  while nCnt < 11 .and. !bof()
    if Student->status = 'C'
      nTemp = (Student->wk_smltn + 1) / 2
      nTemp = nTemp - int(nTemp)
      if nTemp = 0
        nEven++
      else
        nOdd++
      endif
      nCnt++
    endif
    dbskip(-1)
  enddo
  dbgoto(nOrig_recno)
  reclock('Student')
  if Student->start_indx = 0
    Student->status := 'N'
  else
    Student->status := 'C'
  endif
  nTemp = (Student->wk_smltn + 1) / 2
  nTemp = nTemp - int(nTemp)
  if nTemp = 0
    if nOdd > nEven
      Student->wk_smltn := Student->wk_smltn - 1
    endif
  else
    if nEven < nOdd
      Student->wk_smltn := Student->wk_smltn - 1
    endif
  endif
  select Portfol
  dbseek(Student->std_code + 'T')
  nTot_cost = 0
  nTot_value = 0
  nTot_profit = 0
  while portfol->std_code = Student->std_code .and. portfol->type = 'T';
        .and. !eof()
    select Share
    dbseek(portfol->Share)
    select Shrdescr
    dbseek(portfol->Share)
    nLast = Shrdescr->lst_wk_pr
    if nLast = 0
      nLast = 1
    endif
    select Share
    nShr_val = (Portfol->qty * Share->y_cl_pr / 100)
    nPerc_prof = 0
    if Portfol->cost_hold != 0
      nPerc_prof = (nShr_val / Portfol->COST_HOLD * 100) - 100
    endif
    nTot_cost += Portfol->cost_hold
    nTot_value += nShr_val
    nTot_profit += nShr_val - Portfol->COST_HOLD
    select Portfol
    dbskip()
  enddo
  
  * bear sales
  
  select Bear
  dbseek(Student->std_code + 'T')
  nBr_cover = 0
  nBr_sell = 0
  nBr_buy = 0
  nBr_prof = 0
  select Bear
  if dbseek(Student->std_code + 'T')
    while bear->std_code = Student->std_code .and. bear->type = 'T';
          .and. !eof()
      select Share
      dbseek(bear->share)
      nShr_val = (Bear->qty * Share->y_cl_pr / 100)
      nBroker = broker(nShr_val)
      nHand = handle(Bear->QTY)
      nMst = mst(nShr_val)
      nShr_val = nShr_val + nBroker +nHand + nMst
      select Share
      lTraded = .T.
      nBr_cover = nBr_cover + Bear->cov_hld
      nBr_sell = nBr_sell + Bear->sell_val
      nBr_buy = nBr_buy + nShr_val
      nBr_prof = nBr_prof + Bear->sell_val - nShr_val
      select Bear
      dbskip()
    enddo
  endif
  nPort_val = nTot_value + Student->CASH + nBr_cover + nBr_prof
  select Student
  Student->week_4 := nPort_val
  Student->week_3 := nPort_val
  Student->week_2 := nPort_val
  Student->week_1 := nPort_val
  Student->perc_chang := 0
  Student->mnth_chang := 0
  Student->susp_dt := ctod('  /  /  ')
  Student->last_tran := date()
  dbunlock()
  if Student->group_cd != '     '
    nRecord = recno()
    cGroup_cd = Student->group_cd
    dbsetorder(2)
    dbgoto(nRecord)
    dbskip()
    while Student->group_cd = cGroup_cd .and. !eof()
      reclock('Student')
      Student->status := 'C'
      nTemp = (Student->wk_smltn + 1) / 2
      nTemp = nTemp - int(nTemp)
      if nTemp = 0
        if nOdd > nEven
          Student->wk_smltn := Student->wk_smltn - 1
        endif
      else
        if nEven < nOdd
          Student->wk_smltn := Student->wk_smltn - 1
        endif
      endif
      nTot_cost = 0
      nTot_value = 0
      nTot_profit = 0
      select Portfol
      dbseek(Student->std_code + 'T')
      while portfol->std_code = Student->std_code .and. portfol->type = 'T';
            .and. !eof()
        select Share
        dbseek(portfol->Share)
        nShr_val = (Portfol->qty * Share->y_cl_pr / 100)
        nPerc_prof = 0
        if Portfol->cost_hold != 0
          nPerc_prof = (nShr_val / Portfol->cost_hold * 100) - 100
        endif
        nTot_cost = nTot_cost + Portfol->cost_hold
        nTot_value = nTot_value + nShr_val
        nTot_profit = nTot_profit + nShr_val - Portfol->cost_hold
        select Portfol
        dbskip()
      enddo
      
      * BEAR SALES
      
      nBr_cover = 0
      nBr_sell = 0
      nBr_buy = 0
      nBr_prof = 0
      select Bear
      if dbseek(Student->std_code + 'T')
        while bear->std_code = Student->std_code .and. bear->type = 'T';
              .and. !eof()
          select Share
          dbseek(bear->share)
          nShr_val = (Bear->qty * Share->y_cl_pr / 100)
          nBroker = broker(nShr_val)
          nHand = handle(Bear->qty)
          nMst = mst(nShr_val)
          nShr_val = nShr_val + nBroker +nHand + nMst
          lTraded = .T.
          nBr_cover = nBr_cover + Bear->cov_hld
          nBr_sell = nBr_sell + Bear->sell_val
          nBr_buy = nBr_buy + nShr_val
          nBr_prof = nBr_prof + Bear->sell_val - nShr_val
          select Bear
          dbskip()
        enddo
      endif
      nPort_val = nTot_value + Student->cash + nBr_cover + nBr_prof
      select Student
      Student->week_4 := nPort_val
      Student->week_3 := nPort_val
      Student->week_2 := nPort_val
      Student->week_1 := nPort_val
      Student->perc_chang := 0
      Student->mnth_chang := 0
      Student->susp_dt := ctod('  /  /  ')
      Student->last_tran := date()
      dbunlock()
      dbskip()
    enddo
  endif (group leader)
  select Student
  dbsetorder(1)
  dbgoto(nOrig_recno)
end sequence
close database
return
* eof
