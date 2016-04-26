*******************************************************************************
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
local nFiles := 1

lShared  = if(valtype(lExclusive) = 'L'   , !lExclusive,   .t.)
lIndices = if(valtype(lOpen_indices) = 'L', lOpen_indices, .t.)
lRead    = if(valtype(lReadonly) = 'L'    , lReadonly,     .f.)

if select(cName) != 0
  dbselectarea(cName)
  dbclosearea()
endif

cDbf_Name = trim(upper(cName)) + '.DBF'
if !file(cDbf_Name)
  wait_msg(20,cDbf_name + ' DOES NOT EXIST')
  return nil
endif

if !file('DD.DBF')
  wait_msg(20,'DATA DICTIONARY DOES NOT EXIST')
  return nil
endif

if cDbf_name = 'DD.DBF'
  dbusearea(.t., , 'DD', , .t., .t.)
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
  nFiles++
  dbskip()
enddo

if filesfree() < nFiles
  wait_msg(18,'There are not enough file handles available')
  return nil
endif

dbusearea(.t., , cName, , lShared, lRead)

if neterr()
  wait_msg(20,'NETWORK LOCK ON ' + upper(cName) +;
      ' - PLEASE TRY LATER')
  return nil
endif

asort(aIndex)

for nCnt = 1 to len(aIndex)
  aIndex[nCnt] = stuff(aIndex[nCnt], 1, 1, '')
  if !file(aIndex[nCnt])
    wait_msg(20,aIndex[nCnt] + ' DOES NOT EXIST')
    return nil
  endif
  nAt = at('.', aIndex[nCnt])
  cIndex = substr(aIndex[nCnt], 1, nAt - 1)
  dbsetindex(cIndex)
  if neterr()
    wait_msg(20,'NETWORK ERROR ON ' + aIndex[nCnt] +;
        ' - PLEASE TRY LATER')
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

*******************************************************************************
*       This is a database seek utility used to select a record from a database
*
* Parameters    cDatabase - The name of the database
*               aDisp_fields - A numeric array consisting of the ordinal
*                              numbers of the fields in the database to be
*                              displayed.
*               lSearch - A boolean value indicating whether a quick type
*                         search should be used. This works on the first record
*                         and must match the controlling index.
*               aEsc_keys - A numeric array of inkey code which will allow an
*                           escape from the procedure
*               cOrig_key - A character expression equal to the initial part
*                           of the index key. Used for selecting subrecords
*               cFirst      Key of record to start with
*               cHeading    Heading to be displayed
*               cColour     Display colour to be used
*******************************************************************************
function et_seek(cDatabase, aDisp_fields, lSearch, aEsc_keys, cOrig_key,;
    cFirst, cHeading, cIn_Colour)

local nCnt, bAction, lMore, cRet_val, cRet_var, cOrig_val
local aStru, lClose_dd, cData, aDisp_stru, nWidth
local nArea, oColumn, nKey, lSave_Visible, cSeek, cLook
local nRec, nWin, cColour

memvar oPick, lKey_search, cFilter, nTop, nBott, nLeft, nRight, cInd_key

private oPick, lKey_search, cFilter
private nTop, nLeft, nBott, nRight

lKey_search = if(valtype(lSearch) = 'L', lSearch, .f.)
cFilter = cOrig_key
cColour = if(valtype(cIn_colour) = 'C' .and. !empty(cIn_colour),;
    cIn_Colour, memvar->black_white)

nTop = if(empty(cHeading),5,6)
nBott = if(lKey_search, 20, 21)
nRight = 75

cRet_var = readvar()
cOrig_val = if(!empty(cRet_var), &cRet_var, '')
if !empty(cFirst)
  cOrig_val = cFirst
endif

dbselectarea(cDatabase)
dbgotop()

if lKey_search
  if cFilter = NIL
    dbseek(cOrig_val, .t.)
  else
    dbseek(cFilter + cOrig_val, .t.)
  endif
  if eof()
    dbgotop()
  endif
endif

if bof() .or. (!empty(cOrig_key) .and. !dbseek(cOrig_key))
  wopen(10,30,12,50)
  wcenter()
  setcolor(memvar->white_red)
  wbox(1)
  @0,0 say center('Nothing found !')
  inkey(0)
  wclose()
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

nWin = wopen(nTop-1, nLeft-1, nBott+1, nRight+1)
setcolor(cColour)
wbox(1)
if !empty(cHeading)
  @0,0 say center(cHeading,,,.t.)
endif

/* make new browse object */
if lKey_search
  oPick := TBrowseDB(nTop-5, 0, maxrow()-1, maxcol())
  oPick:footSep := MY_FSEP
else
  oPick := TBrowseDB(nTop-5, 0, maxrow(), maxcol())
endif
SetCursor(0)

/* default heading and column separators */
oPick:headSep := MY_HSEP
oPick:colSep := MY_CSEP

/* add custom 'skipper' (to handle append mode) */
oPick:skipBlock := {|x| Skip_any(x)}

/* colors */
*oPick:colorSpec := memvar->black_white
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
      nKey = inkey(10)
      if nKey = 0
        oPick:refreshall()
      endif
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
    @maxrow(), 2 say cSeek + space(len(&cInd_key) - len(cSeek));
        color memvar->white_black
  endif
enddo

if !empty(cRet_var)
  &cRet_var := cRet_val
endif

wclose(nWin)

return(cRet_val)

*******************************************************************************
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
* Paramaters : nTop - Where to place the top of the box (it is always centered)
*              cMsg1 - First message line
*              cMsg2 - Second message line
*              cMsg3 - Third message line
*              nTime - Seconds to wait for a key before returning. The default
*                      is to wait for ever.

procedure wait_msg(nTop, cMsg1, cMsg2, cMsg3, nTime)

local cSect, nSecs, nLen, nHight
nLen = len(cMsg1)
nHight = 1
if !empty(cMsg2)
  nHight++
  if len(cMsg2) > nLen
    nlen = len(cMsg2)
  endif
  if !empty(cMsg3)
    nHight++
    if len(cMsg3) > nLen
      nlen = len(cMsg3)
    endif
  endif
endif

nSecs = if(valtype(nTime) = 'N', nTime, 0)

wopen(8, 38 - (nLen/2), 9+nHight, 42 + (nLen/2))
setcolor(memvar->white_red)
setcursor(0)
wbox(0)
@0,0 say center(cMsg1)
if !empty(cMsg2)
  @1,0 say center(cMsg2)
  if !empty(cMsg3)
    @2,0 say center(cMsg3)
  endif
endif
inkey(nSecs)
wclose()

return

* eof()

*f*****************************************************************************
function get_arr(aIn_arr, nIn_top, nIn_left, cIn_color, lEscape, cHeading,;
    nIn_Start, alVal_arr, cUsr_func, nTime_out)

local nWdt, cHead, nLeft, nRight, nTop, nBott, lEsc, nStart
local nSec, cBlock, bBlock, nCurssave, nWin, nTime_last, oPick, oColumn
local nCnt, lMore, nRet, bAction, nKey, nBval, cChar, nFirst
memvar aArr, nArr_ntx

public nArr_ntx := 1

aArr := aIn_arr

if len(aIn_arr) = 0
  return(0)
endif

nWdt = arr_wdth(aIn_arr)

cHead = if(valtype(cHeading) = 'C', cHeading, 'Select option')
cHead = trim(ltrim(cHead))
nWdt = if(len(cHead) > nWdt, len(cHead), nWdt)

if len(cHead) < nWdt
  cHead = center(cHead, nWdt)
endif

if nIn_left != nil
  nLeft = nIn_left - 1
else
  nLeft = int((maxcol() - nWdt) /2) - 1
endif
nLeft = int(nLeft)

nRight = nLeft + 2 + nWdt

if nIn_top = nil
  if len(aIn_arr) > 16
    nTop = 4
  else
    nTop = int((maxrow() - len(aIn_arr)) / 2)
  endif
else
  nTop = nIn_top - 1
endif

nBott = nTop + 1 + len(aIn_arr)

if nBott > 23
  nBott = 23
endif

lEsc = if((lEscape = NIL .or. valtype(lEscape) != 'L'), .f., lEscape)

nStart = if(valtype(nIn_start) = 'N', nIn_start, 1)

nSec = if(valtype(nTime_out) = 'N', nTime_out, 999999999)
nTime_last = seconds()

if cUsr_func != nil
  cBlock = "{| nElement, nRow, nKey_val | " + cUsr_func;
      + " (nElement, nRow, nKey_val)}"
  bBlock := &(cBlock)
endif

nWin = wopen(nTop-2, nLeft, nBott, nRight)
if cIn_color != nil
  setcolor(cIn_color)
endif
wbox(0)

/* make new browse object */
oPick := TBrowseDB(0, 0, maxrow(), maxcol())

nCursSave := SetCursor(0)

/* default heading and column separators */
oPick:headSep := MY_HSEP
oPick:colSep := MY_CSEP
*oPick:footSep := MY_FSEP

/* add custom 'skip_curr' (to handle append mode) */
oPick:skipBlock := {|x| move_arr(x)}

/* add a column for display */
oColumn := TBColumnNew( cHead, {|| aArr[nArr_ntx]} )
oColumn:width := nWdt
oPick:addColumn(oColumn)

for nCnt = 1 to nStart-1
  oPick:down()
next

lMore := .t.
nRet = 0
while (lMore)
  
  /* don't allow cursor to move out of first column */
  oPick:colPos := 1
  
  /* stabilize the display */
  oPick:forcestable()
  /* display is stable */
  if ( oPick:hitTop .or. oPick:hitBottom )
    Tone(125, 0)
  endif
  
  /* everything's done; just wait for a key */
  nKey := inkey(0)
  
  /* process key */
  do case
    case ( nKey == K_F1 )               // if help is needed
      help(procname(), procline(), cHeading)
      
    case (bAction := SETKEY(nKey)) != NIL
      EVAL(bAction, Procname(), Procline(), readvar())
      
    case ( nKey == K_DOWN )
      oPick:down()
      
    case ( nKey == K_UP )
      oPick:up()
      
    case ( nKey == K_PGDN )
      oPick:pageDown()
      
    case ( nKey == K_PGUP )
      oPick:pageUp()
      
    case ( nKey == K_CTRL_PGUP ) .or. ( nKey == K_HOME )
      oPick:gobottom()
      
    case ( nKey == K_CTRL_PGDN ) .or. ( nKey == K_END )
      oPick:gotop()
      
    case ( nKey == K_ESC ) .and. lEsc
      lMore := .f.                              // exit proc
      nRet = 0
      
    case ( nKey == K_RETURN )
      lMore := .f.                              // exit proc
      nRet = nArr_ntx
      
    otherwise
      if bBlock != nil
        nbVal = eval(bBlock, nArr_ntx, oPick:rowpos, nKey)
        do case
          case nBval = 0
            lMore := .f.                              // exit proc
            nRet = 0                                  // no selection
          case nBval = 1
            lMore := .f.                              // exit proc
            nRet = nArr_ntx                           // select value
        endcase
      else
        cChar = upper(chr(nKey))
        nFirst = 0
        if nArr_ntx < len(aIn_arr)
          nFirst = aScan(aIn_arr, cChar, nArr_ntx+1)
        endif
        if nFirst = 0
          nFirst = aScan(aIn_arr, cChar, 1, nArr_ntx-1)
        endif
        if nFirst != 0
          if nFirst < nArr_ntx
            for nCnt = narr_ntx-1 to nFirst step -1
              oPick:up()
            next
          else
            for nCnt = narr_ntx+1 to nFirst
              oPick:down()
            next
          endif
        endif
      endif
  endcase
  if nTime_last + nSec < seconds()
    exit
    nRet = 0
  endif
enddo
wclose(nWin)
return(nRet)
* eof mget_arr

*******************************************************************************
*       move_arr()
*

static function move_arr(n)
local i

i := 0
if ( len(memvar->aArr) != 0 )
  if ( n > 0)
    while ( i < n )
      memvar->nArr_ntx++
      if ( memvar->nArr_ntx > len(memvar->aArr))
        memvar->nArr_ntx--
        exit
      endif
      i++
    enddo
    
  elseif ( n < 0 )
    while ( i > n )
      memvar->nArr_ntx--
      if ( memvar->nArr_ntx < 1)
        memvar->nArr_ntx++
        exit
      endif
      i--
    enddo
  endif
endif
return (i)

***********************************************************
function inwait
local nRow, nCol
nRow = row()
nCol = col()
set console off
wait ''
set console on
setpos(nRow, nCol)
return(lastkey())

*f*****************************************************************************
*
* FUNCTION WMAKE_SURE - CHECKS FOR YES OR NO
*                       RETURNS BOOLEAN
*
*******************************************************************************
function wmake_sure ( nY_coord, nX_coord, cString1, cString2)
local cStr1, cStr2, cChar, nInkey, nWin
local nHight, nWidth

if cString1 = nil
  cStr1 = 'Are you SURE ?'
else
  cStr1 = cString1
endif
nHight = 3
nWidth = len(trim(cStr1))

if cString2 != nil
  cStr2 = cString2
  nHight++
  if len(trim(cStr2)) > nWidth
    nWidth = len(trim(cStr2))
  endif
endif

if nY_coord = nil
  if row() < 17
    nY_coord = row() + 2
  else
    nY_coord = row() + nHight - 3
  endif
endif
nY_coord = int(nY_coord)

if nX_coord = nil
  nX_coord = ((80-nWidth)/2)
endif
nX_coord = int(nX_coord)

nWin = wopen(nY_coord-1, nX_coord-1, nY_coord+nHight-2,;
    nX_coord+nWidth+2)
setcolor(memvar->white_red)
wbox()
setcursor(0)

@0,0 say center(cStr1)
if cString2 != nil
  @1,0 say center(cString2)
endif
cChar = ' '
while cChar != 'Y' .and. cChar != 'N'
  nInkey = inkey(60)
  if ( nInkey == K_F1 )
    help(procname(), procline(), 'MAKE_SURE')
  endif
  if nInkey = 0 .or. nInkey = K_ESC
    cChar = 'N'
  else
    cChar = upper(chr(nInkey))
  endif
enddo
wclose()
if cChar = 'Y'
  return(.t.)
endif
return(.f.)

* EOF()

*******************************************************************************
*
* Delete files older than a specified date
* Parameter cFile       - File name (can include wildcards)
*           dDate       - Date before which files are to be deleted
*
procedure xfgen (cFile, dDate, cDir, cDisk)
local aFiles, nCnt, cOrig_disk, cOrig_dir

if !empty(cDisk)
  cDisk = trim(cDisk)
endif

if !empty(cDir)
  cDir = trim(cDir)
endif

begin sequence
  if empty(cFile) .or. empty(dDate)
    break
  endif
  if valtype(dDate) != 'D'
    break
  endif
  
  if !empty(cDisk)
    cOrig_disk = diskname()
    if !diskchange(cDisk)
      break
    endif
  endif
  
  if !empty(cDir)
    cOrig_dir = dirname()
    if dirchange(cDir) != 0
      break
    endif
  endif
  
  aFiles = directory(cFile)
  
  for nCnt = 1 to len(aFiles)
    if aFiles[nCnt, 3] < dDate
      deletefile(aFiles[nCnt, 1])
    endif
  next
  
end sequence

if !empty(cOrig_dir)
  dirchange(cOrig_dir)
endif

if !empty(cOrig_disk)
  diskchange(cOrig_disk)
endif

return

*******************************************************************************
* This function opens the print file. It the global variable force_prfile is
* set a print file is opened with a user specified name (defaults to JIM.TXT)
* If global variable lPrn_scr is set output is directed to the screen
* The function also waits until a printer has been located before continuing
*
* Parameter lLandscape - A Boolean which, if set, will issue a
* "print landscape" command. Defaults to false.

*******************************************************************************
function openprn (lLandscape)
local lOK := .f., getlist := {}, nChoice
local lPr_error := .t., lLand, cPr_fl
local aOptions := {"Retry", "Quit"}
local lPr_screen

memvar->pPage = 0
memvar->pline = 200
memvar->lPr_esc = .f.         // reset global variable to disallow esc of print

lPr_screen = if(type('memvar->lPrn_scr') = 'L', memvar->lPrn_scr, .f.)

lLand = if(valtype(lLandscape) = 'L', lLandscape, .f.)
if !lPr_screen                                   // not a screen print
  if valtype(memvar->FORCE_PRFILE) = 'L' .and. memvar->FORCE_PRFILE
    cPr_fl = 'JIM.TXT             '
    wopen(8,20,13,60)
    wbox(1)
    setcursor(1)
    @1,0 say center('Enter print file name')
    @2,10 get cPr_fl picture '@!'
    read
    if !empty(cPr_fl)
      set printer to &cPr_fl
    endif
    wclose()
  endif
  while !lOK
    if empty(set(_SET_PRINTFILE))
      if isprinter()
        set print on
        set console off
        ?? memvar->PR_RESET + memvar->PR_SETUP
        if lLand
          ?? memvar->PR_LAND
        else
          ?? memvar->PR_PORT
        endif
        lOK = .t.
        lPr_error = .f.
      else
        nChoice = 0
        while (nChoice == 0)
          nChoice = Alert('Printer not ready', aOptions)
        enddo
        if nChoice == 2
          break
        endif
      endif
    else
      set print on
      set console off
      ?? memvar->PR_RESET + memvar->PR_SETUP
      if lLand
        ?? memvar->PR_LAND
      else
        ?? memvar->PR_PORT
      endif
      lOK = .t.
      lPr_error = .f.
    endif
  enddo
else                            // print to screen
  wopen(0,0,24,79)              // open screen window
  setcolor(memvar->black_white)
  @0,0 clear
  set print off
  set consol on
endif
return(lPr_error)

*f*****************************************************************************
* This procedure closes the printfile. In addition this function
* releases the printer so that it can print on a network
*
* Parameter lDate - A Boolean which, if set, prints the date at the bottom
*                   of tha last page
procedure shutprn (lDate)
local nCnt, lPr_dt
lPr_dt = if(valtype(lDate) = 'L', lDate, .t.)
if valtype(memvar->lPrn_scr) != 'L';                // not a screen print
    .or. !memvar->lPrn_scr
  if set(_SET_PRINTER)    // printer is set on
    if lPr_dt
      while pRow() < memvar->pr_lines - 2
        ? ''
      enddo
      ? '                   ---   ' + dtoc(date()) + '   ---'
    endif
    ?? memvar->PR_FORM_FEED
    ?? memvar->PR_RESET
  endif
  set print off
  set consol on
  set printer to
  set printer to lpt1
else                            // screen print
  inkey(60)
  wclose()
endif
return

*f*****************************************************************************
* This function is a standard function for printing a line. If the global
* Boolean variable lPr_esc is set and the last key pressed is an "Esc"
* an option is offered to "Break" out of the print.

function pr_line (in_line)

if memvar->lPr_esc .and. inkey() = K_ESC .and.;
      alert('Do you want to :', {'Continue printing', 'Abort printing'}) = 2
  break
endif
? in_line
memvar->pLine++
if memvar->lPrn_scr
 if row() > 23
   inkey(0)
   @0,0 clear
 endif
endif
return(.f.)

*f*****************************************************************************
* A toggle procedure for force_prfile

procedure jw_pri_sw
local aCh, nCh
if memvar->FORCE_PRFILE
  aCh := {'Print to file', 'Print to printer', 'Print to screen'}
else
  aCh := {'Print to printer', 'Print to file', 'Print to screen'}
endif
nCh = get_arr(aCh, 15,,memvar->black_green,,'Select new choice')

memvar->lPrn_scr = .f.
do case
  case nCh = 2
    if memvar->FORCE_PRFILE
      memvar->FORCE_PRFILE = .f.
    else
      memvar->FORCE_PRFILE = .t.
    endif
  case nCh=3
    memvar->lPrn_scr = .t.
endcase
return

*f*****************************************************************************
* PROCEDURE PRNTITLE - Print company title, date, page number and
*                      a subheading at the top of a new page
*                      Global variables pline & ppage used directly
*
* Parameters cSubTitle - The subtitle is printed in the third line
*            mComp - If "Y" the rest of the page is printed in compressed mode
*                    Defaults to 'N'
*            nPg_width - The page width to be used for centering the headings
*                         Defaults to 80

procedure prntitle ( cSubTitle, cComp, nPg_width)

local cTop, nWidth, cTitle, nPage_wdth, lComp, cLine
memvar pPnt_title, pLine
nPage_wdth = if((nPg_width = NIL .or. valtype(nPg_width) != 'N'), 80,;
    nPg_width)
if valtype(cComp) = 'C'
  lComp = if(upper(cComp) = 'Y', .t., .f.)
else
  if valtype(cComp) = 'L'
    lComp = cComp
  else
    lComp = .f.
  endif
endif
if type(pPnt_title) != 'C'
  pPnt_title := "ET's program"
endif
pline := 1
if memvar->pPage != 0
  ? memvar->PR_FORM_FEED + memvar->PR_COMP_OF
else
  ?? memvar->PR_COMP_OF
endif
setprc(0,0)
cTop = ltrim(ppnt_title)
cTop = rtrim(cTop)
store ((nPage_wdth-20)-len(cTop))/2 to nWidth
?? dtoc(date())
?? replicate(' ',nWidth) + cTop + replicate(' ',nWidth) + 'page '
memvar->pPage++
?? ltrim(str(memvar->pPage))
store trim(cSubTitle) to cTitle
store (nPage_wdth-len(cTitle))/2 to nWidth
pr_line(' ')
cLine = space(nWidth) + cTitle
if lComp
  cLine += memvar->PR_COMPRESS
endif
pr_line(cLine)
pr_line(' ')
return
* eof (prntitle)

*******************************************************************************
procedure tts_on()
if nnetistts()
  nnetttsbeg()
endif
return

*******************************************************************************
procedure tts_off()
if nnetistts()
  nnetttsend()
endif
return

*******************************************************************************
function rem_tts(cFile)
local nAttr
if nnetwork()
  nAttr = nnetextatt(cFile)
  if nAttr != -1 .and. isbit(nAttr, 5)
    nAttr -= 16
    nnetextatt(cFile, nAttr)
  endif
endif
return(.t.)

*******************************************************************************
function add_tts(cFile)
local nAttr, nRes
if nnetwork()
  nAttr = nnetextatt(cFile)
  if nAttr != -1 .and. !isbit(nAttr, 5)
    nAttr += 16
    nRes = nnetextatt(cFile, nAttr)
    if nRes != nAttr
      return(.f.)
    endif
  endif
endif
return(.t.)

