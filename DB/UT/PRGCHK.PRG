*******************************************************************************
* program prgchk
local nAction, lCont := .t., cSect, cSect1, aPrg_file, cCol
local aAction := {'Indent program',;
    'Display program structure',;
    'Edit program',;
    'Check program structure',;
    'Load new file',;
    'Save source to DD',;
    'Procedure specs',;
    'Print source file',;
    'Return'}
memvar aPrg, aLines, cOld_file, nCh, mFile
memvar aLevel, nCnt, lFixed
memvar aStru

private aPrg[adir('*.prg')], aLines[0], cOld_file, nCh
private aLevel[0,2], nCnt, lFixed
private aStru[0]

aPrg_file := {}
aadd(aPrg_file, {'PRG_LINE  ', 'C', 255,0})
dbcreate('PRG_FILE', aPrg_file)

select 198
if !net_use('prg_file', .t.)
  return
endif

adir('*.prg', aPrg)
asort(aPrg)
nCh = mget_arr(aPrg,,,,.t.)
if nCh = 0
  return
endif
mFile = memoread(aPrg[nCh])

while lCont
  cSect1 = disp_msg(6, , 'Current program - ' + aPrg[nCh])
  nAction = mget_arr(aAction,11,,,.t.)
  do case
    case nAction = 1                    // indent file
      chk_indent()
      
    case nAction = 2                    // display structure
      chk_dispstru()
      
    case nAction = 3                    // edit program
      cCol = setcolor(memvar->CYAN_BLUE)
      cSect = savesector(0,0,24,79)
      mFile = memoedit(mFile, 0,0,24,79,.t.,,254)
      restsector(cSect)
      setcolor(cCol)
      if wMake_sure(12,,'Write file back to disk')
        memowrit(aPrg[nCh], mFile)
      endif
      
      
    case nAction = 4                    // structure check
      chk_checkstru()
      
    case nAction = 5                    // load new file
      restsector(cSect1)
      nCnt = nCh
      adir('*.prg', aPrg)
      asort(aPrg)
      nCh = mget_arr(aPrg,,,.t.)
      if nCh = 0
        nCh = nCnt
      endif
      mFile = memoread(aPrg[nCh])
      
    case nAction = 6                    // save source to DD
      if wMake_sure(12)
        select ddspec
        seek aPrg[nCh]
        if !found()
          append blank
          reclock('DDSPEC')
          ddspec->file := aPrg[nCh]
          unlock
        endif
        reclock('DDSPEC')
        ddspec->source := mfile
        ddspec->source_dt := date()
        unlock
      endif
      
    case nAction = 7                    // procedure specs
      chk_procspec()
      
    case nAction = 8                    // print source
      chk_print()
      
    case nAction = len(aAction) .or. nAction = 0
      lCont = .f.
  endcase
  mFile = memoread(aPrg[nCh])
enddo

select prg_file
dbclosearea()

ferase('prg_file.dbf')

return

*f********************************************************************
procedure fix_err (nLine)
local cSect, cCol, cSect1, aOpt := {'Edit file', 'Ignore error'}, nOpt, nCnt
local cOld_file, lFixed
cSect1 = disp_msg(6,, lev_type(atail(memvar->aLevel)[1]) + ' stucture not closed, Line ' + ltrim(str(atail(memvar->aLevel)[2])))
nOpt = mget_arr(aOpt)
if nOpt = 1
  cCol = setcolor(memvar->CYAN_BLUE)
  csect = draw_box(10,0,22,79)
  memvar->mFile = memoedit(memvar->mFile, 11,1,21,78,.t.,'memo_udf' ,254,,nLine)
  nCnt = 0
  cOld_file = memvar->mFile
  asize(memvar->aLevel, 0)
  lFixed = .t.
  restsector(cSect)
endif
restsector(cSect1)
setcolor(cCol)
return

*********************************************************************
function lev_type (cIn_type)
local cOut_type
do case
  case cIn_type = 'I'
    cOut_type = 'IF'
  case cIn_type = 'C'
    cOut_type = 'CASE'
  case cIn_type = 'W'
    cOut_type = 'WHILE'
  case cIn_type = 'F'
    cOut_type = 'FOR'
endcase
return (cOut_type)

*********************************************************************
function memo_udf (nMode, nLine, nCol)
if nMode = 0
  @10,60 say 'Line ' + str(nLine,4,0)
endif
return(0)

function fStru_udf (nMode, nItem, nRow)
if nMode = 3
  do case
    case lastkey() = 27
      return(0)
    case lastkey() = 7
      adel(memvar->aStru, nItem)
      asize(memvar->aStru, len(memvar->aStru)-1)
      return(1)
  endcase
endif
return(2)

*f****************************************************************
procedure chk_indent()
local nIndent := 2, lCom_indent := .f., cNew_file, cSect
local cFile_line, cLine, nHandle, nCnt
memvar getlist

#define EOL     chr(13) + chr(10)

select prg_file
zap
append from (memvar->aPrg[memvar->nCh]) sdf

nHandle = fcreate(memvar->aPrg[memvar->nCh])

aSize(memvar->aLevel, 0)
nCnt = 0
cSect = draw_box(12,28,14,50)
@13,30 say 'Spaces to indent' get nIndent picture '9'
read
restsector(cSect)
cSect = draw_box(17,30,19,51)
@18,32 say 'Checking line'
dbgotop()
while !eof()
  nCnt++
  @18,46 say str(recno(),4,0)
  cFile_Line = ltrim(trim(prg_file->prg_line))
  cline = upper(cFile_line)
  cFile_line = space(len(memvar->aLevel)*nIndent) + cFile_line + EOL
  if lCom_indent
    cFile_line = stuff(cFile_line, 1, 0, space(nIndent * 2))
    lCom_indent = .f.
  endif
  if substr(cline,len(cline), 1) = ';'
    lCom_indent = .t.
  endif
  if substr(cLine,1,3) = 'DO '
    while substr(cLine,1,4) = ' '
      cLine = stuff(cLine,4,1,'')
    enddo
  endif
  do case
    case cLine = 'DO CASE'
      aadd(memvar->aLevel, {'C', nCnt})
      aadd(memvar->aLevel, {'D', nCnt})
    case cLine = 'DO WHILE' .or. cLine = 'WHILE '
      aadd(memvar->aLevel, {'W', nCnt})
    case cLine = 'FOR '
      aadd(memvar->aLevel, {'F', nCnt})
    case cLine = 'IF '
      aadd(memvar->aLevel, {'I', nCnt})
    case cLine = 'BEGIN '
      aadd(memvar->aLevel, {'B', nCnt})
    otherwise
      if len(memvar->aLevel) > 0
        do case
          case cLine = 'NEXT'
            if atail(memvar->aLevel)[1] = 'F'
              asize(memvar->aLevel, len(memvar->aLevel)-1)
              cFile_line = stuff(cFile_line, 1, nIndent, '')
            endif
          case cLine = 'ENDIF'
            if atail(memvar->aLevel)[1] = 'I'
              asize(memvar->aLevel, len(memvar->aLevel)-1)
              cFile_line = stuff(cFile_line, 1, nIndent, '')
            endif
          case cLine = 'ENDCASE'
            if atail(memvar->aLevel)[1] = 'D'
              asize(memvar->aLevel, len(memvar->aLevel)-1)
              asize(memvar->aLevel, len(memvar->aLevel)-1)
              cFile_line = stuff(cFile_line, 1, 4, '')
            endif
          case cLine = 'CASE' .or. cLine = 'OTHER'
            if atail(memvar->aLevel)[1] = 'D'
              cFile_line = stuff(cFile_line, 1, nIndent, '')
            endif
          case cLine = 'ELSE'
            if atail(memvar->aLevel)[1] = 'I'
              cFile_line = stuff(cFile_line, 1, nIndent, '')
            endif
          case cLine = 'ENDDO'
            if atail(memvar->aLevel)[1] = 'W'
              asize(memvar->aLevel, len(memvar->aLevel)-1)
              cFile_line = stuff(cFile_line, 1, nIndent, '')
            endif
          case cLine = 'END'
            if atail(memvar->aLevel)[1] = 'D'
              asize(memvar->aLevel, len(memvar->aLevel)-1)
              asize(memvar->aLevel, len(memvar->aLevel)-1)
              cFile_line = stuff(cFile_line, 1, 4, '')
            elseif atail(memvar->aLevel)[1] = 'W' .or. atail(memvar->aLevel)[1] = 'I';
                  .or. atail(memvar->aLevel)[1] = 'B'
              asize(memvar->aLevel, len(memvar->aLevel)-1)
              cFile_line = stuff(cFile_line, 1, nIndent, '')
            endif
        endcase
      endif
  endcase
  fwrite(nHandle, cFile_line)
  dbskip()
enddo
fclose(nHandle)
restsector(cSect)

return

*f********************************************************************
procedure chk_dispstru()
local cOld_file, cSect, nCnt, cLine1, nNext_line, nAt, cLine, nRow
cSect = draw_box(17,30,19,51)
@18,32 say 'Checking line'
nCnt = 0
memvar->aStru = {}
cOld_file = memvar->mFile
while len(cOld_file) > 2
  nCnt++
  @18,46 say str(nCnt,4,0)
  cLine1 = memoline(cOld_file, 254, 1)
  cLine = upper(ltrim(cLine1))
  nNext_line = mlpos(cOld_file, 254, 2)
  cOld_file = stuff(cOld_file, 1, nNext_line-1, '')
  if substr(cLine,1,3) = 'DO '
    while substr(cLine,1,4) = ' '
      cLine = stuff(cLine,4,1,'')
    enddo
  endif
  if cLine = 'DO CASE' .or. cLine = 'DO WHILE' .or. cLine = 'WHILE';
        .or. cLine = 'FOR' .or. cLine = 'IF' .or. cLine = 'NEXT';
        .or. cLine = 'END' .or. cLine = 'ENDIF' .or. cLine = 'ENDCASE';
        .or. cLine = 'CASE' .or. cLine = 'OTHER' .or. cLine = 'ELSE';
        .or. cLine = 'ENDDO'
    aadd(memvar->aStru, str(nCnt,4,0) + ' ' + substr(cLine1,1,70))
  endif
enddo
restsector(cSect)
cSect = draw_box(4,1,23,78)
nat = 1
while nAt != 0
  if nAt < 6
    nRow = nAt
  else
    nRow = 5
  endif
  nAt = achoice(5,2,22,77,memvar->aStru,,'fStru_udf',nAt, nRow)
enddo
memvar->aStru = {}
restsector(cSect)
return

*f********************************************************************
procedure chk_checkstru()
local cOld_file, lFixed, cSect, nCnt, cLine, nNext_line
lFixed = .f.
cSect = draw_box(17,30,19,51)
@18,32 say 'Checking line'
cOld_file = memvar->mFile
nCnt = 0
while len(cOld_file) > 2
  nCnt++
  @18,46 say str(nCnt,4,0)
  cLine = upper(ltrim(memoline(cOld_file, 254, 1)))
  nNext_line = mlpos(cOld_file, 254, 2)
  cOld_file = stuff(cOld_file, 1, nNext_line-1, '')
  if substr(cLine,1,3) = 'DO '
    while substr(cLine,1,4) = ' '
      cLine = stuff(cLine,4,1,'')
    enddo
  endif
  do case
    case cLine = 'DO CASE'
      aadd(memvar->aLevel, {'C', nCnt})
    case cLine = 'DO WHILE' .or. cLine = 'WHILE'
      aadd(memvar->aLevel, {'W', nCnt})
    case cLine = 'FOR'
      aadd(memvar->aLevel, {'F', nCnt})
    case cLine = 'NEXT'
      if atail(memvar->aLevel)[1] = 'F'
        asize(memvar->aLevel, len(memvar->aLevel)-1)
      else
        fix_err(nCnt)
      endif
    case cLine = 'IF'
      aadd(memvar->aLevel, {'I', nCnt})
    case cLine = 'END '
      if atail(memvar->aLevel)[1] = 'C' .or. atail(memvar->aLevel)[1] = 'W' .or.;
            atail(memvar->aLevel)[1] = 'I'
        asize(memvar->aLevel, len(memvar->aLevel)-1)
      else
        fix_err(nCnt)
      endif
    case cLine = 'ENDIF'
      if atail(memvar->aLevel)[1] = 'I'
        asize(memvar->aLevel, len(memvar->aLevel)-1)
      else
        fix_err(nCnt)
      endif
    case cLine = 'ENDCASE'
      if atail(memvar->aLevel)[1] = 'C'
        asize(memvar->aLevel, len(memvar->aLevel)-1)
      else
        fix_err(nCnt)
      endif
    case cLine = 'ENDDO'
      if atail(memvar->aLevel)[1] = 'W'
        asize(memvar->aLevel, len(memvar->aLevel)-1)
      else
        fix_err(nCnt)
      endif
    case cLine = 'PROCEDURE' .or. cLine = 'FUNCTION'
      if len(memvar->aLevel) > 0
        fix_err(nCnt)
      endif
  endcase
enddo
if len(memvar->aLevel) > 0
  fix_err(mlcount(memvar->mFile, 254))
endif
restsector(cSect)
if lFixed
  if wMake_sure(12,,'Write file back to disk')
    memowrit(memvar->aPrg[memvar->nCh], memvar->mFile)
  endif
endif
return

*f********************************************************************
procedure chk_procspec()
local aProc[0], cSect, nPcnt, nAt, cCall_proc, lProc_def, cSeek, cDescr, cSpec
local nCurs, nRec
memvar getlist
select prg_file
zap
append from (memvar->aPrg[memvar->nCh]) sdf
if !prg_load()
  return
endif

cSect = disp_msg(10,, 'Processing ' + memvar->aPrg[memvar->nCh] + '         ')
nAt = at('.', memvar->aPrg[memvar->nCh])
cCall_proc = stuff(memvar->aPrg[memvar->nCh], nAt, len(memvar->aPrg[memvar->nCh])-nAt+1, '')
aadd(aProc, cCall_proc)
dbgotop()
while !eof()
  @11,49 say str(recno(),4,0)
  lProc_def = .f.
  if 'PROC' $ prg_file->prg_line .or. 'FUNC' $ prg_file->prg_line
    nAt = at('PROC', prg_file->prg_line)
    nAt = if(nAt = 1 .or. substr(prg_file->prg_line, nAt-1,1) = ' ', nAt, 0)
    if nAt = 0
      nAt = at('FUNC', prg_file->prg_line)
      nAt = if(nAt = 1 .or. substr(prg_file->prg_line, nAt-1,1) = ' ', nAt, 0)
    endif
    if nAt != 0
      lProc_def = .t.
    endif
  endif
  if lProc_def
    while substr(prg_file->prg_line, nAt, 1) != ' ' .and. nAt <= len(prg_file->prg_line)
      nAt++
    enddo
    cCall_proc = next_word(prg_file->prg_line, nAt+1)
    if len(cCall_proc) > 10
      cCall_proc = substr(cCall_proc, 1, 10)
    else
      cCall_proc = trim(cCall_proc)
    endif
    aadd(aProc, cCall_proc)
  endif
  dbskip()
enddo
restsector(cSect)
nPcnt = 1
while nPcnt != 0
  nPcnt = mget_arr(aProc,,,,.t.,,nPcnt)
  if nPcnt = 0
    if !wMake_sure(12)
      nPcnt = 1
      dbcommitall()
    endif
  else
    cSeek = aProc[nPcnt] + '.PRG               '
    select dd
    seek cSeek
    if found()
      cDescr = dd->descriptn
    else
      cDescr = space(30)
    endif
    select ddspec
    seek substr(cSeek, 1,15)
    if found()
      cSpec = dd->spec
    else
      cSpec = ''
    endif
    cSect = draw_box(4,1,23,77)
    @8,3 to 22,75
    memoedit(cSpec,9,5,21,73,.f., .f.)
    nCurs = setcursor(1)
    @5,20 say 'Source file ' + memvar->aPrg[memvar->nCh]
    @6,20 say 'Procedure   ' + aProc[nPcnt]
    @7,10 say 'Description ' get cDescr
    read
    cSpec = memoedit(cSpec,9,5,21,73)
    setcursor(nCurs)
    if !empty(cDescr)
      select dd
      dbsetorder(1)
      if !dbseek(cSeek)
        dbsetorder(2)
        dbgobottom()
        nRec = dd->rec_code
        nRec++
        dbsetorder(1)
        dbappend()
        reclock('DD')
        dd->file := trim(cSeek)
        dd->rec_code := nRec
        dbunlock()
      endif
      reclock('DD')
      dd->descriptn := cDescr
      dbunlock()
    endif
    if !empty(cSpec)
      select ddspec
      if !dbseek(substr(cSeek, 1,15))
        dbappend()
        reclock('DDSPEC')
        ddspec->file := trim(cSeek)
        dbunlock()
      endif
      reclock('DDSPEC')
      ddspec->spec := cSpec
      dbunlock()
    endif
    restsector(cSect)
  endif
enddo
return

* eof(chk_procspec)

*f********************************************************************
procedure chk_print()
local cStitle := 'PRINTOUT OF ' + memvar->aPrg[memvar->nCh], nCnt, cLine, cSect, nStop
local eol := chr(13) + chr(10), cChk
cSect = draw_box(18,28,20,52)
@19,30 say 'Printing line'
begin sequence
  if openprn()
    break
  endif
  nCnt = 0
  while len(memvar->mFile) > 3
    nCnt++
    @19,46 say str(nCnt,4,0)
    nstop = at(eol, memvar->mFile)                // find eol
    if nstop = 0
      nstop = len(memvar->mFile)
    endif
    cline = substr(memvar->mFile,1,nStop-1)       // extract line to arr
    cChk = substr(ltrim(cLine),1,3)       // get 1st 3 non space chars
    if nstop != len(memvar->mFile)
      memvar->mFile = stuff(memvar->mFile,1,nStop+1,'')
    else
      memvar->mFile = ''
    endif
    
    cLine = str(nCnt,4,0) + ' ' + cLine
    if len(cLine) > 80
      cLine = substr(cLine,1,80)
    endif
    if memvar->pline > memvar->pr_lines - 1 .or. cChk = '*f*' .or.;
          cChk = '*F*'
      prntitle(cStitle)
    endif
    pr_line(cLine)
  enddo
  shutprn()
end sequence
restsector(cSect)
return

*eof(chk_print)
