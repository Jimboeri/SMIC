*******************************************************************************
*
*  STDADDR - MARKS STUDENT AS INCORRECTLY ADDRESSED
*  APRIL 90
*
*******************************************************************************

SELECT 2
IF .NOT. NET_USE('FINISHED', .F., 'FIN')
  CLOSE DATABASES
  RETURN
ENDIF

SELECT 3
IF .NOT. NET_USE('STUDENT', .F., 'STD', 'STDCODE')
  CLOSE DATABASES
  RETURN
ENDIF

SIMHEAD(PSCR_TITLE)

MSTD = 'XXXXX'
DO WHILE MSTD <> SPACE(5)
  @3,0 CLEAR
  MSTD = SPACE(5)
  @5,10 SAY 'Enter Student number ' GET MSTD
  READ
  IF MSTD <> SPACE(5)
    SELECT 3
    SEEK MSTD
    IF FOUND()
      @8,10 SAY TRIM(TITLE) + ' ' + TRIM(NAME) + ' ' + SURNAME  
      @9,10 SAY ADDRESS1
      @10,10 SAY ADDRESS2
      @11,10 SAY P_CODE + ' ' + ADDRESS3
      MYN = ' '
      MINKEY = 200
      IF MAKE_SURE(14,,'Mark this student as incorrectly addressed ')
        RECLOCK('STUDENT')
        STD->ADDR_INCOR := 'Y'
        UNLOCK
      ENDIF
    ELSE
      SELECT 2
      GO TOP
      DO WHILE MSTD <> STD_CODE .AND. .NOT. EOF()
        SKIP
      ENDDO
      IF .NOT. EOF()
        @8,10 SAY TRIM(TITLE) + ' ' + TRIM(NAME) + ' ' + SURNAME  
        @9,10 SAY ADDRESS1
        @10,10 SAY ADDRESS2
        @11,10 SAY P_CODE + ' ' + ADDRESS3
        MYN = ' '
        MINKEY = 200
        DO WHILE MYN <> 'N' .AND. MYN <> 'Y' .AND. MINKEY <> 27 .AND. MINKEY <> 0
          @14,10 SAY 'Mark this student as incorrectly addressed '
          MINKEY = INKEY(60)
          MYN = UPPER(CHR(MINKEY))
        ENDDO
        IF MYN = 'Y'
          RECLOCK('FINISHED')
          REPLACE KILLED WITH 'Y'
          UNLOCK
        ENDIF (MYN = Y)
      ENDIF (FINISHED RECORD FOUND)
    ENDIF (STUDENT FOUND)
  ENDIF (STD_CODE ENTERED)
ENDDO

CLOSE DATABASES
RETURN

* EOF