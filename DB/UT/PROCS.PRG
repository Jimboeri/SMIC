*****
*       PROCS - contains common procedures
*

#include "inkey.ch"
#include "setcurs.ch"

#define MY_HSEP         "ÄÂÄ"
#define MY_CSEP         " ³ "
#define MY_FSEP         "ÄÁÄ"

*******************************************************************************
function et_use_dbf ( cName, lExclusive, lOpen_indices, lReadonly)
local lShared, lIndices, lRead, cDbf_Name, cSect, aIndex, cKey, nCnt
local lClose_dd := .f., nAt, cIndex, aStru, aBlock := {}, nWork_area

lShared  = if(valtype(lExclusive) = 'L'   , !lExclusive,   .t.)
lIndices = if(valtype(lOpen_indices) = 'L', lOpen_indices, .t.)
lRead    = if(valtype(lReadonly) = 'L'    , lReadonly,     .f.)

if select(cName) != 0
  dbselectarea(cName)
  dbclosearea()
endif

cDbf_Name = trim(upper(cName)) + '.DBF'
if !file(cDbf_Name)
  cSect = disp_msg(20,,cDbf_name + ' DOES NOT EXIST')
  inkey(0)
  restsector(cSect)
  return nil
endif

if !file('DD.DBF')
  cSect = disp_msg(20,,'DATA DICTIONARY DOES NOT EXIST')
  inkey(0)
  restsector(cSect)
  return nil
endif

dbusearea(.t., , cName, , lShared, lRead)

if neterr()
  cSect = disp_msg(20,,'NETWORK LOCK ON ' + upper(cName) +;
      ' - PLEASE TRY LATER')
  inkey(0)
  restsector(cSect)
  return nil
endif

if cDbf_name = 'DD.DBF'
  dbsetindex('DD_FILE')
  dbsetindex('DD_RECS')
  dbsetindex('DD_NAME')
  dbsetorder(1)
  dbgotop()
  return({'DD'})
endif

if select('DD') = 0
  lClose_dd := .t.
  dbusearea(.t., , 'DD', , .t., .t.)
  dbsetindex('DD_FILE')
  dbsetindex('DD_RECS')
  dbsetindex('DD_NAME')
else
  dbselectarea('DD')
endif
dbsetorder(3)

aIndex := {}

dbseek(cDbf_name)
while dd->name = cDbf_name .and. !eof()
  cKey = if(dd->key != ' ', dd->key, 'Z')
  aadd(aIndex, cKey + dd->file)
  dbskip()
enddo

asort(aIndex)

dbselectarea(cName)
for nCnt = 1 to len(aIndex)
  aIndex[nCnt] = stuff(aIndex[nCnt], 1, 1, '')
  if !file(aIndex[nCnt])
    cSect = disp_msg(20,,aIndex[nCnt] + ' DOES NOT EXIST')
    inkey(0)
    restsector(cSect)
    return nil
  endif
  nAt = at('.', aIndex[nCnt])
  cIndex = substr(aIndex[nCnt], 1, nAt - 1)
  dbsetindex(cIndex)
  if neterr()
    cSect = disp_msg(20,,'NETWORK ERROR ON ' + aIndex[nCnt] +;
        ' - PLEASE TRY LATER')
    inkey(0)
    restsector(cSect)
    return nil
  endif
next

dbsetorder(1)
dbgotop()

nWork_area = select(cName)

aStru = dbstruct()

dbselectarea('DD')
dbsetorder(1)
for nCnt = 1 to len(aStru)
  cKey = cDbf_name + space(15 - len(cDbf_name)) + aStru[nCnt, 1]
  if dbseek(cKey) .and. dd->key != ' '
    aadd(aBlock, et_wblock(aStru[nCnt, 1], nWork_area, asc(dd->key)))
  else
    aadd(aBlock, fieldwblock(aStru[nCnt, 1], nWork_area))
  endif
next

if lClose_dd
  dbclosearea()
endif

dbselectarea(cName)

return(aBlock)

*******************************************************************************
function et_wblock(cField, nAlias, nKey)
local bRet
bRet = { | In_val | et_wfield ( In_val, cField, nAlias, nKey) }
return(bRet)

*******************************************************************************
function et_wfield ( New_val , cField, nAlias, nKey)
local Ret_val, nOrig_area, cAlias, cName
nOrig_area = select()
dbselectar(nAlias)
cAlias = alias(nAlias)
cName = cAlias + '->' + cField
if !empty(new_val)
  &cName := jw_scram(New_val, nKey)
endif
ret_val = &cName
ret_val = jw_scram(ret_val, nKey)
dbselectarea(nOrig_area)
return(ret_val)

*******************************************************************************
function et_decode ( aBlock, cField, New_val)
if fieldpos(cField) = 0
  return nil
endif
if New_val != nil
  if valtype(new_val) = 'C'
    new_val += space(80)
  endif
  eval(aBlock[fieldpos(cField)], New_val)
endif
return( eval(aBlock[fieldpos(cField)]) )

****
*       This is a database seek utility used to select a record from a database
*
* Parameters    cDatabase - The name of the database
*               aDisp_fields - A numeric array consisting of the ordinal
*                              numbers of the fields in the database to be
*                              displayed.
*               lSearch - A boolean falue indicating whether a quick type
*                         search should be used. This works on the first record
*                         and must match the controlling index.
*               aEsc_keys - A numeric array of inkey code which will allow an
*                           escape from the procedure
*               cOrig_key - A character expression equal to the initial part
*                           of the index key. Used for selecting subrecords

function et_seek(cDatabase, aDisp_fields, lSearch, aEsc_keys, cOrig_key)

local nCnt, bAction, lMore, cRet_val, cRet_var, cOrig_val, cSect1
local nCurssave, aStru, lClose_dd, cData, aDisp_stru, nWidth, cColorsave
local nArea, cSectsave, oColumn, nKey, lSave_Visible, cSeek, cLook
local nRec

memvar oPick, lKey_search, cFilter, nTop, nBott, nLeft, nRight, cInd_key

private oPick, lKey_search, cFilter
private nTop, nLeft, nBott, nRight

lKey_search = if(valtype(lSearch) = 'L', lSearch, .f.)
cFilter = cOrig_key

nTop = 5
nBott = if(lKey_search, 20, 21)
nRight = 75

cRet_var = readvar()
cOrig_val = if(!empty(cRet_var), &cRet_var, '')

dbselectarea(cDatabase)
dbgotop()

if lKey_search
  if cFilter = NIL
    dbseek(cOrig_val, .t.)
  else
    dbseek(cFilter + cOrig_val, .t.)
  endif
endif

if bof() .or. (!empty(cOrig_key) .and. !dbseek(cOrig_key))
  cSect1 = disp_msg(14,memvar->white_red, 'Nothing found !')
  inkey(0)
  restsector(cSect1)
  if !empty(cRet_var)
    &cRet_var := space(len(&cRet_var))
  endif
  return('')
endif

/* analyse fields to be displayed */
aStru = dbstruct()
lClose_dd = .t.
if select('DD') = 0
  select 191
  if empty(et_use_dbf('dd'))
    return nil
  endif
else
  select dd
  lClose_dd = .f.
endif

for nCnt = 1 to len(aStru)
  cData = trim(upper(cDatabase)) + '.DBF'
  cData += space(15 - len(cData))
  if dbseek(cData + upper(aStru[nCnt, 1]) + space(15-len(aStru[nCnt, 1])));
        .and. !empty(dd->descriptn)
    aStru[nCnt,2] := trim(dd->descriptn)
  else
    aStru[nCnt,2] := trim(aStru[nCnt,1])
  endif
  aStru[nCnt, 3] = if(len(aStru[nCnt, 2]) > aStru[nCnt, 3],;
      len(aStru[nCnt, 2]), aStru[nCnt, 3])
next
select dd
if lClose_dd
  dbclosearea()
endif

dbselectarea(cDatabase)
nArea = select()
dbgotop()

if cFilter != nil
  dbseek(cFilter)
endif

if lKey_search
  if cFilter != nil
    dbseek(cFilter + cOrig_val, .t.)
  else
    dbseek(cOrig_val, .t.)
  endif
endif

cInd_key = indexkey()
aDisp_stru := {}

nWidth = 2
for nCnt = 1 to len(aDisp_fields)
  aadd(aDisp_stru, {aStru[aDisp_fields[nCnt], 1],;
      aStru[aDisp_fields[nCnt], 2], aStru[aDisp_fields[nCnt], 3]})
  nWidth += aStru[aDisp_fields[nCnt], 3] + 2
next
release aStru

nLeft = 75 - nWidth

/* make new browse object */
oPick := TBrowseDB(nTop, nLeft, nBott, nRight)
cColorSave := SetColor(memvar->black_white)
if lKey_search
  cSectSave = draw_box(nTop-1, nLeft-1, nBott+2, nRight+1)
  @nBott, nLeft say replicate('Ä', nRight - nLeft)
  @nBott, nLeft-1 say 'Ã'
  @nBott, nRight+1 say '´'
else
  cSectSave = draw_box(nTop-1, nLeft-1, nBott, nRight+1)
endif
@nTop+1, nLeft-1 say 'Ã'
@nTop+1, nRight+1 say '´'
nCursSave := SetCursor(0)

/* default heading and column separators */
oPick:headSep := MY_HSEP
oPick:colSep := MY_CSEP
oPick:footSep := MY_FSEP

/* add custom 'skipper' (to handle append mode) */
oPick:skipBlock := {|x| Skip_any(x)}

/* colors */
oPick:colorSpec := memvar->black_white
for nCnt = 1 to len(aDisp_stru)
  oColumn := TBColumnNew( aDisp_stru[nCnt, 2],;
      fieldwblock(aDisp_stru[nCnt, 1], nArea))
  oPick:addColumn(oColumn)
next

lMore := .t.
cSeek := ''
while (lMore)
  
  /* stabilize the display */
  nKey = 0
  while ( !oPick:stabilize() )
    nKey := InKey()
    if ( nKey != 0 )
      exit                    /* (abort if a key is waiting) */
    endif
  enddo
  
  if ( oPick:stable )
    /* display is stable */
    if ( oPick:hitTop .or. oPick:hitBottom )
      Tone(125, 0)
    end
    
    /* everything's done; just wait for a key */
    if nKey = 0
      nKey = inkey(0)
    endif
    
  endif
  
  /* process key */
  do case
    case ( nKey == K_F1 )
      help(procname(), procline(), cDatabase)
      
    case (bAction := SETKEY(nKey)) != NIL
      EVAL(bAction, Procname(), Procline(), readvar())
      
    case ( nKey == K_DOWN )
      cSeek = ''
      oPick:down()
      
    case ( nKey == K_UP )
      cSeek = ''
      oPick:up()
      
    case ( nKey == K_PGDN )
      cSeek = ''
      oPick:pageDown()
      
    case ( nKey == K_PGUP )
      cSeek = ''
      oPick:pageUp()
      
    case ( nKey == K_CTRL_PGUP ) .or. ( nKey == K_HOME )
      cSeek = ''
      oPick:goTop()
      
    case ( nKey == K_CTRL_PGDN ) .or. ( nKey == K_END )
      cSeek = ''
      oPick:goBottom()
      
    case ( nKey == K_ESC )
      cRet_val = cOrig_val
      lMore := .f.
      
    case ( nKey == K_RETURN )
      cRet_val = fieldget(aDisp_fields[1])
      lMore := .f.
      
    otherwise
      if valtype(aEsc_keys) = 'A'
        for nCnt = 1 to len(aEsc_keys)
          if nKey = aEsc_keys[nCnt]
            cRet_val = fieldget(aDisp_fields[1])
            lMore := .f.
            exit
          endif
        next
      endif
      
      if lKey_search
        if (nKey == K_BS)
          cSeek = bkspace(cSeek)
        else
          cSeek += upper(chr(nKey))
        endif
        if len(cSeek) != 0
          cLook = if(cFilter = nil, cSeek, cFilter+cSeek)
          nRec = recno()
          dbseek(cLook)
          if !found()
            cSeek = bkspace(cSeek)
            dbgoto(nRec)
          else
            cRet_val = fieldget(aDisp_fields[1])
            dbskip()
            if cLook != substr(&cInd_key,1,len(cLook)) .or. eof()
              lMore = .f.
            endif
            if lMore
              dbseek(cLook)
            endif
          endif
          oPick:refreshall()
        endif
      else
        do case
          case ( nKey == K_LEFT )
            oPick:left()
          case ( nKey == K_RIGHT )
            oPick:right()
          case ( nKey == K_CTRL_LEFT )
            oPick:panleft()
          case ( nKey == K_CTRL_RIGHT )
            oPick:panright()
        endcase
      endif                             // search available
  endcase
  if lKey_search
    setcolor(memvar->white_black)
    @nBott+1, nLeft+3 say cSeek + space(len(&cInd_key) - len(cSeek))
    setcolor(memvar->black_white)
  endif
enddo

if !empty(cRet_var)
  &cRet_var := cRet_val
endif

setcolor(cColorSave)
SetCursor(nCursSave)
restsector(cSectSave)

return(cRet_val)

****
*       skip_any()
*
static function skip_any(n)
local i
i := 0
if ( LastRec() != 0 )
  if ( n == 0 )
    dbskip(0)
    
  elseif ( n > 0 .and. Recno() != LastRec() + 1 )
    while ( i < n )
      dbskip(1)
      if ( Eof() .or. (memvar->cFilter != nil .and.;
            &(memvar->cInd_key) != memvar->cFilter))
        dbskip(-1)
        exit
      endif
      i++
    enddo
    
  elseif ( n < 0 )
    while ( i > n )
      dbskip(-1)
      if ( Bof() )
        exit
      endif
      if (memvar->cFilter != nil .and.;
            &(memvar->cInd_key) != memvar->cFilter)
        dbskip(1)
        exit
      endif
      i--
    enddo
  end
endif
return (i)

*******************************************************************************
*
* ET_CLOSE - Close a specified database

procedure et_close ( cDbf )
if select(cDbf) != 0
dbselectarea(cDbf)
dbclosearea()
endif
return

*******************************************************************************
* WAIT_MSG - Displays a message and restores the screen after a key has been
*            pressed
* Paramaters : nTop - Wher to plase the top of the box (it is always centered)
*              cMsg1 - First message line
*              cMsg2 - Second message line
*              cMsg3 - Third message line
*              nTime - Seconds to wait for a key before returning. The default
*                      is to wait for ever.

procedure wait_msg(nTop, cMsg1, cMsg2, cMsg3, nTime)

local cSect, nSecs

nSecs = if(valtype(nTime) = 'N', nTime, 0)
cSect = disp_msg(nTop,,cMsg1, cMsg2, cMsg3)
inkey(nSecs)
restsector(cSect)

return

* eof()
