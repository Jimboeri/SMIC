*******************************************************************************
* NOTES - Program to provide answers to questions
* Author - Jim West
* 1/2/92
* ----     SET UP SYSTEM DEFAULTS

parameters cExt, cTitle, lEdit

local aCh := {'View the notes', 'Edit the notes', 'Print ALL the notes',;
    'Return'}
local cCol, lClose_dd, lEdit_acc, cSeek, nEnd, nCnt, nCnt2
local nHeight

memvar nCh, aPages, nChoice, lRegenerate, cExtension
memvar cExt, cTitle, lEdit
memvar cNot_title               // private var
memvar aMenu                    // private var
memvar aSub_Menu                // private var
memvar aCall_st                 // private var
memvar aKey                     // private var
memvar aRecno                   // private var
memvar nLevel                   // private var  ?? needed ??

memvar white_red, nTime_out     // global vars

private nCh := 1
private aPages := {}
private nChoice := 1, lRegenerate := .t.
private cExtension
lClose_dd := .t.

cExtension = if(valtype(cExt) = 'C', '.' + upper(cExt), '.NOT')
cNot_title = if(valtype(cTitle) = 'C', cTitle, 'SYSTEM NOTES')
lEdit_acc = if(valtype(lEdit) = 'L', lEdit, .f.)

#include 'inkey.ch'

// private aMain_menu := {}     not used ??

if lEdit_acc
  nCh = get_arr(aCh,,,white_red,.t.,,,,,nTime_out)
  if nCh = len(aCh) .or. nCh = 0
    return
  endif
else
  nCh = 1
endif

if select('DD') = 0
  if !net_use('dd', .f.,, 'dd_file', 'dd_name', 'dd_recs')
    return
  endif
  lClose_dd = .t.
else
  select dd
  lClose_dd = .f.
endif

if !dbseek('NOTES' + cExtension)        // add first rec if none exist
  dbsetorder(3)
  dbgobottom()
  nCnt = dd->rec_code
  nCnt++
  dbappend()
  reclock()
  dd->file := 'NOTES' + cExtension
  dd->name := not_num_nm(50000000)
  dd->rec_code := nCnt
  dd->descriptn := 'First Notes entry'
  dbunlock()
  dbsetorder(1)
endif

if nCh = 1 .or. nCh = 2
  dbseek('NOTES' + cExtension)
  private aCall_st := {0}
  private aKey := {'NOTES' + cExtension}
  private aMenu := {}
  private aRecno := {}
  private aSub_menu := {}
  
  while !empty(aCall_st)
    if nCh = 2
      wopen(8,50,17,75)
      wbox()
      @0,1 say 'Ins = Insert new item'
      @1,1 say 'F9  = Edit Item'
      @2,1 say 'F8  = Create new'
      @3,1 say '        sub-menu'
      @4,1 say 'Del = Delete item'
      @5,1 say 'F7  = Print item'
    else
      wopen(8,50,12,75)
      wbox()
      @0,1 say 'F7  = Print item'
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
    cTitle = if(empty(atail(aCall_st)), cNot_title, atail(aCall_st))
    nHeight = 8
    if len(aMenu) > 12
      nHeight = 5
    endif
    nChoice = get_arr(aMenu,nHeight,10 ,,.t. ,cTitle ,nChoice ,,'not_excep',;
        nTime_out)
    if (nChoice = len(aMenu) .and. nextkey() != 3) .or. nChoice = 0
      nEnd = len(aCall_st)
      aSize(aCall_st, nEnd-1)
      aSize(aKey, nEnd-1)
      lRegenerate = .t.
    else                       // selection made
      if nextkey() != 3
        dbgoto(aRecno[nChoice])
        if empty(aSub_menu[nChoice])
          wopen(3,0,24,79)
          setcolor(memvar->white_blue)
          wbox()
          @0,0 say center(dd->descriptn) color memvar->yell_blue
          memoedit(dd->help, 1, 2, maxrow(), maxcol()-1, .f.)
          wclose()
        else
          aadd(aCall_st, dd->descriptn)
          aadd(aKey, dd->name)
          lRegenerate = .t.
        endif
      endif
    endif
    wclose()
  enddo
else                    // nch = 3 : print
  wopen(8,20,18,60)
  setcolor(memvar->black_green)
  wbox()
  @0,2 say 'Printing notes file'
  @1,2 say 'Printing section on :'
  begin sequence
    if openprn()
      break
    endif
    memvar->lPr_esc = .t.         // allow escape from print
    nLevel := 0
    dbseek('NOTES' + cExtension)
    while dd->file = 'NOTES' + cExtension
      not_print(.t.)
      dbskip()
    enddo
    prntitle(cNot_title + ' - INDEX')
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
  wclose()
endif
if lClose_dd
  select dd
  dbclosearea()
endif
return

*f*****************************************************************************
function not_excep(nElem, nRow, nKey_val)
local cSect, nCurs_save, cDescr
memvar getlist

memvar nLevel           // ?? used by subordinate progs

memvar aPages                                   // defined in calling prog
memvar aRecno                                   // defined in calling prog
memvar aMenu                                    // defined in calling prog
memvar aSub_Menu                                // defined in calling prog
memvar nCh                                      // defined in calling prog
memvar lRegenerate                              // defined in calling prog

memvar lPr_esc                                  // public var

do case
  case nKey_val = K_ENTER
    return (1)
  case nKey_val = K_ESC
    return(0)
  case nKey_val = K_F7                 // F7 = Print
    wopen(8,20,18,60)
    wbox()
    @1,5 say 'Printing notes file'
    @2,5 say 'Printing section on :'
    aPages := {}
    dbgoto(aRecno[nElem])
    begin sequence
      if openprn()
        break
      endif
      lPr_esc = .t.         // allow escape from print
      nLevel := 0
      not_print(.t.)
      shutprn()
    end sequence
    wclose()
    keyboard chr(3)                   // arbitary value to test for
    return(2)
  otherwise
    if nCh = 2
      do case
        case nKey_val = K_F9                // F9 = Edit
          if nElem != len(aMenu)            // last field = return
            dbgoto(aRecno[nElem])
            if empty(aSub_menu[nElem])      // does not have a sub menu
              not_edit_item()
            else
              wopen(10,10,14,70)
              wbox()
              setcursor(1)                      // save cursor & force on
              cDescr = dd->descriptn
              @2,5 say 'Description' get cDescr
              read
              reclock()
              dd->descriptn := cDescr
              dbunlock()
              lRegenerate = .t.
              wclose()
            endif
            keyboard chr(3)               // arbitary value to test for
            return(1)
          endif
        case nKey_val = K_INS            // Ins
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
              wait_msg(20,'Sub-menu exists, cannot add another',,,;
                memvar->nTime_out)
              return(2)
            endif
          endif
        case nKey_val = K_DEL               // Del - delete
          if nElem != len(aMenu)            // last field = return
            if empty(aSub_menu[nElem])
              not_del_item(nElem)
              keyboard chr(3)                   // arbitary value to test for
              lRegenerate = .t.
              return(1)
            else
              wait_msg(20,'Sub-menu exists, cannot Delete',,,memvar->nTime_out)
              return(2)
            endif
          endif
      endcase
    else
      return(2)
    endif
endcase
return (2)

*f*****************************************************************************
static procedure not_ins_item(nIn_elem)
local cFl, nPrev, nCurr, nMiddle, nRec
memvar aMenu                                   // defined in calling prog
memvar aRecno                                  // defined in calling prog

if wmake_sure(,,'Add new item to this menu (Y/N) ?')
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
  dbunlock()
  dbcommit()
  not_edit_item()
endif
return

*f*****************************************************************************
static procedure not_sub_menu(nIn_elem)
local cFl, nMiddle, nRec
memvar aCall_st                         // defined in calling prog
memvar aMenu                            // defined in calling prog
memvar aRecno                           // defined in calling prog
memvar aKey                             // defined in calling prog

if nIn_elem != len(aMenu)
  if wmake_sure(20,,'Create a sub-menu for this item (Y/N) ?')
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
    dbunlock()
    dbcommit()
    not_edit_item()
    aadd(aCall_st, dd->descriptn)
    aadd(aKey, cFl)
  endif
endif
return

*f*****************************************************************************
static procedure not_del_item(nIn_elem)
memvar aMenu, aCall_st, nLen_st, aKey, aRecno   // all defined in calling prog
if nIn_elem != len(aMenu)
  if wmake_sure(,,'Delete this item from the menu (Y/N) ?')
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
memvar cExtension
cName = ltrim(str(nIn_num,8,0))
cName = replicate('0', 8-len(cName)) + cName + cExtension
return ( cName)

*f*****************************************************************************
static procedure not_edit_item()
local cDescr, mHelp, lIns
memvar getlist
cDescr = dd->descriptn
mHelp = dd->help
wopen(0,0,24,79)
setcolor(memvar->cyan_blue)
wbox(1)
setcursor(1)
@2,0 to 2,maxcol()
memoedit(dd->help, 3, 1, maxrow()-1, maxcol(), .f., .f.)
while .t.
  @1,1 say 'Enter menu/item description' get cDescr         // get description
  read
  if !empty(cDescr)
    exit
  endif
enddo

@1,65 say 'F10 to finish'
while .t.
  lIns = readinsert(.t.)
  mHelp = memoedit(mHelp, 3, 1, maxrow()-1, maxcol(), .t., 'notes_udf')
  readinsert(lIns)
  if !empty(mHelp)
    exit
  endif
enddo
reclock()                               // store vars back to fields
dd->descriptn := cDescr
dd->help := trim(mHelp)
dbunlock()
wclose()
return

*f**********************************************************
* I wrote this udf as memoedit sometimes would not finish
* with Ctrl W or Esc so I redefined F10 as Ctrl W and F9 as Esc

function notes_udf (pMode, pMline, pCol)
local nRet := 0, nPage, nOn_page := memvar->pr_lines - 7, nLine

*if readinsert()
*  @0,68 say '<insert>'
*else
*  @0,68 say '        '
*endif
nPage = int(pMline / nOn_page) + 1
nLine = pMline - ((nPage-1) * nOn_page)
if nLine = 0
  nLine = nOn_page
  nPage--
endif
@maxrow(),50 say 'Page - ' + str(nPage,2) + ' Line - ' + str(nLine,2)
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
memvar cNot_title                       // defined in calling prog
memvar nLevel                           // defined in calling prog
memvar aPages                           // defined in calling prog

memvar pLine, pr_lines, pPage

nRec := recno()
cName = dd->name
cDescr = dd->descriptn
cFile = dd->file
cText = dd->help
@1,14 say dd->descriptn
if lHeading
  prntitle(cNot_title)
endif
if nLevel = 0
  aadd(aPages, {cDescr, pPage, {}})
else
  nLen = len(aPages)
  if !dbseek(cName) .and. (mlcount(cText,76) + pLine) > pr_lines - 4;
        .and. pLine > 7
    aadd(aPages[nLen,3], {cDescr, pPage+1}) // will print on new page
  else
    aadd(aPages[nLen,3], {cDescr, pPage})
  endif
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
  nText_cnt = mlcount(cText, 76)
  if (nText_cnt + pLine) > pr_lines - 4 .and. pLine > 7
    prntitle(cNot_title)
  endif
  pr_line(' ')
  pr_line(dd->descriptn)
  pr_line(replicate('=', 30))
  
  for nCnt = 1 to nText_cnt
    if pLine > pr_lines - 1
      prntitle(cNot_title)
      pr_line(' ')
      pr_line(dd->descriptn)
      pr_line(replicate('=', 30))
    endif
    pr_line(memoline(cText, 76, nCnt))
  next
  if pLine > pr_lines - 6
    pr_line(' ')
    pr_line(' ')
    pr_line(' ')
  endif
endif
dbgoto(nRec)
return

*******************************************************************************
Function Build_menu(cKey)
local aMenu_arr, cSub, nRec
aMenu_arr := {}
select dd
dbsetorder(1)
dbseek(cKey)
while dd->file = cKey .and. !eof()
  nRec = recno()
  if dbseek(dd->name)                     // try for sub manu
    cSub = '*'
  else
    cSub = ' '
  endif
  dbgoto(nRec)                            // return to orig rec
  aadd(aMenu_arr, {dd->descriptn, nRec, cSub})
  dbskip()
enddo
aadd(aMenu_arr, 'Return')
return(aMenu_arr)
*eof
