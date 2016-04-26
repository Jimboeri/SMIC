*******************************************************************************
* MEDLAB - PRINTS LEADS IN LABEL FORMAT FOR FAXING
* JIM WEST

local cSrc_cd, dSrc_dt, cHead, lStd_fnd, nPost_cd, nCol
memvar getlist
memvar cArc, cArc1, cArc2, cOcc1, cOcc2, cSrc_cd1, cSrc_cd2, dSrc_dt1, dSrc_dt2
memvar cP_code1, cP_code2, cInit1, cInit2, cSur1, cSur2, cAddr31, cAddr32
memvar cAddr21, cAddr22, cAddr11, cAddr12, cPhone_w1, cPhone_w2, cPhone_h1, cPhone_h2
memvar cTitle1, cTitle2, cSp1, cSp2, cMisc_cd1, cMisc_cd2

memvar nAdd, nCount, cTitle

select 1
if !net_use('newleads', .f.,, 'media')
  return
endif

select 3
if !net_use('student', .f.,, 'stdarc')
  dbcloseall()
  return
endif

simhead(memvar->pscr_title)
@3,20 say 'UNSOLD LEADS BY ADVERT'
cSrc_cd = '   '
dSrc_dt = ctod('  /  /  ')
@6,0 say 'Enter Source code ' get cSrc_cd picture '!!!'
@8,0 say 'Enter Source date ' get dSrc_dt picture '@d'
read

if !make_sure()
  dbcloseall()
  return
endif

STORE SPACE(7) TO cArc1
STORE SPACE(3) TO cSrc_cd1, cOcc1
STORE CTOD('  /  /  ') TO dSrc_dt1
STORE SPACE(4) TO cTitle1, cInit1, cP_code1
STORE SPACE(30) TO cSur1
STORE SPACE(25) TO cAddr11, cAddr21, cAddr31
STORE SPACE(15) TO cPhone_w1, cPhone_h1
STORE SPACE(2) TO cMisc_cd1, cSp1
STORE SPACE(7) TO cArc2
STORE SPACE(3) TO cSrc_cd2, cOcc2
STORE CTOD('  /  /  ') TO dSrc_dt2
STORE SPACE(4) TO cTitle2, cInit2, cP_code2
STORE SPACE(30) TO cSur2
STORE SPACE(25) TO cAddr12, cAddr22, cAddr32
STORE SPACE(15) TO cPhone_w2, cPhone_h2
STORE SPACE(2) TO cMisc_cd2, cSp2

begin sequence
  @3,0 CLEAR
  @10,5 SAY 'PRINTING UNSOLD LEADS'
  nCount = 1
  if openprn()
    break
  endif
  memvar->lPr_esc = .t.
  nAdd = 0
  WHILE nAdd < 8
    nAdd++
    STORE 'LEADS FOR ' + cSrc_cd + ' ' + DTOC(dSrc_dt) TO cTitle
    SELECT newleads
    if dbseek(cSrc_cd + DTOS(dSrc_dt))
      cHead = 'N'
      memvar->pline = 90
      WHILE cSrc_cd = newleads->SOURCE_CD .AND.;
            dSrc_dt = newleads->source_dt .and. !eof()
        lStd_fnd = .F.
        cArc = newleads->archiv
        SELECT student
        SEEK cArc
        IF FOUND()
          lStd_fnd = .T.
        ENDIF
        SELECT newleads
        nPost_cd = VAL(newleads->P_CODE)
        IF !lStd_fnd
          DO CASE
            CASE nAdd = 1
              IF cHead = 'N'
                cTitle = 'JOHANNESBURG ' + cTitle
                cHead = 'Y'
                nCount = 1
              ENDIF
              IF (nPost_cd > 1400 .AND. nPost_cd < 2800)
                LABELLINE()
              ENDIF
            CASE nAdd = 2
              IF cHead = 'N'
                cTitle = 'PRETORIA ' + cTitle
                cHead = 'Y'
                nCount = 1
              ENDIF
              IF (nPost_cd > 0 .AND. nPost_cd < 400);
                    .OR. (nPost_cd > 999 .AND. nPost_cd < 1400);
                    .OR. (nPost_cd > 2799 .AND. nPost_cd < 2900)
                LABELLINE()
              ENDIF
            CASE nAdd = 3
              IF cHead = 'N'
                cTitle = 'NORTHERN TVL ' + cTitle
                cHead = 'Y'
                nCount = 1
              ENDIF
              IF (nPost_cd > 399 .AND. nPost_cd < 1000)
                LABELLINE()
              ENDIF
            CASE nAdd = 4
              IF cHead = 'N'
                cTitle = 'OFS & N. CAPE ' + cTitle
                cHead = 'Y'
                nCount = 1
              ENDIF
              IF (nPost_cd > 9299 .AND. nPost_cd < 10000);
                    .OR. (nPost_cd > 8299 .AND. nPost_cd < 9000)
                LABELLINE()
              ENDIF
            CASE nAdd = 5
              IF cHead = 'N'
                cTitle = 'CAPE TOWN ' + cTitle
                cHead = 'Y'
                nCount = 1
              ENDIF
              IF (nPost_cd > 6699 .AND. nPost_cd < 8300)
                LABELLINE()
              ENDIF
            CASE nAdd = 6
              IF cHead = 'N'
                cTitle = 'NATAL ' + cTitle
                cHead = 'Y'
                nCount = 1
              ENDIF
              IF (nPost_cd > 2899 .AND. nPost_cd < 4900)
                LABELLINE()
              ENDIF
            CASE nAdd = 7
              IF cHead = 'N'
                cTitle = 'EAST CAPE ' + cTitle
                cHead = 'Y'
                nCount = 1
              ENDIF
              IF (nPost_cd > 4899 .AND. nPost_cd < 6700)
                LABELLINE()
              ENDIF
            CASE nAdd = 8
              IF cHead = 'N'
                cTitle = 'OTHER ' + cTitle
                cHead = 'Y'
                nCount = 1
              ENDIF
              IF newleads->P_CODE < '0000' .OR. newleads->P_CODE > '9999'
                LABELLINE()
              ENDIF
          ENDCASE
        ENDIF
        SKIP
      ENDDO
      
      
      IF nCount > 1
        IF cArc1 != SPACE(7)
          IF memvar->PLINE > 55
            PRNTITLE(cTitle,'N')
          ENDIF
          ? cArc1 + ' SMC  Rep ' + cSp1 + SPACE(3) + cSrc_cd1 + ' ' + DTOC(dSrc_dt1)
          IF cArc2 != SPACE(7)
            ?? '      ' + cArc2 + ' SMC  Rep ' + cSp2 + SPACE(3) + cSrc_cd2 + ' ' + DTOC(dSrc_dt2)
          ENDIF
          ? ' '
          ? TRIM(cTitle1) + ' ' + TRIM(cInit1) + ' ' + cSur1
          nCol = 40 - PCOL()
          ?? REPLICATE(' ',nCol) + TRIM(cTitle2) + ' ' + TRIM(cInit2) + ' ' + cSur2
          ? cAddr11 + SPACE(15) + cAddr12
          ? cAddr21 + SPACE(7) + cMisc_cd1 + SPACE(6) + cAddr22 + SPACE(7) + cMisc_cd2
          ? cP_code1 + ' ' + TRIM(cAddr31)
          nCol = 40 - PCOL()
          ?? REPLICATE(' ',nCol) + cP_code2 + ' ' + TRIM(cAddr32)
          ? 'Phone H ' + cPhone_h1 + SPACE(5) + 'Occ ' + cOcc1
          IF cArc2 != SPACE(7)
            ?? SPACE(5) + 'Phone H ' + cPhone_h2 + SPACE(5) + 'Occ ' + cOcc2
          ENDIF
          ? 'Phone W ' + cPhone_w1
          IF cArc2 != SPACE(7)
            ?? SPACE(17) + 'Phone W ' + cPhone_w2
          ENDIF
          ? ' '
          ? ' '
          ? ' '
        ENDIF
      ENDIF
    ENDIF
  ENDDO
  SHUTPRN()
end sequence
CLOSE DATABASES
RETURN
* EOF


*******************************************************************************
STATIC PROCEDURE LABELLINE
local cField, nCol
memvar nCount
cField = 'cArc' + LTRIM(STR(nCount))
STORE newleads->ARCHIV TO &cField
cField = 'cSrc_cd' + LTRIM(STR(nCount))
STORE newleads->SOURCE_CD TO &cField
cField = 'cOcc' + LTRIM(STR(nCount))
STORE newleads->OCCUPATION TO &cField
cField = 'dSrc_dt' + LTRIM(STR(nCount))
STORE newleads->SOURCE_DT TO &cField
cField = 'cTitle' + LTRIM(STR(nCount))
STORE newleads->TITLE TO &cField
cField = 'cInit' + LTRIM(STR(nCount))
STORE newleads->INITLS TO &cField
cField = 'cP_code' + LTRIM(STR(nCount))
STORE newleads->P_CODE TO &cField
cField = 'cSur' + LTRIM(STR(nCount))
STORE newleads->SURNAME TO &cField
cField = 'cAddr1' + LTRIM(STR(nCount))
STORE newleads->ADDRESS1 TO &cField
cField = 'cAddr2' + LTRIM(STR(nCount))
STORE newleads->ADDRESS2 TO &cField
cField = 'cAddr3' + LTRIM(STR(nCount))
STORE newleads->ADDRESS3 TO &cField
cField = 'cPhone_h' + LTRIM(STR(nCount))
STORE newleads->PHONE_H TO &cField
cField = 'cMisc_cd' + LTRIM(STR(nCount))
STORE newleads->MISC_CD TO &cField
cField = 'cPhone_w' + LTRIM(STR(nCount))
STORE newleads->PHONE_W TO &cField
cField = 'cSp' + LTRIM(STR(nCount))
STORE newleads->SALESPSN TO &cField
nCount = nCount + 1
IF nCount > 2
  IF memvar->cArc1 != SPACE(7)
    IF memvar->PLINE > 55
      PRNTITLE(memvar->cTitle,'N')
    ENDIF
    ? memvar->cArc1 + ' SMC  Rep ' + memvar->cSp1 + SPACE(3) +;
        memvar->cSrc_cd1 + ' ' + DTOC(memvar->dSrc_dt1)
    IF memvar->cArc2 != SPACE(7)
      ?? '      ' + memvar->cArc2 + ' SMC  Rep ' + memvar->cSp2 + SPACE(3);
          + memvar->cSrc_cd2 + ' ' + DTOC(memvar->dSrc_dt2)
    ENDIF
    ? ' '
    ? TRIM(memvar->cTitle1) + ' ' + TRIM(memvar->cInit1) + ' ' + memvar->cSur1
    nCol = 40 - PCOL()
    ?? REPLICATE(' ',nCol) + TRIM(memvar->cTitle2) + ' ' +;
        TRIM(memvar->cInit2) + ' ' + memvar->cSur2
    ? memvar->cAddr11 + SPACE(15) + memvar->cAddr12
    ? memvar->cAddr21 + SPACE(7) + memvar->cMisc_cd1 + SPACE(6) +;
        memvar->cAddr22 + SPACE(7) + memvar->cMisc_cd2
    ? memvar->cP_code1 + ' ' + TRIM(memvar->cAddr31)
    nCol = 40 - PCOL()
    ?? REPLICATE(' ',nCol) + memvar->cP_code2 + ' ' + TRIM(memvar->cAddr32)
    ? 'Phone H ' + memvar->cPhone_h1 + SPACE(5) + 'Occ ' + memvar->cOcc1
    IF memvar->cArc2 != SPACE(7)
      ?? SPACE(5) + 'Phone H ' + memvar->cPhone_h2 + SPACE(5) + 'Occ ';
          + memvar->cOcc2
    ENDIF
    ? 'Phone W ' + memvar->cPhone_w1
    IF memvar->cArc2 != SPACE(7)
      ?? SPACE(17) + 'Phone W ' + memvar->cPhone_w2
    ENDIF
    ? ' '
    ? ' '
    ? ' '
    STORE SPACE(7) TO memvar->cArc1
    STORE SPACE(3) TO memvar->cSrc_cd1, memvar->cOcc1
    STORE CTOD('  /  /  ') TO memvar->dSrc_dt1
    STORE SPACE(4) TO memvar->cTitle1, memvar->cInit1, memvar->cP_code1
    STORE SPACE(30) TO memvar->cSur1
    STORE SPACE(25) TO memvar->cAddr11, memvar->cAddr21, memvar->cAddr31
    STORE SPACE(15) TO memvar->cPhone_w1, memvar->cPhone_h1
    STORE SPACE(2) TO memvar->cMisc_cd1, memvar->cSp1
    STORE SPACE(7) TO memvar->cArc2
    STORE SPACE(3) TO memvar->cSrc_cd2, memvar->cOcc2
    STORE CTOD('  /  /  ') TO memvar->dSrc_dt2
    STORE SPACE(4) TO memvar->cTitle2, memvar->cInit2, memvar->cP_code2
    STORE SPACE(30) TO memvar->cSur2
    STORE SPACE(25) TO memvar->cAddr12, memvar->cAddr22, memvar->cAddr32
    STORE SPACE(15) TO memvar->cPhone_w2, memvar->cPhone_h2
    STORE SPACE(2) TO memvar->cMisc_cd2, memvar->cSp2
    memvar->PLINE += 11
    memvar->nCount = 1
  ENDIF (ARC != SPACE)
ENDIF
RETURN

*EOF()
