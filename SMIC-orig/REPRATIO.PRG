*******************************************************************************
*
* REPRATIO - DISPLAYS REPS SALES RATIOS ON THE SCREEN OR TO A FILE FOR
*            USE WITH LOTUS
* JIM WEST - 09/90
* USES : REPS FILE & REPSTATS FILE
*
*******************************************************************************

*local MCOUNT, MCONT
local cRep, nKey, cOrig, nIndex, nMax, dTemp, cShort_rep, nCnt
local nChoice, lCont, cTitle, cFile
memvar aDates, aSales, aLeads, nAve_sl, nAve_ld, getlist, pLine, pPage
memvar aOption, aValid

#define NO_OPTIONS  3
#include 'inkey.ch'
simhead(memvar->pscr_title)

if !net_use('repstats', .f.,, 'repstats')
  close database
  return
endif

cRep = '  '
@9,0 say 'To get branch statistics just enter the branch code'
@5,0 say 'Enter the rep or branch code ' get cRep picture '!!'
read
@6,0 clear

if iscolor()
  cOrig = setcolor('GR+/N')
else
  cOrig = setcolor('W+/N')
endif
@7,25 say 'COLLATING DATA'
setcolor('w/n')

declare aDates[52]
declare aSales[52]
declare aLeads[52]
afill(aSales, 0)
afill(aLeads, 0)
nIndex = 52
nMax = 52

dTemp = date()
while dow(dTemp) != 6
  dTemp--
enddo

while nIndex > 0
  aDates[nIndex] = dTemp
  dTemp -= 7
  nIndex--
enddo

if cRep != '  '
  cShort_rep = trim(cRep)
  dbseek(cShort_rep)
  while repstats->rep = cShort_rep .and. !eof()
    for nIndex = 2 to nMax
      if repstats->end_dt > aDates[nIndex-1] .and.;
            repstats->end_dt <= aDates[nIndex]
        aSales[nIndex] += repstats->sales
        if substr(cRep,2,1) != ' '
          aLeads[nIndex] += repstats->good_leads
        else
          aLeads[nIndex] += repstats->gl_rcvd
        endif
      endif
    next
    dbskip()
  enddo
else
  while !eof()
    for nIndex = 2 to nMax
      if repstats->end_dt > aDates[nIndex-1] .and.;
            repstats->end_dt <= aDates[nIndex]
        aSales[nIndex] += repstats->sales
        if substr(cRep,2,1) != ' '
          aLeads[nIndex] += repstats->good_leads
        else
          aLeads[nIndex] += repstats->gl_rcvd
        endif
      endif
    next
    dbskip()
  enddo
endif

nCnt = nMax
while nMax > 0 .and. aSales[1] = 0 .and. aLeads[1] = 0
  adel(aDates, 1)
  adel(aSales, 1)
  adel(aLeads, 1)
  nMax--
enddo

declare aOption[NO_OPTIONS]
aOption[1] = 'Screen'
aOption[2] = 'Printer'
aOption[3] = 'Disk file'
declare aValid[NO_OPTIONS]
afill(aValid, .T.)

nChoice = 1
while nChoice != 0
  simhead(memvar->pscr_title)
  @5,20 say 'Sales ratios for ' + cRep + ' available'
  setcolor('W+/N,N/W,,,W/N')
  nChoice = achoice(12, 25, 18, 55, aOption, aValid, 'esc_udf')
  setcolor(cOrig)
  
  do case
    case nChoice = 1
      * SCREEN DISPLAY
      @2,0 clear
      @3,34 say 'Figures for ' + cRep
      if substr(cRep,2,1) != ' '
        @4,0 say '  Date      Sales     Leads allocated       Leads/Sales   Sl/Ld 5Week MA'
      else
        @4,0 say '  Date      Sales      Leads received       Leads/Sales   Sl/Ld 5Week MA'
      endif
      nCnt = nMax
      lCont = .T.
      while lCont
        ratiodisp(nCnt)
        nKey = inkey(300)
        do case
          case nKey = K_UP
            if nCnt < nMax
              nCnt++
            endif
          case nKey = K_DOWN
            if nCnt > 1
              nCnt--
            endif
          case nKey = K_HOME
            if nMax > 18
              nCnt = 18
            else
              nCnt = nMax
            endif
          case nKey = K_END
            nCnt = nMax
          case nKey = K_PGDN
            if nMax > 18
              nCnt -= 18
              if nCnt < 18
                nCnt = 18
              endif
            else
              nCnt = 18
            endif
          CASE nKey = K_PGUP
            nCnt += 18
            if nCnt > nMax
              nCnt = nMax
            endif
          otherwise
            lCont = .f.
        endcase
      enddo
    case nChoice = 2
      * PRINTER
      pLine = 1
      pPage = 0
      cTitle = 'SALES RATIOS FOR ' + cRep
      set print on
      set console off
      prntitle(cTitle, 'N')
      if substr(cRep,2,1) != ' '
        ? '  Date      Sales     Leads allocated       Leads/Sales   Sl/Ld 5Week MA'
      else
        ? '  Date      Sales      Leads received       Leads/Sales   Sl/Ld 5Week MA'
      endif
      for nIndex = 1 to nMax
        ? dtoc(aDates[nIndex]) + '   ' + str(aSales[nIndex],6,0) +;
            '              ' + str(aLeads[nIndex],6,0) + '          '
        if aSales[nIndex] != 0
          ?? str((aLeads[nIndex]/aSales[nIndex]),8,2)
        else
          ?? 'NO SALES'
        endif
        if nIndex > 4
          nAve_sl = 0
          nAve_ld = 0
          for nCnt = nIndex - 4 to nIndex
            nAve_sl += aSales[nCnt]
            nAve_ld += aLeads[nCnt]
          next
          if nAve_sl != 0
            ?? '         ' +  str((nAve_ld/nAve_sl),8,2)
          endif
        endif
      next
      shutprn()
    case nChoice = 3
      * DISK FILE
      cFile = cRep + SPACE(6)
      @18,20 SAY 'Enter file name ' get cFile picture '!!!!!!!!'
      read
      if cFile != space(8)
        cFile = trim(cFile) + '.PRN'
        set alternate to &cFile
        set alternate on
        set console off
        ?? "'" + memvar->cCo_name + " - sales ratios for " + cRep + "'"
        if substr(cRep,2,1) != ' '
          ? "'  Week      Sales     Leads allocated       Leads/Sales   Sl/Ld 5Week MA'"
        else
          ? "'  Date      Sales      Leads received       Leads/Sales   Sl/Ld 5Week MA'"
        endif
        ? ' '
        for nIndex = 1 to nMax
          ? str(nIndex,4,0) + '   ' + str(aSales[nIndex],6,0) +;
              '              ' + str(aLeads[nIndex],6,0) + '          '
          if aSales[nIndex] != 0
            ?? str((aLeads[nIndex]/aSales[nIndex]),8,2)
          else
            ?? str((99),8,2)
          endif
          * RECIPROCAL
          if aSales[nIndex] != 0 .and. aLeads[nIndex] != 0
            ?? str(1/(aLeads[nIndex]/aSales[nIndex]),8,4)
          else
            ?? str((0),8,4)
          endif
          if nIndex > 4
            nAve_sl = 0
            nAve_ld = 0
            for nCnt = nIndex - 4 to nIndex
              nAve_sl += aSales[nCnt]
              nAve_ld += aLeads[nCnt]
            next
            if nAve_sl != 0
              ?? '         ' +  str((nAve_ld/nAve_sl),8,2)
              * RECIPROCAL
              ?? '         ' +  str((nAve_sl/nAve_ld),8,4)
            endif
          endif
        next
        set alternate off
        close alternate
        set console on
      endif
  endcase
  close databases
enddo
return

* eof()

*******************************************************************************
*
* RATIO DISP DISPLAYS RATIOS ON THE SCREEN AT A CERTAIN INDEX NO
*
*******************************************************************************
static procedure ratiodisp ( nIndex )

local nStart, nEnd, nCnt, nCount
memvar aDates, aSales, aLeads, nAve_sl, nAve_ld
@5,0 clear
nEnd = nIndex
nStart = nIndex - 18
IF nStart < 1
  nStart = 1
ENDIF
FOR nCnt = nStart TO nEnd
  @5+nCnt-nStart,0 SAY DTOC(aDates[nCnt])
  @5+nCnt-nStart,10 SAY STR(aSales[nCnt],6,0)
  @5+nCnt-nStart,31 SAY STR(aLeads[nCnt],6,0)
  IF aSales[nCnt] != 0
    @5+nCnt-nStart,47 SAY STR((aLeads[nCnt]/aSales[nCnt]),8,2)
  ELSE
    @5+nCnt-nStart,47 SAY 'NO SALES'
  ENDIF
  IF nCnt > 4
    nAve_sl = 0
    nAve_ld = 0
    FOR nCount = nCnt - 4 TO nCnt
      nAve_sl = nAve_sl + aSales[nCount]
      nAve_ld = nAve_ld + aLeads[nCount]
    NEXT
    IF nAve_sl != 0
      @5+nCnt-nStart,64 SAY STR((nAve_ld/nAve_sl),8,2)
    ENDIF
  ENDIF
NEXT
RETURN
* EOF()
