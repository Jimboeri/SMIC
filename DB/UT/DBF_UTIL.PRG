*******************************************************************************
* DBF_UTIL - Datebase utilities

local aCh := {'Copy',;
    'Append',;
    'Replace',;
    'Delete',;
    'Recall',;
    'Pack',;
    'Zap',;
    'Return'}
local nCh

#include 'set.ch'

nCh = get_arr(aCh, 10,40,memvar->WHITE_RED, .t.,,,,,60)

if nCh = 0 .or. nCh = len(aCh)
  return
endif

do case
  case nCh = 1
    dbu_Copy()
  case nCh = 2
    dbu_Append()
  case nCh = 3
    dbu_Replace()
  case nCh = 4
    dbu_Delete()
  case nCh = 5
    dbu_Recall()
  case nCh = 6
    dbu_pack()
  case nCh = 7
    dbu_Zap()
endcase

return

*******************************************************************************
procedure dbu_copy
return

*******************************************************************************
procedure dbu_append
return

*******************************************************************************
procedure dbu_replace
return

*******************************************************************************
procedure dbu_delete
local nCnt
local nDel
local cExp
local getlist := {}
local nLen
local nRec
cExp = space(200)

wopen(10,10,17,70)
wbox()

@2,2 say 'Enter expression ' get cExp picture '@s25'
read
cExp = trim(cExp)
if type(cExp) != 'L'
  wait_msg(12,'Invalid expresion')
  return
endif
if wMake_sure(17,,'Proceed with delete ?')
  nLen = lastrec()
  nRec = recno()
  dbgotop()
  nCnt = 1
  nDel = 0
  while !eof()
    @4,15 say 'Processing record ' + ltrim(str(nCnt,8)) + ' of ';
        + ltrim(str(nLen,8))
    if &(cExp) .or. empty(cExp)
      @5,15 say 'Records deleted = ' + ltrim(str(nDel,8))
      reclock()
      dbdelete()
      dbunlock()
      nDel++
    endif
    nCnt++
    dbskip()
  enddo
endif
return

*******************************************************************************
procedure dbu_recall
local aOpt, nOpt, lSet_deleted, cSect, cExp, cS, getlist, nLen, nRec, nCnt, nDel
aOpt = {'Recall all records', 'Recall selected records', 'Return'}
nOpt = mget_arr(aOpt, 10, 30, memvar->WHITE_RED, .t.)
if nOpt = 0 .or. nOpt = len(aOpt)
  return
endif
lSet_deleted = set(_SET_DELETED, .f.)
cSect = draw_box(10,10,17,70)
if nOpt = 2
  cExp = space(200)
  @12,12 say 'Enter expression ' get cExp picture '@s25'
  read
  cExp = trim(cExp)
  if type(cExp) != 'L'
    cS = disp_msg(12,,'Invalid expresion')
    inkey(0)
    restsector(cS)
    return
  endif
endif
if wMake_sure(17,,'Proceed with recall ?')
  nLen = lastrec()
  nRec = recno()
  dbgotop()
  nCnt = 1
  nDel = 0
  while !eof()
    @14,25 say 'Processing record ' + ltrim(str(nCnt,8)) + ' of ';
        + ltrim(str(nLen,8))
    @15,25 say 'Records recalled = ' + ltrim(str(nDel,8))
    if deleted()
      if nOpt = 1 .or. &(cExp)
        reclock()
        dbrecall()
        dbunlock()
        nDel++
      endif
    endif
    nCnt++
    dbskip()
  enddo
endif
set(_SET_DELETED, lSet_deleted)
restsector(cSect)
return


*******************************************************************************
procedure dbu_pack

local aStru, lMemo, nCnt, aDir, nSize

if !wMake_sure(12)
  return
endif
wopen(12,20,14,60)
wbox()
@0,0 say center('Packing and indexing ' + memvar->cAlias)

dbselectarea(memvar->cAlias)
aStru = dbstruct()
lMemo = .f.
for nCnt = 1 to len(aStru)              // check for memo fields
  if aStru[nCnt, 2] = 'M'
    lMemo = .t.
    exit
  endif
next
release aStru
dbclosearea()

aDir = directory(memvar->cAlias + '.db?')
nSize = 0
for nCnt = 1 to len(aDir)
  nSize += aDir[nCnt, 2]
next
nSize += nSize / 10             // add 10% for luck

if net_use(memvar->cAlias, .t.)
  if lMemo .and. nSize < diskspace()
    copy to ddbbffff
    zap
    append from ddbbffff
  endif
  for nCnt = 1 to len(memvar->aNtx)
    dbsetindex(memvar->aNtx[nCnt])
  next
  pack
  dbclosearea()
else
  wait_msg(12,'Cannot obtain exclusive use of the database',;
  'or there is not enough disk space',,20)
endif

net_use(memvar->cAlias, .f.)
for nCnt = 1 to len(memvar->aNtx)
  dbsetindex(memvar->aNtx[nCnt])
next

if file('DDBBFFFF.DBF')
  ferase('DDBBFFFF.DBF')
endif

if file('DDBBFFFF.DBT')
  ferase('DDBBFFFF.DBT')
endif

wclose()
return

*******************************************************************************
procedure dbu_zap
local nCnt
if wMake_sure(12,,'Are you sure you want to ZAP this database ?')
  dbselectarea(memvar->cAlias)
  dbclosearea()
  if !empty(et_use_dbf(memvar->cAlias, .t., .f.))
    zap
    dbclosearea()
  endif
  et_use_dbf(memvar->cAlias, .f., .f.)
  for nCnt = 1 to len(memvar->aNtx)
    dbsetindex(memvar->aNtx[nCnt])
  next
endif
return

