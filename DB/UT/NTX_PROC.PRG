******************************************************************************
procedure setup_ntx(nSt_inx)
local nStart, oColumn, nCnt

#include 'event.ch'
#include 'mouse.ch'

nStart = if(valtype(nSt_inx) = 'N', nSt_inx, 1)

/* make new NTX browse object  -  memvar->oNtx declared in dbfmenu1 */
memvar->oNtx := TBrowseDB(memvar->aNtx_area[1], memvar->aNtx_area[2],;
    memvar->aNtx_area[3], memvar->aNtx_area[4])

/* default heading and column separators */
memvar->oNtx:headSep := "ÄÄ"
memvar->oNtx:colSep  := "  "
memvar->oNtx:footSep := "ÄÄ"

/* add custom 'skip_curr' (to handle append mode) */
memvar->oNtx:skipBlock := {|x| move_Ntx(x)}

/* add a column for display */
oColumn := TBColumnNew( 'INDEX', {|| memvar->aNtx[memvar->nNtx_inx]} )
oColumn:width := 8
memvar->oNtx:addColumn(oColumn)

/* add a column for display */
oColumn := TBColumnNew( 'KEY', {|| memvar->aNtx_descr[memvar->nNtx_inx]} )
oColumn:width = 25
memvar->oNtx:addColumn(oColumn)

/* set colour */
memvar->oNtx:colorspec := memvar->cNtx_col

for nCnt = 1 to nStart-1
  memvar->oNtx:down()
next

return

*******************************************************************************
*       skip_ntx()
*

func move_ntx(nMove)
local nCnt

nCnt := 0
if ( len(memvar->aNtx) != 0 )
  if ( nMove > 0)
    while ( nCnt < nMove )
      memvar->nNtx_inx++
      if ( memvar->nNtx_inx > len(memvar->aNtx))
        memvar->nNtx_inx--
        exit
      endif
      nCnt++
    enddo
    
  elseif ( nMove < 0 )
    while ( nCnt > nMove )
      memvar->nNtx_inx--
      if ( memvar->nNtx_inx < 1)
        memvar->nNtx_inx++
        exit
      endif
      nCnt--
    enddo
  endif
endif
dbsetorder(memvar->nNtx_inx)
return (nCnt)

*******************************************************************************
procedure ntx_bott_msg
restsector(memvar->cScr_bott)
mouse_box(NTX_INS ,'Ins - Open new index')
memvar->oMouse[MI_HOTSPOT, NTX_INS, HS_ACTIVE] := .t.

if len(memvar->aNtx) > 0
  mouse_box(NTX_DEL ,'Del - Close index')
  memvar->oMouse[MI_HOTSPOT, NTX_DEL, HS_ACTIVE] := .t.
  mouse_box(NTX_ORDER ,'Order indices')
  memvar->oMouse[MI_HOTSPOT, NTX_ORDER, HS_ACTIVE] := .t.
else
  memvar->oMouse[MI_HOTSPOT, NTX_DEL, HS_ACTIVE] := .f.
  memvar->oMouse[MI_HOTSPOT, NTX_ORDER, HS_ACTIVE] := .f.
endif

return

*f*****************************************************************************
procedure ntx_activate
local aFile[aDir("*.NTX")], nCnt, nAt, cTemp, cAlias
local aIndex := {}, cKey, cSect, cIndex

if memvar->cDbf = 'DD.DBF'
  select dd
  memvar->aNtx := {}
  memvar->aNtx_descr := {}
  aadd(memvar->aNtx, 'DD_FILE')
  aadd(memvar->aNtx_descr, 'file + name')
  aadd(memvar->aNtx, 'DD_RECS')
  aadd(memvar->aNtx_descr, 'str(rec_code,5,0)')
  aadd(memvar->aNtx, 'DD_NAME')
  aadd(memvar->aNtx_descr, 'name + file')
  
else
  
  cAlias = alias()
  
  select dd
  dbsetorder(3)
  dbseek(memvar->cDbf)
  while dd->name = memvar->cDbf .and. !eof()
    cKey = if(dd->key != ' ', dd->key, 'Z')
    aadd(aIndex, cKey + dd->file)
    dbskip()
  enddo
  
  asort(aIndex)
  
  dbselectarea(cAlias)
  dbclearindex()
  memvar->aNtx := {}
  memvar->aNtx_descr := {}
  for nCnt = 1 to len(aIndex)
    aIndex[nCnt] = stuff(aIndex[nCnt], 1, 1, '')
    if !file(aIndex[nCnt])
      cSect = disp_msg(20,,aIndex[nCnt] + ' DOES NOT EXIST')
      inkey(0)
      restsector(cSect)
      return
    endif
    nAt = at('.', aIndex[nCnt])
    cIndex = substr(aIndex[nCnt], 1, nAt - 1)
    dbsetindex(cIndex)
    aadd(memvar->aNtx, cIndex)
    aadd(memvar->aNtx_descr, indexkey(len(memvar->aNtx)))
    if neterr()
      cSect = disp_msg(20,,'NETWORK ERROR ON ' + aIndex[nCnt] +;
          ' - PLEASE TRY LATER')
      inkey(0)
      restsector(cSect)
      return
    endif
  next
endif
dbsetorder(1)
dbgotop()
return

*******************************************************************************
procedure ntx_reindex
local nCnt, cName, cKey, cSect
cSect = disp_msg(12, memvar->BLACK_RED, 'Reindexing files')
dbselectarea(memvar->cAlias)
dbclosearea()
if net_use(memvar->cDbf, .t.)
  for nCnt = 1 to len(memvar->aNtx)
    cName = memvar->aNtx[nCnt]
    cKey = memvar->aNtx_descr[nCnt]
    dbcreateindex(cName, cKey, {|| &cKey})
  next
  dbclosearea()
  net_use(memvar->cDbf, .f.)
  for nCnt = 1 to len(memvar->aNtx)
    dbsetindex(memvar->aNtx[nCnt])
  next
endif
restsector(cSect)
return

*f*****************************************************************************
procedure ntx_close( nNtx)
local nCnt
dbselectarea(memvar->cAlias)
dbclearind()
aremove(memvar->aNtx, nNtx)
aremove(memvar->aNtx_descr, nNtx)
for nCnt = 1 to len(memvar->aNtx)
  dbsetindex(memvar->aNtx[nCnt])
next
if memvar->nNtx_inx > len(memvar->aNtx)
  memvar->nNtx_inx = len(memvar->aNtx)
endif
memvar->oNtx:gotop()
memvar->oNtx:refreshall()
return

*******************************************************************************
procedure ntx_add()
local aFile[aDir("*.NTX")], nCh, cLook, nLen, nCnt1, nCnt2, nAt, cNtx, nOpt1
local aDict := {'Update data dictionary',;
    'Leave data dictionary'}
local cTemp, nRec
aDir("*.NTX", aFile)
asort(aFile)
* remove duplicate references
for nCnt1 = 1 to len(aFile)
  nAt = at('.', aFile[nCnt1])
  cNtx = substr(aFile[nCnt1], 1, nAt-1)
  for nCnt2 = 1 to len(memvar->aNtx)
    if cNtx = memvar->aNtx[nCnt2]
      aremove(aFile, nCnt1)
      nCnt1--
      exit
    endif
  next
next
aadd(aFile, 'Return')
nOpt1 = mget_arr(aFile,6,10,memvar->WHITE_RED,.t.)
if nOpt1 = 0 .or. nOpt1 = len(aFile)
  return
endif
cTemp = aFile[nOpt1]
nAt = at('.', cTemp)
cTemp = substr(cTemp, 1, nAt-1)
dbsetindex(cTemp)
aadd(memvar->aNtx, cTemp)
aadd(memvar->aNtx_descr, indexkey(len(memvar->aNtx)))
select dd
if !dbseek(aFile[nOpt1]) .or. dd->name != memvar->cDbf
  nCh = mget_arr(aDict,10,10,memvar->WHITE_RED)
  if nCh = 1
    if !found()
      dbsetorder(2)
      dbgobottom()                            // get next rec_code
      nRec = dd->rec_code
      nRec++
      dbsetorder(1)
      dbappend()
      reclock('Data dictionary')
      dd->file := aFile[nOpt1]
      dd->rec_code := nRec
    endif
    dd->name := memvar->cDbf
    dd->help := aTail(memvar->aNtx_descr)
    dbunlock()
    dbcommit()
  endif
endif
dbselectarea(memvar->cAlias)

*******************************************************************************
procedure ntx_create()
local aFile[aDir("*.NTX")], nCh, cLook, nLen, nCnt1, nCnt2, cSect
local aDict := {'Update data dictionary', 'Leave data dictionary'}
local nOpt1, cKey, nAt, cName, nCurs, getlist := {}, nCnt, nRec

aDir("*.NTX", aFile)
asort(aFile)
aadd(aFile, ' ')
aIns(aFile, 1)
Afile[1] = 'Create a new index'
aadd(aFile, 'Return')
nOpt1 = mget_arr(aFile,6,10,memvar->WHITE_RED,.t.)
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
    cKey = dd->help
    cKey += space(160 - len(cKey))
  endif
else
  cName = space(8)
endif
cSect = draw_box(15,10,20,70)
nCurs = setcursor(1)
@16,25 say 'Create index'
@18,15 say 'Index name' get cName picture "!!!!!!!!" when empty(cName)
@19,15 say 'Index key ' get cKey picture "@s40" when !empty(cName)
read
setcursor(nCurs)
if !empty(cKey) .and. MMake_sure(memvar->oMouse,10,,'Create the index ?')
  dbselectarea(memvar->cAlias)
  dbclosearea()
  if net_use(memvar->cDbf, .t.)
    dbcreateindex(cName, cKey, {||&cKey})
    aadd(memvar->aNtx, trim(cName))
    aadd(memvar->aNtx_descr, cKey)
    dbclosearea()
    net_use(memvar->cDbf, .f.)
    for nCnt = 1 to len(memvar->aNtx)
      dbsetindex(memvar->aNtx[nCnt])
    next
    select dd
    if !dbseek(trim(cName) + '.NTX') .or. dd->name != memvar->cDbf
      nCh = mget_arr(aDict,10,10,memvar->WHITE_RED)
      if nCh = 1
        if !found()
          dbsetorder(2)
          dbgobottom()                            // get next rec_code
          nRec = dd->rec_code
          nRec++
          dbsetorder(1)
          dbappend()
          reclock('Data dictionary')
          dd->file := trim(cName) + '.NTX'
          dd->rec_code := nRec
        endif
        dd->name := memvar->cDbf
        dd->help := cKey
        dbunlock()
        dbcommit()
      endif
    endif
  endif
endif
restsector(cSect)

*******************************************************************************
procedure ntx_order
local aOld_order, aOld_descr, aNew_order, aNew_descr
local nCnt, nCh, cName, nRec, cScreen
aOld_order := {}
aOld_descr := {}
aNew_order := {}
aNew_descr := {}
for nCnt = 1 to len(memvar->aNtx)
  aadd(aOld_order, memvar->aNtx[nCnt] + space(10 - len(memvar->aNtx[nCnt]));
      + substr(memvar->aNtx_descr[nCnt],1,20))
  aadd(aOld_descr, memvar->aNtx_descr[nCnt])
next

save screen to cScreen
jw_screen('DATABASE UTILITY PROGRAM')

while .t.
  nCh = mget_arr(aOld_order, 7,40,,.t.)
  if nCh = 0 .and. make_sure(17,,;
        'Have you finished selecting index orders (Y/N) ?')
    exit
  endif
  aadd(aNew_order, substr(aOld_order[nCh],1,8))
  aadd(aNew_descr, aOld_descr[nCh])
  aremove(aOld_order, nCh)
  aremove(aOld_descr, nCh)
  if len(aOld_order) = 0
    exit
  endif
  draw_box(5,6,7+len(aNew_order), 25)
  @6,10 say 'Index order'
  for nCnt = 1 to len(aNew_order)
    @6+nCnt, 10 say aNew_order[nCnt]
  next
enddo

select dd
dbsetorder(3)
while dbseek(memvar->cDbf)
  reclock()
  dbdelete()
  dbunlock()
enddo

dbselectarea('DD')
dbsetorder(2)
for nCnt = 1 to len(aNew_order)
  cName = trim(aNew_order[nCnt]) + '.NTX'
  dbgobottom()                            // get next rec_code
  nRec = dd->rec_code
  nRec++
  dbappend()
  reclock('Data dictionary')
  dd->file := cName
  dd->name := memvar->cDbf
  dd->rec_code := nRec
  dd->help := aNew_descr[nCnt]
  dd->key := str(nCnt,1,0)
  dbunlock()
next
dbcommit()
dbselectarea(memvar->cAlias)
ntx_activate()
return
