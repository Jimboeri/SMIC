*******************************************************************************
* PASPRNT - PORTFOLIO ADVISORY SERVICE PRINT-OUT
* JIM WEST
* 7/91

parameter param_1, param_2

LOCAL nPORT_NTX, nPORT_MAX, nCNT, nHOLD_LINE, cHOLD_LINE, nPERCPROF, nVAL
LOCAL nTOT_COST, nTOT_VAL, nTOT_PROF
LOCAL cP_ADDR1, cP_ADDR2, cP_ADDR3, cP_CODE, cPHONE_NO, cTWIN_CONT
LOCAL lVALUE, lPROFIT

private force_bw := .f., force_prfile := .f.

for nCnt = 1 to 2
  cParam = 'param_' + ltrim(str(nCnt,2,0))
  val_param = &cParam
  if valtype(val_param) = 'C'
    do case
      case upper(val_param) = '/B'
        force_bw = .t.
      case upper(val_param) = '/P'
        force_prfile = .t.
    endcase
  endif
next

PRIVATE aPORT_VAL[200, 3]

#include 'colour.ch'
#include "smic.ch"
#include 'printer.ch'
#include 'mouse.ch'
#include 'mouseini.ch'

SIMHEAD(PSCR_TITLE)

IF !MAKE_SURE(10,10,'Are you REALLY sure you want to print the ADVISORY print run ')
  RETURN
ENDIF

SELECT 9
IF !NET_USE('PARAM', .F.)
  RETURN
ENDIF
cP_ADDR1 = P_ADDR1
cP_ADDR2 = P_ADDR2
cP_ADDR3 = P_ADDR3
cP_CODE = P_CODE
cPHONE_NO = TRIM(PHONE_NO)
cTWIN_CONT = TRIM(TWIN_CONT)
CLOSE

SELECT 1
IF !NET_USE('STUDENT', .F., 'STD', 'NAMES')
  RETURN
ENDIF

SELECT 2
IF !NET_USE('PORTFOL', .F., 'PORT', 'PORTFOL')
  CLOSE DATABASES
  RETURN
ENDIF

SELECT 3
IF !NET_USE('SHARE', .F., 'SHR', 'SHRNAME')
  CLOSE DATABASES
  RETURN
ENDIF

SELECT 4
IF !NET_USE('SHRDESCR', .F., 'DES', 'SHRDESCR')
  CLOSE DATABASES
  RETURN
ENDIF

SET PRINTER TO PAS.TXT
OPENPRN()
SET PRINT ON
* Print Epson
?? CHR(27)
?? '{afxX'
* Print Courier
?? CHR(27)
?? '{s3T'
* Print Portrait
?? CHR(27)
?? '}l0R'
SELECT STD
DO WHILE !EOF()
  @10,10 SAY STD->SURNAME
  IF SOLD_PAS != CTOD('  /  /  ') .AND. P_STAT = 'C'

* LOAD ARRAY WITH PORTFOLIO VALUES

    nTOT_COST := nTOT_VAL := nTOT_PROF := nPORT_MAX := 0
    lVALUE = .T.
    lPROFIT = .T.
    SELECT PORT
    SEEK STD->STD_CODE + 'P'
    DO WHILE STD->STD_CODE = STD_CODE .AND. TYPE = 'P' .AND. !EOF()
      nPORT_MAX++
      aPORT_VAL[nPORT_MAX, 1] = SHARE
      aPORT_VAL[nPORT_MAX, 2] = QTY
      aPORT_VAL[nPORT_MAX, 3] = COST_HOLD
      IF QTY = 0
        lVALUE = .F.
        lPROFIT = .F.
      ENDIF
      IF COST_HOLD = 0
        lPROFIT = .F.
      ENDIF
      SKIP
    ENDDO

  * PRINT ADDRESS PAGE

    LINE1 = TRIM(STD->TITLE) + ' ' + SUBSTR(STD->NAME,1,1) + ' ' + STD->SURNAME
    ? ' '
    ? SPACE(65) + 'R S A'
    ? SPACE(61) + 'POSTAGE PAID'
    FOR nCNT = 1 TO 14
      ? ' '
    NEXT
    ? SPACE(9) + LINE1
    ? SPACE(9) + STD->ADDRESS1
    ? SPACE(9) + STD->ADDRESS2
    ? SPACE(9) + STD->ADDRESS3
    ? SPACE(9) + STD->P_CODE
    ? ' '
    FOR nCNT = 1 TO 29
      ? ' '
    NEXT
    ? '     From ' + cCo_name
    ? '     ' + cP_ADDR1
    ? '     ' + cP_ADDR2
    ? '     ' + cP_CODE + ' ' + cP_ADDR3
    ? ' '
    ? '     Telephone ' + cPHONE_NO
    * Page Throw
    ?? CHR(12)

  * PRINT HOLDING COMMENTS

    STITLE = 'PORTFOLIO ADVISORY PRINTOUT FOR ' + TRIM(STD->TITLE) + ' ' + TRIM(STD->NAME) + ' ' + TRIM(STD->SURNAME)
    PPAGE = 0
    PRNTITLE(STITLE, 'N')

    IF nPORT_MAX = 0
      ? ' '
      ? 'We notice that you have not informed us of the shares in your portfolio,'
      ? 'or have liquidated your entire portfolio. To let us know what shares you'
      ? 'do have, please call ' + cTWIN_CONT + ' on weekdays between 9.00 a.m. and'
      ? '4.30 p.m. on ' + cPHONE_NO + ' and you will be given all the assistance you'
      ? 'need.'
    ELSE
      FOR nPORT_NTX = 1 TO nPORT_MAX
        SELECT SHR
        SEEK aPORT_VAL[nPORT_NTX, 1]
        SELECT DES
        SEEK aPORT_VAL[nPORT_NTX, 1]
        nHOLD_LINE = 6
        FOR nCNT = 6 TO 1 STEP -1
          cHOLD_LINE = 'DES->HOLD_' + LTRIM(STR(nHOLD_LINE))
          IF &cHOLD_LINE = SPACE(80)
            nHOLD_LINE--
          ELSE
            EXIT
          ENDIF
        NEXT
        IF (PLINE + 4 + nHOLD_LINE) > 64
          PRNTITLE(STITLE, 'N')
        ENDIF
        ? SHR->FULL_NAME
        ? ' '
        FOR nCNT = 1 TO nHOLD_LINE
          cHOLD_LINE = 'DES->HOLD_' + LTRIM(STR(nCNT))
          ? &cHOLD_LINE
        NEXT
        ? ' '
        ? ' '
        PLINE += 4
        PLINE += nHOLD_LINE
      NEXT
  
  * PRINT PORTFOLIO SUMMARY

      IF (PLINE + 9 + nPORT_MAX) > 64
        PRNTITLE(STITLE, 'N')
      ENDIF
      
      ? ' '
      ? ' P O R T F O L I O   S U M M A R Y'
      ?? CHR(15)
      ? ' '
      ? '               CURRENT       NO OF        CURRENT        COST OF            %             PROFIT'
      ? 'SHARE           PRICE        SHARES        VALUE         HOLDING          CHANGE          / LOSS'
      ? REPLICATE('-',132)
      FOR nPORT_NTX = 1 TO nPORT_MAX
        SELECT SHR
        SEEK aPORT_VAL[nPORT_NTX, 1]
        PLINE++
        ? aPORT_VAL[nPORT_NTX, 1] + '    ' + STR(SHR->Y_CL_PR / 100,9,2) + '  '
        IF aPORT_VAL[nPORT_NTX, 2] != 0
          nVAL = (aPORT_VAL[nPORT_NTX, 2] * SHR->Y_CL_PR / 100)
          nVAL -= (BROKER(nVAL) + HANDLE())
          ?? STR(aPORT_VAL[nPORT_NTX, 2],10,0) + ' ' + STR(nVAL,14,2) + '  '
          nTOT_VAL += nVAL
        ENDIF
        IF aPORT_VAL[nPORT_NTX, 2] != 0 .AND. aPORT_VAL[nPORT_NTX, 3] != 0
          nPERCPROF = (nVAL / aPORT_VAL[nPORT_NTX, 3] * 100) - 100
          ?? STR(aPORT_VAL[nPORT_NTX, 3],14,2) + '   ' + STR(nPERCPROF,12,2)
          ?? '   ' + STR((nVAL - aPORT_VAL[nPORT_NTX, 3]),14,2)
          nTOT_COST += aPORT_VAL[nPORT_NTX, 3]
          nTOT_PROF += (nVAL - aPORT_VAL[nPORT_NTX, 3])
        ENDIF
      NEXT  
      ? REPLICATE('-',132)
      ? '  TOTALS                           '
      IF lVALUE
        ?? STR(nTOT_VAL,14,2) + '  '
      ENDIF
      IF lPROFIT
        ?? STR(nTOT_COST,14,2) + '                  ' + STR(nTOT_PROF,14,2)
      ENDIF
      ? REPLICATE('-',132) + CHR(18)
      IF !lVALUE
        ? ' '
        ? 'If you let us know the quantity of the various shares that you hold, we'
        ? 'will be able to let you know the value of your portfolio with each printout.'
      ENDIF
      IF !lPROFIT
        ? ' '
        ? 'If you let us know how much you paid for your shares we will be able to tell'
        ? 'how much profit/loss you are making on your shares.'
      ENDIF
    ENDIF
    ?? CHR(12)
  ENDIF
  SELECT STD
  SKIP
ENDDO
SHUTPRN()
clear

CLOSE DATABASES

RETURN

* EOF()