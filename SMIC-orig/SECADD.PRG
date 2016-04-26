*******************************************************************************
* PROGRAM 'SECADD'
* AUTHOR JIM WEST (E.T.)
* 1/10/87

IF .NOT. NET_USE('SECURITY', .F., 'SEC', 'SECURE')
  RETURN
ENDIF

STORE 'XXXXXXXXXX' TO MNAME
DO WHILE MNAME <> SPACE(10)
  SIMHEAD(PSCR_TITLE)
  @3,1 SAY space(12) + 'Initial data capture of a new card'
  MNAME = SPACE(20)
  @5,1 say 'Card holder ' get MNAME picture '!!!!!!!!!!'
  @10,5 SAY 'Enter name or hit enter to return to menu'
  READ
  IF MNAME <> SPACE(10)
    ADD_REC = 'Y'
    SEEK MNAME
    IF .NOT. (EOF() .OR. BOF())
      DISP_MSG(20,WARN_COL, 'CARD ALREADY EXISTS')
      INKEY(10)
    ELSE
      @5,14 CLEAR
      @6,1 CLEAR
      @5,14 SAY MNAME
      STORE SPACE(6) TO MPASS
      STORE 'N' TO MACC_1, MACC_2, MACC_3, MACC_4, MACC_5, MACC_6, MACC_7, MACC_8, MACC_9
      STORE 0 TO MLEVEL
      @7,10 SAY 'Initial password ' GET MPASS PICTURE '!!!!!!!!!!'
      @9,10 SAY 'Access to TWIN     ' GET MACC_1 PICTURE '!'
      @10,10 SAY 'Access to MENU     ' GET MACC_2 PICTURE '!'
      @11,10 SAY 'Access to CRSMAN   ' GET MACC_3 PICTURE '!' 
      @12,10 SAY 'Access to ETADMIN  ' GET MACC_4 PICTURE '!'
      @13,10 SAY 'Access to MIA      ' GET MACC_5 PICTURE '!'
      @14,10 SAY 'Access to PORTPRNT ' GET MACC_6 PICTURE '!'
      @15,10 SAY 'Unused             ' GET MACC_7 PICTURE '!' 
      @16,10 SAY 'Unused             ' GET MACC_8 PICTURE '!'
      @17,10 SAY 'Unused             ' GET MACC_9 PICTURE '!'
      @12,50 SAY 'Security level ' GET MLEVEL PICTURE '9'
      *
      READ
      APPEND BLANK
      RECLOCK('SECURITY')
      SEC->NAME := MNAME
      SEC->PASS_WORD := SCRAM(MPASS)
      SEC->ACC_1 := SCRAM(MACC_1)
      SEC->ACC_2 := SCRAM(MACC_2)
      SEC->ACC_3 := SCRAM(MACC_3)
      SEC->ACC_4 := SCRAM(MACC_4)
      SEC->ACC_5 := SCRAM(MACC_5)
      SEC->ACC_6 := SCRAM(MACC_6)
      SEC->ACC_7 := SCRAM(MACC_7)
      SEC->ACC_8 := SCRAM(MACC_8)
      SEC->ACC_9 := SCRAM(MACC_9)
      SEC->LEVEL := MLEVEL
      SEC->LST_PW_DT := DATE()
      UNLOCK
    ENDIF (REC NOT FOUND)
  ENDIF (NAMEE <> SPACE)
ENDDO (NAME <> SPACE)
CLOSE DATABASES
RETURN
* EOF