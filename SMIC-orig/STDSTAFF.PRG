*******************************************************************************
* 'STDCLASS' - PRINT TOP 10 STUDENTS
* JIM WEST
* 4/88

local aTop[0], aStd_code[0], nNtx, lIns, nMax
nMax = 0

simhead(memvar->pscr_title)
@5,10 say 'PRINTING TEN BEST STAFF OF THE WEEK'

IF MAKE_SURE(12,25,'Do you want to continue ?')
  SELECT STD
  SET INDEX TO STDCODE
  GO TOP
  OPENPRN()
  SUBTITLE = 'Staff performance on "TWIN"'
  MCNT = 0
  DO WHILE !EOF()
    @15,20 SAY STD_CODE + ' ' + SURNAME
    IF STATUS = 'C' .AND. REP = 'ZZ'
      AADD(aTop, -999999999)
      AADD(aStd_code, NIL)
      nMax++
      nNtx = 1
      lIns = .F.
      DO WHILE nNtx < nMax .AND. !lIns
        IF MNTH_CHANG > aTop[nNtx]
          AINS(aTop, nNtx)
          AINS(aStd_code, nNtx)
          aTop[nNtx] = MNTH_CHANG
          aStd_code[nNtx] = STD_CODE
          lIns = .T.
        ENDIF
        nNtx++
      ENDDO
    ENDIF
    SKIP
  ENDDO

  PRNTITLE(SUBTITLE, 'Y')
  ? 'NAME                                                        ANN - MNTH           OVERALL      OVERALL - ANN'
  ? ' '
  FOR nNtx = 1 TO nMax
    SEEK aStd_code[nNtx]
    IF FOUND()
      ? TRIM(SURNAME) + ' ' + TRIM(NAME)
      MCOL = 60 - PCOL()
      MOVERPERF = (WEEK_1 / INITL_VAL * 100) - 100
      ?? REPLICATE(' ',MCOL) + STR(MNTH_CHANG,8,2) + '     ' + STR(MOVERPERF) + '      ' + STR(MOVERPERF * 52 / WK_SMLTN)
      PLINE++
    ENDIF
  NEXT
  ? ' '
  CLOSE DATABASE
  SHUTPRN()
ENDIF
RETURN
* EOF