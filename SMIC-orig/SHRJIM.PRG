* PROGRAM 'SHRJIM' USED FOR EXTRACTING DIVIDENDS TO A TEXT FILE
* AUTHOR JIM WEST (E.T.)
* 1/2/88

DO SIMHEAD WITH PSCR_TITLE
@2,30 SAY 'Share dividend extract'

IF .NOT. NET_USE('SHRDESCR', .F., 'DES', 'SHRDESCR')
  RETURN
ENDIF

SET ALTERNATE TO HIST_DIV.TXT
SET ALTERNATE ON
SET CONSOLE OFF
?? '                   INTERIM               FINAL'
? 'SHARE            AMOUNT   L.D.R.     AMOUNT   L.D.R.'
? '---------------------------------------------------'
DO WHILE .NOT. EOF()
  @10,10 SAY SHARE
  IF DTOC(FIN_DIV_DT) <> '  /  /  ' .OR. DTOC(INT_DIV_DT) <> '  /  /  '
    ? SHARE + '     '
    IF DTOC(INT_DIV_DT) <> '  /  /  '
      ?? STR(INT_DIV) + 'c ' + DTOC(INT_DIV_DT) + '  '
    ELSE
      ?? SPACE(20)
    ENDIF
    IF DTOC(FIN_DIV_DT) <> '  /  /  '
      ?? STR(FIN_DIV) + 'c ' + DTOC(FIN_DIV_DT)
    ENDIF
  ENDIF
  SKIP
ENDDO (SHARE <> SPACE)
SET CONSOLE ON
SET ALTERNATE OFF
CLOSE ALTERNATE
CLOSE DATABASES
RETURN
* EOF
