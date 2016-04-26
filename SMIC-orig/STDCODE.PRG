*******************************************************************************
* PROGRAM 'STDCODE'
* AUTHOR JIM WEST (E.T.)
* 1/2/88

SIMHEAD(PSCR_TITLE)

IF .NOT. NET_USE('STUDENT', .F., 'STD', 'STDCODE')
  RETURN
ENDIF

MSTD = '     '
@5,5 SAY 'Student code ' GET MSTD PICTURE '!!!!!'
READ
SEEK MSTD
IF .NOT. EOF()
  SIMHEAD(PSCR_TITLE)
  @3,1 SAY space(12) + 'Student view screen'
  MSTD_CODE = STD_CODE
  @4,1 CLEAR
  @5,5 SAY 'Account no. ' + STD_CODE
  @5,50 SAY 'Archive no ' + ARCHIV
  @6,1 SAY 'Title: ' + title
  @6,15 SAY 'First name: ' + NAME
  @7,15 SAY 'Surname:    ' + surname
  @8,63 SAY 'Status'
  DO CASE
    CASE STATUS = 'C'
      @8,70 SAY 'Current'
    CASE STATUS = 'N'
      @8,70 SAY 'New stud'
    CASE STATUS = 'S'
      @8,70 SAY 'Suspended'
    CASE STATUS = 'F'
      @8,70 SAY 'Finished'
    CASE STATUS = 'U'
      @8,70 SAY 'Unpaid'
    OTHERWISE
      @8,70 SAY 'INVALID'
  ENDCASE
  @9,1 SAY 'Postal address'
  @10,1 SAY address1
  @11,1 SAY address2
  @12,1 SAY address3
  @13,1 SAY 'Postal Code:    ' + P_CODE
  @15,1 SAY 'Phone-Home: ' + phone_h
  @15,30 SAY 'Phone-Work: ' + phone_w
  @17,1 SAY 'Rep ' + REP
  @17,10 SAY 'Sales manager ' + S_M
  @17,30 SAY 'Nat sales manager ' + N_S_M
  @18,1 SAY 'Length of Simulation  ' + STR(SIMLN_LEN,3,0)
  @19,1 SAY 'Start Date:       ' + DTOC(START_DT)
  @20,1 SAY 'Weeks on simultn       ' + STR(WK_SMLTN,3,0)
  @21,1 SAY 'Unactive weeks         ' + STR(WK_UNACT,3,0)
  @19,30 SAY 'Initial value      ' + STR(INITL_VAL,12,2)
  @21,30 SAY 'Last Transaction       ' + DTOC(LAST_TRAN)
  @18,65 SAY 'M1 ' + DTOC(SOLD_CRS_1)
  @19,65 SAY 'M2 ' + DTOC(SOLD_CRS_2)
  @20,65 SAY 'SS ' + DTOC(SOLD_SS)
  @21,65 SAY 'LC ' + DTOC(SOLD_LECTR)
  @22,0
  WAIT
*
ENDIF (NOT EOF)
CLOSE DATABASES
RETURN
* EOF