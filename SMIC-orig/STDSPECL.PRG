*******************************************************************************
* STDSPECL
* JIM WEST
IF .NOT. NET_USE('STUDENT', .F., 'STD', 'NAMES')
  RETURN
ENDIF
SET FILTER TO (STATUS = 'N' .OR. STATUS = 'C') .AND. ( VAL(P_CODE) > 5199 .AND. VAL(P_CODE) < 5300)

DO SIMHEAD WITH PSCR_TITLE

@5,10 SAY 'Printing label for Transvaal students'
@7,10 SAY 'Load labels into printer and line them up'
WAIT

PRNTOK = .F.
DO WHILE .NOT. PRNTOK
  SET PRINT ON
  SET CONSOL OFF
  ? 'XXXXXXXXXXXXXXXXXXXXXXXXX            XXXXXXXXXXXXXXXXXXXXXXXXX'
  ? 'XXXXXXXXXXXXXXXXXXXXXXXXX            XXXXXXXXXXXXXXXXXXXXXXXXX'
  ? 'XXXXXXXXXXXXXXXXXXXXXXXXX            XXXXXXXXXXXXXXXXXXXXXXXXX'
  ? 'XXXXXXXXXXXXXXXXXXXXXXXXX            XXXXXXXXXXXXXXXXXXXXXXXXX'
  ? 'XXXX                                 XXXX'
  ? ' '
  ? ' '
  ? ' '
  ? ' '
  ?? ' '
  SET PRINT OFF
  SET CONSOL ON
  PRN = ' '
  DO WHILE PRN <> 'Y' .AND. PRN <> 'N'
    @9,10 CLEAR
    WAIT 'Are the labels correctly lined up? ' TO PRN
    STORE UPPER(PRN) TO PRN
  ENDDO
  IF PRN = 'Y'
    PRNTOK = .T.
    SET PRINT ON
    ? ' '
    SET PRINT OFF
  ENDIF
ENDDO
SET CONSOL OFF

LABEL FORM MAIL TO PRINT

SET CONSOL ON
CLOSE DATABASES
RETURN

*EOF