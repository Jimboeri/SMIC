*******************************************************************************
* THIS PROGRAM SELECTS A PARTICULAR STUDENT
* 1/3/88
* JIM WEST
PARAMETER MST_CH
LOCAL MINKEY, MSCR, FOUND_STD, PCURRENT, PLOOOK, PNAME, PSURNAME, PCHAR
LOCAL DISP, DISPNO, MPARAM, PNME_TYPE
MSCR = SAVESCREEN(7,1,22,79)
DRAW_BOX(7,1,22,77)
FOUND_STD = .F.
PCURRENT = CHR(255)
PLOOK = CHR(255)
PNAME = ''
PSURNAME = ''
MPARAM = IF(MST_CH = NIL, .F., .T.)
PCHAR = ' '
PNME_TYPE = 'S'
DISP = 'S'
DISPNO = 2
DO WHILE .NOT. FOUND_STD
  IF PNME_TYPE = 'S'
    @8,24 SAY SPACE(30)
    @8,10 SAY 'ENTER SURNAME ' + PSURNAME
    IF MPARAM
      MINKEY = ASC(MST_CH)
      PCHAR = MST_CH
      MPARAM = .F.
    ELSE
      SET CONSOL OFF
      WAIT '' TO PCHAR
      SET CONSOL ON
      MINKEY = LASTKEY()
    ENDIF
    DO CASE
      CASE MINKEY = 27
        * ESCAPE
        GO BOTTOM
        SKIP
        RESTSCREEN(7,1,22,79, MSCR)
        RETURN
      CASE MINKEY = 13
        IF PCURRENT = CHR(255)
          FOUND_STD = .T.
        ELSE
          IF PLOOK = CHR(255)
            FOUND_STD = .T.
          ELSE
            PNME_TYPE = 'N'
            PSURNAME = SURNAME
            PLOOK = SURNAME
            @8,24 SAY SURNAME
          ENDIF
        ENDIF
      CASE MINKEY = 8
        PSURNAME = BKSPACE(PSURNAME)
        PLOOK = PSURNAME
      CASE MINKEY = 5
        SKIP-1
        PSURNAME = ''
        PCURRENT = SURNAME + NAME
        PLOOK = CHR(255)
      CASE MINKEY = 18
        SKIP - DISPNO
        IF BOF()
          GO TOP
        ENDIF
        PSURNAME = ''
        PCURRENT = SURNAME + NAME
        PLOOK = CHR(255)
     CASE MINKEY = 24	&& DOWN ARROW
        SKIP
        PSURNAME = ''
        PCURRENT = SURNAME + NAME
        PLOOK = CHR(255)
      CASE MINKEY = 3
        SKIP DISPNO
        IF EOF()
          GO BOTTOM
        ENDIF
        PSURNAME = ''
        PCURRENT = SURNAME + NAME
        PLOOK = CHR(255)
      CASE MINKEY = 93
        @8,2 CLEAR TO 21,76
        IF DISP = 'S'
          DISP = 'F'
        ELSE
          DISP = 'S'
        ENDIF
      CASE MINKEY = 91
        @8,2 CLEAR TO 21,76
        IF DISPNO = 2
          DISPNO = 5
        ELSE
          DISPNO = 2
        ENDIF
      OTHERWISE
        STORE UPPER(PCHAR) TO PCHAR
        PSURNAME = PSURNAME + PCHAR
        PLOOK = PSURNAME
    ENDCASE
  ELSE
    @9,24 SAY SPACE(30)
    @9,10 SAY 'ENTER NAME    ' + PNAME
    SET CONSOL OFF
    WAIT '' TO PCHAR
    SET CONSOL ON
    MINKEY = LASTKEY()
    DO CASE
      CASE MINKEY = 13
        FOUND_STD = .T.
      CASE MINKEY = 8
        PNAME = BKSPACE(PNAME)
        PLOOK = SURNAME + PNAME
      CASE MINKEY = 5
        SKIP-1
        PSURNAME = ''
        PNME_TYPE = 'S'
        PCURRENT = SURNAME + NAME
        PLOOK = CHR(255)
      CASE MINKEY = 24	&& DOWN ARROW
        SKIP
        PSURNAME = ''
        PNME_TYPE = 'S'
        PCURRENT = SURNAME + NAME
        PLOOK = CHR(255)
      CASE MINKEY = 93
        @8,2 CLEAR TO 21,76
        IF DISP = 'S'
          DISP = 'F'
        ELSE
          DISP = 'S'
        ENDIF
      CASE MINKEY = 91
        @8,2 CLEAR TO 21,76
        IF DISPNO = 2
          DISPNO = 5
        ELSE
          DISPNO = 2
        ENDIF
      OTHERWISE
        PCHAR = UPPER(PCHAR)
        PNAME = PNAME + PCHAR
        PLOOK = SURNAME + PNAME
    ENDCASE
  ENDIF
  GO TOP
  SAME_STD = .F.
  IF PLOOK = CHR(255)
    SEEK PCURRENT
  ELSE
    SEEK PLOOK
    IF EOF()
      PLOOK = BKSPACE(PLOOK)
      IF PNME_TYPE = 'S'
        PSURNAME = BKSPACE(PSURNAME)
      ELSE
        PNAME = BKSPACE(PNAME)
      ENDIF
      GO TOP
      SEEK PLOOK
    ENDIF
    IF PCURRENT = (SURNAME + NAME)
      SAME_STD = .T.
    ENDIF
    PCURRENT = SURNAME + NAME
  ENDIF
  NUM = 1
  IF PCHAR = ']' .OR. PCHAR = '['
    SAME_STD = .F.
  ENDIF
  IF DISP = 'S'
    @15,3 CLEAR TO 15,76
    @14,2 TO 16,75
    @15,3 SAY TITLE + ' ' + SURNAME + NAME
    DO CASE
      CASE STATUS = 'N'
        @15,65 SAY 'NEW STUD'
      CASE STATUS = 'S'
        @15,65 SAY 'SUSPENDED'
      CASE STATUS = 'F'
        @15,65 SAY 'FINISHED'
      CASE STATUS = 'U'
        @15,65 SAY 'UNPAID'
    ENDCASE
    IF .NOT. EOF()
      SKIP
    ENDIF
    IF PLOOK <> CHR(255)
      IF (SURNAME+NAME) <> PLOOK
        FOUND_STD = .T.
        NUM = 10
      ENDIF
    ENDIF
    GO TOP
    SEEK PCURRENT
    IF .NOT. FOUND_STD .AND. .NOT. SAME_STD
      SKIP
      DO WHILE NUM < DISPNO .AND. .NOT. EOF()
        NUM++
        @15+NUM,3 CLEAR TO 15+NUM,76
        @15+NUM,3 SAY TITLE + ' ' + SURNAME + NAME
        DO CASE
          CASE STATUS = 'N'
            @15+NUM,65 SAY 'NEW STUD'
          CASE STATUS = 'S'
            @15+NUM,65 SAY 'SUSPENDED'
          CASE STATUS = 'F'
            @15+NUM,65 SAY 'FINISHED'
          CASE STATUS = 'U'
            @15+NUM,65 SAY 'UNPAID'
        ENDCASE
        SKIP
      ENDDO
      GO TOP
      SEEK PCURRENT
      IF NUM < 10
        NUM = 1
        SKIP-1
      ENDIF
      DO WHILE NUM < DISPNO .AND. .NOT. BOF()
        NUM++
        @15-NUM,3 CLEAR TO 15-NUM,76
        @15-NUM,3 SAY TITLE + ' ' + SURNAME + NAME
        DO CASE
          CASE STATUS = 'N'
            @15-NUM,65 SAY 'NEW STUD'
          CASE STATUS = 'S'
            @15-NUM,65 SAY 'SUSPENDED'
          CASE STATUS = 'F'
            @15-NUM,65 SAY 'FINISHED'
          CASE STATUS = 'U'
            @15-NUM,65 SAY 'UNPAID'
        ENDCASE
        SKIP-1
      ENDDO
      GO TOP
      SEEK PCURRENT
    ENDIF
  ELSE
    @15,3 CLEAR TO 16,76
    @14,2 TO 17,75
    @15,3 SAY TITLE + ' ' + SURNAME + NAME
    DO CASE
      CASE STATUS = 'N'
        @15,65 SAY 'NEW STUD'
      CASE STATUS = 'S'
        @15,65 SAY 'SUSPENDED'
      CASE STATUS = 'F'
        @15,65 SAY 'FINISHED'
    ENDCASE
    @16,30 SAY 'Phone  w) ' + PHONE_W + '  h) ' + PHONE_H
    IF .NOT. EOF()
      SKIP
    ENDIF
    IF PLOOK <> CHR(255)
      IF (SURNAME+NAME) <> PLOOK
        FOUND_STD = .T.
        NUM = 10
      ENDIF
    ENDIF
    GO TOP
    SEEK PCURRENT
    IF .NOT. FOUND_STD .AND. .NOT. SAME_STD
      SKIP
      DO WHILE NUM < 5 .AND. .NOT. EOF()
        NUM += 2
        @15+NUM,3 CLEAR TO 15+NUM,76
        @15+NUM,3 SAY TITLE + ' ' + SURNAME + NAME
        DO CASE
          CASE STATUS = 'N'
            @15+NUM,65 SAY 'NEW STUD'
          CASE STATUS = 'S'
            @15+NUM,65 SAY 'SUSPENDED'
          CASE STATUS = 'F'
            @15+NUM,65 SAY 'FINISHED'
        ENDCASE
        @16+NUM,30 SAY 'Phone  w) ' + PHONE_W + '  h) ' + PHONE_H
        SKIP
      ENDDO
      GO TOP
      SEEK PCURRENT
      IF NUM < 10
        NUM = 1
        SKIP-1
      ENDIF
      DO WHILE NUM < 5 .AND. .NOT. BOF()
        NUM +=  2
        @15-NUM,3 CLEAR TO 15-NUM,76
        @15-NUM,3 SAY TITLE + ' ' + SURNAME + NAME
        DO CASE
          CASE STATUS = 'N'
            @15-NUM,65 SAY 'NEW STUD'
          CASE STATUS = 'S'
            @15-NUM,65 SAY 'SUSPENDED'
          CASE STATUS = 'F'
            @15-NUM,65 SAY 'FINISHED'
        ENDCASE
        @16-NUM,30 SAY 'Phone  w) ' + PHONE_W + '  h) ' + PHONE_H
        SKIP-1
      ENDDO
      GO TOP
      SEEK PCURRENT
    ENDIF
  ENDIF (DISP = 'S')
ENDDO
CLEAR TYPEAHEAD
RESTSCREEN(7,1,22,79, MSCR)
RETURN
* EOF
