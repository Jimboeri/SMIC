*******************************************************************************
*
* DBFNTX - Open create indices
*

local aOPt := {'Open all associated indices',;
    'Reindex open files',;
    'Open any index',;
    'Create index',;
    'Close index',;
    'Select controlling index',;
    'Return'}
local nOPt, nOpt1

local aFile[aDir("*.NTX")], nCh, cLook, nLen
local aDict := {'Update data dictionary', 'Leave data dictionary'}

#include "dbstruct.ch"

aDir("*.NTX", aFile)
asort(aFile)

nOpt = mget_arr(aOpt,10,10,white_red,.t.)

if nOpt = 0 .or. nOpt = len(aOpt)
  return
endif

if nOpt = 1
  select dd
  dbsetorder(1)
  for nCnt = 1 to len(aFile)
    if !dbseek(aFile[ncnt]) .or. dd->name != cDbf
      adel(aFile, nCnt)
      asize(aFile, len(aFile)-1)
      nCnt--
    endif
  next
endif

select &cAlias
if nOpt = 1
  dbclearindex()
  aNtx := {}
  aNtx_descr := {}
  for nCnt = 1 to len(aFile)
    nAt = at('.', aFile[nCnt])
    cTemp = substr(aFile[nCnt],1,nAt-1)
    dbsetindex(cTemp)
    aadd(aNtx, cTemp)
    aadd(aNtx_descr, indexkey(len(aNtx)))
  next
elseif nOpt = 2 .and. len(aNtx) > 0
  select &cAlias
  dbclosearea()
  if net_use(cDbf, .t.)
    for nCnt = 1 to len(aNtx)
      cName = aNtx[nCnt]
      cKey = aNtx_descr[nCnt]
      dbcreateindex(cName, cKey, {|| &cKey})
    next
    dbclosearea()
    net_use(cDbf, .f.)
    for nCnt = 1 to len(aNtx)
      dbsetindex(aNtx[nCnt])
    next
  endif
elseif nOpt = 3
  aadd(aFile, 'Return')
  nOpt1 = mget_arr(aFile,6,10,white_red,.t.)
  if nOpt1 = 0 .or. nOpt1 = len(aFile)
    return
  endif
  nAt = at('.', aFile[nOpt1])
  cTemp = substr(aFile[nOpt1],1,nAt-1)
  if ascan(aNtx, cTemp) = 0
    dbsetindex(cTemp)
    aadd(aNtx, cTemp)
    aadd(aNtx_descr, indexkey(len(aNtx)))
    select dd
    if !dbseek(aFile[nOpt1]) .or. dd->name != cDbf
      nCh = mget_arr(aDict,10,10,white_red)
      if nCh = 1
        if !found()
          dbsetorder(2)
          dbgobottom()                            // get next rec_code
          nRec = rec_code
          nRec++
          dbsetorder(1)
          dbappend()
          reclock('Data dictionary')
          dd->file := aFile[nOpt1]
          dd->rec_code := nRec
        endif
        dd->name := cDbf
        dd->help := aTail(aNtx_descr)
        dbunlock()
        dbcommit()
      endif
    endif
  endif
  select &cAlias
elseif nOpt = 4
  aadd(aFile, ' ')
  aIns(aFile, 1)
  Afile[1] = 'Create a new index'
  aadd(aFile, 'Return')
  nOpt1 = mget_arr(aFile,6,10,white_red,.t.)
  if nOpt1 = 0 .or. nOpt1 = len(aFile)
    return
  endif
  cKey = space(160)
  if nOpt1 != 1
    nAt = at('.', aFile[nOpt1])
    cName = substr(aFile[nOpt1],1,nAt-1)
    select dd
    dbsetorder(1)
    if dbseek(aFile[nOpt1])
      cKey = help
      cKey += space(160 - len(cKey))
    endif
  else
    cName = space(8)
  endif
  cSect = draw_box(15,10,20,70)
  @16,25 say 'Create index'
  @18,15 say 'Index name' get cName picture "!!!!!!!!" when empty(cName)
  @19,15 say 'Index key ' get cKey picture "@s40" when !empty(cName)
  read
  if !empty(cKey) .and. wMake_sure(10,,'Create the index ?')
    select &cAlias
    dbclosearea()
    if net_use(cDbf, .t.)
      dbcreateindex(cName, cKey, {||&cKey})
      aadd(aNtx, trim(cName))
      aadd(aNtx_descr, cKey)
      dbclosearea()
      net_use(cDbf, .f.)
      for nCnt = 1 to len(aNtx)
        dbsetindex(aNtx[nCnt])
      next
      select dd
      if !dbseek(trim(cName) + '.NTX') .or. dd->name != cDbf
        nCh = mget_arr(aDict,10,10,white_red)
        if nCh = 1
          if !found()
            dbsetorder(2)
            dbgobottom()                            // get next rec_code
            nRec = rec_code
            nRec++
            dbsetorder(1)
            dbappend()
            reclock('Data dictionary')
            dd->file := trim(cName) + '.NTX'
            dd->rec_code := nRec
          endif
          dd->name := cDbf
          dd->help := cKey
          dbunlock()
          dbcommit()
        endif
      endif
      
    endif
  endif
  restsector(cSect)
elseif nOpt = 5 .and. len(aNtx) > 0
  nOpt1 = mget_arr(aNtx, 18,39,white_red,.t.,'Select index to close')
  if nOpt1 != 0
    aDel(aNtx, nOpt1)
    aSize(aNtx, len(aNtx)-1)
    aDel(aNtx_descr, nOpt1)
    aSize(aNtx_descr, len(aNtx_descr)-1)
    dbclosearea()
    net_use(cDbf, .f.)
    for nCnt = 1 to len(aNtx)
      dbsetindex(aNtx[nCnt])
    next
  endif
elseif nOpt = 6 .and. len(aNtx) > 0
  nOpt1 = mget_arr(aNtx, 18,39,white_red,.t.,'Select controlling index')
  if nOpt1 != 0
    dbsetorder(nOpt1)
  endif
endif
return
