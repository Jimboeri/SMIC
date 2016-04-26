*******************************************************************************
*  Program STDGRADD add subordinates to a group portfolio
*  All fields are the same as the student LEADER except for the names
*  group numbers
*
*  Author - Jim West
*  3/90
*******************************************************************************

SELECT 1
IF .NOT. NET_USE('PARAM', .F.)
  RETURN
ENDIF

SELECT 3
IF .NOT. NET_USE('STUDENT', .F., 'STD', 'NAMES', 'STDARC', 'STDCODE', 'STDGROUP')
  RETURN
ENDIF

SIMHEAD(PSCR_TITLE)
FINDSTD()

IF .NOT. EOF()
  SIMHEAD(PSCR_TITLE)
  IF GROUP_NO <> '01'
    MLOOK = GROUP_CD + '01'
    SET INDEX TO STDGROUP
    SEEK MLOOK
    @4,10 SAY 'This is not a group leader - the leader is:' 
    @6,10 SAY TRIM(TITLE) + ' ' + TRIM(NAME) + ' ' + SURNAME
    INKEY(60)
  ELSE
    @4,10 SAY 'Is this the right person to be the leader'
    @6,10 SAY TRIM(TITLE) + ' ' + TRIM(NAME) + ' ' + SURNAME
    @8,10 SAY ADDRESS1
    @9,10 SAY ADDRESS2
    @10,10 SAY P_CODE + ' ' + ADDRESS3
    @8,50 SAY 'Tel (H) ' + PHONE_H
    @9,50 SAY 'Tel (W) ' + PHONE_W
    IF make_sure(12,,'Is the right person to be the group leader ?')
      STORE GROUP_CD TO MGROUP_CD
      STORE GROUP_NO TO MGROUP_NO
      STORE ADDRESS1 TO MADDRESS1
      STORE ADDRESS2 TO MADDRESS2
      STORE ADDRESS3 TO MADDRESS3
      STORE P_CODE TO MP_CODE
      STORE PHONE_H TO MPHONE_H
      STORE PHONE_W TO MPHONE_W
      STORE START_DT TO MSTART_DT
      STORE INITL_VAL TO MINITL_VAL
      STORE REP TO MREP
      STORE S_M TO MS_M
      STORE N_S_M TO MN_S_M
      STORE SIMLN_LEN TO MSIMLN_LEN
      STORE SOLD_CRS_1 TO MSOLD_CRS1
      STORE SOLD_CRS_2 TO MSOLD_CRS2
      STORE SOLD_ELS TO MSOLD_ELS
      STORE SOLD_SS TO MSOLD_SS
      STORE SOLD_LECTR TO MSOLD_LECTR
      STORE ARCHIV TO MARCHIV
      STORE GROUP_CD TO MGROUP_CD
      STORE START_INDX TO MSTART_INDX
      STORE WK_SMLTN TO MWK_SMLTN
      STORE STATUS TO MSTATUS
      STORE SIMLN_LEN TO MSIMLN_LEN
      STORE DEAL_REF TO MDEAL_REF
      STORE SPACE(4) TO MTITLE  
      STORE SPACE(20) TO MNAME
      STORE SPACE(30) TO MSURNAME
      @12,0 CLEAR
      @12,10 SAY 'Title   ' GET MTITLE PICTURE '!!!!'
      @12,25 SAY 'Name ' GET MNAME PICTURE '!!!!!!!!!!!!!!!!!!!!'
      @13,10 SAY 'Surname 'GET MSURNAME PICTURE '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
      @16,10 SAY 'Enter blank surname to finish adding members'
      READ
      IF MSURNAME <> SPACE(30)
        dbsetorder(3)						// stdcode
		dbgobottom()
        nNext_code = val(std_code) + 1
        dbsetorder(0)						// reset indices
        select param
        RECLOCK('Paramater')
        MGCODE = LTRIM(STR(nNext_code))
        DIGT = LEN(MGCODE)
        MGCODE = REPLICATE('0',5-DIGT) + MGCODE
        PARAM->NXT_STD_NO := nNext_code + 1
        IF MGROUP_CD = SPACE(5)
          MGRPCODE = LTRIM(STR(NXT_GRP_NO))
          DIGT = LEN(MGRPCODE)
          MGROUP_CD = REPLICATE('0',5-DIGT) + MGRPCODE
          PARAM->NXT_GRP_NO := NXT_GRP_NO + 1
        ENDIF
        UNLOCK
        select std
        RECLOCK('Student')
        STD->GROUP_CD := MGROUP_CD
        UNLOCK
        MLOOK = MGROUP_CD + '01'
        dbsetorder(4)					// stdgroup
        SEEK MLOOK
        MGNO = '  '
        DO WHILE GROUP_CD = MGROUP_CD .and. !eof()
          MGNO = GROUP_NO
          SKIP
        ENDDO
        dbsetorder(0)
        MGCD = VAL(MGNO)
        APPEND BLANK
        RECLOCK('Student')
        STD->GROUP_CD := MGROUP_CD
        MGCD = MGCD + 1
        IF MGCD < 10
          STD->GROUP_NO := '0' + LTRIM(STR(MGCD))
        ELSE
          STD->GROUP_NO := LTRIM(STR(MGCD))
        ENDIF
        STD->STD_CODE := MGCODE
        STD->GROUP_CD := MGROUP_CD
        STD->ARCHIV := MARCHIV
        STD->TITLE := MTITLE
        STD->NAME := MNAME
        STD->SURNAME := MSURNAME
        STD->ADDRESS1 := MADDRESS1
        STD->ADDRESS2 := MADDRESS2
        STD->ADDRESS3 := MADDRESS3
        STD->P_CODE := MP_CODE
        STD->PHONE_H := MPHONE_H
        STD->PHONE_W := MPHONE_W
        STD->START_DT := MSTART_DT
        STD->START_INDX := MSTART_INDX
        STD->WK_SMLTN := MWK_SMLTN
        STD->INITL_VAL := MINITL_VAL
        STD->CASH := MINITL_VAL
        STD->STATUS := MSTATUS
        STD->FUT_CASH := MINITL_VAL / 4
        STD->REP := MREP
        STD->S_M := MS_M
        STD->N_S_M := MN_S_M
        STD->SIMLN_LEN := MSIMLN_LEN
        STD->DEAL_REF := MDEAL_REF
        STD->SOLD_CRS_1 := MSOLD_CRS1
        STD->SOLD_CRS_2 := MSOLD_CRS2
        STD->SOLD_ELS := MSOLD_ELS
        STD->SOLD_SS := MSOLD_SS
        STD->SOLD_LECTR := MSOLD_LECTR
        UNLOCK
      ENDIF (SURNAME <> SPACE)
    ENDIF (Y TO CONFIRM)
  ENDIF (SELECTED STUDENT IS A LEADER)
ENDIF (STUDENT FOUND)
CLOSE DATABASES
RETURN

*EOF - STDGRADD
