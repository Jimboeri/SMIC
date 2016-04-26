*****
*
*       anylook.prg
*       Returns an existing baule from the file selected
*       Note:  compile with /n/w/a
*

#include "inkey.ch"
#include "setcurs.ch"
#include "mouse.ch"

#define MY_HSEP         "ÄÂÄ"
#define MY_CSEP         " ³ "
#define MY_FSEP         "ÄÁÄ"

****
*
*

function anyseek(cDatabase, aDisp_fields, lSearch, cOrig_key)

local column, n, pol_var,cSeek := '', nRow, nPerc
local cColorSave, nCursSave, cSectSave, cSect1, lSave_visible
local nKey, cOrig_val
private pick, lKey_search
private nTop, nLeft, nBott, nRight, bAction
private cRet_val, lMore, cFilter

lKey_search = if(valtype(lSearch) = 'L', lSearch, .f.)
cFilter = cOrig_key
nTop = 5
nBott = if(lKey_search, 20, 21)
nRight = 75

ret_var = readvar()
cOrig_val = if(!empty(ret_var), &ret_var, '')

bPgup      = setkey(K_PGUP, nil)
bPgdn      = setkey(K_PGDN, nil)
bCtrl_Pgdn = setkey(K_CTRL_PGDN, nil)
bEsc       = setkey(K_ESC, nil)

select &cDatabase
dbgotop()
if lKey_search
  if cFilter = NIL
    dbseek(cOrig_val, .t.)
  else
    dbseek(cFilter + cOrig_val, .t.)
  endif
endif
if bof() .or. (!empty(cOrig_key) .and. !dbseek(cOrig_key))
  cSect1 = disp_msg(14,white_red, 'Nothing found !')
  inkey(0)
  restsector(cSect1)
  if !empty(ret_var)
    &ret_var := space(len(&ret_var))
  endif
  SetCursor(nCursSave)
  return('')
endif

/* analyse fields to be displayed */
aStru = dbstruct()

lClose_dd = .t.
if select('DD') = 0
  select 191
  if !net_use('dd', .f.,,'dd_file')
    return
  endif
else
  select dd
  lClose_dd = .f.
endif
for nCnt = 1 to len(aStru)
  cData = trim(upper(cDatabase)) + '.DBF'
  cData += space(15 - len(cData))
  if dbseek(cData + upper(aStru[nCnt, 1]) + space(15-len(aStru[nCnt, 1])))
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

select &cDatabase
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
pick := TBrowseDB(nTop, nLeft, nBott, nRight)

cColorSave := SetColor(black_white)
if lKey_search
  cSectSave = draw_box(nTop-1, nLeft-1, nBott+2, nRight+1)
  @nBott, nLeft say replicate('Ä', nRight - nLeft)
  @nBott, nLeft-1 say 'Ã'
  @nBott, nRight+1 say '´'
else
  cSectSave = draw_box(nTop-1, nLeft-1, nBott, nRight+1)
endif
@nTop-1,nLeft-1 say ''
@nTop+1,nRight+1 say '´'
nCursSave := SetCursor(0)

/* default heading and column separators */
pick:headSep := MY_HSEP
pick:colSep := MY_CSEP
pick:footSep := MY_FSEP

/* add custom 'skipper' (to handle append mode) */
pick:skipBlock := {|x| Skip_any(x)}

/* colors */
pick:colorSpec := BLACK_WHITE

for nCnt = 1 to len(aDisp_stru)
  test_name = aDisp_stru[nCnt, 1]
  column := TBColumnNew( aDisp_stru[nCnt, 2],;
      fieldwblock(aDisp_stru[nCnt, 1], nArea))
  pick:addColumn(column)
next

/* mouse */
lSave_visible := oMouse[MI_VISIBLE]
if !lSave_visible
  m_show(oMouse)
endif

lMore := .t.
while (lMore)
  
  /* stabilize the display */
  lM_Curs = oMouse[MI_VISIBLE]
  m_hide(oMouse)
  nKey = 0
  while ( !pick:stabilize() )
    nKey := InKey()
    if ( nKey != 0 )
      exit                    /* (abort if a key is waiting) */
    endif
  enddo
  
  if lM_Curs
    m_show(oMouse)
  endif
  
  if ( pick:stable )
    /* display is stable */
    if ( pick:hitTop .or. pick:hitBottom )
      Tone(125, 0)
    end
    
    /* everything's done; just wait for a key */
    if nKey = 0
      mAny_act()
      if oMouse[MI_CLICKS] = 0
        nKey := oMouse[MI_ASCII]
      else
        nKey = 0
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
      pick:down()
      
    case ( nKey == K_UP )
      cSeek = ''
      pick:up()
      
    case ( nKey == K_PGDN )
      cSeek = ''
      pick:pageDown()
      
    case ( nKey == K_PGUP )
      cSeek = ''
      pick:pageUp()
      
    case ( nKey == K_CTRL_PGUP ) .or. ( nKey == K_HOME )
      cSeek = ''
      pick:goTop()
      
    case ( nKey == K_CTRL_PGDN ) .or. ( nKey == K_END )
      cSeek = ''
      pick:goBottom()
      
    case ( nKey == K_ESC )
      cRet_val = cOrig_val
      lMore := .f.
      
    case ( nKey == K_RETURN )
      cRet_val = fieldget(aDisp_fields[1])
      lMore := .f.
      
    otherwise
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
          pick:refreshall()
        endif
      else
        do case
          case ( nKey == K_LEFT )
            pick:left()
          case ( nKey == K_RIGHT )
            pick:right()
          case ( nKey == K_CTRL_LEFT )
            pick:panleft()
          case ( nKey == K_CTRL_RIGHT )
            pick:panright()
        endcase
      endif                             // search available
  endcase
  if lKey_search
    setcolor(white_black)
    @nBott+1, nLeft+3 say cSeek + space(len(&cInd_key) - len(cSeek))
    setcolor(black_white)
  endif
enddo

if !lSave_visible
  m_hide(oMouse)
endif
if !empty(ret_var)
  &ret_var := cRet_val
endif

setkey(K_PGUP, bPgup)
setkey(K_PGDN, bPgdn)
setkey(K_CTRL_PGUP, bCtrl_Pgdn)
setkey(K_ESC, bEsc)

setcolor(cColorSave)
SetCursor(nCursSave)
restsector(cSectSave)
return(cRet_val)


****
*       skip_any()
*

func skip_any(n)
local i

i := 0
if ( LastRec() != 0 )
  if ( n == 0 )
    dbskip(0)
    
  elseif ( n > 0 .and. Recno() != LastRec() + 1 )
    while ( i < n )
      dbskip(1)
      if ( Eof() .or. (cFilter != nil .and. &cInd_key != cFilter))
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
      if (cFilter != nil .and. &cInd_key != cFilter)
        dbskip(1)
        exit
      endif
      i--
    enddo
  end
endif
return (i)

*f*********************************************************
procedure mAny_act
local nY, nX, nM_Y, nM_x, nButton, nOldButton, nTime, nASCII, cCol1
nY = nM_Y
nX = nM_X
if oMouse[MI_CLICKS] = 2       // stabilize after double click
  oMouse[MI_CLICKS] = 0
  oMouse[MI_ASCII] = K_ENTER    // process enter key
  return
endif
oMouse[MI_CLICKS] = 0
oMouse[MI_ASCII] = 0
while .t.
  if keypressed()                     // keyboard used
    oMouse[MI_ASCII] = inkey()
    exit
  endif
  m_info(oMouse)
  nButton = oMouse[MI_BUTTON]
  // display time
  cCol1 = setcolor(yell_blue)
  @1,2 say time()
  setcolor(cCol1)
  
  
  if nButton != 0
    if (oMouse[MI_Y] >= nTop+2) .and. (oMouse[MI_Y] <= nBott) .and.;
          (oMouse[MI_X] >= nLeft) .and. (oMouse[MI_X] <= nRight)
      * browse area
      if oMouse[MI_CLICKS] = 0
        while oMouse[MI_BUTTON] = nButton
          m_info(oMouse)
        enddo
        nY = oMouse[MI_Y]
        nX = oMouse[MI_X]
        nTime = seconds()
        oMouse[MI_CLICKS] = 1
      endif
      
      if oMouse[MI_CLICKS] = 1
        while stopwatch(nTime, seconds()) < oMouse[MI_DELAY]
          m_info(oMouse)
          if oMouse[MI_BUTTON] = nButton .and. oMouse[MI_Y] = nY .and.;
                (oMouse[MI_X] >= nLeft) .and. (oMouse[MI_X] <= nRight)
            oMouse[MI_CLICKS] = 2
            exit
          endif
        enddo
      endif
      
      if oMouse[MI_CLICKS] > 0
        nNew_row = nY - pick:nTop - 1
        if nNew_row != pick:rowpos
          if nNew_row > pick:rowpos
            for nCnt = 1 to nNew_row - pick:rowpos
              pick:down()
            next
          elseif nNew_row < pick:rowpos
            for nCnt = 1 to pick:rowpos - nNew_row
              pick:up()
            next
          endif
        endif
        exit
      endif
    endif                     // in browse area
    
    if (oMouse[MI_Y] = nTop-1) .and. (oMouse[MI_X] = nLeft-1)
      while oMouse[MI_BUTTON] = nButton
        m_info(oMouse)
      enddo
      oMouse[MI_CLICKS] = 0
      oMouse[MI_ASCII] = K_ESC    // process escape block
      exit
    endif                   // escape block
    
  endif                       // button down
enddo
return(0)
