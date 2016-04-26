*******************************************************************************
*
* A generic reindex program that will reindex files as defined in the
* data dictionary
*

local nCnt, nCntr, nAt, aDbf, aDir, nSize, nTemp, lFlag, nRow
memvar cName, cField

#include 'ctnnet.ch'

if select('dd') != 0
  select dd
  dbclosearea()
endif

if !net_use('dd', .t.)
  return
endif

dbclosearea()
aDir = directory('dd.db?')
nSize = 0
for nTemp = 1 to len(aDir)
  nsize += aDir[nTemp, 2]
next

if diskspace() > nSize
  wopen(11,25,13,55)
  wbox(1)
  @0,0 say center('Packing Data Dictionary')
  if file('ddstore.dbf')
    ferase('ddstore.dbf')
  endif
  if file('ddstore.dbt')
    ferase('ddstore.dbt')
  endif
  copy file 'dd.dbf' to 'ddstore.dbf'
  copy file 'dd.dbt' to 'ddstore.dbt'
  net_use('ddstore', .t.)
  copy structure to dd
  dbclosearea()
  net_use('dd', .t.)
  append from ddstore
  dbclosearea()
  wclose()
endif

if !net_use('dd', .t.)
  return
endif

wopen(10,20,16,60)
wbox(1)
dbgotop()
@0,0 say center("creating index DD_FILE")
index on dd->file + dd->name to dd_file

dbgotop()
@1,0 say center("creating index DD_NAME")
index on dd->name + dd->file to dd_name

dbgotop()
@2,0 say center("creating index DD_RECS")
index on str(dd->rec_code,5,0) to dd_recs

wclose()
dbcloseall()
if !net_use('dd', .f.,,'dd_file', 'dd_name', 'dd_recs')
  return
endif

aDbf = directory('*.dbf')

for nCnt = 1 to len(aDbf)
  if aDbf[nCnt,1] = 'DD' .or. aDbf[nCnt,1] = 'DDSPEC' .or. aDbf[nCnt,1] = 'DDSTORE'
    adel(aDbf, nCnt)
    asize(aDbf, len(aDbf)-1)
    if nCnt > 1
      nCnt--
    endif
  endif
  aDbf[nCnt, 3] := {}
  nAt = at('.', aDbf[nCnt, 1])
  aDbf[nCnt, 2] := substr(aDbf[nCnt, 1], 1, nAt-1 )
next

for nCnt = 1 to len(aDbf)
  select dd
  if dbseek(aDbf[nCnt, 1])
    dbsetorder(2)                       // dd_name
    dbseek(aDbf[nCnt, 1])
    while dd->name = aDbf[nCnt, 1] .and. !eof()
      aadd(aDbf[nCnt, 3], {dd->file, dd->help})
      dbskip()
    enddo
    dbsetorder(1)
  else
    adel(aDbf, nCnt)
    asize(aDbf, len(aDbf)-1)
    nCnt--
  endif
  if nCnt > len(aDbf)
    exit
  endif
next

dbcloseall()

for nCnt = 1 to len(aDbf)
  lFlag = .f.
  if nnetwork() .and. nnetistts()               // TTS on a Novell network
    if isbit(nnetextatt(aDbf[nCnt, 2]), 5)      // Check if flagged transactional
      lFlag = .t.
      nnetextatt(aDbf[nCnt, 2], 0)              // Remove transactional status
    endif
  endif
  
  if net_use(aDbf[nCnt, 2], .t.)
    wopen(10,20,18,60)
    wbox(1)
    @0,0 say center('Packing ' + aDbf[nCnt, 1])
    nRow := 1
    pack
    for nCntr = 1 to len(aDbf[nCnt, 3])
*      set_bar(aDbf[nCnt,1], aDbf[nCnt, 3, nCntr, 1])
      nAt = at('.', aDbf[nCnt, 3, nCntr, 1])
      cName = substr(aDbf[nCnt, 3, nCntr, 1],1,nAt-1)
      cField = aDbf[nCnt, 3, nCntr, 2]
      dbgotop()
      if nnetwork() .and. nnetistts()               // TTS on a Novell network
        if lFlag
          nnetextatt(cName + '.NTX', 0)             // Remove transactional status
        endif
      endif
*      dbCreateIndex( cName, cField, {|| move_bar(&cField)} )
      @nRow,0 say center('Creating index ' + trim(cName))
      nRow++
      index on &cField to &cName
      dbclearindex()
      if nnetwork() .and. nnetistts()               // TTS on a Novell network
        if lFlag
          nnetextatt(cName + '.NTX', EXA_TTS)       // Flag as transactional
        endif
      endif
    next
    dbcloseall()
    wclose()
  endif
  if nnetwork() .and. nnetistts()               // TTS on a Novell network
    if lFlag
      nnetextatt(aDbf[nCnt, 2], EXA_TTS)        // Flag as transactional
    endif
  endif
  
next
dbcloseall()

return
* eof

*******************************************************************************
procedure set_bar(cDbf_name, cIndex)
local nCount, cCol
draw_box(5,33,20,47)
draw_box(20,20,23,60)
@20,33 say 'Á'
@20,47 say 'Á'
cCol = setcolor(memvar->yell_blue)
@21,22 say 'Reindexing ' + cDbf_name
@22,22 say 'Index      '  + cIndex
setcolor(cCol)
for nCount = 6 to 19
  @nCount,35 say replicate('±',10)
next
return

*******************************************************************************
function move_bar ( xParam )
local nPos, nCounter
if recno() <= lastrec()
  nPos = int(recno() / lastrec() * 14)
  if nPos > 0
    if lastrec() < 30
      for nCounter = 1 to nPos
        @5+nCounter, 35 say space(10)
      next
    else
      @5+npos, 35 say space(10)
    endif
  endif
endif
return(xParam)

