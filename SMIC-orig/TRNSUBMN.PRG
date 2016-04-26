*******************************************************************************
* PROGRAM 'TRNSUBMN' - TRANSACTION SUB-MENU
* Author - Jim West
* 1/2/88
DO SIMHEAD WITH PSCR_TITLE
@3,15 SAY TRIM(DTITLE) + '  ' + TRIM(DNAME) + '  ' + DSURNAME
IF MSTATUS <> 'C'
  @20,10 SAY 'STUDENT NOT CURRENT - MAY NOT TRANSACT'
ENDIF
INKEY1 = 200
DO WHILE INKEY1 <> 27 .AND. INKEY1 <> 0
  DO SIMHEAD WITH PSCR_TITLE
  @ 5,15
  TEXT
                TRANSACTION SUB MENU

              Choose from the menu below :
  
              1 = Make a bear sale
              2 = Deliver a bear sale
              3 = Exercise rights on NPL's
  
              5 = Take a LONG  position or cover a SHORT position
              6 = Take a SHORT position or cover a LONG  position
              7 = Display futures portfolio
  
            Esc = Return to Main Menu
  endtext
  @21,5 SAY 'Enter selection '
  INKEY1 = INKEY(60)
  OPTN1 = CHR(INKEY1)
  STORE UPPER(OPTN1) TO OPTN1
  DO CASE
    CASE OPTN1 = '1'
      IF MSTATUS = 'C'
        DO BEARSL
      ENDIF
    CASE OPTN1 = '2'
      IF MSTATUS = 'C'
        DO BEARBUY
      ENDIF
    CASE OPTN1 = '3'
      IF MSTATUS = 'C'
        DO TRNNPLEX
      ENDIF
    CASE OPTN1 = '5'
      IF MSTATUS = 'C'
        DO FUTLONG
      ENDIF
    CASE OPTN1 = '6'
      IF MSTATUS = 'C'
        DO FUTSHORT
      ENDIF
    CASE OPTN1 = '7'
      DO FUTDISP
  ENDCASE
ENDDO (INKET1 <> 27)
RETURN
* EOF