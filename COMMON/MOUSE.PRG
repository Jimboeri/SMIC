#include 'mouse.ch'
#include 'inkey.ch'
#include 'setcurs.ch'

#define MY_HSEP         "ÄÂÄ"
#define MY_CSEP         " ³ "
#define MY_FSEP         "ÄÁÄ"

***********************************************************
*  MOUSENEW - Create an array holding all mouse data
*
*  MI_Y           1
*  MI_X           2
*  MI_BUTTON      3
*  MI_VISIBLE     4
*  MI_CHAR        5
*  MI_COLOR       6
*  MI_DELAY       7
*  MI_CLICKS      8
*  MI_ASCII       9
*  MI_CARGO      10
*  MI_HOTSPOT    11

function mousenew()
local oM
oM := {;
    24,;  // Y coord
79,;      // X coord
0,;       // Button
.f.,;     // Curs visible
219,;     // curs ascii char
'+GR/N',; // curs col
0.2,;     // time to wait
0,;       // # clicks
0,;       // inkey() val
nil,;     // cargo
{}}       // hot spots

return(oM)

***********************************************************
function m_init(oM)
local cShape, cColor

_is_mouse := (m_Func0() = -1)
if _is_mouse
  oM[MI_VISIBLE] := .f.
  cColor := oM[MI_COLOR]
  *  M_CursType(oM, cColor)
endif
return(nil)

***********************************************************
function m_info(oM)
local cChar, cTemp
if _is_mouse
  oM[MI_Y] := (m_Func3Y() / 8)
  oM[MI_X] := (m_Func3X() / 8)
  oM[MI_BUTTON] := m_Func3B()
endif
return(nil)

***********************************************************
function m_goto(oM)
local nY, nX
if _is_mouse
  nY := oM[MI_Y]
  nX := oM[MI_X]
  m_func4(((nY % 25) * 8), ((nX % 80) * 8))
endif
return(nil)

***********************************************************
function m_show(oM)
return( M_Cursor(oM, .t.))

***********************************************************
function m_hide(oM)
return( M_Cursor(oM, .f.))

***********************************************************
static function M_Cursor(oM, lShow)
local lCursor
if _is_mouse
  lCursor := oM[MI_VISIBLE]
  if lShow
    if !lCursor
      oM[MI_VISIBLE] := .t.
      m_func1()
    endif
  else
    if lCursor
      oM[MI_VISIBLE] := .f.
      m_func2()
    endif
  endif
endif
return(nil)

***********************************************************
* Check if button is continually pressed
function m_buttonhold(nButton)
return (m_func3B() = nButton)

***********************************************************
function M_CursType(oM, cColor)
if _Is_Mouse
  if cColor = nil
    cColor := strtran(setcolor(), ',')
    oM[MI_COLOR] := cColor
  endif
  
  cColor := asc(Color2Bin(cColor))
  nShape := (cColor * 256) + oM[MI_CHAR]
  m_Func10(nShape)
endif

return (nil)

*f*****************************************************************************
function mget_arr(aIn_arr, nIn_top, nIn_left, cIn_color, lEscape, cHeading,;
    nIn_Start, alVal_arr, cUsr_func, nTime_out)

local column, n, bAction, nCursSave, nKey
LOCAL cSECT, cOrig_col, nWdt, nRet, cHead, alVal, lSave_visible

private nTOP, nLEFT, nBOTT, nRIGHT, nArr_ntx := 1, aArr, mPick, bBlock
private lScroll := .f., nBar_move, nDisp, lMore, nSec, nTime_last

aArr := aIn_arr

if len(aIn_arr) = 0
  return(0)
endif

nWdt = arr_wdth(AiN_ARR)

cHead = if(valtype(cHeading) = 'C', cHeading, 'Select option')
cHead = trim(ltrim(cHead))
nWdt = if(len(cHead) > nWdt, len(cHead), nWdt)

if len(cHead) < nWdt
  cHead = space( int((nWdt-len(Chead)) /2) ) + cHead
endif

if nIn_left != nil
  nLeft = nIn_left - 1
else
  nLeft = int((80 - nWdt) /2) - 1
endif
nLeft = int(nLeft)

nRight = nLeft + 2 + nWdt

if nIn_top = nil
  if len(aIn_arr) > 16
    nTop = 5
    lScroll := .t.
  else
    nTop = 12 - int(len(aIn_arr)/2)
  endif
else
  nTop = nIn_top - 1
endif

nBott = nTop + 1 + len(aIn_arr)

if nBott > 23
  nBott = 23
endif

nBar_move = nBott - nTop - 3
nDisp = nTop + 2

if cIn_color != nil
  cOrig_col = setcolor(cIn_color)
else
  cOrig_col = setcolor()
endif

lEsc = if((lEscape = NIL .or. valtype(lEscape) != 'L'), .f., lEscape)

nStart = if(valtype(nIn_start) = 'N', nIn_start, 1)

alVal = if(alVal_arr = NIL, .t., alVal_arr)

nSec = if(valtype(nTime_out) = 'N', nTime_out, 999999999)
nTime_last = seconds()

if cUsr_func != nil
  cBlock = "{| nElement, nRow, nKey_val | " + cUsr_func;
      + " (nElement, nRow, nKey_val)}"
  bBlock := &(cBlock)
endif

if lScroll
  cSect = draw_box(nTop-2, nLeft, nBott, nRight+2)
  @nTop-2,nLeft say ''
  @nTop-2,nRight say 'Â'
  @nBott,nRight say 'Á'
  for nCnt = nTop-1 to nBott-1
    @nCnt, nRight say '³'
  next
  for nCnt = nTop+3 to nBott-2
    @nCnt, nRight+1 say '°'
  next
  @nTop+1,nRight+1 say ''
  @nBott-1,nRight+1 say ''
  @nTop,nRight say '´'
else
  cSect = DRAW_BOX(nTOP-2, nLEFT, nBOTT, nRIGHT)
  @nTop, nLeft say'Ã'
  @nTop, nLeft+1 say replicate('Ä', nRight-nLeft-1)
  @nTop, nRight say'´'
endif

lSave_visible := oMouse[MI_VISIBLE]
if !lSave_visible
  m_show(oMouse)
endif

/* make new browse object */
mPick := TBrowseDB(nTop-1, nLeft+1, nBott, nRight-1)

nCursSave := SetCursor(0)

/* default heading and column separators */
mPick:headSep := MY_HSEP
mPick:colSep := MY_CSEP
mPick:footSep := MY_FSEP

/* add custom 'skip_curr' (to handle append mode) */
mPick:skipBlock := {|x| move_arr(x)}

/* add a column for display */
column := TBColumnNew( cHead, {|| aArr[nArr_ntx]} )
column:width := nWdt
mPick:addColumn(column)

for nCnt = 1 to nStart-1
  mPick:down()
next

lMore := .t.
nRet = 0
while (lMore)
  
  /* don't allow cursor to move out of currency code column */
  mPick:colPos := 1
  
  /* stabilize the display */
  m_info(oMouse)
  lM_Curs = oMouse[MI_VISIBLE]
  m_hide(oMouse)
  if lScroll
    @nDisp, nRight+1 say '°'
  endif
  while ( !mPick:stabilize() )
    nKey := InKey()
    if ( nKey != 0 )
      exit                    /* (abort if a key is waiting) */
    endif
  enddo
  if lM_Curs
    m_show(oMouse)
  endif
  
  if ( mPick:stable )
    /* display is stable */
    if ( mPick:hitTop .or. mPick:hitBottom )
      Tone(125, 0)
    endif
    
    // display scroll bar
    if lScroll
      nPerc = int(nArr_ntx / len(aIn_arr) * nBar_move)
      nPerc = if(nPerc = nBar_move, nBar_move-1, nPerc)
      nDisp = nTop+2 + nPerc
      @nDisp, nRight+1 say '²'
    endif
    
    /* everything's done; just wait for a key */
    mArr_act()
    if oMouse[MI_CLICKS] = 0
      nKey := oMouse[MI_ASCII]
    else
      nKey = 0
    endif
  endif
  
  /* process key */
  do case
    case ( nKey == K_F1 )               // if help is needed
      help(procname(), procline(), cHeading)
      
    case (bAction := SETKEY(nKey)) != NIL
      EVAL(bAction, Procname(), Procline(), readvar())
      
    case ( nKey == K_DOWN )
      mPick:down()
      
    case ( nKey == K_UP )
      mPick:up()
      
    case ( nKey == K_PGDN )
      mPick:pageDown()
      
    case ( nKey == K_PGUP )
      mPick:pageUp()
      
    case ( nKey == K_CTRL_PGUP ) .or. ( nKey == K_HOME )
      mPick:gobottom()
      
    case ( nKey == K_CTRL_PGDN ) .or. ( nKey == K_END )
      mPick:gotop()
      
    case ( nKey == K_ESC ) .and. lEsc
      lMore := .f.                              // exit proc
      nRet = 0
      
    case ( nKey == K_RETURN )
      lMore := .f.                              // exit proc
      nRet = nArr_ntx
      
    otherwise
      if bBlock != nil
        nbVal = eval(bBlock, nArr_ntx, mPick:rowpos, nKey)
        do case
          case nBval = 0
            lMore := .f.                              // exit proc
            nRet = 0                                  // no selection
          case nBval = 1
            lMore := .f.                              // exit proc
            nRet = nArr_ntx                           // select value
        endcase
      else
        cChar = upper(chr(nKey))
        nFirst = 0
        if nArr_ntx < len(aIn_arr)
          nFirst = aScan(aIn_arr, cChar, nArr_ntx+1)
        endif
        if nFirst = 0
          nFirst = aScan(aIn_arr, cChar, 1, nArr_ntx-1)
        endif
        if nFirst != 0
          if nFirst < nArr_ntx
            for nCnt = narr_ntx-1 to nFirst step -1
              mPick:up()
            next
          else
            for nCnt = narr_ntx+1 to nFirst
              mPick:down()
            next
          endif
        endif
      endif
  endcase
  if nTime_last + nSec < seconds()
    exit
    nRet = 0
  endif
enddo

if !lSave_visible
  m_hide(oMouse)
endif
setcolor(cOrig_col)
SetCursor(nCursSave)
restsector(cSect)
return(nRet)
* eof mget_arr

****
*       skip_curr()
*

func move_arr(n)
local i

i := 0
if ( len(aArr) != 0 )
  if ( n > 0)
    while ( i < n )
      nArr_ntx++
      if ( nArr_ntx > len(aArr))
        nArr_ntx--
        exit
      endif
      i++
    enddo
    
  elseif ( n < 0 )
    while ( i > n )
      nArr_ntx--
      if ( nArr_ntx < 1)
        nArr_ntx++
        exit
      endif
      i--
    enddo
  endif
endif
return (i)

*f*********************************************************
procedure marr_act
local nY, nX, nM_Y, nM_x, nButton, nOldButton, nTime, nASCII, cColorsave
nY = nM_Y
nX = nM_X
if oMouse[MI_CLICKS] = 2       // stabilize after double click
  oMouse[MI_CLICKS] = 0
  oMouse[MI_ASCII] = K_ENTER    // process enter key
  return
endif
oMouse[MI_CLICKS] = 0
while .t.
  if nTime_last + nSec < seconds()
    exit
  endif
  if keypressed()                     // keyboard used
    oMouse[MI_ASCII] = inkey()
    nTime_last = seconds()
    exit
  else
    oMouse[MI_ASCII] = 0
    // display time
    cColorsave = setcolor(yell_blue)
    @1,2 say time()
    setcolor(cColorsave)
    
    m_info(oMouse)
    nButton = oMouse[MI_BUTTON]
    
    if nButton != 0
      nTime_last = seconds()
      if (oMouse[MI_Y] >= nTop+1) .and.;
            (oMouse[MI_Y] <= nBott-1) .and. (oMouse[MI_X] >= nLeft+1) .and.;
            (oMouse[MI_X] <= nRight-1)
        
        if oMouse[MI_CLICKS] = 0
          while oMouse[MI_BUTTON] = nButton
            m_info(oMouse)
          enddo
          nY = oMouse[MI_Y]
          nX = oMouse[MI_X]
          nTime = seconds()
          oMouse[MI_CLICKS] = 1
        endif
        
        if oMouse[MI_CLICKS] = 1
          while stopwatch(nTime, seconds()) < oMouse[MI_DELAY]
            m_info(oMouse)
            if oMouse[MI_BUTTON] = nButton .and. oMouse[MI_Y] = nY .and.;
                  (oMouse[MI_X] >= nLeft+1) .and. (oMouse[MI_X] <= nRight-1)
              oMouse[MI_CLICKS] = 2
              exit
            endif
          enddo
        endif
        
        if oMouse[MI_CLICKS] > 0
          nNew_row = nY - mPick:nTop - 1
          if nNew_row != mPick:rowpos
            if nNew_row > mPick:rowpos
              for nCnt = 1 to nNew_row - mPick:rowpos
                mPick:down()
              next
            elseif nNew_row < mPick:rowpos
              for nCnt = 1 to mPick:rowpos - nNew_row
                mPick:up()
              next
            endif
          endif
          exit
        endif
      endif                     // mouse in browse area
      
      if lScroll
        if (oMouse[MI_Y] = nTop-2) .and. (oMouse[MI_X] = nLeft)
          while oMouse[MI_BUTTON] = nButton
            m_info(oMouse)
          enddo
          oMouse[MI_CLICKS] = 0
          oMouse[MI_ASCII] = K_ESC    // process escape block
          exit
        endif                   // escape block
        
        if (oMouse[MI_Y] = nTop+1) .and. (oMouse[MI_X] = nRight+1)
          while oMouse[MI_BUTTON] = nButton
            m_info(oMouse)
          enddo
          oMouse[MI_CLICKS] = 0
          oMouse[MI_ASCII] = K_PGUP    // process page up block
          exit
        endif                   // page up block
        
        if (oMouse[MI_Y] = nBott-1) .and. (oMouse[MI_X] = nRight+1)
          while oMouse[MI_BUTTON] = nButton
            m_info(oMouse)
          enddo
          oMouse[MI_CLICKS] = 0
          oMouse[MI_ASCII] = K_PGDN    // process page up block
          exit
        endif                   // page up block
        
        if (oMouse[MI_Y] >= nTop+1) .and. (oMouse[MI_Y] <= nBott-2);
              .and. (oMouse[MI_X] = nRight+1)                // scroll bar
          ntemp1 = (oMouse[MI_Y] - nTop - 3)
          ntemp2 = len(aArr) / nBar_move
          nWhere = int((oMouse[MI_Y] - nTop - 1) * len(aArr) / nBar_move)
          if nArr_ntx > nWhere
            for ncnt = nArr_ntx to nWhere+1 step -1
              mPick:up()
            next
          else
            for ncnt = nArr_ntx to nWhere-1
              mPick:down()
            next
          endif
          exit
        endif                       // scroll bar
        
      endif                           // scroll bar exists
      
    endif                       // button down
  endif                         // keyboard used
enddo
return(0)

*f*********************************************************
function Num2Color(nNo)
**
**  Syntax ..... NUM2COLOR(<N>)
**
**  Purpose .... Convert Colour No. to Colour String
**
**  Argument ... <N> := Colour No.
**
**  Returns .... Character
**

local cColor

do case
  Case nNo == 0
    cColor := 'N'
  Case nNo == 1
    cColor := 'B'
  Case nNo == 2
    cColor := 'G'
  Case nNo == 3
    cColor := 'BG'
  Case nNo == 4
    cColor := 'R'
  Case nNo == 5
    cColor := 'RB'
  Case nNo == 6
    cColor := 'GR'
  Case nNo == 7
    cColor := 'W'
  Case nNo == 8
    cColor := '+N'
  Case nNo == 9
    cColor := '+B'
  Case nNo == 10
    cColor := '+G'
  Case nNo == 11
    cColor := '+BG'
  Case nNo == 12
    cColor := '+R'
  Case nNo == 13
    cColor := '+RB'
  Case nNo == 14
    cColor := '+GR'
  Case nNo == 15
    cColor := '+W'
  otherwise
    cColor := ''+.f.        //  create artificial error
endcase

return (cColor)
*| EOF Num2Color

function Color2Bin(cColor)
**
**  Syntax ..... COLOR2BIN(<C>)
**
**  Purpose .... Convert Colour to Binary
**
**  Argument ... <C> := Colour to Convert
**
**  Returns .... Character
**
**  Usage ...... Binary := (background * 16) + foreground [+ 128 for Blinking]
**

local bBlink, cClr, nFore, nBack

cColor := upper(alltrim(cColor))
bBlink := at('*', cColor) # 0
cColor := strtran(cColor, "*", "")          &&  Remove blinking attribute

*|
*|  Work out colour received, working from RIGHT to LEFT
*|
*|
*|  BACKGROUND COLOUR
*|
cClr := right(cColor, (len(cColor)-at('/',cColor)))
cClr := strtran(cClr, '+')

do case
  case "BR" $ cClr
    cClr := strtran(cClr, "BR", "RB")
  case "RG" $ cClr
    cClr := strtran(cClr, "RG", "GR")
  case "GB" $ cClr
    cClr := strtran(cClr, "GB", "BG")
endcase

nBack := Color2Num(cClr)

*|
*|  FOREGROUND COLOUR
*|
cClr := alltrim(left(cColor, (at('/',cColor)-1)))
if at('+', cClr) = 1
  cClr := stuff(cClr, 1, 1, '') + '+'
endif

do case
  case "BR" $ cClr
    cClr := strtran(cClr, "BR", "RB")
  case "RG" $ cClr
    cClr := strtran(cClr, "RG", "GR")
  case "GB" $ cClr
    cClr := strtran(cClr, "GB", "BG")
endcase

nFore := Color2Num(cClr)

cClr := (nBack * 16) + nFore + iif(bBlink, 128, 0)

return ( chr(cClr) )
*| EOF Color2Bin

*|----------------------------------------------------------------------------|*

function Bin2Color(cBin)
**
**  Syntax ..... BIN2COLOR(<C>)
**
**  Purpose .... Convert Binary Number to Clipper Colour String
**
**  Argument ... <C> := Number to Convert
**
**  Returns .... Character
**
**  Usage ...... Binary := (background * 16) + foreground [+ 128 for Blinking]
**

local bBlink, nFore, nBack, nBin

nBin := asc(cBin)

*|
*|  Is colour blinking?
*|
bBlink := (nBin > 127)
if bBlink
  nBin := nBin - 128
endif

*|
*|  Work out colour received, working from RIGHT to LEFT
*|
nBack := int(nBin / 16)
nFore := (nBin % 16)

return ( iif(bBlink, "*", "") + Num2Color(nFore) + "/" + Num2Color(nBack) )
*| EOF Bin2Color

*|----------------------------------------------------------------------------|*
function Color2Num(cColor)
**
**  Syntax ..... COLOR2NUM(<C>)
**
**  Purpose .... Return number of Colour (0-15)
**
**  Argument ... <C> := Colour to convert
**
**  Returns .... Numeric
**

local nNo

cColor := upper(trim(cColor))

do case
  case cColor == 'N'
    nNo := 0
  case cColor == 'B'
    nNo := 1
  case cColor == 'G'
    nNo := 2
  case cColor == 'BG'
    nNo := 3
  case cColor == 'R'
    nNo := 4
  case cColor == 'RB'
    nNo := 5
  case cColor == 'GR'
    nNo := 6
  case cColor == 'W'
    nNo := 7
  case (cColor == 'N+') .or. (cColor == '+N')
    nNo := 8
  case cColor == ('B+') .or. (cColor == '+B')
    nNo := 9
  case cColor == ('G+') .or. (cColor == '+G')
    nNo := 10
  case cColor == ('BG+') .or. (cColor == '+BG')
    nNo := 11
  case cColor == ('R+') .or. (cColor == '+R')
    nNo := 12
  case cColor == ('RB+') .or. (cColor == '+RB')
    nNo := 13
  case cColor == ('GR+') .or. (cColor == '+GR')
    nNo := 14
  case cColor == ('W+') .or. (cColor == '+W')
    nNo := 15
  otherwise
    nNo := ''+.f.           //  create artificial error
endcase

return (nNo)
*| EOF Color2Num

*******************************************************************************
function Pause(nTime)
**  Syntax ..... PAUSE(<N>)
**  Purpose .... Uninterrupible time delay
**  Argument ... <N> = Time in seconds
**  Returns .... Nothing
**  See Also ... STOPWATCH()
**

local nSecs

if nTime > 0
  nSecs := seconds()
  do while StopWatch(nSecs, seconds()) <= nTime
  enddo
endif

return (nil)
*| EOF Pause

function StopWatch(nStart, nStop)
**
**  Syntax ..... STOPWATCH<N1>, <N2>)
**
**  Purpose .... Give difference between 2 times in seconds and 1/100ths
**
**  Argument ... <N1> = Start time in seconds
**               <N2> = Stop time in seconds
**
**  Returns .... Numeric
**

if nStart > nStop
  nStop := nStop + 86400
endif

return (nStop - nStart)
*| EOF StopWatch

*******************************************************************************
function mHot_spot (nExit_val, nTime_out)
local nKey, nCnt := 0, nCurs, cColorsave
private nExit, nSec, nTime_last
nTime_last = seconds()
nSec = if(valtype(nTime_out) = 'N', nTime_out, 999999999)
nExit = if(valtype(nExit_val) = 'N', nExit_val, 0)
nCurs = setcursor(0)
m_show(oMouse)
lCont = .t.
while lCont
  nKey = inkey()
  if nTime_last + nSec < seconds()
    nCnt = nExit
    exit
  endif
  if nKey != 0
    nTime_last = seconds()
    for nCnt = 1 to len(oMouse[MI_HOTSPOT])
      if chr(nKey) $ oMouse[MI_HOTSPOT, nCnt, HS_CHAR];
            .and. oMouse[MI_HOTSPOT, nCnt, HS_ACTIVE]
        lCont = .f.
        exit
      endif
    next
  else
    m_info(oMouse)
    // display time
    cColorsave = setcolor(yell_blue)
    @1,2 say time()
    setcolor(cColorsave)
    if oMouse[MI_BUTTON] != 0
      nTime_last = seconds()
      nButton := oMouse[MI_BUTTON]
      while oMouse[MI_BUTTON] = nButton       // for the heavy handed
        m_info(oMouse)
      enddo
      for nCnt = 1 to len(oMouse[MI_HOTSPOT])
        if oMouse[MI_HOTSPOT, nCnt, HS_ACTIVE]
          if oMouse[MI_Y] >= oMouse[MI_HOTSPOT, nCnt, HS_TOP] .and.;
                oMouse[MI_Y] <= oMouse[MI_HOTSPOT, nCnt, HS_BOTT] .and.;
                oMouse[MI_X] >= oMouse[MI_HOTSPOT, nCnt, HS_LEFT] .and.;
                oMouse[MI_X] <= oMouse[MI_HOTSPOT, nCnt, HS_RIGHT]
            lCont = .f.
            exit
          endif
        endif
      next
    endif
  endif
enddo
setcursor(nCurs)
m_Hide(oMouse)
return(nCnt)
* eof()

*******************************************************************************
*
* FUNCTION MMAKE_SURE - CHECKS FOR YES OR NO with a mouse
*                       RETURNS BOOLEAN
*
*******************************************************************************
function mMake_sure ( oM, my_coord, mx_coord, cString1, cString2, nIn_Time_out)
LOCAL nY_COORD, nX_COORD, cSTR1, cSTR2, cCHAR, nINKEY, cORIG_COLOR, cSECTOR
LOCAL nHIGHT, nWIDTH
private cDefault := '', wt_red, brwt_red, nSecs, nTime_in

if iscolor() .and. !force_bw
  wt_red := 'w/r,r/w,,,n+/r'
  brwt_red := 'w+/r,r/w,,,n+/r'
else
  wt_red := 'w/n,n/w,,,n+/n'
  brwt_red := 'w+/n,n/w,,,n+/n'
endif

if cString1 = nil
  cStr1 = 'Are you SURE (Y/N) ?'
else
  cStr1 = cString1
endif
nHight = 6
nWidth = len(trim(cStr1))

if cString2 != nil
  cStr2 = cString2
  nHight++
  if len(trim(cStr2)) > nWidth
    nWidth = len(trim(cStr2))
  endif
endif

nSecs = if(valtype(nIn_Time_out) = 'N', nIn_time_out, 99999999)

nTime_in = seconds()

nWidth = if(nWidth <17, 17, nWidth)

if mY_coord = nil
  nY_coord = 12
else
  nY_coord = mY_coord
endif

if mX_coord = nil
  nX_coord = ((80-nWidth)/2)
else
  nX_coord = mX_coord
endif
nX_coord = int(nX_coord)

nTop = nY_coord+nHight-5
nBott = nY_coord+nHight-3
if nWidth < 20
  nYes = nX_coord+1
  nNo = nX_coord+nWidth-6
else
  nYes = nX_coord + int(nWidth/2) - 9
  nNo = nX_coord + int(nWidth/2) +2
endif

aYes := {nTop, nYes, nBott, nYes+6}
aNo := {nTop, nNo, nBott, nNo+5}

cOrig_color = setcolor(wt_red)
cSector = draw_box(nY_coord-1, nX_coord-1, nY_coord+nHight-2,;
    nX_coord+nWidth+2)
nExtra = 0
if len(cStr1) < nWidth
  nExtra = int((nWidth-len(cStr1)) / 2 )
endif
@nY_coord,nX_coord+nExtra say cStr1
if cString2 != nil
  nExtra = 0
  if len(cString2) < nWidth
    nExtra = int((nWidth-len(cString2)) / 2 )
  endif
  @nY_coord+1, nX_coord + nExtra say cString2
endif

mSure_box()

m_show(oM)
while oM[MI_BUTTON] != 0
  m_info(oM)
enddo

while .t.
  mSure_active(oM)
  nKey = oM[MI_ASCII]
  do case
    case nKey = K_TAB
      if empty(cDefault) .or. cDefault = 'Y'
        cDefault = 'N'
      else
        cDefault = 'Y'
      endif
      
    case nKey = K_ENTER .and. !empty(cDefault)
      exit
      
    case upper(chr(nKey)) = 'Y'
      cDefault = 'Y'
      exit
      
    case upper(chr(nKey)) = 'N' .or. nKey = K_ESC
      cDefault = 'N'
      exit
      
  endcase
  mSure_box()
enddo

m_hide(oM)

setcolor(cOrig_color)
restsector(cSector)
if cDefault = 'Y'
  return(.t.)
else
  return(.f.)
endif

* eof()

*******************************************************************************
static procedure mSure_box
setcolor(brwt_red)
@aYes[1]+1, aYes[2]+2 say 'Y'
@aNo[1]+1, aNo[2]+2 say 'N'
if cDefault = 'Y'
  setcolor(brwt_red)
else
  setcolor(wt_red)
endif
mSure_draw(aYes)
@aYes[1]+1, aYes[2]+3 say 'es'

if cDefault = 'N'
  setcolor(brwt_red)
else
  setcolor(wt_red)
endif
mSure_draw(aNo)
@aNo[1]+1, aNo[2]+3 say 'o'

return

*******************************************************************************
static procedure mSure_draw(aCoords)
@aCoords[1], aCoords[2] to aCoords[3], aCoords[4]
@aCoords[3], aCoords[2] say 'Ô'
@aCoords[1], aCoords[4] say '·'
for nCnt = aCoords[1]+1 to aCoords[3]-1
  @nCnt, aCoords[4] say 'º'
next
for nCnt = aCoords[2]+1 to aCoords[4]-1
  @aCoords[3], nCnt say 'Í'
next
@aCoords[3], aCoords[4] say '¼'
return

*******************************************************************************
static function msure_active(oM)
local nY, nX, nM_Y, nM_x, nButton, nOldButton, nTime, nASCII, cColorsave
oM[MI_CLICKS] = 0
while .t.
  if keypressed()                     // keyboard used
    nTime_in = seconds()
    oM[MI_ASCII] = inkey()
    exit
  else
    oM[MI_ASCII] = 0
    // display time
    cColorsave = setcolor(yell_blue)
    @1,2 say time()
    setcolor(cColorsave)
    
    m_info(oM)
    
    if oM[MI_BUTTON] != 0
      nTime_in = seconds()
      if (oM[MI_Y] >= aYes[1]) .and.;
            (oM[MI_Y] <= aYes[3]) .and. (oM[MI_X] >= aYes[2]) .and.;
            (oM[MI_X] <= aYes[4])
        oM[MI_ASCII] = asc('Y')
        exit
      endif
      
      if (oM[MI_Y] >= aNo[1]) .and.;
            (oM[MI_Y] <= aNo[3]) .and. (oM[MI_X] >= aNo[2]) .and.;
            (oM[MI_X] <= aNo[4])
        oM[MI_ASCII] = asc('N')
        exit
      endif
      
    endif                       // button down
  endif                         // keyboard used
  if nTime_in + nSecs < seconds()
    oM[MI_ASCII] = K_ESC
    exit
  endif
enddo
return(0)
