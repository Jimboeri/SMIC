*******************************************************************************
* THIS IS THE PROCEDURE FILE PROCFL
*
*******************************************************************************

#include "set.ch"
#include "error.ch"
#define NTRIM(n)                ( LTrim(Str(n)) )

*******************************************************************************
* PROCEDURE SIMHEAD - CLEARS SCREEN AND DISPLAYS COMPANY TITLE
*                     TIME AND DATE AT THE TOP OF THE SCREEN
*
*******************************************************************************
procedure simhead (co_title)
local width, cOrig
setcolor('w/n')
clear screen
setcolor('rb/n')
@1,2 say time()
@1,70 say date()
co_title = ltrim(trim(co_title))
co_title = ' ' + co_title + ' '
store INT((80-len(co_title))/2) to width
@1,0 say replicate('*', 80)
@1,width say co_title
setcolor('w/n,n/w,n,n,n/w')
return
* EOF (simhead)

*******************************************************************************
* PROCEDURE JW_HEAD - CLEARS SCREEN AND DISPLAYS COMPANY TITLE
*                     TIME AND DATE AT THE TOP OF THE SCREEN
*
*******************************************************************************
PROCEDURE JW_HEAD ( CO_TITLE )
LOCAL WIDTH
SETCOLOR(WHITE_BLACK)
@0,0,24,79 BOX '±±±±±±±±±'
SETCOLOR(YELL_BLUE)
@0,0 CLEAR TO 2,79
@0,0 TO 2,79
@1,2 SAY TIME()
@1,70 SAY DATE()
CO_TITLE = LTRIM(CO_TITLE)
CO_TITLE = RTRIM(CO_TITLE)
CO_TITLE = ' ' + CO_TITLE + ' '
STORE (80-LEN(CO_TITLE))/2 TO WIDTH
@1,WIDTH SAY CO_TITLE
SETCOLOR(BLUE_CYAN)
RETURN
* EOF (JW_HEAD)

*******************************************************************************
* PROCEDURE SIMTITLE - PRINT COMPANY TITLE, DATE, PAGE NUMBER AND
*                    A SUBHEADING AT THE TOP OF A NEW PAGE
*******************************************************************************
PROCEDURE SIMTITLE
PARAMETERS PLINE, PPAGE, SUBTITLE, MCOMP 
LOCAL PTOP, WIDTH, MTITLE
IF PPAGE <> 0
  ? pr_form_feed
else
  ? pr_reset
ENDIF
setprc(0,0)
PPAGE++
PTOP = LTRIM(PPNT_TITLE)
PTOP = RTRIM(PTOP)
STORE (60-LEN(PTOP))/2 TO WIDTH
?? DTOC(DATE()) 
?? REPLICATE(' ',WIDTH) + PTOP + REPLICATE(' ',WIDTH) + 'PAGE '
?? LTRIM(STR(PPAGE))
STORE TRIM(SUBTITLE) TO MTITLE
STORE (80-LEN(MTITLE))/2 TO WIDTH
? SPACE(WIDTH) + MTITLE
?  ' ' 
IF MCOMP = 'Y'
  ?? pr_compress
ENDIF
PLINE = 3
RETURN
* EOF (SIMTITLE)

*******************************************************************************
* PROCEDURE PRNTITLE - PRINT COMPANY TITLE, DATE, PAGE NUMBER AND
*                      A SUBHEADING AT THE TOP OF A NEW PAGE
*                      GLOBAL VARIABLES PLINE & PPAGE USED DIRECTLY
*******************************************************************************
PROCEDURE PRNTITLE
PARAMETERS SUBTITLE, MCOMP, Page_width
LOCAL PTOP, WIDTH, MTITLE, nPage_wdth
nPage_wdth = if((Page_width = NIL .or. valtype(Page_width) != 'N'), 80, Page_width)
IF PPAGE <> 0
  ? pr_form_feed
else
  ? pr_reset
ENDIF
PPAGE++
setprc(0,0)
PTOP = LTRIM(PPNT_TITLE)
PTOP = RTRIM(PTOP)
STORE ((nPage_wdth-20)-LEN(PTOP))/2 TO WIDTH
?? DTOC(DATE()) 
?? REPLICATE(' ',WIDTH) + PTOP + REPLICATE(' ',WIDTH) + 'PAGE '
?? LTRIM(STR(PPAGE))
STORE TRIM(SUBTITLE) TO MTITLE
STORE (nPage_wdth-LEN(MTITLE))/2 TO WIDTH
? SPACE(WIDTH) + MTITLE
?  ' ' 
IF MCOMP = 'Y'
  ?? pr_compress
ENDIF
PLINE := 3
RETURN
* EOF (SIMTITLE)

***********************************************************
FUNCTION OPENPRN
local cSector, aOptions, nChoice := 0, lOK := .f., getlist := {}
local lPR_ERROR := .t.
aOptions := {"Retry", "Quit"}
PPAGE = 0
PLINE = 90
cSector = savesector(8,20,18,60)
if valtype(force_prfile) = 'L' .and. force_prfile
  pr_fl = 'JIM.TXT             '
  draw_box(10,25,13,55)
  @11,28 say 'Enter print file name'
  @12,30 get pr_fl picture '!!!!!!!!!!!!!!!!!!!!'
  read
  if !empty(pr_fl)
    set printer to &pr_fl
  endif
  restsector(cSector)
endif
do while !lOK
  if empty(set(_SET_PRINTFILE))
    IF ISPRINTER()
      set print on
      set console off
      lOK = .t.
      lPR_ERROR = .f.
    else
      nChoice = 0
      do while (nChoice == 0)
        nChoice = Alert('Printer not ready', aOptions)
      enddo
      if nChoice == 2
        lOK = .t.
      endif
    endif
  else
    set print on
    set console off
    lOK = .t.
    lPR_ERROR = .f.
  endif
enddo
return(lPR_ERROR)

***********************************************************
PROCEDURE CLOSEPRN
local nCnt
for nCnt = 1 to 10
  if pRow() > 60
    exit
  endif
  ? ''
next
? '                  ---   XXX   ---'
?? pr_form_fe
?? pr_reset
SET PRINT OFF
SET CONSOL ON
RETURN


*******************************************************************************
* SHUTPRN - CLOSES PRINTER AND SENTS PRINT TO PRINTER
PROCEDURE SHUTPRN
local nCnt
for nCnt = 1 to 10
  if pRow() > 60
    exit
  endif
  ? ''
next
? '                  ---   XXX   ---'
?? pr_form_fe
?? pr_reset
SET PRINT OFF
SET CONSOL ON
SET PRINTER TO
SET PRINTER TO LPT1
RETURN

*******************************************************************************
* PROCEDURE BKSPACE - REMOVES LAST CHARACTER FROM A STRING
*
*******************************************************************************
FUNCTION BKSPACE
PARAMETERS PNAME
LOCAL PSTRING
PSTRING = substr(pname,1,len(pName)-1)
RETURN (PSTRING)
* EOF (BKSPACE)
 
*******************************************************************************
* FUNCTION ENDDAY - RETURNS NUMERICAL VALUE OF LAST DAY OF THE MONTH
*
*******************************************************************************
FUNCTION ENDDAY (nMONTH)
LOCAL nDAY
DO CASE
  CASE nMONTH = 4 .OR. nMONTH = 6 .OR. nMONTH = 9 .OR. nMONTH = 11
    nDAY = 30
  CASE nMONTH = 2
    nDAY = 28
  OTHERWISE
    nDAY = 31
ENDCASE
RETURN (nDAY)
* EOF (ENDDAY)

*******************************************************************************
* FUNCTION ADDMONTH - ADDS MONTH TO GIVEN DATE
*
*******************************************************************************
FUNCTION ADDMONTH ( INDATE)
LOCAL nYR, nMT, nDY, cCHARDT, dOUTDATE
nYR = YEAR(INDATE)
nMT = MONTH(INDATE)
nDY = DAY(INDATE)
nMT++
IF nMT = 13
  nYR++
  nMT = 1
ENDIF
IF nDY > 27
  nDY = ENDDAY(nMT)
ENDIF
cCHARDT = STR(nDY,2,0) + '/' + STR(nMT,2,0) + '/' + STR(nYR,4,0)
dOUTDATE = CTOD(cCHARDT)
RETURN (dOUTDATE)
* EOF (ADDMONTH)

***********************************************************
FUNCTION ACTDATE (INDATE)
LOCAL A_DT, MDAY
A_DT = .F.
DO WHILE .NOT. A_DT
  A_DT = .T.
  MDAY = UPPER(SUBSTR(CDOW(INDATE),1,3))
  IF MDAY = 'SAT' .OR. MDAY = 'SUN'
    A_DT = .F.
  ENDIF
  IF .NOT. A_DT
    INDATE++
  ENDIF
ENDDO
RETURN(INDATE)

*******************************************************************************
*  NET_USE function
*
*  Trys to open a file for exclusive or shared use.
*  SET INDEXes in calling procedure if successful.
*  Pass the following parameters
*    1. Character - name of the .DBF file to open
*    2. Logical - mode of open (exclusive/.NOT. exclusive)
*
*  Example:
*    IF NET_USE("Accounts", .T., 5)
*       SET INDEX TO Name
*    ELSE
*       ? "Account file not available"
*    ENDIF

FUNCTION NET_USE
PARAMETERS IN_FILE, EX_USE, ALIAS_NM, INDEX1, INDEX2, INDEX3, INDEX4
LOCAL JEX_USE, JCNTR, JCNTRFL, PORIG_COL, PSCR_SAVE

IF EX_USE = NIL
  JEX_USE = .F.
ELSE
  JEX_USE = EX_USE
ENDIF

PORIG_COL = SETCOLOR()
PSCR_SAVE = SAVESCREEN(18,10,22,70)

FTEST = IN_FILE + '.DBF'
IF .NOT. FILE(FTEST)
  SETCOLOR(BLACK_RED)
  DRAW_BOX(18,10,22,70)
  @20,25 SAY FTEST + ' DOES NOT EXIST - TELL E.T.'
  INKEY(5)
  SETCOLOR(PORIG_COL)
  RESTSCREEN(18,10,22,70,PSCR_SAVE)
  RETURN(.F.)
ENDIF

IF ALIAS_NM = NIL
  IF JEX_USE                                        && exclusive
    USE (IN_FILE) EXCLUSIVE
  ELSE
    USE (IN_FILE) SHARED                            && shared
  ENDIF
ELSE
  IF JEX_USE                                        && exclusive
    USE (IN_FILE) EXCLUSIVE ALIAS (ALIAS_NM)
  ELSE
    USE (IN_FILE) SHARED ALIAS (ALIAS_NM)           && shared
  ENDIF
ENDIF

IF NETERR()           && USE FAILS
  SETCOLOR(BLACK_RED)
  DRAW_BOX(18,10,22,70)
  @20,15 SAY 'NETWORK LOCK ON ' + TRIM(IN_FILE) + ' - PLEASE TRY LATER'
  INKEY(5)
  SETCOLOR(PORIG_COL)
  RESTSCREEN(18,10,22,70,PSCR_SAVE)
  RETURN(.F.)
ENDIF

FOR JCNTR = 1 TO 4
  JCNTRFL = 'INDEX' + LTRIM(STR(JCNTR))
  IF  &JCNTRFL <> NIL
    FTEST = &JCNTRFL + '.NTX'
    IF .NOT. FILE(FTEST)
      SETCOLOR(BLACK_RED)
      DRAW_BOX(18,10,22,70)
      @20,25 SAY &JCNTRFL + ' DOES NOT EXIST - TELL E.T.'
      SETCOLOR(PORIG_COL)
      RESTSCREEN(18,10,22,70,PSCR_SAVE)
      INKEY(5)
      RETURN(.F.)
    ENDIF
  ENDIF
NEXT

IF INDEX1 <> NIL
  IF INDEX2 <> NIL
    IF INDEX3 <> NIL
      IF INDEX4 <> NIL
        SET INDEX TO (INDEX1), (INDEX2), (INDEX3), (INDEX4)
      ELSE
        SET INDEX TO (INDEX1), (INDEX2), (INDEX3)
      ENDIF
    ELSE
      SET INDEX TO (INDEX1), (INDEX2)
    ENDIF
  ELSE
    SET INDEX TO (INDEX1)
  ENDIF
ENDIF

IF NETERR()
  SETCOLOR(BLACK_RED)
  DRAW_BOX(18,10,22,70)
  @20,22 SAY 'UNABLE TO OPEN INDEX ' + INDEX1 + ' ' + INDEX2 + ' ' + INDEX3 + ' ' + INDEX4
  SETCOLOR(PORIG_COL)
  RESTSCREEN(18,10,22,70,PSCR_SAVE)
  INKEY(5)
  RETURN(.F.)
ENDIF

RETURN(.T.)
* End - NET_USE

*******************************************************************************
* PROCEDURE BELWRITE
*
* - APPEND ASCII 10 & ASCII 13 TO END OF LINE TO BE WRITTEN
* - CALL FWRITE
* - CHECKS FOR ERROR CONDITIONS AND DISPLAY MESSAGE
*
*******************************************************************************
PROCEDURE BELWRITE
PARAMETERS FHANDLE, WLINE

WLINE = WLINE + CHR(13) + CHR(10)
IF FWRITE(FHANDLE, WLINE) <> LEN(WLINE)
  IF FERROR() <> 0
    @23,10 SAY 'DOS ERROR = ' + STR(FERROR())
    INKEY()
  ENDIF
ELSE
  BTLINE++
ENDIF
RETURN

* EOF()


*******************************************************************************
*
* FUNCTION MAKE_SURE - CHECKS FOR YES OR NO
*                      RETURNS BOOLEAN
*
*******************************************************************************
FUNCTION MAKE_SURE ( MY_COORD, MX_COORD, cSTRING1, cSTRING2, cRANGE)
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

cORIG_COLOR = SETCOLOR(WHITE_RED)
cSECTOR = DRAW_BOX(nY_COORD-1, nX_COORD-1, nY_COORD+nHIGHT-2, nX_COORD+nWIDTH+2)

cCHAR = ' '
DO WHILE cCHAR <> 'Y' .AND. cCHAR <> 'N'
  @nY_COORD,nX_COORD SAY cSTR1
  IF cSTRING2 != NIL
    @nY_COORD+1, nX_COORD SAY cSTRING2
  ENDIF
  nINKEY = INKEY(60)
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
ELSE
  RETURN(.F.)
ENDIF

* EOF()

*******************************************************************************
*
* PROCEDURE RECLOCK
*    CONTINUES TRYING RLOCK() ON A RECORD UNTIL SUCESSFUL
*
*******************************************************************************
PROCEDURE RECLOCK
PARAMETERS PFILE
LOCAL MLOCK, PSCREEN, PSTRING, PORIG_COLOR

MLOCK = 1
IF .NOT. RLOCK()
  PSTRING = 'Record in ' + TRIM(PFILE) + ' locked - tries = '
  PSCREEN = SAVESCREEN(19, 18, 22, 24 + LEN(PSTRING))
  PORIG_COLOR = SETCOLOR(BLACK_RED)
  DRAW_BOX(19, 18, 21, 22 + LEN(PSTRING))
  
  DO WHILE .NOT. RLOCK()
    @20,19 SAY PSTRING + LTRIM(STR(MLOCK))
    MLOCK++
    INKEY(2)
  ENDDO
  SETCOLOR(PORIG_COLOR)
  RESTSCREEN(19, 18, 22, 19+LEN(PSTRING)+8, PSCREEN)
ENDIF
RETURN

*EOF - RECLOCK

*******************************************************************************
*
* FUNCTION DRAW_BOX - DRAWS A BOX WITH SINGLE OR DOUBLE LINE AROUND
*                     AND WITH BACKGROUND SHADOWING
*       RETURNS SCREEN SECTOR INFORMATION
*
*******************************************************************************
FUNCTION DRAW_BOX (Y1, X1, Y2, X2, DOUBLE_LN)
LOCAL lDOUBLE, PSHADOW1, PSHADOW2, PINX, cSECT
cSECT = savesector(y1, x1, y2+1, x2+2)
lDOUBLE = IF(DOUBLE_LN != NIL, DOUBLE_LN, .F.)
PSHADOW1 = SAVESCREEN(Y2+1, X1+2, Y2+1, X2+2)
PSHADOW2 = SAVESCREEN(Y1+1, X2+1, Y2+1, X2+2)
FOR PINX = 2 TO LEN(PSHADOW1) STEP 2
  PSHADOW1 = STUFF(PSHADOW1, PINX, 1, CHR(08))
NEXT
FOR PINX = 2 TO LEN(PSHADOW2) STEP 2
  PSHADOW2 = STUFF(PSHADOW2, PINX, 1, CHR(08))
NEXT
@Y1, X1 CLEAR TO Y2, X2
IF lDOUBLE
  @Y1, X1 TO Y2, X2 DOUBLE
ELSE
  @Y1, X1 TO Y2, X2
ENDIF

RESTSCREEN(Y2+1, X1+2, Y2+1, X2+2, PSHADOW1)
RESTSCREEN(Y1+1, X2+1, Y2+1, X2+2, PSHADOW2)

RETURN(cSECT)

* EOF

*******************************************************************************
*
* PROCEDURE PROP_NOUN - CONVERT CHARACTER STRINGS TO UPPER CASE FOLLOWED
*                       BY LOWER CASE
*
*******************************************************************************
FUNCTION PROP_NOUN
PARAMETERS INSTRING
LOCAL JINSTR, JOUTSTR, JLEN, JCOUNT, INWORD
INWORD = .F.
JOUTSTR = ''
JINSTR = INSTRING
JLEN = LEN(INSTRING)
FOR JCOUNT = 1 TO JLEN
  IF .NOT. INWORD
    IF ISALPHA(SUBSTR(JINSTR,JCOUNT,1))
      JOUTSTR = JOUTSTR + UPPER(SUBSTR(JINSTR,JCOUNT,1))
      INWORD = .T.
    ELSE
      JOUTSTR = JOUTSTR + SUBSTR(JINSTR,JCOUNT,1)
    ENDIF
  ELSE
    IF ISALPHA(SUBSTR(JINSTR,JCOUNT,1))
      JOUTSTR = JOUTSTR + LOWER(SUBSTR(JINSTR,JCOUNT,1))
    ELSE
      JOUTSTR = JOUTSTR + SUBSTR(JINSTR,JCOUNT,1)
    ENDIF
    IF SUBSTR(JINSTR,JCOUNT,1) = ' '
      INWORD = .F.
    ENDIF
  ENDIF
NEXT
RETURN (JOUTSTR)
*EOF

*******************************************************************************
* FUNCTION ESC_UDF - UDF FOR MCHOICE
*
*******************************************************************************
FUNCTION ESC_UDF
PARAMETERS PMODE, PINX, PROW
DO CASE
  CASE PMODE = 3
    DO CASE
          CASE LASTKEY() = 27
            RETURN(0)
      CASE LASTKEY() = 13
            RETURN(1)
      OTHERWISE
            RETURN(2)
        ENDCASE
  CASE PMODE = 0
    RETURN(2)
ENDCASE
RETURN(0)
*EOF

*******************************************************************************
* FUNCTION ORIG_REC
*  THIS FUNCTION COPIES VALUES OF THE CURRENT DATABASES RECORD TO AN ARRAY
*  TO CHECK IF UPDATES ARE ALLOWED
*******************************************************************************
FUNCTION ORIG_REC
LOCAL REC_AR[FCOUNT()], PCNT
FOR PCNT = 1 TO FCOUNT()
  REC_AR[PCNT] := &(FIELD(PCNT))
NEXT
RETURN REC_AR

* EOF

***********************************************************
* FUNCTION SAVESECTOR
*          RETURNS SAVESCREEN() CHAR STRING PRECEEDED WITH COORDINATES
FUNCTION SAVESECTOR(nTOP, nLEFT, nBOTT, nRIGHT)
LOCAL sSCR
sSCR = STR(nTOP,2,0) + STR(nLEFT,2,0) + STR(nBOTT,2,0) + STR(nRIGHT,2,0)
sSCR += SAVESCREEN(nTOP, nLEFT, nBOTT, nRIGHT)
RETURN sSCR
*EOF()

***********************************************************
* FUNCTION RESTSECTOR
*          REPLACES SCREEN SECTOR FROM STRING FROM SAVESECTOR
FUNCTION RESTSECTOR(sIN_SCREEN)
LOCAL nTOP, nLEFT, nBOTT, nRIGHT
nTOP = VAL(SUBSTR(sIN_SCREEN,1,2))
nLEFT = VAL(SUBSTR(sIN_SCREEN,3,2))
nBOTT = VAL(SUBSTR(sIN_SCREEN,5,2))
nRIGHT = VAL(SUBSTR(sIN_SCREEN,7,2))
sIN_SCREEN = STUFF(sIN_SCREEN,1,8,'')
RESTSCREEN(nTOP, nLEFT, nBOTT, nRIGHT, sIN_SCREEN)
RETURN
*EOF()

***********************************************************
* FUNCTION DISP_MSG - DISPLAY CENTERED MESSAGES ON SCREEN
*                     AT A CERTAIN ROW
*    RETURNS STRING CONTAINING SCREEN SECTOR INFORMATION

FUNCTION DISP_MSG (PROW, PCOL, PMSG_1, PMSG_2, PMSG_3)
LOCAL MTOP, MLEFT, MRIGHT, MBOT, MLEN, MORIG_COL, cSECT

IF (PROW != NIL .and. VALTYPE(PROW) != 'N') .OR. (pcol != NIL .and. VALTYPE(PCOL) != 'C')
  RETURN
ENDIF

IF VALTYPE(PMSG_1) != 'C'
  RETURN
ENDIF

IF prow = NIL .or. PROW > 22
  MTOP = 10
ELSE
  MTOP = PROW
ENDIF
MBOT = MTOP + 2

MLEN = LEN(PMSG_1)

IF VALTYPE(PMSG_2) = 'C'
  IF LEN(PMSG_2) > MLEN
    MLEN = LEN(PMSG_2)
  ENDIF
  MBOT++
ENDIF

IF VALTYPE(PMSG_3) = 'C'
  IF LEN(PMSG_3) > MLEN
    MLEN = LEN(PMSG_3)
  ENDIF
  MBOT++
ENDIF

MLEFT = int((80-MLEN)/2)-3
MRIGHT = 80 - MLEFT

if pcol != NIL
  MORIG_COL = SETCOLOR(PCOL)
else
  MORIG_COL = SETCOLOR()
endif
cSECT = DRAW_BOX(MTOP, MLEFT, MBOT, MRIGHT)
@MTOP+1,((80-LEN(PMSG_1))/2) SAY PMSG_1
IF VALTYPE(PMSG_2) = 'C'
  @MTOP+2,((80-LEN(PMSG_2))/2) SAY PMSG_2
ENDIF
IF VALTYPE(PMSG_3) = 'C'
  @MTOP+3,((80-LEN(PMSG_3))/2) SAY PMSG_3
ENDIF
SETCOLOR(MORIG_COL)
RETURN(cSECT)
*EOF()

*******************************************************************************
FUNCTION ARR_WDTH ( aIN_ARRAY )
LOCAL nCNT, nWDTH
nWDTH = 0
IF LEN(aIN_ARRAY) > 0
  FOR nCNT = 1 TO LEN(aIN_ARRAY)
    IF LEN(aIN_ARRAY[nCNT]) > nWDTH
      nWDTH = LEN(aIN_ARRAY[nCNT])
    ENDIF
  NEXT
ENDIF
RETURN ( nWDTH )
*EOF

*******************************************************************************
FUNCTION GET_ARR(aIN_ARR, nIN_TOP, nIN_LEFT, cIN_COL, lEsc, cHeading, nIn_start, lVal)
LOCAL nTOP, nLEFT, nBOTT, nRIGHT, cSECT, cOrig_col, nWdt, nRet, lEscape, cHead
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
    nTOP = 7
  else
    nTOP = 7 + int(len(aIN_ARR)/2)
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
  nRet = achoice(nTop+1, nLeft+1, nBott-1, nRight-1, aIn_arr,lVal,,nStart)
else
  do while nRet = 0
    nRet = achoice(nTop+1, nLeft+1, nBott-1, nRight-1, aIn_arr,lVal,,nStart)
  enddo
endif

restsector(cSect)
setcolor(cOrig_col)
RETURN(nRet)

/***
*       Sys_Error()
*/
func Sys_Error(e)
local i, cMessage, aOptions, nChoice

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
// aOptions := {"Break", "Quit"}
aOptions := {"Quit"}

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
  if ( aOptions[nChoice] == "Break" )
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
end

close databases
cDt = dtoc(date())
cFl = substr(cDt,1,2) + substr(cDt,4,2) + substr(cDt,7,2)
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

/***
*       error_msg()
*/
static func error_msg(e)
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

***********************************************************
function jw_val_yn
local cVar, cVal
cVar = readvar()
cVal = &cVar
if (cVal $ 'YN')
  return(.t.)
else
  return(.f.)
endif
