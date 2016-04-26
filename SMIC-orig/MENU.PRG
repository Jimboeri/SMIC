*******************************************************************************
* STUDENT AND ACCOUNTS MENU
* Author - Jim West
* 1/2/88
*******************************************************************************
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

DO WHILE .T.
  SIMHEAD(PSCR_TITLE)
  @3,30 
  TEXT
                             MAIN MENU

              OPTIONS :

              S     PROCESS STUDENTS





              E     EXIT TO OPERATING SYSTEM
  ENDTEXT
  @22,5 SAY 'SELECT OPTION '
  INKEY = inwait()
  cOption = upper(CHR(INKEY))
  DO CASE
    CASE cOption = 'E' .OR. INKEY = 0
      CLEAR
      CLEAR ALL
      QUIT
    CASE cOption = 'S'
      DO STDMENU
  ENDCASE
ENDDO
* EOF
