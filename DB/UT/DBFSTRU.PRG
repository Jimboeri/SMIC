*******************************************************************************
*
* DbfStru - Creates or modifies database structures
*

local nKey
local cSect
local cName
local nCnt
local cFile_descr
local cSect1
local cCol
local lOrig_memo
local bStru
local bCol
local lSave
local cType
local nType
local lChg_name
local lAltered
local lStru_alt
local lNew
local nLen
local lExit
local lVal
local lDel
local nRow
local nCol
local mField
local nRec
local cOld
local lNew_dbf := .f.
local aEmpty
local cKey
local cOld_key
local lFix_code
memvar aStru
memvar nNtx
memvar cErr_sect
memvar getlist
memvar cField
memvar nWidth
memvar nDec
memvar cDescr
memvar nOrd

private aStru
private nOrd

#include 'inkey.ch'

#define MY_HSEP         "ÄÂÄ"
#define MY_CSEP         " ³ "
#define MY_FSEP         "ÄÁÄ"
#define EMPTY_ELEMENT   {space(10), 'C', 10, 0, space(30), '', ' '}

* coords for browse area
#define AREA_TOP        6
#define AREA_LEFT       1
#define AREA_BOTT       21
#define AREA_RIGHT      76

#define ST_NAME         1
#define ST_TYPE         2
#define ST_LEN          3
#define ST_DECIMAL      4
#define ST_DESCR        5

private nNtx             // current array position

lOrig_memo = .f.
if empty(memvar->cDbf)
  wopen(8,10,12,70)
  wbox()
  cName = space(8)
  @1,5 say 'Enter new database name ' get cName picture '@!'
  read
  wclose()
  if empty(cName)
    return
  endif
  memvar->cAlias = trim(cName)
  memvar->cDbf = memvar->cAlias + '.DBF'
  cName += space(15 - len(cName))
  if file(memvar->cDbf)
    wait_msg(12,'File ' + memvar->cDbf + ' already exists')
    memvar->cAlias = ''
    memvar->cDbf = ''
    return
  endif
  aStru := {}
  aadd(aStru, EMPTY_ELEMENT)
  cFile_descr = space(30)
  lNew_dbf = .t.
  lNew = .t.
else
  
  dbselectarea(memvar->cAlias)
  
  Astru = dbstruct()
  
  if memvar->cDbf = 'DD.DBF' .or. memvar->cDbf = 'DDSPEC.DBF'
    return
  endif
  
  select dd
  dbsetorder(1)
  
  cName = memvar->cDbf + space(15-len(memvar->cDbf))
  cFile_descr = space(30)
  if dbseek(cName + space(15))
    cFile_descr = dd->descriptn
  endif
  
  for nCnt = 1 to len(aStru)
    aStru[nCnt, ST_NAME] += space(10 - len(aStru[nCnt, ST_NAME]))
    aadd(aStru[nCnt], space(30))
    aadd(aStru[nCnt], '')
    aadd(aStru[nCnt], asc(' '))
    if dbseek(cName + aStru[nCnt, 1])
      aStru[nCnt, ST_DESCR] = dd->descriptn
      aStru[nCnt, 6] = dd->help
      aStru[nCnt, 7] = dd->key
    endif
    if aStru[nCnt,ST_TYPE] = 'M'
      lOrig_memo = .t.
    endif
  next
  lNew = .f.              // new field
endif

cSect = draw_box(10,10,16,70)
@12,20 say 'Data base file name : ' + memvar->cDbf
@14,15 say 'Description ' get cFile_Descr
read
restsector(cSect)

nNtx = 1

bStru = tbrowsenew(AREA_TOP, AREA_LEFT, AREA_BOTT, AREA_RIGHT)
cSect = draw_box(AREA_TOP-1, AREA_LEFT-1, AREA_BOTT+2, AREA_RIGHT+1)
cCol = setcolor(memvar->YELL_BLUE)
@AREA_BOTT+1, 13 say "Press 'F4' to save; 'Esc' to quit or F3 to edit help"
setcolor(cCol)

bCol = tbcolumnNew('Field name', {||aStru[nNtx, ST_NAME]})
bStru:addcolumn(bCol)

bCol = tbcolumnNew('  Type   ', {||pType(aStru[nNtx, ST_TYPE])})
bStru:addcolumn(bCol)

bCol = tbcolumnNew('Width', {||str(aStru[nNtx, ST_LEN],4,0)})
bStru:addcolumn(bCol)

bCol = tbcolumnNew('Dec', {||str(aStru[nNtx, ST_DECIMAL],2,0)})
bStru:addcolumn(bCol)

bCol = tbcolumnNew('Description', {||aStru[nNtx, ST_DESCR]})
bStru:addcolumn(bCol)

if memvar->lDecode
  bCol = tbcolumnNew('Key', {||substr(aStru[nNtx, 7],1,1)})
  bStru:addcolumn(bCol)
endif

bStru:headSep := MY_HSEP
bStru:colSep := MY_CSEP
bStru:footSep := MY_FSEP

bStru:skipblock := {|nMove| pSkip(nMove)}
bStru:gobottomblock := {|| nNtx = len(aStru)}
bStru:gotopblock := {|| nNtx = 1}

bStru:refreshall()

setcursor(0)


cErr_sect = savesector(24,10,24,70)
// set up logical variables
nKey = 0
lSave = .f.
lChg_name = .t.         // can cgange names
lAltered = .f.          // anything altered
lStru_alt = .t.         // can alter structure (no name change)
while nKey != K_ESC .and. nKey != K_F4
  bStru:forcestable()
  
  if bStru:colpos = ST_DECIMAL          // if not numeric
    if aStru[nNtx,ST_TYPE] != 'N'       // move back to LEN
      bStru:left()
      bStru:refreshcurrent()
    endif
  endif
  if bStru:colpos = ST_LEN          // if not numeric or char go back to TYPE
    if aStru[nNtx,ST_TYPE] != 'N' .and. aStru[nNtx,ST_TYPE] != 'C'
      bStru:left()
      bStru:refreshcurrent()
    endif
  endif
  if bStru:colpos = 6           // encryption keys only for char fields
    if aStru[nNtx,ST_TYPE] != 'C'
      bStru:left()
      bStru:refreshcurrent()
    endif
  endif
  
  bStru:forcestable()
  nkey = inkey(0)
  
  restsector(cErr_sect)
  do case
    case nKey = K_F4
      if lAltered
        if wMake_sure(12,,'Save file structure ?')
          if !lStru_alt .and. lOrig_memo .and.;
                Make_sure(10,,'You will lose your memos, are you sure ? (Y/N)')
            lSave = .t.
          else
            lSave = .t.
          endif
        endif
      endif
      
    case nKey = K_ESC
      if !Make_sure(10,,'Lose changes ? (Y/N)')
        nKey = 0
      endif
      
    case nKey = K_DOWN
      if nNtx = len(aStru)
        aadd(aStru, EMPTY_ELEMENT)
        bStru:down()
        bStru:panhome()
        while !bStru:stabilize()
        enddo
        lNew = .t.
        keyboard chr(K_ENTER)
        lChg_name = .f.
      else
        bStru:down()
        lNew = .f.
      endif
      
    case nKey = K_UP
      bStru:up()
      lNew = .f.
      
    case nKey = K_RIGHT
      bStru:right()
      do case
        case aStru[nNtx,ST_TYPE] = 'D' .and. bStru:colpos > ST_TYPE
          bStru:right()
          bStru:right()
        case aStru[nNtx,ST_TYPE] = 'L' .and. bStru:colpos > ST_TYPE
          bStru:right()
          bStru:right()
        case aStru[nNtx,ST_TYPE] = 'M' .and. bStru:colpos > ST_TYPE
          bStru:right()
          bStru:right()
        case aStru[nNtx,ST_TYPE] = 'C' .and. bStru:colpos > ST_LEN
          bStru:right()
      endcase
      
    case nKey = K_LEFT
      bStru:left()
      
    case nKey = K_HOME
      bStru:panhome()
      
    case nKey = K_END
      bStru:panend()
      
    case nKey = K_CTRL_PGUP
      bStru:gotop()
      lNew = .f.
      
    case nKey = K_CTRL_PGDN
      bStru:up()
      lNew = .f.
      
    case nKey = K_PGUP
      bStru:pageup()
      lNew = .f.
      
    case nKey = K_PGDN
      bStru:pagedown()
      lNew = .f.
      
    case nKey = K_DEL
      lAltered = .t.
      adel(aStru, nNtx)
      nLen = len(aStru)
      if nLen > 1
        asize(aStru, nLen-1)
      else
        aStru[nNtx] := EMPTY_ELEMENT
      endif
      lNew = .f.
      lChg_name = .f.
      bStru:refreshall()
      
    case nKey = K_INS
      if lStru_alt
        aadd(aStru, {})
        ains(aStru, nNtx)
        aStru[nNtx] := EMPTY_ELEMENT
        bStru:panhome()
        bStru:refreshall()
        while !bStru:stabilize()
        enddo
        lNew = .t.
        keyboard chr(K_ENTER)
        lChg_name = .f.
      else
        dbf_err('Cannot alter structure')
      endif
      
    case nKey = K_ENTER .or. isdata(nKey)
      if bStru:colpos != ST_TYPE
        setcursor(1)
        if nKey != K_ENTER
          keyboard chr(nKey)
        endif
      endif
      
      do case
        case bStru:colpos = ST_NAME              // field name
          if lChg_name .or. lNew           // allowed to change name
            cField = aStru[nNtx,ST_NAME]         // or new field
            lExit = readexit(.t.)
            lVal = .f.
            lDel = .f.
            nRow = row()
            nCol = col()
            while !lval
              setcursor(1)
              @nrow, ncol get cField picture '@!K' valid val_field()
              read
              setcursor(0)
              if !empty(cField)
                lVal = .t.
              else
                if lastkey() != K_UP
                  nKey = inkey(0)         // get the next key
                else
                  nKey = lastkey()
                endif
                if nKey = K_DEL
                  adel(aStru, nNtx)
                  nLen = len(aStru)
                  if nLen > 1
                    asize(aStru, nLen-1)
                  else
                    aStru[nNtx] := EMPTY_ELEMENT
                  endif
                  bStru:refreshall()
                  lVal = .t.
                  lDel = .t.
                elseif nKey = K_UP .and. nNtx = len(aStru)
                  adel(aStru, nNtx)
                  nLen = len(aStru)
                  if nLen > 1
                    asize(aStru, nLen-1)
                  else
                    aStru[nNtx] := EMPTY_ELEMENT
                  endif
                  nNtx = len(aStru)
                  bStru:refreshall()
                  lVal = .t.
                  lDel = .t.
                elseif nKey != K_ENTER
                  keyboard chr(nKey)
                endif
              endif
              if !lVal
                dbf_err('Invalid field name')
              endif
            enddo
            readexit(lExit)
            if lastkey() = K_UP .or. lastkey() = K_DOWN
              keyboard chr(lastkey())
            endif
            if cField != aStru[nNtx,ST_NAME]
              if !lNew
                lStru_alt = .f.               // prevent structure alterations
              endif
              lAltered = .t.
              aStru[nNtx,ST_NAME] = cField
              if lastkey() != K_UP .and. lastkey() != K_DOWN
                bStru:right()
              endif
              bStru:refreshcurrent()
            endif
          else
            dbf_err('Cannot change field names')
            inkey()     // remove key from buffer
          endif
          
        case bStru:colpos = ST_TYPE           // type field
          if lStru_alt
            cType = aStru[nNtx, ST_TYPE]
            do case
              case upper(chr(nKey)) $ 'CNDLM'
                if aStru[nNtx,ST_TYPE] != upper(chr(nKey))
                  aStru[nNtx,ST_TYPE] = upper(chr(nKey))
                  lAltered = .t.
                  lChg_name = .f.               // prevent name changes
                endif
                bStru:right()
                bStru:refreshcurrent()
              case nKey = asc(' ')
                nType = at(cType, 'CNDLM')
                nType = if(nType < 5, nType+1, 1)
                aStru[nNtx,ST_TYPE] = substr('CNDLM', nType, 1)
                lChg_name = .f.               // prevent name changes
                lAltered = .t.
                bStru:refreshcurrent()
              case nKey = K_ENTER
                bStru:right()
                bStru:refreshcurrent()
            endcase
            do case
              case aStru[nNtx, ST_TYPE] = 'D'
                if bStru:colpos = ST_LEN
                  aStru[nNtx, ST_LEN] = 8
                  bStru:panend()
                endif
              case aStru[nNtx, ST_TYPE] = 'L'
                if bStru:colpos = ST_LEN
                  aStru[nNtx, ST_LEN] = 1
                  bStru:panend()
                endif
              case aStru[nNtx, ST_TYPE] = 'M'
                if bStru:colpos = ST_LEN
                  aStru[nNtx, ST_LEN] = 10
                  bStru:panend()
                endif
            endcase
          else
            dbf_err('Cannot alter structure')
          endif
          
        case bStru:colpos = ST_LEN           // width
          if lStru_alt
            nWidth = aStru[nNtx,ST_LEN]
            lExit = readexit(.t.)
            @row(), col() get nWidth picture '9999' valid val_width()
            read
            setcursor(0)
            readexit(lExit)
            if lastkey() = K_UP .or. lastkey() = K_DOWN
              keyboard chr(lastkey())
            endif
            if nWidth != aStru[nNtx,ST_LEN]
              lChg_name = .f.               // prevent name changes
              lAltered = .t.
              aStru[nNtx,ST_LEN] = nWidth
              bStru:right()
              bStru:refreshcurrent()
              if aStru[nNtx, ST_TYPE] = 'N'
                keyboard chr(K_ENTER)
              endif
            endif
          else
            inkey()             // clear any key in the buffer
            dbf_err('Cannot alter structure')
          endif
          
        case bStru:colpos = ST_DECIMAL           // decimals
          if lStru_alt
            ndec = aStru[nNtx,ST_DECIMAL]
            lExit = readexit(.t.)
            @row(), col() get ndec picture '99' valid val_dec()
            read
            setcursor(0)
            readexit(lExit)
            if lastkey() = K_UP .or. lastkey() = K_DOWN
              keyboard chr(lastkey())
            endif
            if ndec != aStru[nNtx,ST_DECIMAL]
              lChg_name = .f.               // prevent name changes
              lAltered = .t.
              aStru[nNtx,ST_DECIMAL] = ndec
              bStru:right()
              bStru:refreshcurrent()
            endif
          else
            dbf_err('Cannot alter structure')
          endif
          
        case bStru:colpos = ST_DESCR           // description
          cDescr = aStru[nNtx,ST_DESCR]
          lExit = readexit(.t.)
          @row(), col() get cDescr
          read
          setcursor(0)
          readexit(lExit)
          if lastkey() = K_UP .or. lastkey() = K_DOWN
            keyboard chr(lastkey())
          endif
          if !empty(cDescr) .and. cDescr != aStru[nNtx,ST_DESCR]
            lAltered = .t.
            aStru[nNtx,ST_DESCR] = cDescr
            bStru:refreshcurrent()
          endif
          
        case bStru:colpos = 6           // key
          cKey = aStru[nNtx,7]
          lExit = readexit(.t.)
          @row(), col() get cKey
          read
          setcursor(0)
          readexit(lExit)
          if lastkey() = K_UP .or. lastkey() = K_DOWN
            keyboard chr(lastkey())
          endif
          if cKey != aStru[nNtx,7]
            lAltered = .t.
            aStru[nNtx,7] = cKey
            bStru:refreshcurrent()
          endif
      endcase
      
    case nKey = K_F3
      mField = aStru[nNtx,6]
      cCol = setcolor(memvar->BLACK_WHITE)
      cSect1 = draw_box(6,8,20,72, .t.)
      setcursor(1)
      mField = memoedit(mField,7,10,19,70,.t.)
      setcursor(0)
      aStru[nNtx,6] := mField
      restsector(cSect1)
      setcolor(cCol)
  endcase
enddo

if lSave
  // save structure to data dictionary
  select dd
  dbsetorder(1)
  if !dbseek(trim(cName) + '.DBF' + space(15))
    dbsetorder(2)
    dbgobottom()
    nRec = dd->rec_code
    dbappend()
    reclock()
    dd->file := trim(cName) + '.DBF'
    dd->rec_code := nRec+1
    dbunlock()
    dbsetorder(1)
  endif
  reclock()
  dd->descriptn := cFile_descr
  dbunlock()
  
  lFix_code = .f.
  for nCnt = 1 to len(aStru)
    if !dbseek(cName + aStru[nCnt,ST_NAME])
      dbsetorder(2)
      dbgobottom()
      nRec = dd->rec_code
      nRec++
      dbappend()
      reclock()
      dd->file := memvar->cDbf
      dd->name := aStru[nCnt,ST_NAME]
      dd->rec_code := nRec
      dbunlock()
    endif
    reclock()
    dd->type      := aStru[nCnt,ST_TYPE]
    dd->length    := aStru[nCnt,ST_LEN] + (aStru[nCnt,ST_DECIMAL] / 100)
    dd->descriptn := aStru[nCnt,ST_DESCR]
    dd->help      := aStru[nCnt,6]
    aadd(aStru[nCnt], dd->key)
    if dd->key != aStru[nCnt,7]
      lFix_code = .t.
      dd->key     := aStru[nCnt,7]
    endif
    dbunlock()
  next
  dbcommitall()
  if lNew_dbf
    dbcreate(memvar->cAlias, aStru)
  else
    dbselectarea(memvar->cAlias)
    dbclosearea()
    cOld = memvar->cAlias + '.DBF'
    rename &cOld to ddbbuu.dbf
    if lOrig_memo
      cOld = memvar->cAlias + '.DBT'
      rename &cOld to ddbbuu.dbt
    endif
    dbcreate(memvar->cAlias, aStru)
    select 1
    if !lStru_Alt         // change field names by copying SDF
      use ddbbuu
      copy to ddbbuu.txt sdf
      dbusearea(.t.,,memvar->cAlias,,.f.)
      append from ddbbuu.txt sdf
      ferase('ddbbuu.txt')
    else
      dbusearea(.t.,,memvar->cAlias,,.f.)
      append from ddbbuu
    endif
    if file('ddbbuu.dbf')
      ferase('ddbbuu.dbf')
    endif
    if file('ddbbuu.dbt')
      ferase('ddbbuu.dbt')
    endif
    if lFix_code .and. make_sure(10,,'Modify fields to match new keys')
      for nCnt = 1 to len(aStru)
        if aStru[nCnt, 7] != aStru[nCnt, 8]
          nOrd = nCnt
          dbeval({ | | et_fix_field () })
        endif
      next
    endif
  endif
endif
restsector(cSect)
return

*******************************************************************************
function pSkip( nIn_moves )
local nTemp

nTemp := 0
if ( len(memvar->aStru) != 0 )
  if ( nIn_moves > 0)
    while ( nTemp < nIn_moves )
      memvar->nNtx++
      if ( memvar->nNtx > len(memvar->aStru))
        memvar->nNtx--
        exit
      endif
      nTemp++
    enddo
    
  elseif ( nIn_moves < 0 )
    while ( nTemp > nIn_moves )
      memvar->nNtx--
      if ( memvar->nNtx < 1)
        memvar->nNtx++
        exit
      endif
      nTemp--
    enddo
  endif
endif
return (nTemp)

******
*   isdata()
*
*   determine if a key is data suitable for entry in place
******
FUNCTION isdata

PARAMETERS k

RETURN (M->k >= 32 .AND. M->k < 249 .AND. M->k <> 219 .AND. CHR(M->k) <> ";")


*******************************************************************************
function pType (cIn_char)
do case
  case cIn_char = 'C'
    return('Character')
  case cIn_char = 'D'
    return('Date     ')
  case cIn_char = 'N'
    return('Numerical')
  case cIn_char = 'L'
    return('Logical  ')
  case cIn_char = 'M'
    return('Memo     ')
endcase
return nil

*******************************************************************************
procedure dbf_err ( cIn_string )
local cCol, nLen
cCol = setcolor(memvar->YELL_RED)
nLen = len(cIn_string)
@24, 40 - int(nlen/2) say cIn_string
setcolor(cCol)
return

*******************************************************************************
function val_field
local cVar, cVal, lField, lChar, nCnt, cChar
restsector(memvar->cErr_sect)
cVar = readvar()
cVal = &cVar
cChar = substr(cVal,1,1)
if empty(cVal)
  return(.t.)
endif
if !isalpha(cChar)
  dbf_err('Invalid field name')
  &cVar = memvar->aStru[memvar->nNtx, ST_NAME]
  return(.f.)
endif
for nCnt = 1 to len(cVal)
  cChar = substr(cVal,nCnt,1)
  if !isdigit(cChar) .and. !isalpha(cChar) .and. !(cChar $ ' _')
    dbf_err('Invalid field name')
    &cVar = memvar->aStru[memvar->nNtx, ST_NAME]
    return(.f.)
  endif
next
for nCnt = 1 to len(memvar->aStru)
  if nCnt != memvar->nNtx
    if cVal = memvar->aStru[nCnt, ST_NAME]
      dbf_err('Duplicate names not allowed')
      &cVar = memvar->aStru[memvar->nNtx, ST_NAME]
      return(.f.)
    endif
  endif
next
return(.t.)

*******************************************************************************
function val_width
local cVar, nVal
restsector(memvar->cErr_sect)
cVar = readvar()
nVal = &cVar
if nVal = 0
  dbf_err('Cannot have zero width')
  return(.f.)
endif
return(.t.)

*******************************************************************************
function val_dec
local cVar, nVal
restsector(memvar->cErr_sect)
cVar = readvar()
nVal = &cVar
if nVal > memvar->aStru[memvar->nNtx,ST_LEN] - 1
  dbf_err('Too many decimals')
  return(.f.)
endif
return(.t.)

*******************************************************************************
function et_fix_field ()
local cTemp_val

if memvar->aStru[memvar->nOrd, 8] = ' '
  cTemp_val = fieldget(memvar->nOrd)
else
  cTemp_val = jw_scram(fieldget(memvar->nOrd),;
      asc(memvar->aStru[memvar->nOrd, 8]))
endif

if memvar->aStru[memvar->nOrd, 7] = ' '
  fieldput(memvar->nOrd, cTemp_val)
else
  fieldput(memvar->nOrd, jw_scram(cTemp_val,;
      asc(memvar->aStru[memvar->nOrd, 7])))
endif
@24,20 say str(recno(),5,0)
return nil
