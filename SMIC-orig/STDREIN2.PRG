*******************************************************************************
* 'STDREIN2' PROGRAM TO REINSTATE STUDENTS  - CALLED FROM CHECKRUN
* 5/91
* JIM WEST

local nSusp_no, nSusp_exp, nOrig, nOdd, nEven, nCnt, nWork, cGroup
local nWk_smltn, nRecs := 0
memvar cMessage
nSusp_no := nSusp_exp := 0

#define EOL     chr(13) + chr(10)

wopen(8,10,11,70)
wcenter()
wbox(0)
setcursor(0)
@0,0 say center('CHECKING FOR STUDENTS TO BE REINSATED')

begin sequence
  
  select 2
  if !net_use('student', .f.,, 'stdgroup')
    break
  endif
  
  select 4
  if !net_use('portfol', .f.,, 'portfol')
    break
  endif
  
  select 8
  if !net_use('bear', .f.,, 'bear')
    break
  endif
  
  select 1
  if !net_use('share', .f.,, 'shrname')
    break
  endif
  
  select Student
  while !eof()
    nRecs++
    @1,0 say replicate('±', int(nRecs / lastrec() * 60))
    tts_on()
    if Student->status = 'S' .and. Student->group_no = '01'
      if Student->susp_dt = ctod('  /  /  ')
        nSusp_no++
      else
        nSusp_exp++
      endif
    endif
    if Student->status = 'S' .and. Student->susp_dt <= date() .and.;
          Student->group_no = '01' .and. !empty(Student->susp_dt)
      cMessage += trim(Student->title) + ' ' + trim(Student->name) + ' ' +;
          trim(Student->surname) + ' has been reinstated' + EOL
      
      nOrig = recno()
      nOdd = 0
      nEven = 0
      dbskip()
      nCnt = 1
      while nCnt < 11 .and. !eof()
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
        dbskip()
      enddo
      dbgoto(nOrig)
      dbskip(-1)
      nCnt = 1
      while nCnt < 11 .and. !bof()
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
      Student->status := 'C'
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
      dbunlock()
      nWk_smltn = student->wk_smltn
      rein_std()
      
      if student->group_cd != '     '
        cGroup = Student->group_cd
        dbskip()
        while Student->group_cd = cGroup .and. !eof()
          reclock('Student')
          Student->status := 'C'
          Student->wk_smltn = nWk_smltn
          rein_std()
          dbskip()
        enddo
      endif (group leader)
      select Student
      dbgoto(nOrig)
    endif (yesno = y)
    dbcommitall()
    tts_off()
    select Student
    dbskip()
  enddo
  cMessage += ltrim(str(nSusp_no,10,0)) +;
      '  Students suspended without renewal date' + EOL
  cMessage += ltrim(str(nSusp_exp,10,0)) +;
      '  Students suspended with renewal date' + EOL
  
  if select('param') != 0 .or. net_use('param', .f.)
    select param
    reclock('param')
    param->lst_reins := date()
    dbunlock()
  endif
end sequence
et_close('Student')
et_close('Portfol')
et_close('Bear')
et_close('Share')
et_close('Param')
wclose()

return
* eof

*******************************************************************************
procedure rein_std
local nWork, nCost, nValue, nProfit, nVal, nPerc_prof
local nBr_cover, nBr_sell, nBr_buy, nBr_prof
local nBrok, nHand, nMst, nPort_val, nPerf
select Portfol
dbseek(Student->std_code + 'T')
nCost = 0
nValue = 0
nProfit = 0
while portfol->std_code = Student->std_code .and. portfol->type = 'T';
      .and. !eof()
  dbseek(portfol->share)
  nVal = (Portfol->qty * Share->y_cl_pr / 100)
  nPerc_prof = 0
  if Portfol->cost_hold != 0
    nPerc_prof = (nVal / Portfol->cost_hold * 100) - 100
  endif
  nCost += Portfol->cost_hold
  nValue += nVal
  nProfit += nVal - Portfol->cost_hold
  select Portfol
  dbskip()
enddo

* BEAR SALES

select Bear
nBr_cover = 0
nBr_sell = 0
nBr_buy = 0
nBr_prof = 0
dbseek(Student->std_code + 'T')
while bear->std_code = Student->std_code .and. bear->type = 'T';
      .and. !eof()
  dbseek(bear->share)
  nVal = (bear->qty * Share->y_cl_pr / 100)
  nBrok = broker(nVal)
  nHand = handle(bear->qty)
  nMst = mst(nVal)
  nVAL += nBrok +nHand + nMst
  nBr_cover += bear->cov_hld
  nBr_sell += bear->sell_val
  nBr_buy += nVal
  nBr_prof += bear->sell_val - nVal
  select Bear
  dbskip()
enddo
nPort_val = nValue + Student->cash + nBr_cover + nBr_prof
nPerf = 0
if Student->week_4 != 0
  nPerf = (((nPort_val) / Student->week_4) *100) - 100
endif
select Student
reclock()
Student->week_4 := nPort_val
Student->week_3 := nPort_val
Student->week_2 := nPort_val
Student->week_1 := nPort_val
Student->perc_chang := 0
Student->mnth_chang := 0
Student->susp_dt := ctod('  /  /  ')
Student->last_tran := date()
dbunlock()

return
