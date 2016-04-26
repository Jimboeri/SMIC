*******************************************************************************
* NOTES - Program to provide answers to questions
* Author - Jim West
* 1/2/92
* ----     SET UP SYSTEM DEFAULTS

local aCh := {'View the notes',;
    'Edit the notes',;
    'Print ALL the notes',;
    'Return'}
local cCol, cSect, cSeek, nCnt, nCnt2, cTitle, nEnd

memvar nCh, cNot_title, aPages, nChoice, lRegenerate, aMain_menu
memvar aCall_st, aKey, aMenu, aRecno, aSub_menu, nLevel

#include 'inkey.ch'

private nCh := 1, cNot_title := memvar->cCo_name + ' NOTES'
private aPages := {}
private nChoice := 1, lRegenerate := .t.

private aMain_menu := {}

simhead(memvar->pScr_title)

nCh = get_arr(aCh,,,memvar->white_red,.t.)
if nCh = len(aCh) .or. nCh = 0
  return
endif

if nCh = 2
  if !net_use('dd', .t.)
    return
  endif
  
  cSect = disp_msg(14, memvar->White_red, 'Preparing notes file')
  index on dd->name to dd_name
  restsector(cSect)
  
  close databases
  
  if !net_use('dd', .f.,, 'dd_file', 'dd_name', 'dd_recs')
    return
  endif
else
  if !net_use('dd', .f.,, 'dd_file', 'dd_recs')
    return
  endif
endif

if nCh = 1 .or. nCh = 2
  dbseek('NOTES.NOT')
  private aCall_st := {0}
  private aKey := {'NOTES.NOT'}
  private aMenu := {}
  private aRecno := {}
  private aSub_menu := {}
  
  while !empty(aCall_st)
    simhead(memvar->pScr_title)
    if nCh = 2
      draw_box(8,50,17,75)
      @10,52 say 'Ins = Insert new item'
      @11,52 say 'F9  = Edit Item'
      @12,52 say 'F8  = Create new'
      @13,52 say '        sub-menu'
      @14,52 say 'Del = Delete item'
      @15,52 say 'F7  = Print item'
    else
      draw_box(8,50,12,75)
      @10,52 say 'F7  = Print item'
    endif
    if lRegenerate
      cSeek = trim(atail(aKey))
      aMenu := {}
      aRecno := {}
      aSub_menu := {}
      dbsetorder(1)
      dbseek(cSeek)
      while dd->file = cSeek .and. !eof()
        aadd(aMenu, dd->descriptn)
        aadd(aRecno, recno())
        if dbseek(dd->name)                 // try for sub manu
          aadd(aSub_menu, '*')
        else
          aadd(aSub_menu, ' ')
        endif
        dbgoto(aTail(aRecno))               // return to orig rec
        dbskip()
      enddo
      aadd(aMenu, 'Return')
      nChoice = 1
      lRegenerate = .f.
    endif
    cTitle = if(empty(atail(aCall_st)), 'NOTES ON THE ' + memvar->cCo_name +;
     ' SYSTEM', atail(aCall_st))
    nChoice = get_arr(aMenu,,10 ,,.t. ,cTitle ,nChoice ,,'not_excep')
    if (nChoice = len(aMenu) .and. nextkey() != 3) .or. nChoice = 0
      nEnd = len(aCall_st)
      aSize(aCall_st, nEnd-1)
      aSize(aKey, nEnd-1)
      lRegenerate = .t.
    else                       // selection made
      if nextkey() != 3
        dbgoto(aRecno[nChoice])
        if empty(aSub_menu[nChoice])
          simhead(memvar->pScr_title)
          cCol = setcolor(memvar->white_blue)
          @3,0 clear to 24,79
          @3,0 to 24,79
          @4,20 say dd->descriptn
          memoedit(dd->help, 6, 2, 23, 77, .f.)
          setcolor(cCol)
        else
          aadd(aCall_st, dd->descriptn)
          aadd(aKey, dd->name)
          lRegenerate = .t.
        endif
      endif
    endif
  enddo
else                    // nch = 3 : print
  cSect = draw_box(8,20,18,60)
  @10,25 say 'Printing notes file'
  @12,25 say 'Printing section on :'
  begin sequence
    openprn()
    nLevel := 0
    dbseek('NOTES.NOT')
    while dd->file = 'NOTES.NOT'
      not_print(.t.)
      dbskip()
    enddo
    prntitle(memvar->cCo_name + 'NOTES - INDEX')
    pr_line('     SUBJECT' + space(43) + 'PAGE')
    for nCnt = 1 to len(aPages)
      pr_line(' ')
      pr_line(space(5) + aPages[nCnt, 1] + space(20);
          + str(aPages[nCnt, 2],3))
      pr_line(space(5) + replicate('-', 30))
      for nCnt2 = 1 to len(aPages[nCnt, 3])
        pr_line(space(9) + aPages[nCnt, 3, nCnt2, 1] + space(16);
            + str(aPages[nCnt, 3, nCnt2, 2],3))
      next
    next
    shutprn()
  end sequence
endif
close databases
return

*******************************************************************************
function not_excep(nElem, nRow, nKey_val)
local cSect
memvar aPages, aRecno, nCh, aMenu, aSub_menu, lRegenerate, nLevel
do case
  case nKey_val = K_RETURN
    return (1)
  case nKey_val = K_ESC
    return(0)
  case nKey_val = K_F7                 // F7 = Print
    cSect = draw_box(8,20,18,60)
    @10,25 say 'Printing notes file'
    @12,25 say 'Printing section on :'
    aPages := {}
    dbgoto(aRecno[nElem])
    begin sequence
      openprn()
      nLevel := 0
      not_print(.t.)
      shutprn()
    end sequence
    restsector(cSect)
    keyboard chr(3)                   // arbitary value to test for
    return(2)
  otherwise
    if nCh = 2
      do case
        case nKey_val = K_F9                // F9 = Edit
          if nElem != len(aMenu)            // last field = return
            if empty(aSub_menu[nElem])      // does not have a sub menu
              dbgoto(aRecno[nElem])
              not_edit_item()
              keyboard chr(3)               // arbitary value to test for
              return(1)
            else
              cSect = disp_msg(20,,'Sub-menu exists, cannot edit this item')
              inkey(0)
              restsector(cSect)
              return(2)
            endif
          endif
        case nKey_val = K_INS               // Ins
          not_ins_item(nElem)
          keyboard chr(3)                   // arbitary value to test for
          lRegenerate = .t.
          return(1)
        case nKey_val = K_F8                // F8 create sub menu
          if nElem != len(aMenu)            // last field = return
            if empty(aSub_menu[nElem])
              not_Sub_menu(nElem)
              keyboard chr(3)                   // arbitary value to test for
              lRegenerate = .t.
              return(1)
            else
              cSect = disp_msg(20,,'Sub-menu exists, cannot add another')
              inkey(0)
              restsector(cSect)
              return(2)
            endif
          endif
        case nKey_val = K_DEL                 // Del - delete
          if nElem != len(aMenu)            // last field = return
            if empty(aSub_menu[nElem])
              not_del_item(nElem)
              keyboard chr(3)                   // arbitary value to test for
              lRegenerate = .t.
              return(1)
            else
              cSect = disp_msg(20,,'Sub-menu exists, cannot Delete')
              inkey(0)
              restsector(cSect)
              return(2)
            endif
          endif
      endcase
    else
      return(2)
    endif
endcase
return (2)

*******************************************************************************
static procedure not_ins_item(nIn_elem)
local cFl, nCurr, nPrev, nMiddle, nRec
memvar aMenu, aRecno
if make_sure(,,'Add new item to this menu (Y/N) ?')
  if nIn_elem != len(aMenu)
    dbgoto(aRecno[nIn_elem])
    cFl = dd->file
    nCurr = not_nm_num(dd->name)
    dbskip(-1)
    if cFl = dd->file
      nPrev = not_nm_num(dd->name)
    else
      nPrev = 1
    endif
  else
    nCurr = 90000000
    dbgoto(aRecno[len(aMenu)-1])
    cFl = dd->file
    nPrev = not_nm_num(dd->name)
  endif
  nMiddle = int((nCurr - nPrev) / 2) + nPrev
  dbsetorder(2)
  while dbseek(not_num_nm(nMiddle))
    nMiddle++
  enddo
  dbgoto(lastrec())
  nRec = dd->rec_code
  nRec++
  dbappend()
  reclock('DD')
  dd->file := cFl
  dd->name := not_num_nm(nMiddle)
  dd->rec_code := nRec
  unlock
  commit
  not_edit_item()
endif
return

*******************************************************************************
static procedure not_sub_menu(nIn_elem)
local cFl, nMiddle, nRec
memvar aMenu, aRecno, aKey, aCall_st
if nIn_elem != len(aMenu)
  if make_sure(20,,'Create a sub-menu for this item (Y/N) ?')
    dbgoto(aRecno[nIn_elem])
    cFl = dd->name
    nMiddle = 55555555
    dbsetorder(2)
    while dbseek(not_num_nm(nMiddle))
      nMiddle++
    enddo
    dbgoto(lastrec())
    nRec = dd->rec_code
    nRec++
    dbappend()
    reclock('DD')
    dd->file := cFl
    dd->name := not_num_nm(nMiddle)
    dd->rec_code := nRec
    unlock
    commit
    not_edit_item()
    aadd(aCall_st, dd->descriptn)
    aadd(aKey, cFl)
  endif
endif
return

*******************************************************************************
static procedure not_del_item(nIn_elem)
local nLen_st
memvar aRecno, aMenu, aCall_st, aKey
if nIn_elem != len(aMenu)
  if make_sure(,,'Delete this item from the menu (Y/N) ?')
    select dd
    dbgoto(aRecno[nIn_elem])
    reclock('DD')
    dbdelete()
    dbunlock()
    if len(aMenu) = 2           // only one choice
      nLen_st = len(aCall_st)
      aSize(aCall_st, nLen_st - 1)
      aSize(aKey, nLen_st - 1)
    endif
  endif
endif
return

***********************************************************
static function not_nm_num(cIn_name)
local cChars, nAt
nAt = at('.', cIn_name)
cChars = substr(cIn_name,1,nAt-1)
return (val(cChars))

***********************************************************
static function not_num_nm(nIn_num)
local cName
cName = ltrim(str(nIn_num,8,0))
cName = replicate('0', 8-len(cName)) + cName + '.NOT'
return ( cName)


***********************************************************
static procedure not_edit_item()
local cDescr, mHelp, cSave_col, cSect, nCurs_save, lIns
memvar getlist
cDescr = dd->descriptn
mHelp = dd->help
cSect = savesector(0,0,24,79)
cSave_col = setcolor(memvar->blue_cyan)                 // save colour for later
nCurs_save = setcursor(1)                       // save cursor & force one

@3,0 clear to 24,79
@3,0 to 24,79
@4,10 say dd->descriptn
memoedit(dd->help, 6, 2, 23, 77, .f., .f.)
while .t.
  @4,10 get cDescr             // get description
  read
  if !empty(cDescr)
    exit
  endif
enddo

@4,65 say 'F10 to finish'
while .t.
  lIns = readinsert(.t.)
  mHelp = memoedit(mHelp, 6, 2, 23, 77, .t., 'notes_udf')
  readinsert(lIns)
  if !empty(mHelp)
    exit
  endif
enddo
reclock('Data dictionary')                      // store vars back to fields
dd->descriptn := cDescr
dd->help := trim(mHelp)
unlock
setcolor(cSave_col)
setcursor(nCurs_save)
restsector(cSect)
return

*f**********************************************************
* I wrote this udf as memoedit sometimes would not finish
* with Ctrl W or Esc so I redefined F10 as Ctrl W and F9 as Esc

function notes_udf (pMode, pLine, pCol)
local nRet := 0, nPage, nOn_page := 55, nLine
if readinsert()
  @4,48 say '<insert>'
else
  @4,48 say '        '
endif
nPage = int(pLine / nOn_page) + 1
nLine = pLine - ((nPage-1) * nOn_page)
if nLine = 0
  nLine = nOn_page
  nPage--
endif
@24,50 say 'Page - ' + str(nPage,2) + ' Line - ' + str(nLine,2)
if pMode = 1 .or. pMode = 2
  do case
    case lastkey() = K_CTRL_END
      nret = K_CTRL_END
    case lastkey() = K_ESC
      nret = K_ESC
    case lastkey() = K_F10
      nret = K_CTRL_END
    case lastkey() = K_F9
      nret = K_ESC
  endcase
endif
return(nRet)

*f*****************************************************************************
procedure not_print (lHeading)
local nRec, cName, cFile, nCnt, cText, nText_cnt, cDescr, nLen
memvar cNot_title, nLevel, aPages, pPage, pLine

nRec := recno()
cName = dd->name
cDescr = dd->descriptn
cFile = dd->file
@14,25 say dd->descriptn
if lHeading
  prntitle(cNot_title)
endif
if nLevel = 0
  aadd(aPages, {cDescr, pPage, {}})
else
  nLen = len(aPages)
  aadd(aPages[nLen,3], {cDescr, pPage})
endif
if dbseek(cName)
  pr_line(' ')
  pr_line(cDescr)
  pr_line(replicate('=', 30))
  nLevel++
  while cName = dd->file .and. !eof()
    not_print(.f.)
    dbskip()
  enddo
  nLevel--
else
  dbgoto(nRec)
  cText = dd->help
  nText_cnt = mlcount(cText, 76)
  if (nText_cnt + pLine) > 58 .and. pLine > 7
    prntitle(cNot_title)
  endif
  pr_line(' ')
  pr_line(dd->descriptn)
  pr_line(replicate('=', 30))
  
  for nCnt = 1 to nText_cnt
    if pLine > 60
      prntitle(cNot_title)
      pr_line(' ')
      pr_line(dd->descriptn)
      pr_line(replicate('=', 30))
    endif
    pr_line(memoline(cText, 76, nCnt))
  next
  if pLine > 55
    pr_line(' ')
    pr_line(' ')
    pr_line(' ')
  endif
endif
dbgoto(nRec)
return

