*******************************************************************************
* MIA - LEAD & STUDENT HANDLING PROGRAM
* Author - Jim West
* 1/2/88
* ----     SET UP SYSTEM DEFAULTS

parameter param_1, param_2

local cOption

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

CLEAR TYPEAHEAD

#include "smic.ch"

SECURITY(PROCNAME())

setkey(-3, {|| to_do(mpw_nme) } )

MCNT = 1
MCONT = .T.

DO WHILE .T.
  SIMHEAD(PSCR_TITLE)
  @3,30
  TEXT
                             MAIN MENU

              OPTIONS :


              L     PROCESS LEADS

              A     PROCESS ADVERTS

              P     PRINT SALES REPORTS

              S     PROCESS STUDENTS

              M     PRINT MEDIA REPORTS


              E     EXIT TO OPERATING SYSTEM
ENDTEXT
  @21,5 CLEAR
  cOption = upper(chr(inwait()))
  DO CASE
    CASE cOption = 'E'
      CLEAR
      CLEAR ALL
      QUIT
    CASE cOption = 'L'
      CALL LDMENU
    CASE cOption = 'A'
      DO ADVMENU
    CASE cOption = 'P'
      CALL PRNTMENU
    CASE cOption = 'S'
      CALL STDMENU1
    CASE cOption = 'M'
      CALL MEDMENU
  ENDCASE
ENDDO

CLEAR
RETURN
* EOF
