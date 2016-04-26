*******************************************************************************
* prgspec prints system specification
local nPcnt, nScan, cSect, cCall_proc, nAt, nCall_proc, nScan1, cProc1, nChoice
local val_char := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ_1234567890'
local aWhat_do := {'Print specs for an Exe', 'Print procedures alphabetically', 'Print structure map'}
local cSect1, lProc_def, cPath, cOrig, cSec1, cSec2, nPerc, cProc, cTemp
local cExe, nTemp, nUp_to, sTitle, nLast, lNo_more
memvar aSpec, aPr_type, nPr_type, aMap, nMap, aPrg, aExe, clp_proc, aCh
memvar aPrg_file, aTemp, Ncnt
public aSpec[5][0]              // 1st element - procedure name
// 2nd elements - source file
// 3rd element - used by
// 4th element - procedures used
// 5th element - logical
#include 'inkey.ch'
public aPr_type := {'Print full spec      ', 'Print proc names only', 'Print calling info   ', 'Print spec only      '}
public nPr_type := 1
public aMap := {'Unique procedure calls', 'Defined procedure calls', 'All procedure calls'}
public nMap := 1
public aPrg[adir('*.prg')], aCh[adir('*.Ch')]
public prerror, aExe[0]
public clp_proc[0]
adir('*.prg', aPrg)
asort(aPrg)
cPath = getenv("PATH")
set path to (cPath)
select 198
if net_use('clp_proc', .f.)
  while !eof()
    aadd(clp_proc, trim(clp_proc->proc_name))
    dbskip()
  enddo
  dbclosearea()
endif
if file('COM_PROC.DBF') .and. net_use('com_proc', .f.)
  while !eof()
    aadd(clp_proc, trim(com_proc->proc_name))
    dbskip()
  enddo
  dbclosearea()
endif
set path to
aPrg_file := {}
aadd(aPrg_file, {'PRG_LINE  ', 'C', 255,0})
dbcreate('PRG_FILE', aPrg_file)
select 198
if !net_use('prg_file', .t.)
  return
endif
cSec1 = disp_msg(21,memvar->BLACK_GREEN,;
    'Press "ESC" to quit processing program files')
cSec2 = disp_msg(4,,'Percentage program files processed 0%³                         ³100%')
for ncnt = 1 to len(aPrg)
  nPerc = int(nCnt / len(aPrg) * 25)
  @5,44 say replicate('±', nPerc)
  if inkey() = K_ESC
    if mMake_sure(memvar->oMouse, 10,,'Quit processing program files ?')
      return
    endif
  endif
  cSect = disp_msg(10,, 'Processing ' + aPrg[nCnt] + '         ')
  select prg_file
  zap
  append from (aPrg[nCnt]) sdf
  if !prg_load()
    return
  endif
  nAt = at('.', aPrg[ncnt])
  cCall_proc = stuff(aPrg[ncnt], nAt, len(aPrg[nCnt])-nAt+1, '')
  nCall_proc = ascan(aSpec[1], cCall_proc)
  if nCall_proc = 0
    aadd(aSpec[1], cCall_proc)
    aadd(aSpec[2], aPrg[nCnt])
    aadd(aSpec[3], {})
    aadd(aSpec[4], {})
    aadd(aSpec[5], .f.)
    nCall_proc = len(aSpec[1])
  else
    aSpec[2, nCall_proc] = aPrg[nCnt]
  endif
  select prg_file
  dbgotop()
  while !eof()
    @11,49 say str(recno(),4,0)
    lProc_def = .f.
    if 'PROC ' $ trim(prg_file->prg_line) .or. 'PROCEDURE' $ trim(prg_file->prg_line);
          .or. 'FUNC ' $ trim(prg_file->prg_line) .or. 'FUNCTION' $ trim(prg_file->prg_line)
      nAt = at('PROC', trim(prg_file->prg_line))
      nAt = if(nAt = 1 .or. substr(trim(prg_file->prg_line), nAt-1,1) = ' ', nAt, 0)
      if nAt = 0
        nAt = at('FUNC', trim(prg_file->prg_line))
        nAt = if(nAt = 1 .or. substr(trim(prg_file->prg_line), nAt-1,1) = ' ', nAt, 0)
      endif
      if nAt != 0
        lProc_def = .t.
      endif
    endif
    if lProc_def
      while substr(trim(prg_file->prg_line), nAt, 1) != ' ' .and. nAt <= len(trim(prg_file->prg_line))
        nAt++
      enddo
      cCall_proc = next_word(trim(prg_file->prg_line), nAt+1)
      nCall_proc = ascan(aSpec[1], cCall_proc)
      if nCall_proc = 0
        aadd(aSpec[1], cCall_proc)
        aadd(aSpec[2], aPrg[nCnt])
        aadd(aSpec[3], {})
        aadd(aSpec[4], {})
        aadd(aSpec[5], .f.)
        nCall_proc = len(aSpec[1])
      else
        aSpec[2, nCall_proc] = aPrg[nCnt]
      endif
    else
      if substr(trim(prg_file->prg_line),1,3) = 'DO '
        while substr(trim(prg_file->prg_line),1,4) = ' '
          prg_file->prg_file->prg_line := stuff(trim(prg_file->prg_line),4,1,'')
        enddo
        if substr(trim(prg_file->prg_line),1,7) != 'DO WHIL' .and. substr(trim(prg_file->prg_line),1,7) != 'DO CASE'
          cProc = next_word(trim(prg_file->prg_line), 4)
          ins_proc(cProc, cCall_proc, nCall_proc)
        endif
      endif
      if substr(trim(prg_file->prg_line),1,5) = 'CALL '
        while substr(trim(prg_file->prg_line),1,6) = ' '
          prg_file->prg_file->prg_line := stuff(trim(prg_file->prg_line),6,1,'')
        enddo
        cProc = next_word(trim(prg_file->prg_line), 6)
        ins_proc(cProc, cCall_proc, nCall_proc)
      endif
      cTemp = trim(prg_file->prg_line)
      while at('(', cTemp) != 0
        cProc = ''
        nAt = at('(', cTemp)
        if nAt != 0
          while nAt > 1 .and. (substr(cTemp, nAt-1, 1) $ val_char)
            cProc += substr(cTemp, nAt-1, 1)
            nAt--
          enddo
        endif
        if !empty(cProc)
          cProc1 = ''
          for nAt = len(cProc) to 1 step -1         // reverse reversed string
            cProc1 += substr(cProc, nAt, 1)
          next
          if ascan(clp_proc, substr(cProc1,1,10)) = 0
            ins_proc(cProc1, cCall_proc, nCall_proc)
          endif
        endif
        nAt = at('(', cTemp)
        cTemp = stuff(cTemp,1,nAt,'')
      enddo
    endif
    select prg_file
    dbskip()
  enddo
  restsector(cSect)
next
restsector(cSec1)
restsector(cSec2)
release cSec1
release cSec2
setkey(-4, {|| spec_prtype()})
select prg_file
dbclosearea()
ferase('prg_file.dbf')
nChoice = 1
while nChoice != 0
  cOrig = setcolor(memvar->CYAN_BLUE)
  cSect = draw_box(3,50,6,77)
  @4,52 say aPr_type[nPr_type]
  @5,52 say 'Press F5 to change this'
  setcolor(cOrig)
  nChoice = mget_arr(aWhat_do,,,,.t.)
  do case
    case nChoice = 1 .or. nChoice = 3
      afill(aSpec[5], .f.)
      asize(aExe, 0)
      for nCnt = 1 to len(aSpec[1])
        if substr(aSpec[2, nCnt], 1,  at('.', aSpec[2, nCnt])-1) = aSpec[1, nCnt]
          if empty(aSpec[3, nCnt])
            cExe = trim(aspec[1, nCnt]) + '.exe'
            if file(cExe)
              aadd(aExe, aSpec[1, nCnt])
            endif
          endif
        endif
      next
      nPcnt = mget_arr(aExe)
      nCnt = ascan(aSpec[1], aExe[nPcnt])
      for nTemp = 1 to 5
        asize(aSpec[nTemp], len(aSpec[nTemp])+1)
      next
      
      for nPcnt = 1 to 5
        ains(aSpec[nPcnt], 1)
        aSpec[nPcnt,1] = aSpec[nPcnt,nCnt+1]
        adel(aSpec[nPcnt], nCnt+1)
      next
      
      nUp_to = 1
      
      for nCnt = 1 to len(aSpec[1])-1
        if len(aspec[3, nCnt]) > 1
          exit
        endif
        aSpec[5, nCnt] = .t.
        for nPcnt = 1 to len(aSpec[4,nCnt])
          nAt = ascan(aSpec[1], aspec[4, nCnt, nPcnt], nCnt)
          if nAt != 0
            aSpec[5, nAt] = .t.
            if len(aSpec[3, nAt]) = 1
              nUp_to++
              for nTemp = 1 to 5
                ains(aSpec[nTemp], nUp_to)
                aSpec[nTemp,nUp_to] = aSpec[nTemp,nAt+1]
                adel(aSpec[nTemp], nAt+1)
              next
            endif
          endif
        next
      next
      for nAt = 1 to 5                      // delete temp element use for sorting
        aSize(aSpec[nAt], len(aSpec[nAt])-1)
      next
    case nChoice = 2
      declare aTemp[len(aSpec[1])]
      acopy(aSpec[1], aTemp)
      asort(aTemp)
      for nTemp = 1 to 5
        asize(aSpec[nTemp], len(aSpec[nTemp])+1)
      next
      for nCnt = 1 to len(aTemp)-1
        nAt = ascan(aSpec[1], aTemp[nCnt])
        if nAt != nCnt
          for nTemp = 1 to 5
            ains(aSpec[nTemp], nCnt)
            aSpec[nTemp,nCnt] = aSpec[nTemp,nAt+1]
            adel(aSpec[nTemp], nAt+1)
          next
        endif
      next
      for nTemp = 1 to 5
        asize(aSpec[nTemp], len(aSpec[nTemp])-1)
      next
      release aTemp
      
  endcase
  
  do case
    case nChoice = 0
      if !mMake_sure(memvar->oMouse,,,'Return to menu ?')
        nChoice = 9
      endif
    case nChoice = 1
      begin sequence
        if openprn()
          break
        endif
        memvar->sTitle = 'SPECIFICATION FOR ' + aspec[1, 1]
        for nCnt = 1 to len(aSpec[1])
          if aSpec[5, nCnt]
            proc_print(nCnt)
          endif
        next
        shutprn()
      end sequence
      
    case nChoice = 2
      begin sequence
        if openprn()
          break
        endif
        memvar->sTitle = 'ALPHABETIC LIST OF PROCEDURES AND FUNCTIONS'
        for nCnt = 1 to len(aSpec[1])
          proc_print(nCnt)
        next
        shutprn()
      end sequence
      
    case nChoice = 3
      nMap = mget_arr(aMap, 20, 50)
      begin sequence
        if openprn()
          break
        endif
        select dd
        dbsetorder(1)
        memvar->sTitle = 'STRUCTURE MAP FOR ' + aspec[1, 1]
        do case
          case nMap = 1
            memvar->sTitle += " (Uniquely called procedures)"
          case nMap = 2
            memvar->sTitle += " (Defined/coded procedures)"
          case nMap = 3
            memvar->sTitle += " (All procedures)"
        endcase
        prntitle(memvar->sTitle, "Y")
        ? aSpec[1, 1]
        if nMap = 1 .or. nMap = 2
          for nCnt = len(aSpec[4, 1]) to 1 step -1
            nScan = ascan(aSpec[1], aSpec[4, 1, nCnt])
            if nMap = 1
              if len(aSpec[3,nScan]) = 1    // last unique proc
                nLast = nCnt
                exit
              endif
            else
              if !empty(aSpec[2,nScan])      // last defined proc
                nLast = nCnt
                exit
              endif
            endif
          next
        else
          nLast = len(aSpec[4,1])                 // last proc
        endif
        for ncnt = 1 to len(aSpec[4,1])
          nAt = ascan(aSpec[1], aSpec[4, 1, nCnt])
          lNo_more = if(nLast = nCnt, .t., .f.)
          if nMap = 1
            if len(aSpec[3,nAt]) = 1              // unique proc
              map_prn('', aSpec[4, 1, nCnt], lNo_more)
            endif
          elseif nMap = 2                         // defined proc
            if !empty(aSpec[2,nAt])
              map_prn('', aSpec[4, 1, nCnt], lNo_more)
            endif
          else
            map_prn('', aSpec[4, 1, nCnt], lNo_more)
          endif
        next
        shutprn()
      end sequence
      
  endcase
enddo
return
*eof()
*********************************************************************
static function next_word (cLine, nStart)
local cName := '', nCnt
nCnt = nStart
while nCnt <= len(cLine) .and. substr(cLine,nCnt,1) != ' ' .and. substr(cLine,nCnt,1) != '('
  cName += substr(cLine,nCnt,1)
  nCnt++
enddo
return(cName)
*********************************************************************
static function prg_load
local cLine, cSect, lComment := .f., nAt, lString, nQu, nDqu, nStr
local cChar, nRstr, nAt1
cSect = draw_box(16,30,18,50)
@17,32 say 'Reading line'
select prg_file
dbgotop()
while !eof()
  if inkey() = K_ESC
    if mMake_sure(memvar->oMouse, 10,,'Quit processing program files ?')
      return(.f.)
    endif
  endif
  @17,45 say str(recno(),4,0)
  cline = trim(prg_file->prg_line)                // extract line to arr
  
  if lComment = .t.
    nAt = at('*/', cLine)
    if nAt = 0
      cLine = ''
    else
      cLine = stuff(cLine, 1, nAt+1, '')
      lComment = .f.
    endif
  endif
  
  lString = .t.                         // remove strings
  while lstring
    nQu = at("'", cLine)
    nDqu = at('"', cLine)
    nstr = nQu
    nStr = if(nDqu > 0 .and. nDqu > nStr, nDqu, nStr)
    if nStr = 0
      lString = .f.
    else
      cChar = if(nStr = nQu, "'", '"')
      nRstr = rat(cChar, cLine)
      if nRstr = 0
        lString = .f.
      else
        cLine = stuff(cLine, nStr, nRstr-nStr+1, '')
      endif
    endif
  enddo
  
  nAt = at('/*', cLine)
  while nAt != 0
    nAt1 = at('*/', cline)
    if nAt1 != 0
      cLine = stuff(cLine,nat,nAt1-nAt+2,'')
      nAt = at('/*', cLine)
    else
      cLine = substr(cLine,1,nAt-1)
      lComment = .t.
      nAt = 0
    endif
  enddo
  
  nAt = at('//', cLine)                 // remove // type comments
  if nAt != 0
    cLine = stuff(cLine, nAt, len(cLine)-nAt, '')
  endif
  
  nAt = at('&&', cLine)                 && remove && type comments
  if nAt != 0
    cLine = stuff(cLine, nAt, len(cLine)-nAt, '')
  endif
  
  cLine = ltrim(trim(cLine))
  
  if substr(cLine,1,1) = '*'
    cLine = ''
  endif
  
  cLine = upper(cLine)
  
  if !empty(cLine)
    prg_file->prg_file->prg_line := cline
  else
    dbdelete()
  endif
  dbskip()
enddo
pack
restsector(cSect)
return(.t.)
*********************************************************************
static procedure ins_proc (cProc, cCall_proc, nCall_proc)
local nScan, nScan1
if empty(cProc)
  return
endif
nScan = ascan(memvar->aSpec[1], cProc)
if nScan = 0
  aadd(memvar->aSpec[1], cProc)
  aadd(memvar->aSpec[2], '')
  aadd(memvar->aSpec[3], {})
  aadd(memvar->aSpec[4], {})
  aadd(memvar->aSpec[5], .f.)
  nScan = len(memvar->aSpec[1])
endif
nScan1 = ascan(memvar->aSpec[3,nScan], cCall_proc)
if nScan1 = 0
  aadd(memvar->aSpec[3,nScan], cCall_proc)
endif
nscan1 = ascan(memvar->aSpec[4, nCall_proc], cProc)
if nScan1 = 0
  aadd(memvar->aSpec[4,nCall_proc], cproc)
endif
return
*********************************************************************
static procedure spec_print ( cString )
if memvar->pLine > 55
  prntitle(memvar->sTitle)
  if !memvar->lHeading
    pr_line('      Program/procedure name  ' + memvar->aSpec[1, memvar->nCnt])
  endif
endif
pr_line(space(6) + cString)
return
*******************************************************************************
static procedure proc_print(nInx)
local nPcnt, cSect, cSeek, cLine, cSpec, nLen
cSect = disp_msg(,,'Printing ' + memvar->aSpec[1, nInx])
select dd
cSeek = trim(memvar->aSpec[1, nInx])
if len(cSeek) > 10
  cSeek = substr(cSeek,1,10)
endif
dbseek(cSeek + '.PRG               ')
if memvar->nPr_type = 2
  if memvar->pLine > 55
    prntitle(memvar->sTitle)
  endif
  memvar->pLine++
  cLine = memvar->aSpec[1, nInx] + space(20-len(memvar->aSpec[1, nInx]))
  if found()
    cLine += dd->descriptn
  endif
  pr_line(space(6) + cLine)
else
  memvar->lHeading = .t.
  if memvar->pLine > 45
    memvar->pLine = 70
  endif
  spec_print('Program/procedure name  ' + memvar->aSpec[1, nInx])
  memvar->lHeading = .f.
  if found()
    spec_print('  Description :         ' + dd->descriptn)
  endif
endif
if memvar->nPr_type = 1 .or. memvar->nPr_type = 3
  spec_print('  Source in             ' + memvar->aSpec[2, nInx])
  if len(memvar->aSpec[3,nInx]) > 0
    spec_print('  Called from    ' + memvar->aSpec[3,nInx,1])
    for nPcnt = 2 to len(memvar->aSpec[3,nInx])
      spec_print(space(17) + memvar->aSpec[3, nInx, nPcnt])
    next
  endif
  if len(memvar->aSpec[4,nInx]) > 0
    spec_print('  Uses           ' + memvar->aSpec[4,nInx,1])
    for nPcnt = 2 to len(memvar->aSpec[4,nInx])
      spec_print(space(17) + memvar->aSpec[4, nInx, nPcnt])
    next
  endif
  spec_print(' ')
endif
if memvar->nPr_type = 1 .or. memvar->nPr_type = 4
  cSpec = ''
  select ddspec
  dbseek(cSeek + '.PRG')
  if found() .and. !empty(ddspec->spec)
    cSpec = ddspec->spec
  else
    select dd
    dbseek(cSeek + '.PRG               ')
    if found() .and. len(dd->help) > 0
      cSpec = dd->help
    endif
  endif
  
  nLen = mlcount(cSpec, 69)
  for nPcnt = 1 to nLen
    spec_print('  ' + memoline(cSpec, 69, nPcnt))
  next
  spec_print(' ')
  spec_print(' ')
endif
restsector(cSect)
return
***********************************************************
static function map_prn(cIn_str, cProc_name, lLast)
local nAt, nCnt, cOut_str, nScan, nLast, lNo_more, cDescr, cLook, cLine
local nReiterative
cDescr = space(1)
if memvar->pLine > 60
  prntitle(memvar->sTitle, "Y")
endif
select dd
cLook = cProc_name
if len(cLook) > 10
  clook = substr(cLook,1,10)
endif
if dbseek(trim(cLook) + '.PRG' + space(15))
  cDescr = dd->descriptn
endif
if lLast
  cOut_str = cIn_str + '     '
  cLine = cIn_str + ' ÀÄÄÄ' + cProc_name
  if len(cLine) < 65
    cLine += space(67 - len(cLine)) + cDescr
  else
    cLine += '  ' + cDescr
  endif
  pr_line(cLine)
else
  cOut_str = cIn_str + ' ³   '
  cLine = cIn_str + ' ÃÄÄÄ' + cProc_name
  if len(cLine) < 65
    cLine += space(67 - len(cLine)) + cDescr
  else
    cLine += '  ' + cDescr
  endif
  pr_line(cLine)
endif
nAt = ascan(memvar->aSpec[1], cProc_name)
if memvar->nMap = 1 .or. memvar->nMap = 2
  for nCnt = len(memvar->aSpec[4, nAt]) to 1 step -1
    nScan = ascan(memvar->aSpec[1], memvar->aSpec[4, nAt, nCnt])
    if memvar->nMap = 1
      if len(memvar->aSpec[3,nScan]) = 1        // last unique proc
        nLast = nCnt
        exit
      endif
    else
      if !empty(memvar->aSpec[2,nScan])         // last defined proc
        nLast = nCnt
        exit
      endif
    endif
  next
else
  nLast =  len(memvar->aSpec[4, nAt])           // last proc
endif
for nCnt = 1 to len(memvar->aSpec[4, nAt])
  nScan = ascan(memvar->aSpec[1], memvar->aSpec[4, nAt, nCnt])
  lNo_more = if(nCnt = nLast, .t., .f.)
  nReiterative = ascan(memvar->aSpec[4, nAt], cProc_name)
  if nReiterative = 0
    if memvar->nMap = 1
      if len(memvar->aSpec[3,nScan]) = 1          // if proc unique
        map_prn(cOut_str, memvar->aSpec[4, nAt, nCnt], lNo_more)
      endif
    elseif memvar->nMap = 2
      if !empty(memvar->aSpec[2,nScan])           // last defined proc
        map_prn(cOut_str, memvar->aSpec[4, nAt, nCnt], lNo_more)
      endif
    else
      map_prn(cOut_str, memvar->aSpec[4, nAt, nCnt], lNo_more)    // last proc
    endif
  endif
next
return nil
*********************************************************************
static procedure spec_prtype
local cOrig
cOrig = setcolor(memvar->CYAN_BLUE)
memvar->nPr_type = mget_arr(memvar->aPr_type, 8, 55)
@4,52 say memvar->aPr_type[memvar->nPr_type]
setcolor(cOrig)
return
* eof (spec_prtype)
