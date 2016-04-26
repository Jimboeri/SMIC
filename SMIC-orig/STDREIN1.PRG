*******************************************************************************
* 'STDREIN1' PROGRAM TO REINSTATE STUDENTS  - CALLED FROM TWIN
* 5/91
* JIM WEST

local nOrig, nOdd, nEven, nCnt, nWork, nPort_val, nPerformance, nRecno, cGroup

begin sequence
  
  select Student
  
  if make_sure(17,,'Do you want to reinstate this student (Y/N) ?')
    nOrig = recno()
    nOdd = 0
    nEven = 0
    dbskip()
    nCnt = 1
    while nCnt < 21 .and. !eof()
      if student->status = 'C'
        nWork = (student->wk_smltn + 1) / 2
        nWork = nWork - int(nWork)
        if nWork = 0
          nEven++
        else
          nOdd++
        endif
        nCnt++
      endif
      dbskip()
    enddo
    dbgoto(nOrig)
    dbskip(-1)
    nCnt = 1
    while nCnt < 21 .and. !bof()
      if Student->status = 'C'
        nWork = (Student->wk_smltn + 1) / 2
        nWork = nWork - int(nWork)
        if nWork = 0
          nEven++
        else
          nOdd++
        endif
        nCnt++
      endif
      dbskip(-1)
    enddo
    dbgoto(nOrig)
    reclock('Student')
    if Student->start_indx = 0
      Student->status := 'N'
    else
      Student->status := 'C'
    endif
    nWork = (Student->wk_smltn + 1) / 2
    nWork = nWork - int(nWork)
    if nWork = 0
      if nOdd > nEven
        Student->wk_smltn := Student->wk_smltn - 1
      endif
    else
      if nEven < nOdd
        Student->wk_smltn := Student->wk_smltn - 1
      endif
    endif
    nPort_val = std_port_val()
    nPerformance = 0
    if Student->week_4 != 0
      nPerformance = (((nPort_val) / Student->week_4) *100) - 100
    endif
    select Student
    Student->week_4 := nPort_val
    Student->week_3 := nPort_val
    Student->week_2 := nPort_val
    Student->week_1 := nPort_val
    Student->Perc_chang := 0
    Student->Mnth_chang := 0
    Student->susp_dt := ctod('  /  /  ')
    Student->last_tran := date()
    dbunlock()
    
    if student->group_cd != '     '
      nRecno = recno()
      cGroup = student->GROUP_CD
      dbsetorder(4)
      goto nRecno
      dbskip()
      while student->group_cd = cGroup .and. !eof()
        reclock('Student')
        Student->status := 'C'
        nWork = (student->wk_smltn + 1) / 2
        nWork = nWork - int(nWork)
        if nWork = 0
          if nOdd > nEven
            Student->wk_smltn := student->wk_smltn - 1
          endif
        else
          if nEven < nOdd
            Student->wk_smltn := Student->wk_smltn - 1
          endif
        endif
        nPort_val = std_port_val()
        nPerformance = 0
        if Student->week_4 != 0
          nPerformance = (((nPort_val) / Student->week_4) *100) - 100
        endif
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
    dbsetorder(2)
    dbgoto(nOrig)
  endif (yesno = y)
end sequence
return
* EOF

*******************************************************************************
function std_port_val ()
local nCost, nValue, nProf, nShr_val
local nPerc_prof, nBear_cov, nBear_sell, nBear_buy, nBear_prof
local nBrok, nHand, nMst
select portfol
dbseek(Student->std_code + 'T')
nCost = 0
nValue = 0
nProf = 0
while portfol->std_code = Student->std_code .and. portfol->type = 'T';
      .and. !eof()
  select share
  dbseek(portfol->share)
  nShr_val = (portfol->QTY * share->y_cl_pr / 100)
  nPerc_prof = 0
  if portfol->cost_hold != 0
    nPerc_prof = (nShr_val / portfol->cost_hold * 100) - 100
  endif
  nCost = nCost + portfol->COST_HOLD
  nValue = nValue + nShr_val
  nProf = nProf + nShr_val - portfol->cost_hold
  select portfol
  dbskip()
enddo

* BEAR SALES

select Bear
nBear_cov = 0
nBear_sell = 0
nBear_buy = 0
nBear_prof = 0
if dbseek(Student->std_code + 'T')
  do while bear->std_code = Student->std_code .and. bear->type = 'T';
        .and. !eof()
    select share
    dbseek(bear->share)
    nBrok = 0
    nHand = 0
    nMst = 0
    nShr_val = (Bear->qty * share->y_cl_pr / 100)
    nBrok = broker(nShr_val)
    nHand = handle(Bear->QTY)
    nMst = mst(nShr_val)
    nShr_val = nShr_val + nBrok +nHand + nMst
    nBear_cov = nBear_cov + Bear->cov_hld
    nBear_sell = nBear_sell + Bear->SELL_VAL
    nBear_buy = nBear_buy + nShr_val
    nBear_prof = nBear_prof + Bear->SELL_VAL - nShr_val
    select Bear
    dbskip()
  enddo
endif
return ( nValue + Student->cash + nBear_cov + nBear_prof)
