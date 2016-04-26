*******************************************************************************
* PROGRAM 'TRNDISP'
* AUTHOR JIM WEST
* 9/2/88

parameter cPort_type

local cType, cOrig_col, lProfit, nRow, nTot_Cost, nTot_Value, nValue
local nHand, nBrok, nMst, nKey, lBear_sl
memvar cTitle, cPort_type

#include 'inkey.ch'

private cTitle          // used in prnport

cType = if(cPort_type != nil, cPort_type, 'T')
lProfit = .t.                 // USED FOR PROFIT PRINT ON LIVE PORTFOLIOS

begin sequence
  
  select student
  clear screen
  @0,0 to 24,79
  @22,0 Say 'Ã'
  @22,1 say replicate('Ä', 78)
  @22,79 say '´'
  @22,17 say 'Â'
  @23,17 say '³'
  @24,17 say 'Á'
  @22,62 say 'Â'
  @23,62 say '³'
  @24,62 say 'Á'
  @23,6 say 'to return'
  @23,70 say 'to print'
  @23,26 say 'Any other key to continue'
  cOrig_col = setcolor(memvar->yell_black)
  @23,2 say 'Esc'
  @23,64 say 'Alt P'
  if cType = 'P'
    cTitle = 'REAL PORTFOLIO OF '
  ELSE
    cTitle = 'TWIN PORTFOLIO OF '
  ENDIF
  cTitle += trim(student->title) + ' ' + trim(student->name) + ' ' +;
      trim(student->surname)
  @1,((80-len(cTitle))/2) say cTitle
  setcolor(cOrig_col)
  @2,1 say '             NO OF        COST OF   AVERAGE   CURRENT     CURRENT        %   '
  @3,1 say 'SHARE       SHARES        HOLDING    PRICE     PRICE       VALUE       PROFIT'
  @4,1 say replicate('Ä',78)
  setcolor(memvar->disp_text)
  select portfol
  dbseek(student->std_code + Ctype)
  nRow = 5
  nTot_cost = 0
  nTot_value = 0
  while portfol->std_code = student->std_code .and. portfol->type = cType;
        .and. !eof()
    select share
    dbseek(portfol->share)
    @nRow,1 say portfol->share
    if portfol->qty != 0
      @nRow,11 say str(portfol->qty)
    else
      lProfit = .f.
    endif
    if portfol->cost_hold != 0
      @nRow,20 say str(portfol->cost_hold,13,2)
      nTot_cost += portfol->cost_hold
    else
      lProfit = .f.
    endif
    if portfol->cost_hold != 0 .and. portfol->qty != 0
      @nRow,34 say str(portfol->cost_hold/portfol->qty,9,2)
    endif
    @nRow,44 say str(share->price / 100,9,2)
    nValue = (portfol->qty * share->price / 100)
    nHand = handle(portfol->qty)
    nBrok = broker(nValue)
    nValue = nValue - nHand - nBrok
    if portfol->qty != 0
      @nRow,56 say str(nValue,10,2)
      nTot_value += nValue
    endif
    if portfol->cost_hold != 0 .and. portfol->qty != 0
      @nRow,71 say str((nValue / portfol->cost_hold * 100) - 100,7,2)
    endif
    nRow++
    select portfol
    dbskip()
    if nRow > 19
      @nRow + 1,1 say 'PORTFOLIO CONTINUES  -  PRESS A KEY TO CONTINUE'
      nKey = inkey(300)
      if nKey = K_ESC
        break
      endif
      if nKey = K_ALT_P
        prnport(cType)
        inkey(300)
        break
      endif
      @5,1 clear to 21,78
      nRow = 5
    endif
  enddo
  select bear
  lBear_sl = .F.
  dbseek(student->std_code + cType)
  while bear->std_code = student->std_code .and. !eof()
    if nRow > 15
      @nRow + 1,1 say 'PORTFOLIO CONTINUES  -  PRESS A KEY TO CONTINUE'
      nKey = inkey(300)
      if nKey = K_ESC
        break
      endif
      if nKey = K_ALT_P
        prnport(cType)
        inkey(300)
        break
      endif
      @2,1 clear to 21,78
      nRow = 2
    endif
    if !lBear_sl .or. nRow = 3
      lBear_sl = .t.
      setcolor(cOrig_col)
      @nRow+1,1 say 'BEAR SALES     QTY       COV HELD       SELL VAL    PRICE    CURR COST  % PROF'
      @nRow+2,1 say replicate('Ä',78)
      nRow += 3
      setcolor(memvar->disp_text)
    endif
    select share
    dbseek(bear->share)
    @nRow,1 say bear->share
    IF bear->qty != 0
      @nRow,11 say str(bear->qty)
    endif
    if bear->cov_hld != 0
      @nRow,19 say str(bear->cov_hld)
    endif
    if bear->sell_val != 0
      @nRow,34 say str(bear->sell_val)
    endif
    @nRow,49 say str(share->price / 100,9,2)
    nValue = (bear->qty * share->price / 100)
    nBrok = broker(nValue)
    nHand = handle(bear->qty)
    nMst = mst(nValue)
    nValue += nMst + nBrok + nHand
    if bear->qty != 0
      @nRow,60 say str(nValue,10,2)
      @nRow,71 say str(((bear->sell_val - nValue) / bear->sell_val * 100),7,2)
      nTot_cost += bear->cov_hld
      nTot_value += bear->cov_hld + bear->sell_val - nValue
    endif
    nRow++
    select bear
    dbskip()
  enddo
  setcolor(cOrig_col)
  @nRow,1 say replicate('Ä',78)
  nRow++
  @nRow,1 say 'SHARES         Cost'
  @nRow,40 say 'Current value'
  if cType = 'T'
    @nRow+1,1 say 'PORTFOLIO      Cash'
    @nRow+1,42 say 'Total value'
  else
    if lProfit
      @nRow+1,40 say 'Profit'
    endif
  endif
  setcolor(memvar->disp_text)
  @nRow,24 say str(nTot_cost,10,2)
  @nRow,56 say str(nTot_value,10,2)
  if cType = 'T'
    if nTot_cost != 0
      @nRow,71 say str((nTot_value / nTot_cost * 100) - 100,7,2)
    endif
    @nRow+1,24 say str(student->cash,10,2)
    @nRow+1,56 say str(nTot_value + student->cash,10,2)
    @nRow+1,71 say str(((nTot_value + student->cash) / student->initl_val * 100) - 100,7,2)
  else
    if lProfit
      @nRow,71 say str((nTot_value/nTot_cost*100)-100,7,2)
      @nRow+1,56 say str((nTot_value - nTot_cost),10,2)
    endif
  endif
  setcolor(cOrig_col)
  
  nKey = inkey(300)
  if nKey = K_ALT_P
    prnport(cType)
    inkey(0)
  endif
end sequence
return
* EOF

***********************************************************
static procedure prnport(in_type) // prints hardcopy of student portfolio
local nCost, nValue, nHand, nMst, nBrok, nVal, lProfit, cLine
nCost := nValue := 0
lProfit = .T.
openprn()
select portfol
dbseek(student->std_code + in_type)
while portfol->std_code = student->std_code .and. portfol->type = in_type;
      .and. !eof()
  if memvar->pline > 55
    prntitle(memvar->cTitle)
    pr_line('             NO OF        COST OF   AVERAGE   CURRENT     CURRENT        %   ')
    pr_line('SHARE       SHARES        HOLDING    PRICE     PRICE       VALUE       PROFIT')
    pr_line(replicate('-',78))
  endif
  select share
  dbseek(portfol->share)
  cLine = portfol->share + ' '
  if portfol->qty != 0
    cLine += str(portfol->qty)
  else
    lProfit = .f.
  endif
  if portfol->cost_hold != 0
    cLine += str(portfol->cost_hold)
    nCost += portfol->cost_hold
  else
    lProfit = .f.
  endif
  if portfol->qty != 0
    cLine += str(portfol->cost_hold/portfol->qty,9,2) + ' ' +;
        str(share->price / 100,9,2) + '   '
    nVal = (portfol->qty * share->price / 100)
    nHand = handle(portfol->qty)
    nBrok = broker(nVal)
    nVal = nVal - nHand - nBrok
    cLine += str(nVal,10,2) + '     '
    if portfol->cost_hold != 0
      cLine += str((nVal / portfol->cost_hold * 100) - 100,7,2)
    endif
    nValue += nVal
  endif
  pr_line(cLine)
  select portfol
  dbskip()
enddo
select bear
dbseek(student->std_code + in_type)
while bear->std_code = student->std_code .and. !eof()
  if memvar->pline > 55
    prntitle(memvar->cTitle)
  endif
  pr_line(' ')
  pr_line('BEAR SALES     QTY       COV HELD       SELL VAL    PRICE    CURR COST  % PROF')
  pr_line(replicate('-',78))
  select share
  dbseek(bear->share)
  cLine = bear->share + ' '
  if bear->qty != 0
    cLine += str(bear->qty) + str(bear->cov_hld)
    cLine += str(bear->sell_val) + str(share->price / 100,9,2) + '  '
    nVal = (bear->qty * share->price / 100)
    nBrok = broker(nVal)
    nHand = handle(bear->qty)
    nMst = mst(nVal)
    nVal += nMst + nBrok + nHand
    cLine += str(nVal,10,2) + ' ' +;
        str(((bear->sell_val - nVal) / bear->sell_val * 100),7,2)
    nCost += bear->cov_hld
    nValue += bear->cov_hld + bear->sell_val - nVal
  endif
  pr_line(cLine)
  select bear
  dbskip()
enddo
pr_line(replicate('-',78))
cLine = 'SHARES         Cost    ' + STR(nCost,10,2) + '      Current value   '
cLine += str(nValue,10,2) + '     '
if in_type = 'T'
  if nCost != 0
    cLine += str((nValue / nCost * 100) - 100,7,2)
  endif
  pr_line(cLine)
  cLine = 'PORTFOLIO      Cash    ' + str(student->cash,10,2) +;
      '        Total value   ' + str(nValue + student->cash,10,2) + '     ' +;
      str(((nValue + student->cash) / student->initl_val * 100) - 100,7,2)
  pr_line(cLine)
else
  pr_line(cLine)
  IF lProfit
    pr_line('                                                        Profit        ';
        + str((nValue-nCost),10,2))
  endif
endif
shutprn()
return
*EOF()
