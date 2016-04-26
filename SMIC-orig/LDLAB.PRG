*******************************************************************************
* LDLAB - PRINTS LEADS IN LABEL FORMAT FOR FAXING
* JIM WEST
* Last modified 28/4/94

local cRep, dAlloc, cType, nSt_cd, nEnd_cd, nCnt, cLine
memvar aLable, getlist, pLine
private aLable[11]

#define LABELS_ACROSS   2

simhead(memvar->pscr_title)

begin sequence
  
  if !net_use('newleads', .f.,, 'rleads')
    break
  endif
  
  cRep = '  '
  dAlloc = ctod('  /  /  ')
    cType = 'D'
  @5,10 say 'Rep ' get cRep picture '@!'
  @7,10 SAY 'Leads for one "D"ay or "A"ll leads ' get cType picture '!';
     valid cType $ 'AD'
  read
  
  if empty(cRep)
    break
  endif
  
  if cType = 'D'
    @10,40 say 'Date received ' get dAlloc picture '@d'
    read
  endif
  
  nSt_cd = 0
  nEnd_cd = 9999
  if cType = 'A'
    @9,10 say 'Start at postal code ' get nSt_cd picture '9999'
    @10,10 SAY 'End at postal code   ' get nEnd_cd picture '9999'
    read
  endif
  
  dbseek(cRep)
  @5,10 SAY 'Printing leads for rep ' + cRep
  
  if !wmake_sure(16,,'Print leads in lable format ?') .or. openprn()
    break
  endif
  pLine = 1
  
  while Newleads->salespsn = cRep .and. !eof()
    afill(alable, '')
    nCnt = 1
    while nCnt <= LABELS_ACROSS .and. Newleads->salespsn = cRep .and. !eof()
      if Newleads->date_rcvd = dAlloc .or.;
            ( cType = 'A' .and. (val(Newleads->p_code) >= nSt_cd .and.;
            val(Newleads->p_code) <= nEnd_cd))
        
        cLine = Newleads->archiv + ' SMIC' + space(10) +;
            newleads->source_cd + ' ' + dtoc(newleads->source_dt)
        cLine += space(40 - len(cLine))
        aLable[1] += cLine
        
        cLine = trim(Newleads->title) + ' ' + trim(Newleads->initls) + ' ';
            + Newleads->surname
        cLine += space(40 - len(cLine))
        aLable[3] += cLine
        
        cLine = Newleads->address1
        cLine += space(40 - len(cLine))
        aLable[4] += cLine
        
        cLine = Newleads->address2
        cLine += space(40 - len(cLine))
        aLable[5] += cLine
        
        cLine = newleads->p_code + ' ' + Newleads->address3
        cLine += space(40 - len(cLine))
        aLable[6] += cLine
        
        cLine = 'Phone H ' + newleads->phone_h + space(5) + 'Occ ' +;
            newleads->occupation
        cLine += space(40 - len(cLine))
        aLable[7] += cLine
        
        cLine = 'Phone W ' + newleads->phone_w
        cLine += space(40 - len(cLine))
        aLable[8] += cLine
        
        nCnt++
      endif
      dbskip()
    enddo
    if !empty(aLable)
      for nCnt = 1 to len(aLable)
        ? aLable[nCnt]
      next
      if pLine > 5
        pLine = 1
        ?? memvar->pr_form_fe
      endif
      pLine++
    endif
  enddo
  shutprn()
end sequence
dbcloseall()
return

*eof
