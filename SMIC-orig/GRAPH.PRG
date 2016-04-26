*******************************************************************************
*
* Graph
*
*

local nKey

#include 'defcolor.ch'
#include 'defprint.ch'

memvar force_prfile
memvar force_bw
memvar nTime_out
memvar cShare

public force_bw := force_prfile := .f.

#include "colour.ch"
#include "printer.ch"
#include "inkey.ch"
#include "graph.ch"

set date british
set deleted on

#include "smic.ch"

cShare = space(9)
nKey = 0
clear screen

if empty(et_use_dbf('SHR_DATA'))
  quit
endif

if empty(et_use_dbf('SHARE'))
  quit
endif

while nKey != K_ESC
  findshr()
  cShare = share->share

  price_graph('Price graph')

  nKey = inkey(0)
enddo

dbcloseall()

quit

*eof()

*******************************************************************************
procedure price_graph(cTitle)
local dStart, dEnd              // Start and end dates for graph
local nMax := -9999999999       // largest graph point
local nMin := 9999999999        // smallest graph point
local nYinc                     // increments in Y axis
local nYoffset                  // Offset from X axis (of Y values)
local nLast                     // Last weight encountered
local nResult                   // result of graphical functions
local nXdivs                    // Number of divisions on X axis
local nYdivs                    // Number of divisions on Y axis
local nXinc                     // Dist between points on x axis
local dTemp                     // Temp date variable
local nXpts                     // No of points in X axis
local nXlen                     // adjusted length of X axis
local aAverage                  // Array for moving averages
local nTotal                    // Total for calculating moving averages
local nCnt                      // counter

memvar nYmax, nYmin             // max and min values on Y axis
memvar dXmax                    // max value on X axis
nYmax := nYmin := 0
dXmax := ctod('  /  /  ')

set console off

nMax = 0
nMin = 9999999999

select shr_data
dbseek(share->shr_cd)
dStart = dta_date()

while shr_data->shr_cd = share->shr_cd .and. !eof()
  if dta_price() < nMin
    nMin = dta_price()
  endif
  if dta_price() > nMax
    nMax = dta_price()
  endif
  dbskip()
enddo

findy_max(nMax, nMin, @nYmax, @nYmin)   // Max & min values for graph labels
*                                     // may be different that actual max & min
nYinc = Y_LEN / (nYmax - nYmin)
nYoffset = nYinc * (nMin - nYmin)       // Diff between min and lable min

findx_max(dEnd, dStart, @dXmax)   // Max & min values for graph labels

nXpts = int(dXmax - dStart)
nXinc = int(X_LEN / (dXmax - dStart))
nXlen = nXinc * nXpts                   // adjusted length

nResult = datareset()

dTemp = dStart
while dTemp < date()
  while 




dbseek(share->shr_code)
i2bin(shr_date(dTran))

while empty(runs->morn_wt)
  dbskip()
enddo
dTemp = runs->sess_dt
while dTemp <= dEnd
  if dbseek(memvar->cRun_code + dtos(dTemp)) .and. !empty(runs->morn_wt)
    nLast = runs->morn_wt
  endif
  nResult = datastore(((nLast - nMin) * nYinc) + nYoffset, 0, 0, 0)
  dTemp++
enddo

if param->draw = 'Y'
  sethires(0)
  saystring(675, 920, 0, 8, 14, cTitle)
  saystring(0, 600, 0, 1, 7, 'Weight')
endif

nYdivs = lab_y_axis(nYmax, nYmin)
nXdivs = lab_x_axis(dXmax, dStart, nXlen)
nResult = xyaxes(X_ORG, Y_ORG, nXlen, Y_LEN, nXdivs, nYdivs, 0, 3)

nResult = xygraph(X_ORG, Y_ORG, nXinc, 0, 14)

nResult = datareset()
aAverage := {}
dbseek(memvar->cRun_code + dtos(dStart), .t.)
dTemp = runs->sess_dt
while dTemp <= dEnd
  if dbseek(memvar->cRun_code + dtos(dTemp)) .and. !empty(runs->morn_wt)
    nLast = runs->morn_wt
  endif
  aadd(aAverage, nLast)
  if len(aAverage) = param->wt_mv_ave
    nTotal = 0
    for nCnt = 1 to param->wt_mv_ave
      nTotal += aAverage[nCnt]
    next
    nTotal /= param->wt_mv_ave
    nResult = datastore(((nTotal - nMin) * nYinc) + nYoffset, 10, 0, 0)
    aremove(aAverage, 1)
  endif
  dTemp++
enddo

nResult = xygraph(X_ORG + (nXinc * param->wt_mv_ave), Y_ORG, nXinc, 2, 6)
inkey(0)
settext()
set console on
return

*******************************************************************************
procedure findy_max ( nIn_max, nIn_Min, nY_max, nY_min )
local nMax, nRange, nMin
nRange = nIn_Max - nIn_Min
nMin = int(nIn_min)                     // integer of Min
nMax = nIn_max
if nIn_max - int(nIn_max) != 0          // round up if not an integer
  nMax := int(nIn_Max + 1)
endif
nY_max = nMax                           // set ruturn values
nY_min = nMin                           // passed back by reference
if nRange > Y2_SPLIT
  while (nY_max % Y2_DIVS) != 0          // round up
    nY_max++
  enddo
  while (nY_min % Y2_DIVS) != 0           // round down
    nY_min--
  enddo
elseif nRange > Y1_SPLIT
  while (nY_max % Y1_DIVS) != 0            // round up
    nY_max++
  enddo
  while (nY_min % Y1_DIVS) != 0            // round down
    nY_min--
  enddo
endif
return

*******************************************************************************
procedure findx_max ( dIn_max, dIn_Min, dX_max)
local nRange, nMonth
nRange = dIn_Max - dIn_Min
dX_max = dIn_max                                 // set return values
if nRange > X2_SPLIT                             // months
  while month(dX_max) = month(dIn_max)           // round up
    dX_max++
  enddo
elseif nRange > X1_SPLIT                        // weeks
  while dow(dX_max) != dow(dIn_min) - 1         // round up
    dX_max++
  enddo
endif
return

*******************************************************************************
function lab_y_axis ( nMax, nMin )
local cStr := '', nStep := 1, nLen := 2, nCnt, nDivs, nRange, nYinc
nRange = nMax - nMin
if nRange < 0
  return(0)
endif
if nRange > Y2_SPLIT
  nStep = Y2_DIVS
  nLen = 4
elseif nRange > Y1_SPLIT
  nStep = Y1_DIVS
  nLen = 3
endif
nCnt = nMin
while nCnt <= nMax
  cStr += str(nCnt,nLen)
  nCnt += nStep
enddo
nCnt = len(cStr) / nLen
nCnt--
nYinc = round((Y_LEN / nCnt), 0)
labely(X_ORG-75, Y_ORG, nYinc, nLen, 1, 0+64, 7, cStr)

return(nCnt)

*******************************************************************************
function lab_x_axis(dMax, dStart, nXlen)
local cLabel := '', nCnt, nX_inc, dTemp, nMonth
nX_inc = nXlen / (dMax - dStart)
dTemp = dStart
do case
  case (dMax - dStart) > X2_SPLIT            // monthly basis
    while dTemp < dMax + 1
      cLabel += substr(cmonth(dTemp),1,3)
      nMonth = month(dTemp)
      while month(dTemp) = nMonth
        dTemp++
      enddo
    enddo
    nCnt = len(cLabel) / 3
    nCnt--
    nX_inc = round((nXlen / nCnt), 0)
    labelx(X_ORG, Y_ORG-50, nX_inc, 3, 0, 0, 7, cLabel)
    saystring(675, 0, 0, 8, 7, 'Time in months')
  case (dMax - dStart) > X1_SPLIT             // weekly basis
    while dTemp < dMax + 1
      cLabel += str(week(dTemp),2)
      dTemp += 7
    enddo
    nCnt = len(cLabel) / 2
    nCnt--
    nX_inc = round((nXlen / nCnt), 0)
    labelx(X_ORG, Y_ORG-50, nX_inc, 2, 1, 1, 7, cLabel)
    saystring(675, 0, 0, 8, 7, 'Time in weeks')
  otherwise                             // daily basis
    while dTemp < dMax + 1
      cLabel += substr(cDow(dTemp),1,3)
      dTemp++
    enddo
    labelx(X_ORG, Y_ORG-50, nX_inc, 3, 1, 1, 7, cLabel)
endcase
return(nCnt)














/*
local aGraphs := {'Weight',;
    'Points',;
    'Average weekly pts',;
    'Pulse',;
    'Return'}, nGraphs := 1, cScr

#include 'graph.ch'
#include 'inkey.ch'
showtime()

while nGraphs != 0 .and. nGraphs != len(aGraphs)
  save screen to cScr
  nGraphs = get_arr(aGraphs,3,43,,.t.,,nGraphs)
  do case
    case nGraphs = 1
      weight_graph('Morning weight')
    case nGraphs = 2
      do pts_grf
    case nGraphs = 3
      av_wk_pt_graph('Average Weekly Points')
    case nGraphs = 4
      do pulse_gr
  endcase
  restore screen from cScr
enddo
showtime(1,2,,"BG/B")
return

*******************************************************************************
procedure av_wk_pt_graph(cTitle)
local nMin, nMax, nPts, nFactor, nXinc, nYinc, r, nXdivs, nYdivs, cYlab
local nCnt, cXlab, dStart, nStep, dEnd, nLast, dTemp, nTrn
local aValues := {}

set console off

nMax = 0
nMin = 0

dStart = date() - 365
dEnd = date()

select runs
dbseek(memvar->cRun_code + dtos(dStart), .t.)
while empty(runs->cooper_pt)
  dbskip()
enddo
if memvar->cRun_code != runs->run_code .or. eof()
  return
endif
dStart = runs->sess_dt
dTemp = dStart
while dow(dTemp) != 1
  dTemp--
enddo
while dTemp < dEnd
  dTemp += 7
  dbseek(memvar->cRun_code + dtos(dTemp-7), .t.)
  nPts = 0
  while runs->run_code = memvar->cRun_code .and. runs->sess_dt < dTemp;
        .and. !eof()
    nPts += runs->cooper_pt
    dbskip()
    if runs->sess_dt > dEnd
      exit
    endif
  enddo
  nTrn = 0
  dbseek(runners->train_schd + dtos(dTemp-7), .t.)
  while runs->run_code = runners->train_schd .and. runs->sess_dt < dTemp;
        .and. !eof()
    nTrn += runs->cooper_pt
    dbskip()
    if runs->sess_dt > dEnd
      exit
    endif
  enddo
  aadd(aValues, {nPts, nTrn})
  if nPts > nMax
    nMax = nPts
  endif
  if nTrn > nMax
    nMax = nTrn
  endif
enddo

nMax = find_max(nMax, 0)

nFactor = Y_LEN / (nMax - nMin)
nYdivs = int(nMax - nMin)
nXdivs = len(aValues)-1
nXinc = X_LEN / nXdivs
nYinc = Y_LEN / nYdivs

r = datareset()

dTemp = dStart
cXlab = ''
for nCnt = 1 to len(aValues)
  r = datastore(aValues[nCnt, 1] * nFactor, 0, 0, 0)
  cXlab += str(week(dTemp),2)
  dTemp += 7
next

r = sethires(0)
r = saystring(675, 920, 0, 8, 7, cTitle)

nYdivs = lab_y_axis(nMax, 0)
labelx(X_ORG, Y_ORG-50, nXinc, 2, 1, 1+8, 7, cXlab)
r = xyaxes(X_ORG, Y_ORG, X_LEN, Y_LEN, nXdivs, nYdivs, 0, 3)
r = xygraph(X_ORG, Y_ORG, nXinc, 0, 7)

r = datareset()

for nCnt = 1 to len(aValues)
  r = datastore(aValues[nCnt, 2] * nFactor, 5, 0, 0)
next
r = xygraph(X_ORG, Y_ORG, nXinc, 0, 7)

inkey(0)

settext()
set console on
return

*******************************************************************************
procedure draw_x_dt_axis(dStart, dEnd, nX_orig, nY_orig, nX_len)
local cLabel := '', nCnt, nX_inc, dTemp
nX_inc = nX_len / (dEnd - dStart)
dTemp = dStart
do case
  case (dEnd - dStart) > 200            // monthly basis
    while dTemp < dEnd + 1
      cLabel += substr(cmonth(dTemp),1,3)
      dTemp = addmonth(dTemp)
    enddo
    nX_Inc *= 30
    labelx(nX_orig, nY_orig-50, nX_inc, 3, 1, 1, 7, cLabel)
  case (dEnd - dStart) > 30             // weekly basis
    while dTemp < dEnd + 7
      cLabel += str(week(dTemp),2)
      dTemp += 7
    enddo
    nX_inc = nX_len / (dEnd - 7 - dStart)
    nX_Inc *= 7
    labelx(nX_orig, nY_orig-50, nX_inc, 2, 1, 1, 7, cLabel)
  otherwise                             // daily basis
    while dTemp < dEnd + 1
      cLabel += substr(cDow(dTemp),1,3)
      dTemp++
    enddo
    labelx(nX_orig, nY_orig-50, nX_inc, 3, 1, 1, 7, cLabel)
endcase
return

*******************************************************************************
procedure vo2_graph(cTitle)
local nMin, nMax, nPts, nFactor, nXinc, nYinc, r, nXdivs, nYdivs, cYlab
local nCnt, cXlab, dStart, nStep, dEnd, nLast, dTemp, nXlen
local nO2_cons, nVO2_perc, nVo2_max
local nO2, nVo2, nGroup, nMode
memvar getlist

set console off

nXlen = X_LEN + 50
nMax = 0
nPts = 0

dStart = date() - 365
dEnd = date()

nPts = 0
select runs
dbseek(memvar->cRun_code + dtos(dStart), .t.)
while empty(runs->cooper_pt)
  dbskip()
enddo
if memvar->cRun_code != runs->run_code
  return
endif
dStart = runs->sess_dt
while memvar->cRun_code = runs->run_code .and. !eof();
      .and. runs->sess_dt <= dEnd
  if !empty(runs->cooper_pt)
    nO2_cons = O2_cons(runs->distance, runs->time)
    nVO2_perc = VO2_perc(runs->time)
    nVo2_max = VO2_max(nO2_cons, nVO2_perc)
    if nVO2_max > nMax
      nMax = nVO2_max
    endif
  endif
  dbskip()
enddo

nMin = 0

nYdivs = int(nMax - nMin)
if nMax - nMin > nYdivs
  nYdivs++
endif
nFactor = Y_LEN / nYdivs
nXdivs = dEnd - dStart
nXinc = int(nXlen / nXdivs)
nYinc = Y_LEN / nYdivs
nXlen = nXinc * nXdivs

cYlab = ''
for nCnt = nMin to nMax
  cYlab += str(nCnt,3)
next

r = datareset()

dbseek(memvar->cRun_code + dtos(dStart), .t.)
dTemp = dStart
while dTemp <= dEnd
  nO2 = 0
  nVO2 = 0
  dbseek(memvar->cRun_code + dtos(dTemp))
  while runs->run_code = memvar->cRun_code .and. runs->sess_dt = dTemp;
        .and. !eof()
    nO2_cons = O2_cons(runs->distance, runs->time)
    nVO2_perc = VO2_perc(runs->time)
    nVo2_max = VO2_max(nO2_cons, nVO2_perc)
    nO2 = if(nO2_cons > nO2, nO2_cons, nO2)
    nVO2 = if(nVO2_max > nVO2, nVO2_max, nVO2)
    dbskip()
  enddo
  r = datastore(nO2 * nFactor, 10, 0, 4)
  r = datastore(nVO2 * nFactor, 4, 0, 5)
  dTemp++
enddo

wopen(7,10,15,70)
wbox(0)
nGroup = 2
nMode = 0
@0,0 say 'Inc   ' get nXinc
@1,0 say 'Mode  ' get nMode picture '99999999.99999'
@2,0 say 'Group ' get nGroup picture '99999999.99999'
@3,0 say str(X_LEN)
@3,30 say dtoc(dStart)
@4,0 say str(nXdivs)
@4,30 say dtoc(dEnd)
read
wclose()

r = sethires(0)
r = saystring(675, 920, 0, 8, 7, cTitle)

r = xyaxes(X_ORG, Y_ORG, nXlen, Y_LEN, nXdivs, nYdivs, 0, 3)

r = labely(X_ORG-75, Y_ORG-25, nYinc, 3, 1, 0, 7, cYlab)
draw_x_dt_axis(dStart, dEnd, X_ORG, Y_ORG, nXlen)
r = bargraph(X_ORG, Y_ORG, nXinc, nMode, nGroup)

inkey(0)

settext()
set console on
return

*******************************************************************************
function find_max ( nIn_max, nIn_Min )
* still needs to return min
local nMax, nRange, nMin
nMin = int(nIn_min)                     // integer of Min
nMax := int(nIn_Max + 1) - nMin         // difference of max rounded up & min
if nMax > 200
  while (nMax % 50) != 0                // round up to nearest 50
    nMax++
  enddo
elseif nMax > 20
  while (nMax % 10) != 0                // round up to nearest 10
    nMax++
  enddo
endif
return(nMax + nMin)

*/
