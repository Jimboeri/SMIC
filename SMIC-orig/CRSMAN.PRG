*******************************************************************************
* COURSE MANAGERS PROGRAM
* Author - Jim West
* 1/2/88

parameter param_1, param_2

local nKey, cChoice

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

#include "smic.ch"
#include 'mouse.ch'

public oMouse := mousenew()
public _is_mouse := .f.
m_init(oMouse)
m_goto(oMouse)

SECURITY(PROCNAME())

setkey(-3, {|| to_do(mpw_nme) } )

CLEAR
MLCNT = 1
DNLDATE = DATE()
MDOW = DOW(DNLDATE)
IF MDOW = 2
  DNLDATE = DATE() - 3
ELSE
  DNLDATE = DATE() - 1
ENDIF
CNLDATE = DTOC(DNLDATE)
BNLDATE = SUBSTR(CNLDATE,7,2) + SUBSTR(CNLDATE,4,2) + SUBSTR(CNLDATE,1,2) + '.MSG'
ENLDATE = BNLDATE
@0,0 CLEAR
IF FILE(BNLDATE)
  TYPE &BNLDATE
ELSE
  @10,10 SAY 'MESSAGE FILE DOES NOT EXIST'
  @15,10 SAY BNLDATE
ENDIF
FOR MLCNT = 1 TO 23
  @MLCNT,40 SAY CHR(186)
NEXT
SET COLOR TO +W/N
@23,1 SAY 'F2'
@23,20 SAY 'F3'
@23,40 SAY 'F4'
@23,60 SAY 'F5'
SET COLOR TO W/N
@23,4 SAY 'Previous'
@23,23 SAY 'Next'
@23,43 SAY 'Yesterday'
@23,63 SAY 'Problem shares'
MCHAR = ' '
nKey = 0
DO WHILE nKey <> 27 .AND. nKey <> 32 .AND. nKey <> 13
  @23,0 SAY ' '
  nKey = inwait()
  mchar = upper(chr(nKey))
  DO CASE
    CASE nKey = -1
      DNLDATE--
      MDOW = DOW(DNLDATE)
      DO WHILE MDOW < 2 .OR. MDOW > 6
        DNLDATE--
        MDOW = DOW(DNLDATE)
      ENDDO
      CNLDATE = DTOC(DNLDATE)
      BNLDATE = SUBSTR(CNLDATE,7,2) + SUBSTR(CNLDATE,4,2) + SUBSTR(CNLDATE,1,2) + '.MSG'
      @0,0 CLEAR
      IF FILE(BNLDATE)
        TYPE &BNLDATE
      ELSE
        @10,10 SAY 'MESSAGE FILE DOES NOT EXIST'
        @15,10 SAY BNLDATE
      ENDIF
      FOR MLCNT = 1 TO 23
        @MLCNT,40 SAY CHR(186)
      NEXT
    CASE nKey = -2
      DNLDATE++
      MDOW = DOW(DNLDATE)
      DO WHILE MDOW < 2 .OR. MDOW > 6
        DNLDATE++
        MDOW = DOW(DNLDATE)
      ENDDO
      CNLDATE = DTOC(DNLDATE)
      BNLDATE = SUBSTR(CNLDATE,7,2) + SUBSTR(CNLDATE,4,2) + SUBSTR(CNLDATE,1,2) + '.MSG'
      @0,0 CLEAR
      IF FILE(BNLDATE)
        TYPE &BNLDATE
      ELSE
        @10,10 SAY 'MESSAGE FILE DOES NOT EXIST'
        @15,10 SAY BNLDATE
      ENDIF
      FOR MLCNT = 1 TO 23
        @MLCNT,40 SAY CHR(186)
      NEXT
    CASE nKey = -3
      @0,0 CLEAR
      IF FILE(ENLDATE)
        TYPE &ENLDATE
      ELSE
        @15,10 SAY ENLDATE
        @10,10 SAY 'MESSAGE FILE DOES NOT EXIST'
      ENDIF
      FOR MLCNT = 1 TO 23
        @MLCNT,40 SAY CHR(186)
      NEXT
    CASE nKey = -4
      @0,0 CLEAR
      IF FILE('PROBSHR.TXT')
        TYPE PROBSHR.TXT
      ENDIF
  ENDCASE
  SET COLOR TO +W/N
  @23,1 SAY 'F2'
  @23,20 SAY 'F3'
  @23,40 SAY 'F4'
  @23,60 SAY 'F5'
  SET COLOR TO W/N
  @23,4 SAY 'Previous'
  @23,23 SAY 'Next'
  @23,43 SAY 'Yesterday'
  @23,63 SAY 'Problem shares'
ENDDO

STORE ' ' TO cChoice
nKey = 200
DO WHILE nKey <> 27 .AND. nKey <> 0
  SIMHEAD(PSCR_TITLE)
  @ 3,15
  TEXT
               COURSE MANAGER'S PROGRAM

            Choose from the menu below :


            S = Share database maintainance


            T = Transaction maintainance


            D = Student maintainance



            E = Return to D O S

F1 for help
  endtext
  @21,5 CLEAR
  nKey = inwait()
  cChoice = upper(chr(nKey))
  DO CASE
    CASE cChoice = 'S'
      DO CRS1
    CASE cChoice = 'T'
      DO CRS2
    CASE cChoice = 'D'
      DO CRS3
    CASE cChoice = 'E'
      CLEAR
      CLEAR ALL
      RETURN
  ENDCASE
  cChoice = ' '
ENDDO
RETURN

*EOF