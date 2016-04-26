*******************************************************************************
*
* PROGRAM ACCSHOW - DISPLAY STD ACCOUNTS
*
*******************************************************************************
DO SIMHEAD WITH PSCR_TITLE
@2,10 SAY 'Accounts for ' + TRIM(STD->TITLE) + ' ' + TRIM(STD->NAME) + ' ' + TRIM(STD->SURNAME)
@3,10 SAY 'Account no   ' + STD->STD_CODE + ' ' + STD->REP
@4,10 SAY 'Amounts payable'
@4,50 SAY 'Payments to date'
DO CASE
  CASE STD->STATUS = 'C'
    @2,70 SAY 'Current'
  CASE STD->STATUS = 'N'
    @2,70 SAY 'New Stud'
  CASE STD->STATUS = 'F'
    @2,70 SAY 'Finished'
  CASE STD->STATUS = 'S'
    @2,70 SAY 'Suspended'
  CASE STD->STATUS = 'U'
    @2,70 SAY 'Unpaid'
ENDCASE
IF STD->DEAL_REF = 'S' .OR. STD->DEAL_REF = 'T'
  @3,70 SAY 'Splt dep'
ENDIF
IF STD->DEAL_REF = 'R' .OR. STD->DEAL_REF = 'T'
  @4,70 SAY 'Referal'
ENDIF
@5,3 SAY 'Agreed dt      Amount    Paid'
@5,47 SAY 'Pmt date        Amount    Type'
@6,0 SAY REPLICATE('-',80)
MSTD = STD->STD_CODE
GO TOP
SEEK MSTD
MPMT_TYPE = PMT_TYPE
@3,40 SAY 'Payment type'
DO CASE
  CASE MPMT_TYPE = 'Q'
    @3,54 SAY 'Cheque'
    @5,35 SAY 'Cq hld'  
  CASE MPMT_TYPE = 'C'
    @3,54 SAY 'Credit card'
  CASE (MPMT_TYPE = 'D' .OR. MPMT_TYPE = 'E')
    @3,54 SAY 'Debit order'
  CASE MPMT_TYPE = 'O'
    @3,54 SAY 'Other'
ENDCASE
CROW = 7
DROW = 7
MAMT_CURRENT = 0
MAMT_ARREAR = 0
MTOTAL = 0
DO WHILE MSTD = STD_CODE .AND. (.NOT. EOF())
  IF CR_DR = 'D'
    @DROW,2 SAY PMT_TYPE + ' ' + DTOC(PMT_DT) + STR(AMOUNT,13,2)
    IF COMMENT = 'B'
      @DROW,30 SAY 'Y'
    ELSE
      IF PMT_TYPE = 'Q'
        @DROW,38 SAY COMMENT
      ENDIF
    ENDIF
    MTOTAL = MTOTAL + AMOUNT
    IF COMMENT <> 'B'
      MDT1 = ADDMONTH(PMT_DT)    
      IF MDT1 < DATE()
        MAMT_ARREAR = MAMT_ARREAR + AMOUNT
      ELSE
        IF PMT_DT <= DATE()
          MAMT_CURRENT = MAMT_CURRENT + AMOUNT
        ENDIF
      ENDIF
    ENDIF
    DROW = DROW + 1
  ELSE
    IF COMMENT <> 'C'
      @CROW,47 SAY DTOC(PMT_DT) + STR(AMOUNT,14,2) + '      ' + PMT_TYPE
      CROW = CROW + 1
    ENDIF
  ENDIF
  SKIP
ENDDO (STUDENTS ACCOUNTS)
@23,1 SAY 'TOTAL FOR COURSE = ' + STR(MTOTAL,10,2)
IF (MAMT_CURRENT + MAMT_ARREAR) > 0
  @22,40 SAY 'CURRENTLY DUE = ' + STR(MAMT_CURRENT,10,2)
  @23,40 SAY 'ARREARS DUE   = ' + STR(MAMT_ARREAR,10,2)
ENDIF
RETURN
* EOF