*******************************************************************************
* MANUAL PRICE INPUT FOR FUTURES PROGRAM
* Author - Jim West
* 04/10/87
* ----     SET UP SYSTEM DEFAULTS

@3,0 CLEAR
@10,15 SAY 'Checking for expired options'

DO FUTEXP

@3,0 CLEAR
@3,15 SAY 'Manual future value input screen'

SELECT 1
IF .NOT. NET_USE('FUTOPTN', .F., 'FUT', 'FUTOPTN')
  RETURN
ENDIF

IF .NOT. FLOCK()
  @23,10 SAY 'Futures/Options file in use - Please try later'
  INKEY(10)
  CLOSE DATABASE
  RETURN
ENDIF
DO WHILE .NOT. EOF()
  IF F_OR_O = 'F'
    IF EXPIRED <> 'E'
      @4,0 CLEAR
      @5,16 SAY FUT_OPTN
      @5,55 SAY EXP_DATE
      @7,16 SAY FULL_NAME
      STORE 0 TO MBID, MOFFER
      @12,10 SAY 'Bid price   ' GET MBID PICTURE '99999999.9999'
      @14,10 SAY 'Offer price ' GET MOFFER PICTURE '99999999.9999'
      *
      READ
      MBID = ABS(MBID)
      MOFFER = ABS(MOFFER)
      MVAL = .F.
      DO WHILE .NOT. MVAL
        MVAL = .T.
        IF MBID = 0
          MVAL = .F.
          @23,10 SAY 'Bid price cannot be 0'
          @12,10 SAY 'Bid price   ' GET MBID PICTURE '99999999.9999'
          READ
          @23,0 CLEAR
        ENDIF
        IF MOFFER = 0
          MVAL = .F.
          @23,10 SAY 'Offer price cannot be 0'
          @14,10 SAY 'Offer price ' GET MOFFER PICTURE '99999999.9999'
          READ
          @23,0 CLEAR
        ENDIF
      ENDDO (VALIDATION)
      REPLACE BID WITH MBID
      REPLACE OFFER WITH MOFFER
    ELSE
      MDT = EXP_DATE
      MDT = et_addmonth(MDT)
      IF MDT < DATE()
        dbdelete()
      ENDIF
    ENDIF (NOT EXPIRED)
  ENDIF (FUTURE)
  SKIP
ENDDO (NOT EOF)
UNLOCK
CLOSE DATABASES

IF MAKE_SURE(7,10,'Have you entered all the prices correctly ? ')
  DO WHILE .NOT. NET_USE('PARAM', .F.)
    XX = 1
  ENDDO
  DO RECLOCK WITH 'PARAM'
  REPLACE LST_F_UPDT WITH DATE()
  UNLOCK
  CLOSE

  @8,15 SAY 'Checking for any extra margin that is due'
  DO FUTMARG
ENDIF

INKEY = 0
RETURN
* EOF