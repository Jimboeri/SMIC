*******************************************************************************
* FINPRNT - PRINTS OUT ALL FINISHED STUDENTS
* JIM WEST
* 03/89

DRAW_BOX(4,2,20,76)
@6,20 SAY 'Printing finished students'

IF .NOT. MAKE_SURE()
  RETURN
ENDIF

SELECT 1
IF .NOT. NET_USE('TRANSACT', .F., 'TRN', 'TRANCODE')
  RETURN
ENDIF

SELECT 2
if !net_use('student', .f.,,'names')
  dbcloseall()
  return
endif

OPENPRN()
STITLE = 'STUDENTS THAT HAVE RECENTLY FINISHED'

GO TOP
DO WHILE !EOF()
  @16,20 SAY SURNAME
  IF STATUS = 'F'
    MSTD = STD_CODE
    IF PLINE > 60
      PRNTITLE(STITLE,'Y')
      ? 'ACC NO  NAME                                     REP FIN DT   PHONE HOME      PHONE WORK      PERFORM   ANNUAL   MARKET     DIFF'
      ? ' '
    ENDIF
    PLINE++
    ? STD_CODE + '  ' + TRIM(SURNAME) + ' ' + TRIM(TITLE) + ' ' + TRIM(NAME)
    MCOL = 50 - PCOL()
    ?? REPLICATE(' ',MCOL) + REP + ' ' + DTOC(LAST_TRAN) + ' ' + PHONE_H + ' ' + PHONE_W
    MPERF = (WEEK_4 / INITL_VAL *100) - 100
    ?? STR(MPERF,8,2) + ' '
    MANN = MPERF * 52 / WK_SMLTN
    ?? STR(MANN,8,2) + ' '
    SELECT TRN
    SEEK MSTD
    DO WHILE MSTD = STD_CODE .AND. TRN_TYPE <> 'FIN' .AND. .NOT. EOF()
      SKIP
    ENDDO
    IF MSTD = STD_CODE .AND. .NOT. EOF()
      JSE_PERF = ((QTY / student->START_INDX)*100)-100
      ?? STR(JSE_PERF,8,2) + ' '
      ?? STR((MPERF - JSE_PERF),8,2)
    ENDIF
    SELECT student
  ENDIF (STUDENT FINISHED)
  dbskip()
ENDDO

shutprn()
RETURN

*EOF