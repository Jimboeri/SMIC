*******************************************************************************
*
* DBFMENU1 - control database functions
*
memvar lNtx
memvar lDbf
memvar lRedraw
memvar cDbf_col
memvar cNtx_col
memvar aVisible
memvar aOther
memvar oDbf
memvar nDbf_inx
memvar cDbf
memvar cAlias
memvar aNtx
memvar aNtx_descr
memvar oNtx
memvar aNtx_area
memvar nNtx_inx
memvar cScr_bott
memvar nDbf_win

local lSave_visible
local cCol
local cSect
local nEvent
local cScreen
local nCnt
local cString
local aOth_name
local nBottom
#include 'mouse.ch'
#include 'inkey.ch'
#include 'event.ch'

#define MY_HSEP         "ÄÂÄ"
#define MY_CSEP         " ³ "
#define MY_FSEP         "ÄÁÄ"

lNtx := .f.
lDbf := lRedraw := .t.
private aVisible := {}, aOther := {}, oDbf, nDbf_inx := nNtx_inx := 1
private aNtx := aNtx_descr := {}, oNtx
cDbf_col := memvar->BLACK_GREEN
cNtx_col := setcolor()
private aNtx_area := {0,0,0,0}
private cDbf, cAlias

if .f.
  do ntx_proc           // compile index procedures
endif

* setup mouse hotspots
memvar->oMouse[MI_HOTSPOT] := {}

* Event - 1 - DBF_SELECT
aadd(memvar->oMouse[MI_HOTSPOT], {14, 40, 16, 53 ,'sS', .t.})

* Event - 2 - ESCAPE
aadd(memvar->oMouse[MI_HOTSPOT], {18, 40, 20, 49 ,chr(K_ESC), .t.})

* Event - 3 - DBF_EDIT
aadd(memvar->oMouse[MI_HOTSPOT], {14, 58, 16, 65 ,'eE', .t.})

* Event - 4 - DBF_MODIFY
aadd(memvar->oMouse[MI_HOTSPOT], {14, 69, 16, 78 ,'mM', .t.})

* Event - 5 - DBF_PRINT
aadd(memvar->oMouse[MI_HOTSPOT], {18, 69, 20, 77 ,'pP', .t.})

* Event - 6 - DBF_UTILITIES
aadd(memvar->oMouse[MI_HOTSPOT], {18, 53, 20, 65 ,'uU', .t.})

* Event - 7 - DBF_INS
aadd(memvar->oMouse[MI_HOTSPOT], {22, 4, 24, 33 ,chr(K_INS), .t.})

* Event - 8 - DBF_DEL
aadd(memvar->oMouse[MI_HOTSPOT], {22, 40, 24, 71 ,chr(K_DEL), .t.})

* Event - 9 - NTX_ACTIVATE
aadd(memvar->oMouse[MI_HOTSPOT], {14, 56, 16, 79 ,'aA', .f.})

* Event - 10 - NTX_REINDEX
aadd(memvar->oMouse[MI_HOTSPOT], {18, 53, 20, 65 ,'rR', .f.})

* Event - 11 - NTX_CREATE
aadd(memvar->oMouse[MI_HOTSPOT], {18, 68, 20, 77 ,'cC', .f.})

* Event - 12 - NTX_INS
aadd(memvar->oMouse[MI_HOTSPOT], {22, 3, 24, 28 ,chr(K_INS), .t.})

* Event - 13 - NTX_DEL
aadd(memvar->oMouse[MI_HOTSPOT], {22, 32, 24, 53 ,chr(K_DEL), .t.})

* Event - 14 - NTX_ORDER
aadd(memvar->oMouse[MI_HOTSPOT], {22, 57, 24, 75 ,'oO', .t.})

lSave_visible := memvar->oMouse[MI_VISIBLE]
if !lSave_visible
  m_show(memvar->oMouse)
endif

do dbfsel
if empty(cDbf)
  return
endif

ntx_activate()

jw_screen('DATABASE UTILITY PROGRAM')
nBottom = 3 + len(aVisible)   // bottom
nBottom = if(nBottom > 21, 21, nBottom)
nDbf_win = wopen(3, 1, nBottom , 36)
setcolor(memvar->BLACK_GREEN)
wbox(1)
setup_dbf()

while .t.
  if lRedraw
    cScr_bott = savesector(22,0,24,79)
    cCol = setcolor()

    if lDbf
      cDbf_col = memvar->BLACK_GREEN
    else
      cDbf_col = cCol
    endif
    wselect(nDbf_win)
    setcolor(cDbf_col)
    @0,0 clear
    @0,0 say center(cDbf)
    @2,0 say replicate('Ä', maxcol()+1)
    oDbf:refreshall()
    while ( !oDbf:stabilize() )
      *      xx = 1
    enddo
    
    aNtx_area[1] := 5         // top
    aNtx_area[2] := 42        // left
    aNtx_area[4] := 76        // right
    aNtx_area[3] = aNtx_area[1] + 2 + len(aNtx)  // bottom
    if len(aNtx) = 0
      aNtx_area[3]++
    endif
    aNtx_area[3] = if(aNtx_area[3] > 12, 12, aNtx_area[3])
    if lNtx
      cNtx_col = memvar->BLACK_GREEN
    else
      cNtx_col = cCol
    endif
    setup_ntx()
    
    setcolor(cNtx_col)
    cSect = draw_box(aNtx_area[1] - 2, aNtx_area[2] - 1, aNtx_area[3] ,;
        aNtx_area[4] + 1)
    @aNtx_area[1] - 1, aNtx_area[2] + 10 say 'OPEN INDEXES'
    @aNtx_area[1] + 1, aNtx_area[2] - 1 say'Ã'
    @aNtx_area[1] + 1, aNtx_area[2] say replicate('Ä',;
        aNtx_area[4] - aNtx_area[2] + 1)
    @aNtx_area[1] + 1, aNtx_area[4] + 1 say'´'
    if len(aNtx) > 0
      oNtx:refreshall()
      while ( !oNtx:stabilize() )
        *        xx = 1
      enddo
    endif
    
    setcolor(cCol)
    if lDbf
      mouse_box(DBF_EDIT ,'Edit')
      memvar->oMouse[MI_HOTSPOT, DBF_EDIT, HS_ACTIVE] := .t.
      
      mouse_box(DBF_PRINT ,'Print')
      memvar->oMouse[MI_HOTSPOT, DBF_PRINT, HS_ACTIVE] := .t.
      
      mouse_box(DBF_UTILITIES ,'Utilities')
      memvar->oMouse[MI_HOTSPOT, DBF_UTILITIES, HS_ACTIVE] := .t.
      
      mouse_box(DBF_MODIFY ,'Modify')
      memvar->oMouse[MI_HOTSPOT, DBF_MODIFY, HS_ACTIVE] := .t.
      
      memvar->oMouse[MI_HOTSPOT, NTX_ACTIVATE, HS_ACTIVE] := .f.
      memvar->oMouse[MI_HOTSPOT, NTX_REINDEX, HS_ACTIVE] := .f.
      memvar->oMouse[MI_HOTSPOT, NTX_CREATE, HS_ACTIVE] := .f.
      memvar->oMouse[MI_HOTSPOT, NTX_INS, HS_ACTIVE] := .f.
      memvar->oMouse[MI_HOTSPOT, NTX_DEL, HS_ACTIVE] := .f.
      
      dbf_bott_msg()
    else
      mouse_box(NTX_ACTIVATE ,'Activate ass indices')
      memvar->oMouse[MI_HOTSPOT, NTX_ACTIVATE, HS_ACTIVE] := .t.
      
      mouse_box(NTX_CREATE ,'Create')
      memvar->oMouse[MI_HOTSPOT, NTX_CREATE, HS_ACTIVE] := .t.
      
      if len(aNtx) > 0
        mouse_box(NTX_REINDEX ,'Reindex')
        memvar->oMouse[MI_HOTSPOT, NTX_REINDEX, HS_ACTIVE] := .t.
      else
        memvar->oMouse[MI_HOTSPOT, NTX_REINDEX, HS_ACTIVE] := .f.
      endif
      
      memvar->oMouse[MI_HOTSPOT, DBF_EDIT, HS_ACTIVE] := .f.
      memvar->oMouse[MI_HOTSPOT, DBF_PRINT, HS_ACTIVE] := .f.
      memvar->oMouse[MI_HOTSPOT, DBF_UTILITIES, HS_ACTIVE] := .f.
      memvar->oMouse[MI_HOTSPOT, DBF_MODIFY, HS_ACTIVE] := .f.
      memvar->oMouse[MI_HOTSPOT, DBF_INS, HS_ACTIVE] := .f.
      memvar->oMouse[MI_HOTSPOT, DBF_DEL, HS_ACTIVE] := .f.
      ntx_bott_msg()
      
    endif
    mouse_box(DBF_SELECT, 'Select DBF')
    mouse_box(ESCAPE ,'Escape')
    
    lRedraw = .f.
  endif
  
  if lDbf .and. len(aVisible) > 0
    while ( !oDbf:stabilize() )
      *      xx = 1
    enddo
  endif
  
  if lNtx .and. len(aNtx) > 0
    while ( !oNtx:stabilize() )
      *      xx = 1
    enddo
    dbsetorder(nNtx_inx)
  endif
  
  nEvent = db_mnu_act()
  
  do case
    case nEvent = DBF_SELECT
      do dbfsel
      ntx_activate()
      nDbf_inx = 1
      lRedraw = .t.
      
    case nEvent = ESCAPE
      exit
      
    case nEvent = TAB_DBF
      lDbf = .t.
      lNtx = .f.
      lRedraw = .t.
      
    case nEvent = TAB_NTX
      lNtx = .t.
      lDbf = .f.
      lRedraw = .t.
      
    case nEvent = DBF_EDIT
      save screen to cScreen
      do dbfedit
      restore screen from cScreen
      
    case nEvent = DBF_MODIFY
      do dbfstru
      
    case nEvent = DBF_PRINT
      save screen to cScreen
      do dbfprnt
      restore screen from cScreen
      
    case nEvent = DBF_INS
      if len(aOther) != 0
        aOth_name := {}
        for nCnt = 1 to len(aOther)
          cString = aOther[nCnt, 1]
          cString += space(12 - len(cString))
          cString += aOther[nCnt, 2] + '  ' + str(aOther[nCnt, 3],4)
          if aOther[nCnt, 2] = 'N'
            cString += '  ' + str(aOther[nCnt, 4],2)
          endif
          aadd(aOth_name, cString)
        next
        nCnt = mget_arr(aOth_name, 4, 45, memvar->GREEN_BLACK, .t.)
        if nCnt != 0
          aadd(aVisible, {})
          ains(aVisible, nDbf_inx)
          aVisible[nDbf_inx] = aclone(aOther[nCnt])
          aremove(aOther, nCnt)
          oDbf:refreshall()
        endif
      endif
      dbf_bott_msg()
      
    case nEvent = DBF_DEL
      if len(aVisible) > 0
        aadd(aOther, aclone(aVisible[nDbf_inx]))
        aremove(aVisible, nDbf_inx)
      endif
      oDbf:refreshall()
      dbf_bott_msg()
      
    case nEvent = DBF_UTILITIES
      save screen to cScreen
      do dbf_util
      restore screen from cScreen
      
    case nEvent = DBF_DOWN
      oDbf:down()
    case nEvent = DBF_UP
      oDbf:up()
    case nEvent = DBF_PGDN
      oDbf:pagedown()
    case nEvent = DBF_PGUP
      oDbf:pageup()
    case nEvent = DBF_HOME
      oDbf:gotop()
    case nEvent = DBF_END
      oDbf:gobottom()
      
    case nEvent = NTX_ACTIVATE
      ntx_activate()
      lRedraw = .t.
      
    case nEvent = NTX_REINDEX
      ntx_reindex()
      
    case nEvent = NTX_DEL
      ntx_close(nNtx_inx)
      lRedraw = .t.
      
    case nEvent = NTX_CREATE
      ntx_create()
      lRedraw = .t.
      
    case nEvent = NTX_INS
      ntx_add()
      lRedraw = .t.
      
    case nEvent = NTX_ORDER
      ntx_order()
      lRedraw = .t.
      
    case nEvent = NTX_DOWN
      oNtx:down()
    case nEvent = NTX_UP
      oNtx:up()
    case nEvent = NTX_PGDN
      oNtx:pagedown()
    case nEvent = NTX_PGUP
      oNtx:pageup()
    case nEvent = NTX_HOME
      oNtx:gotop()
    case nEvent = NTX_END
      oNtx:gobottom()
      
  endcase
enddo
wselect(nDbf_win)
wclose()
return

*f*****************************************************************************
procedure setup_dbf()
local oColumn
memvar oDbf
memvar nDbf_win

wselect(nDbf_win)

/* make new DBF browse object  -  oDbf declared in dbfmenu1 */
oDbf := TBrowseDB(1, 0, maxrow(), maxcol())

/* default heading and column separators */
oDbf:headSep := MY_HSEP
oDbf:colSep := MY_CSEP
oDbf:footSep := MY_FSEP

/* add custom 'skip_curr' (to handle append mode) */
oDbf:skipBlock := {|x| move_dbf(x)}

/* add a column for display */
oColumn := TBColumnNew( 'FIELD', {|| memvar->aVisible[memvar->nDbf_inx, 1]} )
oColumn:width := 11
oDbf:addColumn(oColumn)

/* add a column for display */
oColumn := TBColumnNew( 'TYPE', {|| memvar->aVisible[memvar->nDbf_inx, 2]} )
oDbf:addColumn(oColumn)

/* add a column for display */
oColumn := TBColumnNew( 'LEN', {|| str(memvar->aVisible[memvar->nDbf_inx, 3],4,0)} )
oDbf:addColumn(oColumn)

/* add a column for display */
oColumn := TBColumnNew( 'DEC', {|| str(memvar->aVisible[memvar->nDbf_inx, 4],2,0)} )
oDbf:addColumn(oColumn)

/* set colour */
oDbf:colorspec := memvar->cDbf_col

return

*******************************************************************************
*       skip_dbf()
*

func move_dbf(nMove)
local nCnt

nCnt := 0
if ( len(memvar->aVisible) != 0 )
  if ( nMove > 0)
    while ( nCnt < nMove )
      memvar->nDbf_inx++
      if ( memvar->nDbf_inx > len(memvar->aVisible))
        memvar->nDbf_inx--
        exit
      endif
      nCnt++
    enddo
    
  elseif ( nMove < 0 )
    while ( nCnt > nMove )
      memvar->nDbf_inx--
      if ( memvar->nDbf_inx < 1)
        memvar->nDbf_inx++
        exit
      endif
      nCnt--
    enddo
  endif
endif
return (nCnt)

*f*****************************************************************************
function db_mnu_act()
local nReturn := 0, nCurs, lCont, nKey, nCnt, nButton, aArea
if memvar->lDbf .and. in_area(memvar->oMouse, memvar->aNtx_area)
  return(TAB_NTX)
endif
if memvar->lNtx .and. in_area(memvar->oMouse, memvar->aDbf_area)
  return(TAB_DBF)
endif

nCurs = setcursor(0)
m_show(memvar->oMouse)
lCont = .t.
while lCont
  nKey = inkey()
  if nKey != 0
    for nCnt = 1 to len(memvar->oMouse[MI_HOTSPOT])
      if chr(nKey) $ memvar->oMouse[MI_HOTSPOT, nCnt, HS_CHAR];
            .and. memvar->oMouse[MI_HOTSPOT, nCnt, HS_ACTIVE]
        return(nCnt)
      endif
    next
    if nKey = K_TAB
      if memvar->lDbf
        return(TAB_NTX)
      else
        return(TAB_DBF)
      endif
    endif
    
    if memvar->lDbf
      do case
        case nKey = K_DOWN
          return(DBF_DOWN)
        case nKey = K_UP
          return(DBF_UP)
        case nKey = K_PGDN
          return(DBF_PGDN)
        case nKey = K_PGUP
          return(DBF_PGUP)
        case nKey = K_HOME .or. nKey = K_CTRL_PGUP
          return(DBF_HOME)
        case nKey = K_END .or. nKey = K_CTRL_PGDN
          return(DBF_END)
        case nKey = K_INS
          return(DBF_INS)
        case nKey = K_DEL
          return(DBF_DEL)
      endcase
    endif
    if memvar->lNtx
      do case
        case nKey = K_DOWN
          return(NTX_DOWN)
        case nKey = K_UP
          return(NTX_UP)
        case nKey = K_PGDN
          return(NTX_PGDN)
        case nKey = K_PGUP
          return(NTX_PGUP)
        case nKey = K_HOME .or. nKey = K_CTRL_PGUP
          return(NTX_HOME)
        case nKey = K_END .or. nKey = K_CTRL_PGDN
          return(NTX_END)
        case nKey = K_INS
          return(NTX_INS)
        case nKey = K_DEL
          return(NTX_DEL)
      endcase
    endif
  else
    m_info(memvar->oMouse)
    // display time
    if memvar->oMouse[MI_BUTTON] != 0
      nButton := memvar->oMouse[MI_BUTTON]
      while memvar->oMouse[MI_BUTTON] = nButton       // for the heavy handed
        m_info(memvar->oMouse)
      enddo
      for nCnt = 1 to len(memvar->oMouse[MI_HOTSPOT])
        if memvar->oMouse[MI_HOTSPOT, nCnt, HS_ACTIVE]
          aArea := {memvar->oMouse[MI_HOTSPOT, nCnt, HS_TOP],;  // set up search area
          memvar->oMouse[MI_HOTSPOT, nCnt, HS_LEFT],;
              memvar->oMouse[MI_HOTSPOT, nCnt, HS_BOTT],;
              memvar->oMouse[MI_HOTSPOT, nCnt, HS_RIGHT]}
          if in_area(memvar->oMouse, aArea)
            lCont = .f.
            nReturn = nCnt
            exit
          endif
        endif
      next
      if memvar->lDbf .and. in_area(memvar->oMouse, memvar->aNtx_area)
        lCont = .f.
        nReturn = TAB_NTX
      endif
      if memvar->lNtx .and. in_area(memvar->oMouse, memvar->aDbf_area)
        lCont = .f.
        nReturn = TAB_DBF
      endif
    endif
  endif
enddo
setcursor(nCurs)
m_Hide(memvar->oMouse)
return(nReturn)
* eof()

*f*****************************************************************************
procedure mouse_box(nEvent, cMsg)
local cCol, nLen
cCol = setcolor(memvar->WHITE_RED)
nLen = len(cMsg)
@memvar->oMouse[MI_HOTSPOT, nEvent, 1], memvar->oMouse[MI_HOTSPOT, nEvent, 2] clear to;
    memvar->oMouse[MI_HOTSPOT, nEvent, 3], memvar->oMouse[MI_HOTSPOT, nEvent, 4]
@memvar->oMouse[MI_HOTSPOT, nEvent, 1], memvar->oMouse[MI_HOTSPOT, nEvent, 2] to;
    memvar->oMouse[MI_HOTSPOT, nEvent, 3], memvar->oMouse[MI_HOTSPOT, nEvent, 4]
@memvar->oMouse[MI_HOTSPOT, nEvent, 1] + 1, memvar->oMouse[MI_HOTSPOT, nEvent, 2] + 3;
    say substr(cMsg,2,nlen-1)
setcolor(memvar->YELL_RED)
@memvar->oMouse[MI_HOTSPOT, nEvent, 1] + 1, memvar->oMouse[MI_HOTSPOT, nEvent, 2] + 2;
    say substr(cMsg,1,1)
setcolor(cCol)
return

*******************************************************************************
function in_area ( aIn_mouse, aIn_area)
local lInside := .t.
if (aIn_mouse[MI_Y] < aIn_area[1]) .or.;
      (aIn_mouse[MI_Y] > aIn_area[3])
  lInSide = .f.
endif
if (aIn_mouse[MI_X] < aIn_area[2]) .or.;
      (aIn_mouse[MI_X] > aIn_area[4])
  lInSide = .f.
endif
return (lInside)

*******************************************************************************
procedure dbf_bott_msg
restsector(memvar->cScr_bott)
if len(memvar->aOther) > 0
  mouse_box(DBF_INS ,'Ins - Insert field in list')
  memvar->oMouse[MI_HOTSPOT, DBF_INS, HS_ACTIVE] := .t.
else
  memvar->oMouse[MI_HOTSPOT, DBF_INS, HS_ACTIVE] := .f.
endif

if len(memvar->aVisible) > 0
  mouse_box(DBF_DEL ,'Del - Remove field From list')
  memvar->oMouse[MI_HOTSPOT, DBF_DEL, HS_ACTIVE] := .t.
else
  memvar->oMouse[MI_HOTSPOT, DBF_DEL, HS_ACTIVE] := .f.
endif
return
