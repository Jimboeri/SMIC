*******************************************************************************
* MEDLAB - PRINTS LEADS BY AREA IN LABEL FORMAT
* JIM WEST

local nCnt, nSt_cd, nEnd_cd, dStart, dEnd, cTitle
local nExtract, nSold, nPost_code, aLable[11], cLine, nKey
memvar getlist, pLine

nExtract := nSold := 0

#include 'inkey.ch'
#define LABELS_ACROSS   2

simhead(memvar->pscr_title)

begin sequence
  select 1
  if !net_use('newleads', .f.,, 'archives')
    break
  endif
  
  select 2
  if !net_use('student', .f.,, 'stdarc')
    break
  endif
  
  @3,20 say 'UNSOLD LEADS BY AREA'
  nSt_cd = 0
  nEnd_cd = 9999
  dStart = date() - 60
  dEnd = date()
  @6,0 say 'Enter Start postal code ' get nSt_cd picture '9999'
  @8,0 say 'Enter End postal code   ' get nEnd_cd picture '9999'
  @10,0 say 'Date to start from      ' get dStart
  @11,0 say 'Date to end at          ' get dEnd
  read
  
  if !wmake_sure(12,,'Print unsold leads by area ? (Y/N)') .or. openprn()
    break
  endif
  pLine = 1
  @3,0 clear
  @10,10 say 'PRINTING UNSOLD LEADS BY AREA'
  nCnt = 1
  
  cTitle = 'UNSOLD LEADS FROM ' + str(nSt_cd,4,0) + ' TO ' +;
      str(nEnd_cd,4,0) + ' AFTER ' + dtoc(DsTART)
  @5,int((80-len(cTitle))/2) say cTitle
  select Newleads
  dbgotop()
  while !eof()
    afill(alable, '')
    nCnt = 1
    while nCnt <= LABELS_ACROSS .and. !eof()
      nKey = inkey()
      if nKey = K_ESC .and.;
            alert('Do you want to :', {'Continue printing', 'Abort printing'}) = 2
        break
      endif
      @15,30 say Newleads->archiv
      if nExtract > 0
        @17,25 say 'Leads extracted = ' + ltrim(str(nExtract))
      endif
      if nSold > 0
        @18,25 say 'Leads sold      = ' + ltrim(str(nSold))
      endif
      nPost_code = val(Newleads->p_code)
      if nSt_cd <= nPost_code .and. nEnd_cd >= nPost_code
        if Newleads->date_rcvd >= dStart .and. Newleads->date_rcvd <= dEnd
          select Student
          if !dbseek(Newleads->archiv)
            Select Newleads
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
            pLine++
            nCnt++
            nExtract++
          else
            nSold++
          endif
        endif
      endif
      Select Newleads
      dbskip()
    enddo
    if !empty(aLable)
      for nCnt = 1 to len(aLable)
        ? aLable[nCnt]
      next
      if pLine > 5
        pLine = 1
        ?? chr(12)
      endif
    endif
  enddo
  if nExtract > 0
    ? 'Leads extracted = ' + ltrim(str(nExtract))
    ? ' '
    ? 'Leads SOLD & not extracted = ' + ltrim(str(nSold))
  endif
end sequence
shutprn()
dbcloseall()
return
* eof

