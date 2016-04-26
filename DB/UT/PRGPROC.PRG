*******************************************************************************
*
* prgproc
*

local aCh := {'Define directories', 'Recreate list', 'Return'}
local nCh := 1

#include "inkey.ch"

while nCh != len(aCh) .and. nCh != 0
  nCh = mGet_arr(aCh,,,,.t.)
  do case
    case nCh = 1
      def_dir()
    case nCh = 2
      common_load()
  endcase
enddo
return

*******************************************************************************
procedure def_dir
local bIns, bDel, cProc
memvar lAdd, lDel
select dd
dbsetorder(1)
cProc = 'x'
while !empty(cProc)
  lAdd = .f.
  lDel = .f.
  if !dbseek('PROCEDURES')
    lAdd = .t.
  else
    bIns = setkey(K_INS, {|| proc_plus()})
    bDel = setkey(K_DEL, {|| proc_minus()})
    cProc = et_seek('dd', {11},,, 'PROCEDURES')
    setkey(K_INS, bIns)
    setkey(K_DEL, bDel)
  endif
  if lAdd
    proc_add()
    cProc = dd->help
  else
    if lDel
      proc_del()
      cProc = 'x'
    endif
  endif
enddo
return

*******************************************************************************
procedure proc_add
local cDirectory, cSect, nRec
memvar getlist
if wMake_sure(12,,'Add new procedure directory ?')
  cDirectory = space(50)
  cSect = draw_box(10,5,14,75)
  @12,7 say 'Directory name' get cDirectory picture '@S30'
  read
  restsector(cSect)
  if !empty(cDirectory)
    dbsetorder(2)
    dbgobottom()
    nRec = dd->rec_code
    dbappend()
    reclock()
    dd->rec_code := nRec+1
    dd->file := 'PROCEDURES'
    dd->help := cDirectory
    dbunlock()
    dbsetorder(1)
  endif
endif
return

*******************************************************************************
procedure proc_del
if wMake_sure(,,'Delete procedure directory ?')
  reclock()
  dbdelete()
  dbunlock()
endif
return

*******************************************************************************
procedure proc_plus
memvar->lAdd = .t.
memvar->lMore = .f.
return

*******************************************************************************
procedure proc_minus
memvar->lDel = .t.
memvar->lMore = .f.
return

*******************************************************************************
procedure common_load()
local aDir, nCnt, cDir, aPrg_file, cProc, cSect, cFile, nAt, cCall_proc
local lProc_def

aPrg_file := {}
aadd(aPrg_file, {'PRG_LINE  ', 'C', 255,0})
dbcreate('PRG_FILE', aPrg_file)

aPrg_file := {}
aadd(aPrg_file, {'PROC_NAME ', 'C', 10,0})
dbcreate('COM_PROC', aPrg_file)

select 198
if !net_use('prg_file', .t.)
  return
endif

select 197
if !net_use('com_proc', .t.)
  return
endif

cSect = draw_box(8,20,12,60)
@10,22 say 'Processing'

select dd
dbsetorder(1)
dbseek('PROCEDURES')
while dd->file = 'PROCEDURES' .and. !eof()
  cDir = trim(dd->help) + '\*.prg'
  aDir = directory(cDir)
  for nCnt = 1 to len(aDir)
    cFile = trim(dd->help) + '\' + aDir[nCnt, 1]
    @10,33 say space(27)
    @10,33 say cFile
    if !file(cFile)
      loop
    endif
    select prg_file
    zap
    append from (cFile) sdf
    if !prg_load()
      return
    endif
    nAt = at('.', aDir[nCnt, 1])
    cCall_proc = stuff(aDir[nCnt, 1], nAt, len(aDir[nCnt, 1])-nAt+1, '')
    select com_proc
    dbappend()
    com_proc->proc_name := cCall_proc
    select prg_file
    dbgotop()
    while !eof()
      
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
        select com_proc
        dbappend()
        com_proc->proc_name := cCall_proc
      endif
      select prg_file
      dbskip()
    enddo
  next
  select dd
  dbskip()
enddo
restsector(cSect)
select com_proc
index on com_proc->proc_name to com_temp
dbgotop()
cProc = com_proc->proc_name
dbskip()
while !eof()
  if com_proc->proc_name = cProc
    dbdelete()
  endif
  cProc = com_proc->proc_name
  dbskip()
enddo
pack
dbclosearea()
if file('COM_TEMP.NTX')
  ferase('COM_TEMP.NTX')
endif

select prg_file
dbclosearea()
if file('PRG_FILE.DBF')
  ferase('PRG_FILE.DBF')
endif

return
