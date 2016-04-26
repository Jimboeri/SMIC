*******************************************************************************
*
* DbfEdit
*
local nTop, nBott, nLeft, nRight, nCnt, nRow, nCol, nLast_rec, nKey
local oColumn, lMore, lEdit, bAction, cTemp, cT, nRec
local cCol, cSect, val, oCol

memvar lRlock, lAppend, lKill_append, lFreshorder, cKey, cFilter, lFuzzy
memvar oDbf, getlist

private oDbf, getlist := {}

#define MY_HSEP         "ÄÂÄ"
#define MY_CSEP         " ³ "
#define MY_FSEP         "ÄÁÄ"
#include "inkey.ch"

set deleted off

nTop = 5
nLeft = 2
nBott = 21
nRight = 76

lRlock = .f.
lAppend = .f.
lKill_append = .f.
lFreshorder = .f.

cKey = space(60)
cFilter = space(60)
lFuzzy = .f.

dbselectarea(memvar->cAlias)
dbgotop()
draw_box(nTop-2, nLeft-2, nBott+2, nRight+2)
oDbf := TBrowseDB(nTop, nLeft, nBott, nRight)
@nBott+1, 5 say 'F6 - softseek ON/OFF          F7 - Seek             F8 - Filter'

/* default heading and column separators */
oDbf:headSep := MY_HSEP
oDbf:colSep := MY_CSEP
oDbf:footSep := MY_FSEP

/* add custom 'skipper' (to handle append mode) */
oDbf:skipBlock := {|x| Skip_edit(x)}

/* colors */
oDbf:colorSpec := memvar->BLUE_CYAN
for nCnt = 1 to len(memvar->aVisible)
  if memvar->aVisible[nCnt, 2] = 'M'
    oColumn := TBColumnNew( memvar->aVisible[nCnt, 5], {||'<memo>'})
  else
    if memvar->lDecode
      oColumn := TBColumnNew( memvar->aVisible[nCnt, 5],;
          memvar->aVisible[nCnt, 7])       // this code block decodes data
    else
      oColumn := TBColumnNew( memvar->aVisible[nCnt, 5],;
          memvar->aVisible[nCnt, 6])
    endif
  endif
  oDbf:addColumn(oColumn)
next

oDbf:refreshall()
nLast_rec = recno()
/* mouse */
lMore := .t.
while (lMore)
  
  if nLast_rec != recno()
    oDbf:refreshcurrent()
    nLast_rec = recno()
  endif
  
  /* stabilize the display */
  nKey = 0
  oDbf:forcestable()
  
  if oDbf:hitbottom
    if ( !lAppend .or. recno() = lastrec() + 1)
      if recno() = lastrec() + 1
        oDbf:refreshcurrant()
        while ( !oDbf:stabilize() )
        enddo
      else
        lAppend = .t.
        setcursor(1)
      endif
      if recno() != lastrec() + 1
        oDbf:down()
        while ( !oDbf:stabilize() )
        enddo
      endif
    endif
  endif
  
  nRow = row()
  nCol = col()
  
  if recno() <= lastrec()
    @nTop - 1,40 say 'Rec ' + ltrim(str(recno())) + '/' +;
        ltrim(str(lastrec())) + space(4)
  else
    @nTop - 1,40 say '<New>          '
  endif
  
  if deleted()
    @nTop - 1,65 say '<Deleted>'
  else
    @nTop - 1,65 say space(9)
  endif
  
  if lFuzzy
    @nTop-1, 5 say 'Softseek'
  else
    @nTop-1, 5 say '        '
  endif
  @nRow, nCol say ''
  
  if ( oDbf:hitTop .or. oDbf:hitBottom )
    Tone(125, 0)
  end
  
  /* everything's done; just wait for a key */
  if nKey = 0
    nKey = inkeytrap(10)
  endif
  if nKey = 0
    oDbf:refreshall()
    loop
  endif
  if !eof()
    memvar->lRlock = rlock()
  endif
  
  lEdit = .f.
  nCol = oDbf:colpos
  
  /* process key */
  do case
    case ( nKey == K_F1 )
      help(procname(), procline(), memvar->cDatabase)
      
    case (bAction := SETKEY(nKey)) != NIL
      EVAL(bAction, Procname(), Procline(), readvar())
      
    case ( nKey == K_DOWN )
      if lAppend
        oDbf:hitbottom = .t.
      else
        oDbf:down()
      endif
      
    case ( nKey == K_PGDN )
      if lAppend
        oDbf:hitbottom = .t.
      else
        oDbf:pageDown()
      endif
      
    case ( nKey == K_CTRL_PGDN )
      if lAppend
        oDbf:hitbottom = .t.
      else
        oDbf:goBottom()
      endif
      
    case ( nKey == K_UP )
      if lAppend
        lKill_append = .t.
      else
        oDbf:up()
      endif
      
    case ( nKey == K_PGUP )
      if lAppend
        lKill_append = .t.
      else
        oDbf:pageUp()
      endif
      
    case ( nKey == K_CTRL_PGUP )
      if lAppend
        lKill_append = .t.
      else
        oDbf:goTop()
      endif
      
    case ( nKey == K_RIGHT )
      oDbf:right()
      
    case ( nKey == K_LEFT )
      oDbf:left()
      
    case ( nKey == K_CTRL_RIGHT )
      oDbf:panright()
      
    case ( nKey == K_CTRL_LEFT )
      oDbf:panleft()
      
    case ( nKey == K_END )
      oDbf:panend()
      
    case ( nKey == K_HOME )
      oDbf:panHome()
      
    case ( nKey == K_DEL )
      if recno() != lastrec() + 1
        if deleted()
          recall
        else
          dbdelete()
        endif
      endif
      
    case ( nKey == K_ESC )
      lMore := .f.
      
    case ( nKey == K_F6 )
      if lFuzzy
        lFuzzy = .f.
      else
        lfuzzy = .t.
      endif
      
    case ( nKey == K_F7 ) .and. len(memvar->aNtx) > 0       // seek
      cTemp = draw_box(10,20,14,60)
      @12,22 say 'Enter key value ' get cKey picture '@S20'
      read
      restsector(cTemp)
      if lastkey() != K_ESC
        if lFuzzy
          dbseek(trim(cKey), .t.)
          oDbf:refreshall()
        else
          nRec = recno()
          if !dbseek(trim(cKey))
            ct = disp_msg(13,,'Record not found')
            inkey(20)
            restsector(ct)
            dbgoto(nRec)
          else
            oDbf:refreshall()
          endif
        endif
      endif
      
    case ( nKey == K_F8 )                   // filter
      cTemp = draw_box(10,10,14,70)
      @12,12 say 'Enter Filter value ' get cFilter picture '@S36'
      read
      restsector(cTemp)
      if empty(cFilter)
        set filter to
      else
        if type(cFilter) != 'L'
          ct = disp_msg(13,,'Not a logical value')
          inkey(20)
          restsector(ct)
        else
          set filter to &cFilter
          oDbf:down()
          while ( !oDbf:stabilize() )
          enddo
          oDbf:up()
        endif
      endif
      oDbf:refreshall()
      
    case ( nKey == K_RETURN )
      lEdit = .t.
      
    case nKey = K_ALT_P
      pr_rec()
      
    otherwise
      do case
        case memvar->aVisible[nCol, 2] = 'L'
          if upper(chr(nKey)) = 'T' .or. upper(chr(nKey)) = 'F'
            lEdit = .t.
            keyboard chr(nKey)
          endif
          
        case memvar->aVisible[nCol, 2] = 'D'
          if isdigit(chr(nKey))
            lEdit = .t.
            keyboard chr(nKey)
          endif
          
        case memvar->aVisible[nCol, 2] = 'N'
          if isdigit(chr(nKey)) .or. chr(nKey) = '-'
            lEdit = .t.
            keyboard chr(nKey)
          endif
          
        case memvar->aVisible[nCol, 2] = 'C'
          if isdata(nKey)
            lEdit = .t.
            keyboard chr(nKey)
          endif
      endcase
      
  endcase
  
  if lEdit
    oDbf:refreshcurrent()
    while ( !oDbf:stabilize() )
    enddo
    cCol = setcolor(memvar->BLACK_WHITE)
    setcursor(1)
    oCol = oDbf:getcolumn(nCol)
    Val = eval(oCol:block)
    if memvar->aVisible[nCol, 2] != 'M'
      @row(), col() get val
      read
      oDbf:refreshcurrent()
      if upper(trim(memvar->aVisible[nCol, 1])) $ upper(indexkey(indexord()))
        lfreshorder = .t.
        lKill_append = .t.
      endif
    else
      cSect = draw_box(8,10,20,70)
      Val = memoedit(Val,9,12,19,68,.t.)
      restsector(cSect)
    endif
    setcolor(cCol)
    setcursor(0)
    if recno() = lastrec() + 1
      dbappend()
      reclock()
      lAppend = .f.
    endif
    eval(oCol:block, Val)
    dbcommit()
  endif
  
  if lKill_append
    lKill_append = .f.
    lAppend = .f.
    if lFreshorder
      nRec = recno()
      oDbf:refreshall()
      while ( !oDbf:stabilize() )
      enddo
      if nRec != recno() + 1
        while nRec != recno()
          oDbf:up()
          while ( !oDbf:stabilize() )
          enddo
        enddo
      endif
      lFreshorder = .f.
      setcursor(0)
    endif
  endif
  
enddo
set deleted on
return

*******************************************************************************
*       skip_edit()
*
function skip_edit(n)
local i
i := 0
if ( LastRec() != 0 )
  if ( n == 0 )
    dbskip(0)
    
  elseif ( n > 0 .and. Recno() != LastRec() + 1 )
    dbunlock()
    memvar->lRlock = .f.
    while ( i < n )
      dbskip(1)
      if ( Eof())
        if memvar->lAppend
          i++
        else
          dbskip(-1)
        endif
        exit
      endif
      i++
    enddo
    
  elseif ( n < 0 )
    dbunlock()
    memvar->lRlock = .f.
    while ( i > n )
      dbskip(-1)
      if ( Bof() )
        exit
      endif
      i--
    enddo
  end
endif
return (i)

*******************************************************************************
procedure pr_rec
local cLine, nCnt, nVal
begin sequence
  openprn()
  for nCnt = 1 to fcount()
    if memvar->pLine > memvar->pr_lines - 2
      prntitle('RECORD VALUES FOR ' + memvar->cDbf,,80)
    endif
    cLine = fieldname(nCnt)
    cLine += space(15-len(cLine))
    nVal = fieldget(nCnt)
    if nVal = NIL
      cLine += 'NIL'
    else
      if valtype(nVal) = 'C'
        cLine += nVal
      elseif valtype(nVal) = 'N'
        cLine += str(nVal)
      elseif valtype(nVal) = 'D'
        cLine += dtoc(nVal)
      endif
    endif
    pr_line(cLine)
  next
  shutprn()
end sequence
return

