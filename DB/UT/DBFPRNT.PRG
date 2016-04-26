*******************************************************************************
*
* STRUPRNT - PRINTS DATABASE STRUCTURES

local aCh := {}                 // list of options
local aExtr
local nCnt
local nAccept
local nExtr
local cLine
local aTemp
memvar aFiles
memvar nChoice

#include 'inkey.ch'

if !empty(memvar->cDbf)
  aadd(aCh, 'Print structure of ' + memvar->cDbf)
else
  aadd(aCh, 'Print one database structure')
endif
aadd(aCh, 'Print all database structures')
aadd(aCh, 'Print list of databases')
aadd(aCh, 'Print list of all index keys')
aadd(aCh, 'Return')

aExtr := {'Print file', 'Create extract file'}

private afiles[adir('*.DBF')], nChoice

adir('*.dbf', afiles)
asort(aFiles)
nCnt = ascan(afiles, 'DD.DBF')
if nCnt != 0
  adel(afiles, nCnt)
  asize(afiles, len(afiles)-1)
endif
nCnt = ascan(afiles, 'DDSPEC.DBF')
if nCnt != 0
  adel(afiles, nCnt)
  asize(afiles, len(afiles)-1)
endif
nCnt = ascan(afiles, 'TO_DO.DBF')
if nCnt != 0
  adel(afiles, nCnt)
  asize(afiles, len(afiles)-1)
endif

select dd

begin sequence
nChoice = get_arr(aCh)
  if nChoice = 0 .or. nChoice = len(aCh)
    break
  endif
  if openprn()
    break
  endif
  memvar->LPR_ESC = .t.
  do case
    case nChoice = 1
      if empty(memvar->cDbf)
        nAccept = get_arr(afiles, , , , .t.)
        if nAccept != 0
          prnt_file(afiles[nAccept])
        endif
      else
        nExtr = Get_arr(aExtr)
        if nExtr = 1
          prnt_file(memvar->cDbf)
        else
          extr_file(memvar->cDbf)
        endif
      endif
    case nChoice = 2
      for nCnt = 1 to len(afiles)
        prnt_file(afiles[nCnt])
      next
    case nChoice = 3
      select dd
      for nCnt = 1 to len(afiles)
        if memvar->pLine > memvar->PR_LINES - 3
          prntitle('LIST OF DATA BASE FILES')
        endif
        cLine = '  ' + aFiles[nCnt]
        seek aFiles[nCnt] + space(15)
        if found()
          cLine += '      ' + dd->descriptn
        endif
        pr_line(cLine)
      next
    case nChoice = 4 .and. !empty(memvar->cDbf)
      aTemp = directory('*.NTX')
      for nCnt = 1 to len(aTemp)
        if memvar->pLine > memvar->PR_LINES - 4
          prntitle('LIST OF INDEXES WITH KEYS')
          pr_line('INDEX          KEY')
          pr_line('------------   --------------------------------')
        endif
        dbclearindex()
        dbsetindex(aTemp[nCnt, 1])
        cLine = aTemp[nCnt, 1]
        cLine += space(15 - len(cLine)) + indexkey()
        pr_line(cLine)
      next
      * reset indices to original values
      select &memvar->cAlias
      dbclearindex()
      for nCnt = 1 to len(memvar->aNtx)
        dbsetindex(memvar->aNtx[nCnt])
      next
  endcase
  shutprn()
end sequence
return

*******************************************************************************
procedure prnt_file ( f_name)
local aStru, cShort, nCount, cDescr, cLine, cSeek, aIndex := {}

wopen(11,20,13,60)
setcolor(memvar->BLUE_CYAN)
wbox()
@0,0 say center('Printing structure of ' + f_name)

cShort = substr(f_name,1,at('.', f_name)-1)
memvar->pLine = 90
if select(cShort) = 0
  use &cShort new
  aStru = dbstruct()
  dbclosearea()
else
  dbselectarea(cShort)
  aStru = dbstruct()
endif
select dd
dbsetorder(1)
dbseek(f_name + space(30-len(f_name)))
cDescr = trim(dd->descriptn)
for nCount = 1 to len(aStru)
  if memvar->pLine > memvar->PR_LINES - 3
    pr_line(' ')
    prntitle('STRUCTURE OF ' + f_name)
    pr_line(space(40-(len(cDescr)/2)) + cDescr)
    pr_line(' ')
    pr_line('Name         Type    Len  Dec    Description')
    pr_line(' ')
  endif
  cLine = aStru[nCount, 1] + space(15-len(aStru[nCount, 1])) +;
   aStru[nCount, 2] + '    ' + str(aStru[nCount, 3],4,0)
  if aStru[nCount, 2] = 'N'
    cLine +='  ' + str(aStru[nCount, 4],2,0) + '     '
  else
    cLine += space(9)
  endif
  cSeek = f_name + space(15-len(f_name)) + aStru[nCount, 1]
  if dbseek(cSeek)
    cLine += dd->descriptn
  endif
  pr_line(cLine)
next
pr_line(' ')
dbsetorder(3)
if dbseek(f_name)
  if memvar->pLine > memvar->PR_LINES - 7
    prntitle('STRUCTURE OF ' + f_name)
    pr_line(space(40-(len(cDescr)/2)) + cDescr)
    pr_line(' ')
  endif
  pr_line('        ASSOCIATED INDICES')
endif
while f_name = trim(dd->name) .and. !eof()
  aadd(aIndex, dd->key + dd->file + dd->help)
  dbskip()
enddo
for nCount = 1 to len(aIndex)
  pr_line(posdel(aIndex[nCount],1,1))
next
dbsetorder(1)
wclose()
return

*******************************************************************************
procedure extr_file ( f_name)
local aStru, cShort, nCount, cDescr, cLine, cSeek

wopen(11,20,13,60)
setcolor(memvar->BLUE_CYAN)
wbox()
@0,0 say center('Printing structure of ' + f_name)

cShort = substr(f_name,1,at('.', f_name)-1)
memvar->pLine = 90
if select(cShort) = 0
  use &cShort new
  aStru = dbstruct()
  dbclosearea()
else
  dbselectarea(cShort)
  aStru = dbstruct()
endif
select dd
dbsetorder(1)
dbseek(f_name + space(30-len(f_name)))
cDescr = trim(dd->descriptn)
pr_line('STRUCTURE OF ' + f_name)
pr_line(cDescr)
pr_line('Name' + chr(K_TAB) + 'Type' + chr(K_TAB) + 'Len' + chr(K_TAB);
 + 'Dec' + chr(K_TAB) + 'Description')
pr_line(' ')
for nCount = 1 to len(aStru)
  cLine = aStru[nCount, 1] + chr(K_TAB) + aStru[nCount, 2] + chr(K_TAB) +;
      ltrim(str(aStru[nCount, 3],4,0)) + chr(K_TAB)
  if aStru[nCount, 2] = 'N'
    cLine += ltrim(str(aStru[nCount, 4],2,0))
  endif
  cLine += chr(K_TAB)
  cSeek = f_name + space(15-len(f_name)) + aStru[nCount, 1]
  if dbseek(cSeek)
    cLine += dd->descriptn
  endif
  pr_line(cLine)
next
pr_line(' ')
dbsetorder(3)
if dbseek(f_name)
  pr_line('ASSOCIATED INDICES')
endif
while f_name = trim(dd->name) .and. !eof()
  pr_line(dd->file + chr(K_TAB) + dd->help)
  dbskip()
enddo
dbsetorder(1)
wclose()
return
