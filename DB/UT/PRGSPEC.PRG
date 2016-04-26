*******************************************************************************
* prgspec prints system specification
local cVal_char := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ_1234567890'
local aWhat_do := {'Print procedures alphabetically',;
    'Print structure map'}

local aStru     // temp array for creating temp database files
local cSect, nAt, cCall_proc, cProc1, nChoice, cPrg_line
local cPath, cSec2, nPerc, lProc_def, cProc, cTemp, cOrig
local nCnt, cTop_proc, nRec, lNo_more
local nWin1, nWin2, nWin3

* Declare public variables
memvar aPr_type, nPr_type, aPrg, aExe, aClp_proc

#include 'inkey.ch'

public aPr_type := {'Print full spec      ',;
    'Print proc names only',;
    'Print calling info',;
    'Print spec only'}, nPr_type := 1
public aPrg[adir('*.prg')]
public aExe[0]
public aClp_proc[0]

begin sequence

* Create array with Clipper and common procedure names - then close files
cPath = getenv("PATH")
set path to (cPath)
select 198
if net_use('Clp_proc', .f.)
  while !eof()
    aadd(aClp_proc, trim(clp_proc->proc_name))
    dbskip()
  enddo
  dbclosearea()
endif

if file('COM_PROC.DBF') .and. net_use('com_proc', .f.)
  while !eof()
    aadd(aClp_proc, trim(com_proc->proc_name))
    dbskip()
  enddo
  dbclosearea()
endif
set path to

* Create temporary database files used by the program
aStru := {}
aadd(aStru, {'PRG_LINE  ', 'C', 255,0})
dbcreate('PRG_FILE', aStru)
select 195
if !net_use('prg_file', .t.)
  break
endif

aStru := {}
aadd(aStru, {'PROC_NAME ', 'C', 12,0})
aadd(aStru, {'SOURCE    ', 'C', 12,0})
dbcreate('PROCS', aStru)
select 196
if !net_use('PROCS', .t.)
  break
endif
index on procs->proc_name to procs

aStru := {}
aadd(aStru, {'CALLING   ', 'C', 12,0})
aadd(aStru, {'CALLED    ', 'C', 12,0})
dbcreate('CALLS   ', aStru)
select 197
if !net_use('CALLS', .t.)
  break
endif
index on calls->calling + calls->called to calling
index on calls->called + calls->calling to called
dbclearindex()
dbsetindex('CALLING')
dbsetindex('CALLED')
release aStru

adir('*.prg', aPrg)     // obtain and sort an array of prg file names
asort(aPrg)

nWin1 = wopen(21,15,23,65)
setcolor(memvar->black_green)
setcursor(0)
wbox(0)
@0,0 say center('Press "ESC" to quit processing program files')

nWin2 = wopen(4,5,7,75)
setcolor(memvar->blue_cyan)
setcursor(0)
wbox(0)
@0,2 say center('Percentage program files processed')

for nCnt = 1 to len(aPrg)
  wselect(nWin2)
  nPerc = int(nCnt / len(aPrg) * maxcol()+1)    // display progress
  @1,0 say replicate('±', nPerc)
  if inkey() = K_ESC
    if wmake_sure(10,,'Quit processing program files ?')
      break
    endif
  endif

nWin3 = wopen(10,20,12,60)
setcursor(0)
wbox(0)
@0,3 say 'Processing ' + aPrg[nCnt]

  select prg_file
  zap
  append from (aPrg[nCnt]) sdf          // import file into database format
  if !prg_load()                        // trim of excess detail
    break
  endif
  
  nAt = at('.', aPrg[nCnt])
  cCall_proc = stuff(aPrg[nCnt], nAt, len(aPrg[nCnt])-nAt+1, '')
  cCall_proc = proc_full_name(cCall_proc)
  select procs
  if !dbseek(cCall_proc)
    dbappend()
    procs->proc_name := cCall_proc
    procs->source := aPrg[nCnt]
  else
    procs->source := aPrg[nCnt]
  endif
  select prg_file
  dbgotop()

  wselect(nWin3)  
  while !eof()
    @0,30 say str(recno(),5,0)
    lProc_def = .f.
    cPrg_line = alltrim(upper(prg_file->prg_line))
    if 'PROC ' $ trim(cPrg_line);
          .or. 'PROCEDURE' $ trim(cPrg_line);
          .or. 'FUNC ' $ trim(cPrg_line);
          .or. 'FUNCTION' $ trim(cPrg_line)
      nAt = at('PROC', trim(cPrg_line))
      nAt = if(nAt = 1 .or. substr(trim(cPrg_line), nAt-1,1) = ' ';
          , nAt, 0)
      if nAt = 0
        nAt = at('FUNC', trim(cPrg_line))
        nAt = if(nAt = 1 .or. substr(trim(cPrg_line), nAt-1,1) = ' ',;
            nAt, 0)
      endif
      if nAt != 0
        lProc_def = .t.
      endif
    endif
    if lProc_def
      while substr(trim(cPrg_line), nAt, 1) != ' ' .and.;
            nAt <= len(trim(cPrg_line))
        nAt++
      enddo
      cCall_proc = next_word(trim(cPrg_line), nAt+1)
      cCall_proc = proc_full_name(cCall_proc)
      select procs
      if !dbseek(cCall_proc)
        dbappend()
        procs->proc_name := cCall_proc
        procs->source := aPrg[nCnt]
      else
        procs->source := aPrg[nCnt]
      endif
    else
      if substr(trim(cPrg_line),1,3) = 'DO '
        while substr(trim(cPrg_line),1,4) = ' '
          cPrg_line := stuff(trim(cPrg_line),4,1,'')
        enddo
        if substr(trim(cPrg_line),1,7) != 'DO WHIL' .and.;
              substr(trim(cPrg_line),1,7) != 'DO CASE'
          cProc = next_word(trim(cPrg_line), 4)
          ins_proc(cProc, cCall_proc)
        endif
      endif
      if substr(trim(cPrg_line),1,5) = 'CALL '
        while substr(trim(cPrg_line),1,6) = ' '
          prg_file->cPrg_line := stuff(trim(cPrg_line),6,1,'')
        enddo
        cProc = next_word(trim(cPrg_line), 6)
        ins_proc(cProc, cCall_proc)
      endif
      cTemp = trim(cPrg_line)
      while at('(', cTemp) != 0
        cProc = ''
        nAt = at('(', cTemp)
        if nAt != 0
          while nAt > 1 .and. (substr(cTemp, nAt-1, 1) $ cVal_char)
            cProc += substr(cTemp, nAt-1, 1)
            nAt--
          enddo
        endif
        if !empty(cProc)
          cProc1 = ''
          for nAt = len(cProc) to 1 step -1         // reverse reversed string
            cProc1 += substr(cProc, nAt, 1)
          next
          if ascan(aClp_proc, substr(cProc1,1,10)) = 0
            ins_proc(cProc1, cCall_proc)
          endif
        endif
        nAt = at('(', cTemp)
        cTemp = stuff(cTemp,1,nAt,'')
      enddo
    endif
    select prg_file
    dbskip()
  enddo
  wselect(nWin3)
  wclose()
next
wselect(nWin1)
wclose()
wselect(nWin2)
wclose()

setkey(-4, {|| spec_prtype()})

* Delete temporary source file
select prg_file
dbclosearea()
deletefile('prg_file.dbf')

nChoice = 1
while nChoice != 0
  cOrig = setcolor(memvar->CYAN_BLUE)
  cSect = draw_box(3,50,6,77)
  @4,52 say aPr_type[nPr_type]
  @5,52 say 'Press F5 to change this'
  setcolor(cOrig)
  nChoice = mget_arr(aWhat_do,,,,.t.)
  do case
    case nChoice = 0
      if !wmake_sure(10,,'Return to menu ?')
        nChoice = 9
      endif
    case nChoice = 1
      begin sequence
        if openprn()
          break
        endif
        memvar->sTitle = 'ALPHABETIC LIST OF PROCEDURES AND FUNCTIONS'
        select procs
        dbgotop()
        while !eof()
          proc_print(nPr_type)
          select procs
          dbskip()
        enddo
        shutprn()
      end sequence
      
    case nChoice = 2
      cTop_proc = et_seek('procs', {1}, .t.)
      begin sequence
        if openprn()
          break
        endif
        select dd
        dbsetorder(1)
        memvar->sTitle = 'STRUCTURE MAP FOR ' + cTop_proc
        prntitle(memvar->sTitle, "Y")
        ? cTop_proc
        select calls
        dbsetorder(1)
        dbseek(cTop_proc)
        while calls->calling = cTop_proc .and. !eof()
          nRec = recno()
          lNo_more = last_call()
          map_prn('', calls->called, lNo_more)
          select calls
          dbsetorder(1)
          dbgoto(nRec)
          dbskip()
        enddo
        shutprn()
      end sequence
      
  endcase
enddo

end sequence
wselect(nWin1)
wclose()
wselect(nWin2)
wclose()
* Delete temporary storage files

select procs
dbclosearea()
deletefile('procs.dbf')
deletefile('procs.ntx')

select calls
dbclosearea()
deletefile('calls.dbf')
deletefile('calling.ntx')
deletefile('called.ntx')

return

*eof()

*******************************************************************************
function next_word (cLine, nStart)
local cName := '', nCnt
nCnt = nStart
while nCnt <= len(cLine) .and. substr(cLine,nCnt,1) != ' ' .and. substr(cLine,nCnt,1) != '('
  cName += substr(cLine,nCnt,1)
  nCnt++
enddo
return(cName)

*f*****************************************************************************
* Prg_load
function prg_load
local cLine, cSect, lComment := .f., nAt, lString, nQu, nDqu, nStr
local cChar, nRstr, nAt1, nWin, lReturn := .t.

nWin = wopen(16,25,18,55)
setcolor(memvar->blue_cyan)
wbox()
setcursor(0)
@0,3 say 'Reading line'
select prg_file

begin sequence

dbgotop()
while !eof()
  if inkey() = K_ESC
    if wmake_sure(10,,'Quit processing program files ?')
      lReturn = .f.
      break
    endif
  endif
  @0,15 say str(recno(),6,0)
  cline = trim(prg_file->prg_line)              // extract line
  
  if lComment = .t.                             // remove /* */ type comments
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
  
  nAt = at('/*', cLine)                         // remove /* */ type comments
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
  
  if substr(cLine,1,1) = '*'            // remove * type comments
    cLine = ''
  endif
  
  cLine = upper(cLine)                  // transform to uppercase
  
  if !empty(cLine)
    prg_file->prg_line := cline
  else
    dbdelete()                          // delete if empty
  endif
  dbskip()
enddo
pack                                    // pack database
end sequence
wclose()
return(lReturn)

*f********************************************************************
* Procedure ins proc - load procedure details into data structure
* Parameters - cProc - procedure to be inserted
*              cCall proc - procedure called from
static procedure ins_proc (cProc, cCall_proc)

local cSeek

if empty(cProc)
  return
endif

select procs
cproc = proc_full_name(cproc)
if !dbseek(cProc)
  dbappend()
  procs->proc_name := cProc
endif
cSeek = cProc + space(12- len(cProc))  + cCall_proc
select calls
dbsetorder(2)
if !dbseek(cSeek)
  dbappend()
  calls->calling := cCall_proc
  calls->called := cProc
endif
return

*******************************************************************************
static procedure spec_print ( cString )
if memvar->pLine > 55
  prntitle(memvar->sTitle)
  if !memvar->lHeading
    pr_line('      Program/procedure name  ' + procs->proc_name)
  endif
endif
pr_line(space(6) + cString)
return

*f*****************************************************************************
static procedure proc_print(nIn_pr_type)
local cSect, cSeek, cLine, cSpec, nLen, nPcnt
memvar lHeading
cSect = disp_msg(,,'Printing ' + procs->proc_name)
select dd                               // search for proc in data dictionary
cSeek = trim(procs->proc_name)
if len(cSeek) > 10
  cSeek = substr(cSeek,1,10)
endif
dbseek(cSeek + '.PRG               ')
if nIn_pr_type = 2
  if memvar->pLine > memvar->pr_lines - 5
    prntitle(memvar->sTitle)
  endif
  cLine = procs->proc_name + space(20-len(procs->proc_name))
  if found()
    cLine += dd->descriptn
  endif
  pr_line(space(6) + cLine)
else
  lHeading = .t.
  if memvar->pLine > 45
    memvar->pLine = 70
  endif
  spec_print('Program/procedure name  ' + procs->proc_name)
  lHeading = .f.
  if found()
    spec_print('  Description :         ' + dd->descriptn)
  endif
endif
if nIn_pr_type = 1 .or. nIn_pr_type = 3
  spec_print('  Source in             ' + procs->source)
  select calls
  dbsetorder(2)
  if dbseek(procs->proc_name)
    spec_print('  Called from    ' + calls->calling)
    dbskip()
  endif
  while calls->called = procs->proc_name .and. !eof()
    spec_print(space(17) + calls->calling)
    dbskip()
  enddo
  select calls
  dbsetorder(1)
  if dbseek(procs->proc_name)
    spec_print('  Uses           ' + calls->called)
    dbskip()
  endif
  while calls->calling = procs->proc_name .and. !eof()
    spec_print(space(17) + calls->called)
    dbskip()
  enddo
  spec_print(' ')
endif
if nIn_pr_type = 1 .or. nIn_pr_type = 4
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

*f*****************************************************************************
static procedure map_prn(cIn_str, cProc_name, lLast)

local cOut_str, lNo_more, cDescr, cLook, cLine, nRec

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
select calls
dbsetorder(1)
dbseek(cProc_name)
while cProc_name = calls->calling .and. !eof()
  nRec = recno()
  lNo_more = last_call()
  if calls->calling != calls->called            // reiterative
    map_prn(cOut_str, calls->called, lNo_more)
  endif
  select calls
  dbsetorder(1)
  dbgoto(nRec)
  dbskip()
enddo
return

*f*****************************************************************************
static procedure spec_prtype

local cOrig
cOrig = setcolor(memvar->CYAN_BLUE)
memvar->nPr_type = mget_arr(memvar->aPr_type, 8, 55)
@4,52 say memvar->aPr_type[memvar->nPr_type]
setcolor(cOrig)
return
* eof (spec_prtype)

*f*****************************************************************************
* Last_call - Determines if this is the last procedure called by the current
*             procedure
static function last_call
local cKey, nOrder, lReturn, nRec
select calls
nOrder = indexord()
dbsetorder(1)
cKey = calls->calling
nRec = recno()
dbskip()
if cKey != calls->calling
  lReturn = .t.
else
  lReturn = .f.
endif
dbsetorder(nOrder)
dbgoto(nRec)
return(lReturn)

*******************************************************************************
function proc_full_name(cName)
if len(cName) = 10
  return(cName)
endif
if len(cName) < 10
  cName += space(10 - len(cName))
else
  cName = substr(cName,1,10)
endif
return(cName)

