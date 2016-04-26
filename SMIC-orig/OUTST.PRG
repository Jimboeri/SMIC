* PROGRAM 'OUTST'
* JIM WEST

SELECT 1
IF .NOT. NET_USE('STUDENT', .F., 'STD', 'STDARC')
  RETURN
ENDIF

SELECT 2
IF .NOT. NET_USE('NEWLEADS', .F., 'LD', 'RLEADS')
  CLOSE DATABASES
  RETURN
ENDIF

DO SIMHEAD WITH PSCR_TITLE
@12,5 SAY '  ******* PRINT LISTS OF OUTSTANDING LEADS PER AGENT OR SALESPERSON ******'
MADDRESS = '                         '
MPHONE = '               '
STORE 'XX' TO SALESP1
DO WHILE SALESP1 <> '  '
  STORE '  ' TO SALESP1
  @6,0 CLEAR
  @7,0 SAY 'or space to exit'
  @6,0 SAY 'Enter sales person code or agent code' GET SALESP1 PICTURE '!!'
  READ
  IF SALESP1 <> '  '
    @10,0 SAY 'SALESPERSON/AGENT CODE = '
    @10,25 SAY SALESP1
    *
    STORE 'X' TO YESNO
    DO WHILE 'Y'<>YESNO .AND. 'N'<>YESNO
      @14,0 CLEAR
      WAIT 'PROCEED (Y/N) ? ' TO YESNO
      STORE UPPER(YESNO) TO YESNO
    ENDDO
    IF 'Y'=YESNO
      @18,10 SAY 'Printing outstanding leads report for ' + SALESP1
      SET CONSOL OFF
      SET PRINT ON
      STORE 'LIST OF OUTSTANDING LEADS FOR SALESPERSON/AGENT ' + SALESP1 TO SUBTITLE
      STORE 70 TO PLINE
      STORE 0 TO PPAGE
      STORE 0 TO Y_CTR,D_CTR,S_CTR,B_CTR,F_CTR,R_CTR,O_CTR,BIG_TOT,;
      INT_TOT,FULL_TOT,PART_TOT,GOOD_LD,POOR_LD
      SEEK SALESP1
      DO WHILE SALESPSN = SALESP1
        MARC = ARCHIV
        SELECT 1
        SEEK MARC
        IF FOUND()
          MSOLD = SOLD_CRS_1
        ELSE
          MSOLD = CTOD('  /  /  ')
        ENDIF
        SELECT 2
        IF KILLED = 'Y' .AND. MSOLD = CTOD('  /  /  ')
          IF FOLLOW_DT = CTOD('  /  /  ') .OR. FOLLOW_DT <= DATE()
            IF PLINE > 57
              DO SIMTITLE WITH PLINE,PPAGE,SUBTITLE,'Y'
              PLINE = 6
              ? '                                                                      ' +;
                '                                   FOLLOW'
              ? 'SP ALLOC-DT ARCHIV            NAME                           ADDRESS3 ' +;
                '                 KILLED   SRC CHGE  DATE  INT PHONE'
              ? ' '   
            ENDIF  
            IF ADDRESS3 = SPACE(20)          
              MADDRESS = ADDRESS2
            ELSE
              MADDRESS = ADDRESS3
            ENDIF
            IF PHONE_W = SPACE(15)
              MPHONE = PHONE_H
            ELSE
              MPHONE = PHONE_W
            ENDIF
            ? SALESPSN, ALLOC_DT, ARCHIV, TITLE, INITLS, SURNAME, MADDRESS, '        ', SOURCE_CD, MISC_CD, FOLLOW_DT, INTVIEW, MPHONE
            ? MEMOLINE(MEM_COMNT,50,1)
            PLINE = PLINE + 2
            STORE SUBSTR(MISC_CD,1,1) TO CD1
            STORE SUBSTR(MISC_CD,2,1) TO CD2
            DO CASE
            CASE 'Y'=CD1
              STORE Y_CTR+1 TO Y_CTR
            CASE 'D'=CD1
              STORE D_CTR+1 TO D_CTR
            CASE 'S'=CD1
              STORE S_CTR+1 TO S_CTR
            CASE 'B'=CD1
              STORE B_CTR+1 TO B_CTR
            CASE 'F'=CD1
              STORE F_CTR+1 TO F_CTR
            CASE 'R'=CD1
              STORE R_CTR+1 TO R_CTR
            OTHERWISE
              STORE O_CTR+1 TO O_CTR
            ENDCASE
            IF CD2 = 'G'
              GOOD_LD = GOOD_LD + 1
            ENDIF
            IF CD2 = 'P'
              POOR_LD = POOR_LD + 1
            ENDIF
            IF 'Y'=INTVIEW
              STORE INT_TOT+1 TO INT_TOT
            ENDIF
            STORE BIG_TOT+1 TO BIG_TOT
          ENDIF
        ENDIF
        SKIP
      ENDDO
      IF PLINE > 40
        DO SIMTITLE WITH PLINE,PPAGE,SUBTITLE,'Y'
      ENDIF
      ? 'CHARGED    = ',Y_CTR
      ? 'DISTANT    = ',D_CTR
      ? 'STUDENTS   = ',S_CTR
      ? 'BLACKS     = ',B_CTR
      ? 'FREE       = ',F_CTR
      ? 'REFERRALS  = ',R_CTR
      ? 'OTHERS     = ',O_CTR
      ? ' '
      ? 'GOOD LEADS = ' , GOOD_LD
      ? 'POOR LEADS = ' , POOR_LD
      ? ' '
      ? 'NO. OF INTERVIEWS = ',INT_TOT
      ? 'TOTAL LEADS       = ',BIG_TOT
      ? ' '
      ? '****** END OF REPORT *******'
      ? '                                                  '
      shutprn()
    ENDIF (YESNO = 'Y')
  ENDIF (SALESP1 <> '  ')
ENDDO (SALESP1 = '  ')
CLOSE DATABASES
RETURN

*EOF