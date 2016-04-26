*******************************************************************************
* THIS IS THE PROCEDURE FILE PROCFL
*
*******************************************************************************

#include "set.ch"
#include "error.ch"
#include 'inkey.ch'
#include 'mouse.ch'

#define NTRIM(n)                ( LTrim(Str(n)) )

***********************************************************
* FUNCTION SAVESECTOR
* This function returns a savescreen() screen image preceded by the
* coordinates in character format. The function restsector() is the complement
* to this function. The mouse cursor needs to be toggled if it is in the
* sector to be saved
*
* Parameters Top, Left, Bottom and right coordinates of the area to be saved

function savesector(nTop, nLeft, nBott, nRight)

local sSCr
sSCR = STR(nTOP,2,0) + STR(nLEFT,2,0) + STR(nBOTT,2,0) + STR(nRIGHT,2,0)
sSCR += SAVESCREEN(nTOP, nLEFT, nBOTT, nRIGHT)
return(sScr)
*EOF()

*f**********************************************************
* FUNCTION RESTSECTOR
* This function resores a section of the screen that has been saved with the
* the savesector function. The mouse cursor needs to be toggled if it is
* in the sector to be restored

procedure restsector(sIn_screen)

LOCAL nTOP, nLEFT, nBOTT, nRIGHT
nTOP = VAL(SUBSTR(sIN_SCREEN,1,2))
nLEFT = VAL(SUBSTR(sIN_SCREEN,3,2))
nBOTT = VAL(SUBSTR(sIN_SCREEN,5,2))
nRIGHT = VAL(SUBSTR(sIN_SCREEN,7,2))
sIN_SCREEN = STUFF(sIN_SCREEN,1,8,'')
RESTSCREEN(nTOP, nLEFT, nBOTT, nRIGHT, sIN_SCREEN)
return
*eof()

*f******************************************************************************
* procedure jw_screen - Displays a grey screen with the company title
*                       time and date at the top of the screen in yellow
*                       enclosed in a blue box
*
procedure jw_screen (co_title)
local width, cTitle
if co_title = nil .or. empty(co_title) .and. valtype(memvar->cCo_name) = 'C'
  cTitle = memvar->cCo_name
else
  cTitle = co_title
endif
setcolor(memvar->white_black)
@0,0,24,79 box '±±±±±±±±±'
setcolor(memvar->YELL_BLUE)
@0,0 clear to 2,79
@0,0 to 2,79
@1,2 say time()
@1,70 say date()
cTitle = ltrim(cTitle)
cTitle = rtrim(cTitle)
cTitle = ' ' + cTitle + ' '
store (80-len(cTitle))/2 to width
@1,width say cTitle
setcolor(memvar->BLUE_CYAN)
return
* eof (jw_screen)

*f******************************************************************************
* Procedure jW_head - Clears screen and displays company title
*                     time and date at the top of the screen in magenta
*
* Parameter cCo_title This is the title to display

procedure jw_head ( co_title )

local nWidth, cTitle
if co_title = nil .or. empty(co_title) .and. valtype(memvar->cCo_name) = 'C'
  cTitle = memvar->cCo_name
else
  cTitle = co_title
endif
setcolor(memvar->WHITE_BLACK)
@0,0 clear to 24,79
setcolor('rb/n')
cTitle = ltrim(cTitle)
cTitle = rtrim(cTitle)
cTitle = ' ' + cTitle + ' '
store int((80-len(cTitle))/2) to nWidth
@0,0 say replicate('*', 80)
@0,nWidth say cTitle
@1,2 say time()
@1,70 say date()
setcolor(memvar->WHITE_BLACK)
return
* eof (simhead)

*f*****************************************************************************
* procedure simtitle - Prints company title, date, page number and
*                      a subheading at the top of a new page
*
* Parameters pLine
*******************************************************************************
procedure simtitle ( PLINE, PPAGE, SUBTITLE, MCOMP )
LOCAL PTOP, nWidth, MTITLE
memvar pPnt_title
IF PPAGE != 0
  ?? memvar->PR_FORM_FEED
else
  ?? memvar->PR_RESET
ENDIF
setprc(0,0)
PPAGE++
PTOP = LTRIM(PPNT_TITLE)
PTOP = RTRIM(PTOP)
STORE (60-LEN(PTOP))/2 TO nWidth
?? DTOC(DATE())
?? REPLICATE(' ',nWidth) + PTOP + REPLICATE(' ',nWidth) + 'PAGE '
?? LTRIM(STR(PPAGE))
STORE TRIM(SUBTITLE) TO MTITLE
STORE (80-LEN(MTITLE))/2 TO nWidth
? SPACE(nWidth) + MTITLE
?  ' '
IF MCOMP = 'Y'
  ?? memvar->PR_COMPRESS
ENDIF
PLINE := 3
RETURN
* EOF (SIMTITLE)

*f**********************************************************
* This procedure issues a form feed character and resets the internal
* row and column counters

procedure jw_eject

? memvar->PR_FORM_FEED
setprc(0,0)
return



*******************************************************************************
* This function opens the print file. It the global variable force_prfile is
* set a print file is opened with a user specified name (defaults to JIM.TXT)
* The function also waits until a printer has been located before continuing
*
* Parameter lLandscape - A Boolean which, if set, will issue a
* "print landscape" command. Defaults to false.

*f**********************************************************
* This procedure closes the printfile. This procedure is superceded by
* shutprn() and should be phased out.
*
* Parameter lDate - A Boolean which, if set, prints the date at the bottom
*                   of tha last page

procedure closeprn (lDate)

local lPr_dt
lPr_dt = if(valtype(lDate) = 'L', lDate, .t.)
if lPr_dt
  while pRow() < memvar->PR_LINES - 2
    ? ''
  enddo
  ? '                  ---   ' + dtoc(date()) + '   ---'
endif
?? memvar->PR_FORM_FEED
?? memvar->PR_RESET
set print off
set consol on
return


*f*****************************************************************************
* Procedure bkspace - removes last character from a string
*
*******************************************************************************
function bkspace (cString)
local cOut
cOut = substr(cString,1,len(cString)-1)
return (cOut)
* eof (bkspace)

*f*****************************************************************************
* function endday - returns numerical value of last day of the month
*
*******************************************************************************

function endday (nMonth)

local nDay
do case
  case nMonth = 4 .or. nMonth = 6 .or. nMonth = 9 .or. nMonth = 11
    nDay = 30
  case nMonth = 2
    nDay = 28
  otherwise
    nDay = 31
ENDCASE
RETURN (nDay)
* EOF (ENDDAY)

*f*****************************************************************************
* function et_addmonth - adds month to given date
*
*******************************************************************************

function et_addmonth ( dIn)

local dTemp, nMt, dOutdate, dDay
dTemp = dIn
nMt = month(dTemp)
while nMt = month(dTemp)
  dTemp++
enddo
dDay = day(dIn)
nMt = month(dTemp)
dTemp += dDay - 1
while nMt != month(dTemp)
  dTemp--
enddo
return (dTemp)
* eof (addmonth)

*f*********************************************************
* Procedure no longer used
FUNCTION ACTDATE (INDATE)
LOCAL A_DT, MDAY
A_DT = .F.
DO WHILE !A_DT
  A_DT = .T.
  MDAY = UPPER(SUBSTR(CDOW(INDATE),1,3))
  IF MDAY = 'SAT' .OR. MDAY = 'SUN'
    A_DT = .F.
  ENDIF
  IF !A_DT
    INDATE++
  ENDIF
ENDDO
RETURN(INDATE)

*f*****************************************************************************
*  NET_USE function
*
*  Trys to open a file for exclusive or shared use.
*  SET INDEXes in calling procedure if successful.
*  Pass the following parameters
*    1. Character - name of the .DBF file to open
*    2. Logical - mode of open (exclusive/!exclusive)
*    3. Alias - reccommed don't use
*    4 - 7 Character - index names
*
*  Example:
*    IF !NET_USE("Accounts", .T.,,"ACCOUNTS")
*       ? "Account file not available"
*    ENDIF

function net_use (cIn_dbf, lIn_ex, ALIAS_NM, cIndex1, cIndex2, cIndex3, cIndex4)
local lEx_use, nCntr, cCol, cSect, cFtest, cInx_tst, aIndex

lEx_use = if(valtype(lIn_ex) = 'L', lIn_ex, .f.)

cCol = setcolor()

aIndex := {}
if valtype(cIndex1) = 'C'
  aadd(aIndex, cIndex1)
endif
if valtype(cIndex2) = 'C'
  aadd(aIndex, cIndex2)
endif
if valtype(cIndex3) = 'C'
  aadd(aIndex, cIndex3)
endif
if valtype(cIndex4) = 'C'
  aadd(aIndex, cIndex4)
endif

cFtest = cIn_dbf + '.DBF'
if !file(cFtest)
  setcolor(memvar->BLACK_RED)
  cSect = draw_box(18,10,22,70)
  @20,25 SAY cFtest + ' DOES NOT EXIST - TELL E.T.'
  inkey(20)
  setcolor(cCol)
  restsector(cSect)
  return(.f.)
endif

if valtype(alias_nm) != 'C'
  if lEx_use                                        && exclusive
    use (cIn_dbf) exclusive
  else
    use (cIn_dbf) shared                            && shared
  endif
else
  if lEx_use                                        && exclusive
    use (cIn_dbf) exclusive alias (alias_nm)
  else
    use (cIn_dbf) shared alias (alias_nm)           && shared
  endif
endif

if neterr()           && use fails
  setcolor(memvar->BLACK_RED)
  cSect = draw_box(18,10,22,70)
  @20,15 say 'NETWORK LOCK ON ' + TRIM(cIn_dbf) + ' - PLEASE TRY LATER'
  inkey(20)
  setcolor(cCol)
  restsector(cSect)
  return(.f.)
endif

for nCntr = 1 to len(aIndex)
  cFtest = trim(aIndex[nCntr]) + '.NTX'
  if !file(cFtest)
    setcolor(memvar->BLACK_RED)
    cSect = draw_box(18,10,22,70)
    @20,25 say &cFtest + ' DOES NOT EXIST - TELL E.T.'
    setcolor(cCol)
    inkey(20)
    restsector(cSect)
    return(.f.)
  endif
next

for nCntr = 1 to len(aIndex)
  dbsetindex(aIndex[nCntr])
  if neterr()
    setcolor(memvar->BLACK_RED)
    cSect = draw_box(18,10,22,70)
    @20,22 SAY 'UNABLE TO OPEN INDEX ' + aIndex[nCntr]
    setcolor(cCol)
    inkey(20)
    restsector(cSect)
    return(.f.)
  endif
next

if len(aIndex) > 0
  dbsetorder(1)
  dbgotop()
endif

return(.t.)
* End - NET_USE

*f*****************************************************************************
* PROCEDURE BELWRITE
*
* - APPEND ASCII 10 & ASCII 13 TO END OF LINE TO BE WRITTEN
* - CALL FWRITE
* - CHECKS FOR ERROR CONDITIONS AND DISPLAY MESSAGE
*
*******************************************************************************
procedure belwrite ( nFile_hndl, cLine)

cLine = cLine + chr(13) + chr(10)
if fwrite(nFile_hndl, cLine) != len(cLine)
  if ferror() != 0
    @23,10 say 'DOS ERROR = ' + str(ferror())
    inkey()
  endif
else
  *  btline++
endif
return

* EOF()


*f*****************************************************************************
*
* FUNCTION MAKE_SURE - CHECKS FOR YES OR NO
*                      RETURNS BOOLEAN
*          Superceded by MMake_sure() - mouse sensitive source in mouse.prg
*
*******************************************************************************
FUNCTION MAKE_SURE ( MY_COORD, MX_COORD, cSTRING1, cSTRING2)
LOCAL nY_COORD, nX_COORD, cSTR1, cSTR2, cCHAR, nINKEY, cORIG_COLOR, cSECTOR
LOCAL nHIGHT, nWIDTH

IF cSTRING1 = NIL
  cSTR1 = 'Are you SURE ?'
ELSE
  cSTR1 = cSTRING1
ENDIF
nHIGHT = 3
nWIDTH = LEN(TRIM(cSTR1))

IF cSTRING2 != NIL
  cSTR2 = cSTRING2
  nHIGHT++
  IF LEN(TRIM(cSTR2)) > nWIDTH
    nWIDTH = LEN(TRIM(cSTR2))
  ENDIF
ENDIF

IF MY_COORD = NIL
  IF ROW() < 17
    nY_COORD = ROW() + 2
  ELSE
    nY_COORD = ROW() + nHIGHT - 3
  ENDIF
ELSE
  nY_COORD = MY_COORD
ENDIF
nY_COORD = int(nY_COORD)

IF MX_COORD = NIL
  nX_COORD = ((80-nWIDTH)/2)
ELSE
  nX_COORD = MX_COORD
ENDIF
nX_COORD = int(nx_COORD)

cORIG_COLOR = SETCOLOR(memvar->WHITE_RED)
cSECTOR = DRAW_BOX(nY_COORD-1, nX_COORD-1, nY_COORD+nHIGHT-2,;
    nX_COORD+nWIDTH+2)

cCHAR = ' '
DO WHILE cCHAR != 'Y' .AND. cCHAR != 'N'
  @nY_COORD,nX_COORD SAY cSTR1
  IF cSTRING2 != NIL
    @nY_COORD+1, nX_COORD SAY cSTRING2
  ENDIF
  nINKEY = INKEY(60)
  if ( nINKEY == K_F1 )
    help(procname(), procline(), 'make_sure')
  endif
  IF nINKEY = 0 .OR. nINKEY = 27
    cCHAR = 'N'
  ELSE
    cCHAR = UPPER(CHR(nINKEY))
  ENDIF
ENDDO
SETCOLOR(cORIG_COLOR)
RESTSECTOR(cSECTOR)
IF cCHAR = 'Y'
  RETURN(.T.)
ENDIF
RETURN(.F.)

* EOF()

*f*****************************************************************************
*
* PROCEDURE RECLOCK
*    CONTINUES TRYING RLOCK() ON A RECORD UNTIL SUCESSFUL
*
*******************************************************************************
function reclock ( cFile , nSeconds )
local nLock, cSect, cString, cCol, cName, nTries

cName = if(valtype(cFile) = 'C', cFile, alias())
nTries = if(valtype(nSeconds) = 'N', nSeconds * 2, 999999999)

nLock = 1
if !rlock()
  cString = 'Record in ' + trim(cName) + ' locked - tries = '
  cCol = setcolor(memvar->BLACK_RED)
  cSect = draw_box(19, 18, 21, 22 + len(cString))
  
  while !rlock()
    @20,19 say cString + ltrim(str(nLock))
    nLock++
    inkey(0.5)
    if nLock > nTries
      return(.f.)
    endif
  enddo
  setcolor(cCol)
  restsector(cSect)
endif
return(.t.)

*eof - reclock

*f*****************************************************************************
*
* function draw_box - draws a box with single or double line around
*                     and with background shadowing
*                     returns screen sector information from savesector()
*
*******************************************************************************
function draw_box (nY1, nX1, nY2, nX2, lDoub_ln)
local lDouble, cShadow1, cShadow2, nCnt, cSect
cSect = savesector(nY1, nX1, nY2+1, nX2+2)
lDouble = IF(valtype(lDoub_ln) = 'L', lDoub_ln, .F.)
cShadow1 = savescreen(nY2+1, nX1+2, nY2+1, nX2+2)
cShadow2 = savescreen(nY1+1, nX2+1, nY2+1, nX2+2)
FOR nCnt = 2 to len(cShadow1) step 2
  cShadow1 = STUFF(cShadow1, nCnt, 1, CHR(08))
next
for nCnt = 2 to len(cShadow2) step 2
  cShadow2 = STUFF(cShadow2, nCnt, 1, CHR(08))
next
@nY1, nX1 clear to nY2, nX2
if lDouble
  @nY1, nX1 to nY2, nX2 double
else
  @nY1, nX1 to nY2, nX2
endif

restscreen(nY2+1, nX1+2, nY2+1, nX2+2, cShadow1)
restscreen(nY1+1, nX2+1, nY2+1, nX2+2, cShadow2)

return(cSect)

* EOF

*f*****************************************************************************
*
* PROCEDURE PROP_NOUN - CONVERT CHARACTER STRINGS TO UPPER CASE FOLLOWED
*                       BY LOWER CASE
*
*******************************************************************************
function prop_noun ( cIn_string )
local cString, cOut_str, nLen, nCnt, lIn_word
lIn_word = .F.
cOut_str = ''
cString = cIn_string
nLen = len(cIn_string)
for nCnt = 1 to nLen
  if !lIn_word
    if isalpha(substr(cString,nCnt,1))
      cOut_str = cOut_str + upper(substr(cString,nCnt,1))
      lIn_word = .T.
    else
      cOut_str = cOut_str + substr(cString,nCnt,1)
    endif
  else
    if isalpha(substr(cString,nCnt,1))
      cOut_str = cOut_str + lower(substr(cString,nCnt,1))
    else
      cOut_str = cOut_str + substr(cString,nCnt,1)
    endif
    if substr(cString,nCnt,1) = ' '
      lIn_word = .F.
    endif
  endif
next
return (cOut_str)
*EOF

*f*****************************************************************************
* FUNCTION ESC_UDF - UDF FOR MCHOICE
*
*******************************************************************************
function esc_udf ( nMode, nInx, nRow)
do case
  case nMode = 3
    do case
      case lastkey() = K_ESC
        return(0)
      case lastkey() = K_ENTER
        return(1)
      otherwise
        return(2)
    endcase
  case nMode = 0
    return(2)
endcase
return(0)
*EOF

*f*****************************************************************************
* function disp_msg - display centered messages on screen
*                     at a certain row
*    returns string containing screen sector information

function disp_msg (nRow, cCol, cMsg_1, cMsg_2, cMsg_3)
local nTop, nLeft, nRight, nBottom, nlen, cOrig_col, cSect, nCursor

if (nRow != nil .AND. valtype(nRow) != 'N') .or.;
      (cCol != NIL .and. valtype(cCol) != 'C')
  return NIL
endif

nCursor = setcursor(0)

if valtype(cMsg_1) != 'C'
  return NIL
endif

if nRow = NIL .or. nRow > 22
  nTop = 10
else
  nTop = nRow
endif
nBottom = nTop + 2

nlen = len(cMsg_1)

if valtype(cMsg_2) = 'C'
  if len(cMsg_2) > nlen
    nlen = len(cMsg_2)
  endif
  nBottom++
endif

if valtype(cMsg_3) = 'C'
  if len(cMsg_3) > nlen
    nlen = len(cMsg_3)
  endif
  nBottom++
endif

nLeft = int((80-nlen)/2)-3
nRight = 80 - nLeft

if cCol != NIL
  cOrig_col = setcolor(cCol)
else
  cOrig_col = setcolor(memvar->WHITE_RED)
endif
cSect = draw_box(nTop, nLeft, nBottom, nRight)
@nTop+1,((80-len(cMsg_1))/2) say cMsg_1
if valtype(cMsg_2) = 'C'
  @nTop+2,((80-len(cMsg_2))/2) say cMsg_2
endif
if valtype(cMsg_3) = 'C'
  @nTop+3,((80-len(cMsg_3))/2) say cMsg_3
endif
setcolor(cOrig_col)
setcursor(nCursor)
return(cSect)
*EOF()

*f*****************************************************************************
* This function returns the length of the longest element in a character array

function arr_wdth ( aIn_array )

local nCnt, nWdth
nWdth = 0
if len(aIn_array) > 0
  for nCnt = 1 to len(aIn_array)
    if len(aIn_array[nCnt]) > nWdth
      nWdth = len(aIn_array[nCnt])
    endif
  next
endif
return ( nWdth )
*EOF

*f*****************************************************************************
* This function properly displays an achoice array.
*
* param aIn_arr - The character array to select from
*       nIn_top - The top coord to use
*       nIn_left - The left coord to use
*       cIn_col - A colour code string to use
*       lEsc - Whether the use can leave with Esc
*       cHeading - An optional heading to display
*       nIn_Start - The element to put the initial bar on
*       lVal_arr - An array of logical values for input to aChoice
*       pUsr_func - Optional user defind function

FUNCTION pGET_ARR(aIN_ARR, nIN_TOP, nIN_LEFT, cIN_COL, lEsc, cHeading,;
    nIn_start, lVal_arr, pUsr_func)
LOCAL nTOP, nLEFT, nBOTT, nRIGHT, cSect, cOrig_col, nWdt, nRet, lEscape,;
    cHead, lVal, cUsr
local nStart
if len(aIn_arr) = 0
  return(0)
endif
nWdt = ARR_WDTH(aIn_arr)
if cHeading != NIl .and. valtype(cHeading) = 'C'
  cHead = trim(ltrim(cHeading))
  nWdt = if(len(cHead) > nWdt, len(cHead), nWdt)
endif
IF nIN_LEFT != NIL
  nLEFT = nIN_LEFT - 1
ELSE
  nLEFT = INT((80 - nWdt) /2) - 1
ENDIF
nLeft = int(nLeft)
nRIGHT = nLEFT + 2 + nWdt

if nIN_TOP = NIL
  if len(aIN_ARR) > 14
    nTOP = 6
  else
    nTOP = 6 + int(len(aIN_ARR)/2)
  endif
else
  nTOP = nIN_TOP - 1
endif
nBOTT = nTOP + 1 + LEN(aIN_ARR)
IF nBOTT > 23
  nBOTT = 23
ENDIF

if cIn_col != nil
  cOrig_col = setcolor(cIn_col)
else
  cOrig_col = setcolor()
endif

lEscape = if((lEsc = NIL .or. valtype(lEsc) != 'L'), .f., lEsc)

nStart = if(valtype(nIn_start) = 'N', nIn_start, 1)

lVal = if(lVal_arr = NIL, .t., lVal_arr)

cUsr = pUsr_func

if cHeading != NIl .and. valtype(cHeading) = 'C'
  cSect = DRAW_BOX(nTOP-2, nLEFT, nBOTT, nRIGHT,.t.)
  @nTop, nLeft say'Ç'
  @nTop, nLeft+1 say replicate('Ä', nRight-nLeft-1)
  @nTop, nRight say'¶'
  @nTop-1, nLeft + 1 + (nWdt-len(cHead))/2 say cHead
else
  cSect = DRAW_BOX(nTOP, nLEFT, nBOTT, nRIGHT,)
endif

nRet = 0
if lEscape
  nRet = achoice(nTop+1, nLeft+1, nBott-1, nRight-1, aIn_arr,lVal,cUsr,nStart)
else
  do while nRet = 0
    nRet = achoice(nTop+1, nLeft+1, nBott-1, nRight-1, aIn_arr,lVal,cUsr,nStart)
  enddo
endif

restsector(cSect)
setcolor(cOrig_col)
RETURN(nRet)

*f*****************************************************************************
/******************************************************************************
*       Sys_Error()
*/
function Sys_Error(e)
local i, cMessage, aOptions, nChoice, cDt, nNo, cNo, cFl, cFile

#command ? <list,...>   =>  ?? Chr(13) + Chr(10) ; ?? <list>
#command ?? <list,...>  =>  OutErr(<list>)

// by default, division by zero yields zero
if ( e:genCode == EG_ZERODIV )
  return (0)
endif

// for network open error, set NETERR() and subsystem default
if ( e:genCode == EG_OPEN .and. e:osCode == 32 .and. e:canDefault )
  NetErr(.t.)
  return (.f.)                                         // NOTE - default
endif

// for lock error during APPEND BLANK, set NETERR() and subsystem default
if ( e:genCode == EG_APPENDLOCK .and. e:canDefault )
  NetErr(.t.)
  return (.f.)                                         // NOTE - default
end

// build error message
cMessage := error_msg(e)

// build options array
if e:genCode == EG_PRINT
  aOptions := {"Abandon this print"}
else
  aOptions := {"Quit"}
endif

if (e:canRetry)
  AAdd(aOptions, "Retry")
end

if (e:canDefault)
  AAdd(aOptions, "Default")
end

// put up alert box
nChoice := 0
while ( nChoice == 0 )
  
  if ( Empty(e:osCode) )
    nChoice := Alert( cMessage, aOptions )
    
  else
    nChoice := Alert( cMessage + ;
        ";(DOS Error " + NTRIM(e:osCode) + ")", ;
        aOptions )
  endif
  
  if ( nChoice == NIL )
    exit
  endif
enddo

if ( !Empty(nChoice) )
  // do as instructed
  if ( aOptions[nChoice] == "Abandon this print" )
    Break(e)
  elseif ( aOptions[nChoice] == "Retry" )
    return (.t.)
  elseif ( aOptions[nChoice] == "Default" )
    return (.f.)
  endif
endif

// display message and traceback
if ( !Empty(e:osCode) )
  cMessage += " (DOS Error " + NTRIM(e:osCode) + ") "
endif

if nnetistts()                          // aborts transaction if tts enabled
  nnetttsab()
endif

close databases
cDt = dtoc(date())
cFl = substr(cDt,7,2) + substr(cDt,4,2) + substr(cDt,1,2)
nNo = 1
if nNo < 10
  cNo = '0' + str(nNo,1,0)
else
  cNo = str(nNo,2,0)
endif
cFile = cFl + cNo + '.ERR'
while file(cFile)
  nNo++
  if nNo < 10
    cNo = '0' + str(nNo,1,0)
  else
    cNo = str(nNo,2,0)
  endif
  cFile = cFl + cNo + '.ERR'
enddo

#command ?  [ <list,...> ]      => QOut( <list> )
#command ?? [ <list,...> ]      => QQOut( <list> )

set printer to &cFile
set print on
? cMessage
i := 2
while ( !Empty(ProcName(i)) )
  ? "Called from", Trim(ProcName(i)) + "(" + NTRIM(ProcLine(i)) + ")  "
  i++
end
set print off
set alternate off

// give up
ErrorLevel(1)
QUIT

return (.f.)

*f*
/******************************************************************************
*       error_msg()
*/
function error_msg(e)
local cMessage

// start error message
cMessage := if( e:severity > ES_WARNING, "Error ", "Warning " )

// add subsystem name if available
if ( ValType(e:subsystem) == "C" )
  cMessage += e:subsystem()
else
  cMessage += "???"
end

// add subsystem's error code if available
if ( ValType(e:subCode) == "N" )
  cMessage += ("/" + NTRIM(e:subCode))
else
  cMessage += "/???"
end

// add error description if available
if ( ValType(e:description) == "C" )
  cMessage += ("  " + e:description)
end

// add either filename or operation
if ( !Empty(e:filename) )
  cMessage += (": " + e:filename)
elseif ( !Empty(e:operation) )
  cMessage += (": " + e:operation)
endif

return (cMessage)

*f*****************************************************************************
* A geneneric validation procedure for a get. Will only allow an entry of
* "Y" .or. "N"
function jw_val_yn
local cVal, oGet
oGet := getactive()
cVal := oGet:buffer
if lastkey() = 5                // uparrow
  return (.t.)
endif
if cVal $ 'YN'
  return(.t.)
endif
return(.f.)

* eof jw_val_yn

*f*****************************************************************************
* NanLogo(): Displays a Nantucket Logo on the screen along with
*            a short message promoting Clipper applications.
*      Size: The displayed Logo is 17 rows long and 40 columns wide.
*     Usage: NanLogo( row, col ) where row and col are the upper
*            left coordinates for the Logo.  If omited they
*            defalut to the current screen position.
*      Note: Nantucket, Clipper, and the Nantucket Logo are
*            trademarks of Nantucket Copr.
function NanLogo
return(nil)
*f*****************************************************************************
procedure notprog
local cSect
cSect = disp_msg(12,memvar->WHITE_RED,'This program has not been writtten yet !!!!',;
    'Press any key to proceed !!')
set consol off
inkey(0)
set consol on
restsector(cSect)
return

*f*****************************************************************************
procedure testprog
local cSect
cSect = disp_msg(12,memvar->WHITE_RED,'This program is still being tested !!!!',;
    'Press any key to proceed !!')
set consol off
inkey(0)
set consol on
restsector(cSect)
return

*f*****************************************************************************
* Deletes an element from an array and shrinks the array by 1
procedure aRemove ( aIn_arr , nIndex)
local nLen
nLen = len(aIn_arr)
if nLen < 1
  return
endif
if nIndex > nLen
  return
endif
adel(aIn_arr, nIndex)
asize(aIn_arr, nLen-1)
return

* eof()
