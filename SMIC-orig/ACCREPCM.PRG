*******************************************************************************
* PROGRAM ACCREPCM PRINTS REPS BANKING (FOR COMMISSIONS)
* 14/3/88
* JIM WEST

LAST_RUN(PROCNAME())

SELECT 1
IF .NOT. NET_USE('ACCOUNT', .F., 'ACC', 'ACCCODE')
  RETURN
ENDIF

SELECT 3
IF .NOT. NET_USE('STUDENT', .F., 'STD', 'NAMES')
  CLOSE DATABASES
  RETURN
ENDIF

SIMHEAD(PSCR_TITLE)
@4,15 SAY 'Sales reps monthly banking'
MTH = 0
DO WHILE MTH < 1 .OR. MTH > 12
  @ 6,10 SAY 'Enter report month ' GET MTH PICTURE '99'
  READ
ENDDO
YR = 0
DO WHILE YR < 88 .OR. YR > 99
  @ 7,10 SAY 'Enter report year  ' GET YR PICTURE '99'
  READ
ENDDO
YR = YR + 1900

MREP = 'XX'
DO WHILE MREP <> '  '
  MREP = '  '
  MTYPE = ' '
  DO WHILE MTYPE <> 'R' .AND. MTYPE <> 'S' .AND. MTYPE <> 'N'
    @10,0 CLEAR
    WAIT 'Enter run type (Rep : Sales manager : National sales manager ' TO MTYPE
    STORE UPPER(MTYPE) TO MTYPE
  ENDDO
  @15,0 CLEAR
  @16,10 SAY 'or enter to leave program'
  @15,10 SAY 'Input sales person code ' GET MREP PICTURE '!!'
  READ
  SUBTITLE = 'BANKING FOR ' + MREP + ' FOR THE MONTH ' + STR(MTH,2,0) + '/' + STR(YR,4,0)
  IF MTYPE = 'S'
    SUBTITLE = '(SM) ' + SUBTITLE
  ENDIF
  IF MTYPE = 'N'
    SUBTITLE = '(NSM) ' + SUBTITLE
  ENDIF
  IF MREP <> '  '
    OPENPRN()
    MNEWBANK = 0
    MOLDBANK = 0
    PRNTITLE(SUBTITLE,'Y')
    SELECT 3
    ? ' ACC   NAME                                                       NEW      OLD       DATE     PMT       REP    SM   NSM'
    ? '  NO                                                              BANK     BANK     BANKED    TYPE'
    ? ' '
    PLINE = 6
    GO TOP
    DO WHILE !EOF()
      DO CASE
        CASE MTYPE = 'R'
          MCONS = REP
        CASE MTYPE = 'S'
          MCONS = S_M
        CASE MTYPE = 'N'
          MCONS = N_S_M
      ENDCASE
      IF MCONS = MREP
        MSTD = STD_CODE
        MARC = ARCHIV
        MMTH = MONTH(SOLD_CRS_1)
        SELECT 1
        GO TOP
        SEEK MSTD
        DO WHILE STD_CODE = MSTD .AND. (.NOT. EOF())
          IF CR_DR = 'C' .AND. MONTH(PMT_DT) = MTH .AND. YEAR(PMT_DT) = YR
            IF PLINE > 60
              PRNTITLE(SUBTITLE,'Y')
              ? ' ACC   NAME                                                       NEW      OLD       DATE     PMT       REP    SM   NSM'
              ? '  NO                                                              BANK     BANK     BANKED    TYPE'
              ? ' '
              PLINE = 6
            ENDIF
            ? STD_CODE, TRIM(STD->SURNAME) + ' ' + TRIM(STD->NAME)
            MCOL = 60 - PCOL()
            ?? REPLICATE(' ',MCOL)
            IF MMTH = MONTH(PMT_DT)
              ?? STR(AMOUNT,10,2) + '          '
              MNEWBANK = MNEWBANK + AMOUNT
            ELSE
              ?? '          ' + STR(AMOUNT,10,2)
              MOLDBANK = MOLDBANK + AMOUNT
            ENDIF
            ?? '    ' + DTOC(PMT_DT) + '     ' + PMT_TYPE + '       ' + STD->REP + '    ' + STD->S_M + '    ' + STD->N_S_M
            PLINE = PLINE + 1
          ENDIF (FORWARD BANK ACC REC)
          SKIP
        ENDDO (MSTD = STD_CODE)
      ENDIF (REP = MREP)
      SELECT 3
      SKIP
    ENDDO
    ? ' '
    ? 'TOTALS                                              ' + STR(MNEWBANK,14,2) + STR(MOLDBANK,14,2)
    ? 'GRAND TOTAL                                                        ' + STR(MNEWBANK + MOLDBANK)
    SHUTPRN()
  ENDIF (MREP = SPACE)
ENDDO (MREP <> SPACE)
CLOSE DATABASES
RETURN
*EOF
