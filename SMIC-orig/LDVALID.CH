***********************************************************
FUNCTION LDAD_V01
LOCAL cFIELD, CVAL
cFIELD = READVAR()
cVAL = &cFIELD
restsector(cSect)
IF cVAL <> 'W' .AND. cVAL <> 'B'.AND. cVAL <> 'A'
  DISP_MSG(20, INFO_COL, "Race must be 'W', 'B' or 'A'")
  RETURN(.F.)
ELSE
  RETURN(.T.)
ENDIF

***********************************************************
FUNCTION LDAD_V02
LOCAL cFIELD, CVAL
cFIELD = READVAR()
cVAL = &cFIELD
restsector(cSect)
IF cVAL <> 'M' .AND. cVAL <> 'F'
  DISP_MSG(20, INFO_COL, "Sex must be 'M' or 'F'")
  RETURN(.F.)
ELSE
  RETURN(.T.)
ENDIF

***********************************************************
FUNCTION LDAD_V03
LOCAL cFIELD, CVAL
cFIELD = READVAR()
cVAL = &cFIELD
restsector(cSect)
IF cVAL <> 'N' .AND. cVAL <> 'Y'
  DISP_MSG(20, INFO_COL, "Self employed must be 'Y' or 'N'")
  RETURN(.F.)
ELSE
  RETURN(.T.)
ENDIF

***********************************************************
FUNCTION LDAD_V04
LOCAL cFIELD, CVAL
cFIELD = READVAR()
cVAL = &cFIELD
restsector(cSect)
IF cVAL <> '02' .AND. cVAL <> '04' .AND. cVAL <> '06' .AND. cVAL <> '08' .AND. cVAL <> '10';
   .AND. cVAL <> '12' .AND. cVAL <> '14' .AND. cVAL <> '16' .AND. cVAL <> '18' .AND. cVAL <> '20';
   .AND. cVAL <> '22' .AND. cVAL <> '24' .AND. cVAL <> '26' .AND. cVAL <> '28' .AND. cVAL <> '32';
   .AND. cVAL <> '34' .AND. cVAL <> '36' .AND. cVAL <> '38' .AND. cVAL <> '40' .AND. cVAL <> '42';
   .AND. cVAL <> '44' .AND. cVAL <> '46' .AND. cVAL <> '48' .AND. cVAL <> '50' .AND. cVAL <> '52';
   .AND. cVAL <> '54' .AND. cVAL <> '56' .AND. cVAL <> '58' .AND. cVAL <> '59' .AND. cVAL <> '60';
   .AND. cVAL <> '62' .AND. cVAL <> '64' .AND. cVAL <> '66' .AND. cVAL <> '68' .AND. cVAL <> '70';
   .AND. cVAL <> '72' .AND. cVAL <> '74' .AND. cVAL <> '76' .AND. cVAL <> '78' .AND. cVAL <> '80';
   .AND. cVAL <> '82' .AND. cVAL <> '84' .AND. cVAL <> '86' .AND. cVAL <> '88'
  DISP_MSG(20, INFO_COL, "Invalid occupation - Press F1")
  RETURN(.F.)
ELSE
  RETURN(.T.)
ENDIF

***********************************************************
FUNCTION LDAD_V05
LOCAL cFIELD, CVAL, nLENPCD, lNUMERIC, nCNT, cCHAR
cFIELD = READVAR()
cVAL = &cFIELD
restsector(cSect)
DO CASE
  CASE VAL(cVal) > 0 .AND. VAL(cVal) < 1400 .AND. SUBSTR(MSALESPSN,1,1) <> 'P' .AND. SUBSTR(MSALESPSN,1,1) <> 'N'
    MSALESPSN = 'P '
  CASE VAL(cVal) > 2799 .AND. VAL(cVal) < 2900 .AND. SUBSTR(MSALESPSN,1,1) <> 'P' .AND. SUBSTR(MSALESPSN,1,1) <> 'N'
    MSALESPSN = 'P '
  CASE VAL(cVal) > 8299 .AND. VAL(cVal) < 9000 .AND. SUBSTR(MSALESPSN,1,1) <> 'P' .AND. SUBSTR(MSALESPSN,1,1) <> 'N'
    MSALESPSN = 'P '
  CASE VAL(cVal) > 9299 .AND. VAL(cVal) < 10000 .AND. SUBSTR(MSALESPSN,1,1) <> 'P' .AND. SUBSTR(MSALESPSN,1,1) <> 'N'
    MSALESPSN = 'P '
  CASE VAL(cVal) > 1399 .AND. VAL(cVal) < 2800 .AND. SUBSTR(MSALESPSN,1,1) <> 'J' .AND. SUBSTR(MSALESPSN,1,1) <> 'N'
    MSALESPSN = 'J '
  CASE VAL(cVal) > 4899 .AND. VAL(cVal) < 8300 .AND. SUBSTR(MSALESPSN,1,1) <> 'C' .AND. SUBSTR(MSALESPSN,1,1) <> 'N'
    MSALESPSN = 'C '
  CASE VAL(cVal) > 2899 .AND. VAL(cVal) < 4900 .AND. SUBSTR(MSALESPSN,1,1) <> 'D' .AND. SUBSTR(MSALESPSN,1,1) <> 'N'
    MSALESPSN = 'D '
ENDCASE
nLENPCD = TRIM(cVal)
IF LEN(nLENPCD) <> 4
  DISP_MSG(20, INFO_COL, 'Postal code must be fully entered')
  RETURN(.F.)
else
  RETURN(.T.)
ENDIF

***********************************************************
FUNCTION LDAD_V06
LOCAL cFIELD, CVAL
cFIELD = READVAR()
cVAL = &cFIELD
restsector(cSect)
IF .NOT. ((cVAL = 'B' .OR. cVAL = 'D');
   .OR. (cVAL = 'S' .OR. cVAL ='Y');
   .OR. (cVAL = 'F' .OR. cVAL = 'R'))
  DISP_MSG(20, INFO_COL, '1st char of Miscellaneous code must be Y/F/S/R/B/D')
  RETURN(.F.)
ELSE
  RETURN(.T.)
ENDIF

***********************************************************
FUNCTION LDAD_V07
LOCAL cFIELD, CVAL
cFIELD = READVAR()
cVAL = &cFIELD
restsector(cSect)
IF .NOT. (cVAL = 'G' .OR. cVAL = 'P')
  DISP_MSG(20, INFO_COL, '2nd char of Miscellaneous code must be G / P')
  RETURN(.F.)
ELSE
  RETURN(.T.)
ENDIF

***********************************************************
FUNCTION LDAD_V08
LOCAL cFIELD, CVAL
cFIELD = READVAR()
cVAL = &cFIELD
restsector(cSect)
IF cVAL <> 'P' .AND. cVAL <> 'T' .AND. cVAL <> 'F'
  DISP_MSG(20, INFO_COL, "Please tell me how you recieved the lead - Post/Telephone/Fax")
  RETURN(.F.)
ELSE
  RETURN(.T.)
ENDIF

***********************************************************
FUNCTION LDAD_V09
LOCAL cFIELD, CVAL, lRETURN
cFIELD = READVAR()
cVAL = &cFIELD
restsector(cSect)
lRETURN = .T.
SELECT REP
SEEK cVAL
IF .NOT. FOUND()
  lRETURN = .F.
  @23,10 SAY 'Sales person does not exist'
ELSE
  IF STATUS <> 'C'.AND. (END_DT + 30) < DATE()
    lRETURN = .F.
    @23,10 SAY 'Sales person is not current'
  ENDIF
ENDIF
SELECT LDS
RETURN(lRETURN)

***********************************************************
FUNCTION LDAD_V10
LOCAL cFIELD, CVAL
cFIELD = READVAR()
cVAL = &cFIELD
restsector(cSect)
IF cVAL <> 'N' .AND. cVAL <> 'Y' .AND. cVAL <> ' '
  DISP_MSG(20, INFO_COL, "Must be space or 'Y' or 'N'")
  RETURN(.F.)
ELSE
  RETURN(.T.)
ENDIF

***********************************************************
FUNCTION LDAD_V11
LOCAL cFIELD, CVAL
cFIELD = READVAR()
cVAL = &cFIELD
restsector(cSect)
IF cVAL <> 'N' .AND. cVAL <> 'Y' .AND. cVAL <> ' '
  DISP_MSG(20, INFO_COL, "Must be space or 'Y' or 'N'")
  RETURN(.F.)
ELSE
  RETURN(.T.)
ENDIF

