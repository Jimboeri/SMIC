*******************************************************************************
* Program 'LDDELETE'

LOCAL PORIG_COL

IF .NOT. NET_USE('NEWLEADS', .F., 'LD', 'ARCHIVES', 'MEDIA', 'RLEADS')
  RETURN
ENDIF

STORE 'XXX' TO MARCHIV
DO WHILE MARCHIV <> '       '
  
  SIMHEAD(PSCR_TITLE)
  PORIG_COL = SETCOLOR(SCR_HEADING)
  @3,30 SAY  'Deletion of a lead'
  SETCOLOR(PORIG_COL)
  MARCHIV = SPACE(7)
  @5,1 say 'Archive No: ' get marchiv picture '!!!!!!!'
  @10,5 SAY 'Enter archive number or hit enter to return to main menu'
  READ
  
  IF MARCHIV <> SPACE(7)
    SEEK MARCHIV
    IF .NOT. FOUND()
      @23,10 SAY 'LEAD DOES NOT EXIST'
      INKEY(10)
    ELSE
      IF .NOT. RLOCK()
        @23,10 SAY 'Lead being used - Please try later'
        INKEY(10)
      ELSE
        @5,14 CLEAR
        @5,14 SAY MARCHIV
        @6,1 CLEAR
        @8,20 SAY 'Clients name'
        @9,20 SAY TRIM(TITLE) + ' ' + TRIM(INITLS) + ' ' + SURNAME
        @10,20 SAY ADDRESS1
        @11,20 SAY ADDRESS2
        @12,20 SAY P_CODE + ' ' + ADDRESS3
        IF MAKE_SURE(16,30,'Delete the record (Y/N) ? ')
          dbdelete()
          @16,1 SAY 'RECORD IS NOW MARKED FOR DELETION'
          INKEY(10)
        ENDIF (DEL1 = 'Y')
        UNLOCK
      ENDIF (REC LOCK)
    ENDIF (RECORD NOT FOUND)
  ENDIF  (MARCHIVE = SPACE)
ENDDO (MARCHIV <> SPACE)
CLOSE DATABASE
RETURN

* eof
