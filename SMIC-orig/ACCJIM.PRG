* PROGRAM ACCCOMM PRINTS REPS COMMISSIONS
* 14/3/88
* JIM WEST

SELECT 1
IF .NOT. NET_USE('ACCOUNT', .F., 'ACC', 'ACCCODE')
  RETURN
ENDIF

SELECT 2
IF .NOT. NET_USE('REPS', .F., 'REP', 'REPS')
  CLOSE DATABASES
  RETURN
ENDIF

SELECT 3
IF .NOT. NET_USE('STUDENT', .F., 'STD', 'NAMES')
  CLOSE DATABASES
  RETURN
ENDIF

SELECT 4
IF .NOT. NET_USE('PARAM')
  CLOSE DATABASES
  RETURN
ENDIF

SIMHEAD(PSCR_TITLE)
@4,15 SAY 'Sales reps monthly banking'

@7,10 SAY 'Commission period from ' + DTOC(START_COMM) + ' to ' + DTOC(END_COMM)
YESNO = 'X'
DO WHILE YESNO <> ' ' .AND. YESNO <> 'N' .AND. YESNO <> 'Y'
  @8,10 CLEAR
  WAIT 'Do you want to change this ? ' TO YESNO
  STORE UPPER(YESNO) TO YESNO
ENDDO
MSTART_COMM = START_COMM
MEND_COMM = END_COMM

IF YESNO = 'Y'
  @11,10 SAY 'Start of commission period ' GET MSTART_COMM PICTURE '@D'
  @13,10 SAY 'End of commission period   ' GET MEND_COMM PICTURE '@D'
  READ
  RECLOCK('Parameter')
  REPLACE START_COMM WITH MSTART_COMM
  REPLACE END_COMM WITH MEND_COMM
  UNLOCK
  @7,0 CLEAR
  @7,10 SAY 'Commission period from ' + DTOC(START_COMM) + ' to ' + DTOC(END_COMM)
ENDIF
@8,0 CLEAR

OPENPRN()
SELECT REP
MREP = 'XX'
DO WHILE !EOF()
  MREP = SALESPSN
  IF LEVEL != 'B'
    @9,10 SAY 'PROCESSING REP ' + MREP
    MTYPE = LEVEL
    MSMTOT = 0
    MSMDEALS = 0
    MNSMTOT = 0
    MNSMTOT = 0
    DO CASE
      CASE MTYPE = 'R'
        MRUNTYPE = 3
      CASE MTYPE = 'S'
        MRUNTYPE = 2
      CASE MTYPE = 'N'
        MRUNTYPE = 1
    ENDCASE
    DO WHILE MRUNTYPE <= 3
      DO CASE
        CASE MRUNTYPE = 3
          MTYPE = 'R'
        CASE MRUNTYPE = 2
          MTYPE = 'S'
        CASE MRUNTYPE = 1
          MTYPE = 'N'
      ENDCASE
      MRUNTYPE++
      MDEALS = 0
      SUBTITLE = 'COMMISSION FOR ' + MREP + ' FROM ' + DTOC(MSTART_COMM) + ' TO ' + DTOC(MEND_COMM)
      IF MTYPE = 'S'
        SUBTITLE = '(SM) ' + SUBTITLE
      ENDIF
      IF MTYPE = 'N'
        SUBTITLE = '(NSM) ' + SUBTITLE
      ENDIF
      MNEWBANK = 0
      MOLDBANK = 0
      MREF     = 0
      PRNTITLE(SUBTITLE,'Y')
      SELECT STD
      ? ' ACC   NAME                                                       NEW      OLD       DATE     PMT       REP    SM   NSM'
      ? '  NO                                                              BANK     BANK     BANKED    TYPE'
      ? ' '
      PLINE = 6
      GO TOP
      DO WHILE .NOT. EOF()
        @12,20 SAY STD->SURNAME
        MDDT = CTOD('01/01/80')
        DO CASE
          CASE MTYPE = 'R'
            MCONS = REP
          CASE MTYPE = 'S'
            MCONS = S_M
          CASE MTYPE = 'N'
            MCONS = N_S_M
        ENDCASE
        MFIN_PAY = .T.
        IF MCONS = MREP .AND. FIN_PAY <> 'Y'
          MSTD = STD_CODE
          MARC = ARCHIV
          MFIRST = 0
          M1DT = CTOD('  /  /  ')
          MMTH = MONTH(SOLD_CRS_1)
          SELECT ACC
          GO TOP
          SEEK MSTD
          DO WHILE STD_CODE = MSTD .AND. (.NOT. EOF())
            IF CR_DR = 'C'
              JPMT_DT = PMT_DT
              IF MFIRST = 0
                MFIRST = AMOUNT
                M1DT = PMT_DT
                IF STD->DEAL_REF = 'S' .OR. STD->DEAL_REF = 'T'
                  MRNO = RECNO()
                  SKIP
                  DO WHILE CR_DR <> 'C' .AND. STD_CODE = MSTD .AND. (.NOT. EOF())
                    SKIP
                  ENDDO
                  IF .NOT. EOF() .AND. STD_CODE = MSTD
                    JPMT_DT = PMT_DT
                    M1DT = PMT_DT
                  ELSE
                    JPMT_DT = CTOD('31/12/1999')
                    M1DT = CTOD('31/12/1999')
                  ENDIF
                  GOTO MRNO
                ENDIF (SPLIT DEPOSIT)
              ENDIF (MFIRST)
              IF JPMT_DT >= MSTART_COMM .AND. JPMT_DT <= MEND_COMM
                IF PLINE > 50
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
                IF MTYPE = 'R'
                  IF STD->DEAL_REF = 'R' .OR. STD->DEAL_REF = 'T'
                    MREF = MREF + AMOUNT
                    ?? '  R'
                  ELSE
                    ?? '   '
                  ENDIF
                ENDIF
                PLINE = PLINE + 1
              ENDIF (DATE CORRECT)
            ELSE
              IF COMMENT <> 'B'
                MFIN_PAY = .F.
              ENDIF
            ENDIF (FORWARD BANK ACC REC)
            IF PMT_DT > MDDT
              STORE PMT_DT TO MDDT
            ENDIF
            SKIP
          ENDDO (MSTD = STD_CODE)
          IF M1DT >= MSTART_COMM .AND. M1DT <= MEND_COMM .AND. COMMENT <> 'C'
            MDEALS++
            ?? '  *'
          ENDIF
          JM = 1
          FOR JM = 1 TO 3
            MDDT = et_addmonth(mddt)
          NEXT
          IF MDDT >= DATE()
            MFIN_PAY = .F.
          ENDIF
          SELECT STD
          IF MFIN_PAY
            RECLOCK('Student')
            REPLACE FIN_PAY WITH 'Y'
            UNLOCK
          ENDIF
        ENDIF (REP = MREP)
        SELECT STD
        SKIP
      ENDDO
      ? ' '
      ? 'TOTALS                                              ' + STR(MNEWBANK,14,2) + STR(MOLDBANK,14,2)
      IF MTYPE = 'R'
        ??  '     Referals = ' + STR(MREF)
      ENDIF
      MGRAND = MNEWBANK + MOLDBANK
      ? 'GRAND TOTAL                                                        ' + STR(MGRAND)
      ? '                                                                                     Orders for this month = ' + STR(MDEALS)
      ? ' '
      DO CASE
        CASE MTYPE = 'R'
          ? 'Commission at 20% of ' + STR(MGRAND) + ' = ' + STR(MGRAND / 5)
          MCOMM = MGRAND / 5
          IF MREF <> 0
            ? 'Referal fee at 5% of ' + STR(MREF) + ' = ' + STR(MREF / 20)
            MCOMM = MCOMM + (MREF / 20)
          ENDIF
        CASE MTYPE = 'S'
          ? 'Commission at 10% of ' + STR(MGRAND) + ' = ' + STR(MGRAND / 10)
          MSMTOT = MGRAND
          MSMDEALS = MDEALS
        CASE MTYPE = 'N'
          ? 'Commission at 5% of ' + STR(MGRAND) + ' = ' + STR(MGRAND / 20)
          MNSMTOT = MGRAND
          MNSMDEALS = MDEALS
      ENDCASE
    ENDDO
    SUBTITLE = 'COMMISSION SHEET FOR ' + MREP + ' FROM ' + DTOC(MSTART_COMM) + ' TO ' + DTOC(MEND_COMM)
    SELECT REP
    RECLOCK('REPS')
    REPLACE BANKING WITH MGRAND
    IF MSMTOT <> 0
      REPLACE BANKING WITH MSMTOT
    ENDIF
    IF MNSMTOT <> 0
      REPLACE BANKING WITH MNSMTOT
    ENDIF
    IF BANKING <> 0
      REPLACE LAST_COMM WITH DATE()
    ENDIF
    UNLOCK
  ENDIF (MREP = BRANCH)
  SELECT REP
  SKIP
ENDDO ()
SHUTPRN()
CLOSE DATABASES
RETURN
*EOF
