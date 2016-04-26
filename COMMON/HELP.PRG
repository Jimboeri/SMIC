*******************************************************************************
*
*  HELP - This program uses the passed parameters of variable and program
*         to search the data dictionary for a help field.
*         If not found it will look for the program help field and will keep
*         on moving up the call stack list until help is found.
*         If found but the help memo is empty it will use any links
*         available to find help or failing that, act as above.
parameters pProc, pLine, pVar
local nAct,;                              // Procedure activation no
lDisp,;                                   // boolean showing display fnd
cSeek,;                                   // string for file seeks
cCol_save, Csect_save,;                   // save current screen
nSelect_save,;                            // save current work area
lGive_up, nLink1,;                        // temp vars for linked search
nKey := 0,;                               // key pressed after help disp
nWdt, nTop, nBott, Nleft, nRight,;        // help box dimensions
nCnt                                      // counter
local lClose_dd := .t.                    // close DD after use
local cLook, nCentre, xx, cScr_save

memvar aProg_list, aFile_list             // program and file lists
memvar aLink_to
memvar pProc, pVar, cIn_var, cIn_proc

private aProg_list[0], aFile_list[0]      // program and file lists
private cIn_proc, cIn_var                 // private vars to hold params
private aLink_to[2], nLink_to             // selection to move to

#include 'inkey.ch'

if pProc = 'HELP'                         // ignore recursive call to help
  return
endif

nSelect_save = select()                   // save current work area

cIn_proc = upper(pProc)                   // save params to private vars
if valtype(pVar) = 'C'
  cIn_var = upper(pVar)
else
  cIn_var = ''
endif

if substr(cIn_var,1,8) = 'MEMVAR->'
  cIn_var = stuff(cIn_var,1,8,'')
endif

if select('DD') = 0
  lClose_dd = .t.
  select 222                              // open data dict
  if !net_use('dd', .f.,, 'dd_file', 'dd_recs', 'dd_name')
    select(nSelect_save)
    return
  endif
else
  select dd
  lClose_dd := .f.
endif

nAct = 0                                  // find occurence of call prog
while procname(nAct) != cIn_Proc          // in call stack
  nAct++
enddo

cLook = upper(trim(cIn_Proc)) + '.PRG'    // set up seek var for current
cLook += space(15-len(cLook))
if valtype(cIn_Var) = 'C'
  cLook += upper(cIn_Var)
endif

dbseek(cLook)                             // seek current help

lDisp = .f.                               // found something to display
if found()
  if !empty(dd->help)                         // can disp current
    lDisp = .t.
  else
    if dd->link1 != 0                         // if link exists
      dbsetorder(2)                       // set index to 'dd_recs'
      lGive_up = .f.                      // got to give up sometime
      while !lGive_up .and. !lDisp
        nLink1 = dd->link1                    // move link to var
        if dbseek(str(nLink1,5,0))        // look for link
          if !empty(dd->descriptn + dd->help)     // if there and displayable
            lDisp = .t.
          else
            if dd->link1 = 0                  // give up if no link
              lGive_up = .t.
            endif
          endif
        else
          lGive_up = .t.                  // not found - give up
        endif
      enddo
    endif
  endif
endif

if !lDisp                                 // if nothing to disp yet
  while !lDisp .and. !empty(procname(nAct)) // search up call stack
    cLook = trim(procname(nAct)) +'.PRG'  // set up seek var
    cLook += space(30-len(cLook))
    dbsetorder(1)                         // set index to 'dd_file'
    dbseek(cLook)                         // seek help
    if found() .and. !empty(dd->descriptn + dd->help)
      lDisp = .t.                         // something to display
    else
      nAct++                              // go further up stack
    endif
  enddo
endif

while lDisp                               // something to display
  lDisp = .f.
  nLeft = 5                               // find nice size for box
  if mlcount(dd->help,30) < 11
    nWdt = 30
  elseif mlcount(dd->help,40) < 16
    nWdt = 40
  elseif mlcount(dd->help,50) < 16
    nWdt = 50
  elseif mlcount(dd->help,60) < 18
    nWdt = 60
  else
    nWdt = 73
    nLeft = 3
  endif
  nRight = nLeft+nWdt                     // set up box size & position
  nTop = int((24 - mlcount(dd->help, nWdt))/2) - 1
  nTop = if(nTop<2,2,nTop)
  nBott = nTop + mlcount(dd->help, nWdt)
  cCol_save = setcolor(memvar->black_green)       // save orig col
  cSect_save = draw_box(nTop-1,nLeft-2,nBott+1,nRight+2)    //draw box
  nCentre = nLeft + int(nWdt/2) - (len(trim(dd->descriptn))/2)  // centre descr
  @nTop,nCentre say upper(trim(dd->descriptn))
  memoedit(dd->help, nTop+1,nLeft,nBott,nRight,.f., .f.)        // display help
  if dd->link1 != 0                           // started on links & then
    aLink_to[1] := {}                     // gave up for a while
    aLink_to[2] := {}
    for nCnt = 1 to 3
      if &('LINK' + ltrim(str(nCnt,1,0))) != 0
        aadd(aLink_to[1], '')
        aadd(aLink_to[2], &('LINK' + ltrim(str(nCnt,1,0))))
        link_descr(aLink_to[1], &('LINK' + ltrim(str(nCnt,1,0))),;
            len(aLink_to[1]))
      endif
    next
    // end of links
  endif
  nKey = inkey(0)                         // get a key
  restsector(cSect_save)                  // restore screen
  setcolor(cCol_save)                     // restore color
enddo

if nKey = K_ALT_F10                       // if key = Alt F10
  build_lists()                           // build prog & file lists
  while edit_help()                       // edit help screens
    xx = 1
  enddo
elseif nKey = K_CTRL_F1                   // If key = Ctrl F1
  save screen to cScr_save                  // save old screen
  if cIn_proc = 'GET_ARR'                // if std menu proc get calling proc
    nCnt = 0
    while procname(nCnt) != 'GET_ARR'
      nCnt++
    enddo
    cIn_proc = upper(procname(nCnt+1))
  endif
  user_edit(cIn_Proc, cIn_Var, .t.)       // edit current
  restore screen from cScr_save
endif

if lClose_dd
  select dd                               // close data dict
  dbclosearea()
endif

select(nSelect_save)                      // reselect original workarea
return

*f**********************************************************
static function edit_help
local cScr_save, nCnt, cSeek, cSector, cCol, nRec
memvar nCh1, nCh2, nCh3, nCh4, nCh5
memvar aCh1, aCh2, aCh3, aCh4, aCh5
memvar cIn_proc, cIn_var, aProg_list, aFile_list
memvar arr_bl_cy, white_red, arr_cy_bl, red_white
private aCh1 := {'Create/edit current help screen',;
    'Edit existing help screen',;
    'Quit'}, nCh1
private aCh2 := {'Help for current variable - ',;
    'Help for current program - '}, nCh2
private aCh3 := {'Edit program help',;
    'Edit database help',;
    'Quit'}, nCh3
private aCh4[0], nCh4           // field/list array
private aCh5 := {'Edit help screen',;
    'Change links to other help screens',;
    'Quit'}, nCh5
save screen to cScr_save                    // save old screen
jw_head('HELP ADMINISTRATOR FACILITY')    // draw clean screen
dbsetorder(1)                             // set index to 'dd_file'
nCh1 = get_arr(aCh1,,,white_red,.t.)     // get edit type
if nCh1 = len(aCh1) .or. nCh1 = 0         // if quit
  restore screen from cScr_save             // rest screen
  return(.f.)
endif
if nCh1 = 1                               // add/create current help
  cSeek = cIn_proc + '.PRG'               // init seek var
  cSeek += space(30-len(cSeek))
  nCh2 = 2                                // init type to prog help
  if !empty(cIn_var)                      // if input var exists
    aCh2[1] += cIn_var                    // set up table prog/var
    aCh2[2] += cIn_proc
    nCh2 = get_arr(aCh2,,,arr_bl_cy)     // get type
    if nCh2 = 1
      cSeek = substr(cSeek,1,15) + cIn_var  // if var midify seek var
    endif
  endif
  if dbseek(cSeek)                        // find help record
    if make_sure(18,,'Create new help record ?')  // check first
      dbgoto(lastrec())                   // get next rec_code
      nRec = dd->rec_code
      nRec++
      dbappend()                          // add record
      reclock('Data dictionary')
      dd->file := cIn_proc + '.PRG'       // create fields
      if nCh2 = 1
        dd->name := cIn_var
      endif
      dd->rec_code := nRec
      dbunlock()
      nRec = recno()                      // store rec
      build_lists()
      dbgoto(nRec)                        // return to rec
    else
      restore screen from cScr_save         // leave proc
      return(.t.)
    endif
  endif
else                                      // edit other record
  nCh3 = get_arr(aCh3,,,arr_bl_cy,.t.)   // program or database help
  if nCh3 = 1                             // program help
    nCh4 = get_arr(aProg_list,,,arr_cy_bl)  // find program
    cSeek = trim(aProg_list[nCh4]) + '.PRG'  // set up seek var
  elseif nCh3 = 2                         // database help
    nCh4 = get_arr(aFile_list,,,arr_cy_bl)  // find file
    cSeek = trim(aFile_list[nCh4]) + '.DBF'  // set up seek var
  endif
  dbseek(cSeek)                           // find prog/file
  while dd->file = cSeek .and. !eof()         // create table of vars/fields
    aadd(aCh4, dd->name + space(5) + dd->descriptn)
    dbskip()
  enddo
  nCh4 = get_arr(aCh4,,,arr_cy_bl)       //get var/fiels
  dbseek(cSeek)                           // go to help rec
  for nCnt = 1 to nCh4-1
    dbskip()
  next
endif
nCh5 = 0
cCol = setcolor(red_white)
cSector = draw_box(5,5,22,75)
while nCh5 != 0 .and. nCh5 != len(aCh5)   // until quit
  nCh5 = get_arr(aCh5,,,arr_bl_cy, .t.)  // edit text or links
  if nCh5 = 1                             // description/help editor
    text_edit()
  elseif nCh5 = 2                         // linkage editor
    link_edit()
  endif
enddo
setcolor(cCol)
restore screen from cScr_save               // return user orig screen
return(make_sure(20,,'Edit more help screens ?'))  // check for more edits

*f**********************************************************
* PROCEDURE TEXT_EDIT
*
*  This procedure allows edit the description and help memo fields
*  of help/data dictionary records.

static procedure text_edit
local cSave_col, cSect, nCurs_savecDescr, cHelp, getlist := {}
local cDescr
cSave_col = setcolor(memvar->blue_cyan)           // save colour for later
cSect = draw_box(5,5,22,75)               // draw box & save sector
nCurs_save = setcursor(1)                 // save cursor & force one
@6,10 say 'Help for '                     // create heading
if dd->name != space(15)
  @6,20 say trim(dd->name) + ' in ' + dd->file
else
  @6,20 say dd->file
endif
cDescr = dd->descriptn                        // move fields to mem vars
cHelp = dd->help
@8,10 to 21,70
memoedit(cHelp,9,12,20,68,.f., .f.)       // display help text
@7,10 say 'Description ' get cDescr       // get description
@7,60 say 'F10 to finish'
read
cHelp = memoedit(cHelp,9,12,20,68, .t., 'help_udf')  // edit help memo
@7,60 clear to 7,74
reclock('Data dictionary')                // store vars back to fields
dd->descriptn := cDescr
dd->help := trim(cHelp)
dbunlock()
restsector(cSect)                         // restore screen
setcolor(cSave_col)                       // restore colour
setcursor(nCurs_save)                     // restore cursor
return

*f**********************************************************
* PROCEDURE USER_EDIT
*
*  This procedure allows edit the description and help memo fields
*  of help/data dictionary records.

static procedure user_edit (cProc, cVar, lUser_edit)
local cSave_col, cSect, nCurs_savecDescr, cHelp, getlist := {}
local cIn_proc, cIn_var, aEdit_opt, nCh
local cOption1 := 'Edit current help screen'
local cOption2 := 'Add help screen for current field'
local cOption3 := 'Add help screen for current screen'
local cOption4 := 'Delete current help screen'
local cField, cScreen, cDescr, nRec
local lUser_mod
memvar black_green, white_red
cIn_proc = trim(upper(cProc)) + '.PRG'
cIn_var = trim(upper(cVar))
lUser_mod = if(valtype(lUser_edit) = 'L', lUser_edit, .f.)
cScreen = cIn_proc + space(15-len(cIn_proc))
cField = cScreen + cIn_Var
cScreen += space(15)
if valtype(memvar->test_env) = 'L' .and. memvar->test_env
  cSave_col = setcolor(black_green)           // save colour for later
  draw_box(2,2,5,35)
  @3,4 say 'Proc = ' + cIn_proc
  @4,4 say 'Var  = ' + cIn_var
  setcolor(cSave_col)
endif

do case
  case dbseek(cField)
    aEdit_opt := {cOption1, cOption4, 'Quit'}
  case dbseek(cScreen)
    aEdit_opt := {cOption1, cOption2, cOption4, 'Quit'}
  otherwise
    if lUser_mod
      aEdit_opt := {cOption2, cOption3, 'Quit'}
    else
      aEdit_opt := {cOption1, cOption2, cOption3, cOption4, 'Quit'}
    endif
endcase
cSave_col = setcolor(memvar->blue_cyan)           // save colour for later
cSect = draw_box(5,5,22,75)               // draw box & save sector
nCurs_save = setcursor(1)                 // save cursor & force one
@6,10 say 'Help for '                     // create heading
if dd->name != space(15)
  @6,20 say trim(dd->name) + ' in ' + dd->file
else
  @6,20 say dd->file
endif
cDescr = dd->descriptn                        // move fields to mem vars
cHelp = dd->help
@8,10 to 21,70
memoedit(cHelp,9,12,20,68,.f., .f.)       // display help text
@7,10 say 'Description  ' +  cDescr       // display description
nCh = get_arr(aEdit_opt, 5, 40, white_red, .t., 'SELECT OPTION')
do case
  case nCh = len(aEdit_opt) .or. nCh = 0  // quit
    return
  case aEdit_opt[nCh] = cOption1          // edit current help rec
    @7,10 say 'Description ' get cDescr   // get description
    @7,60 say 'F10 to finish'
    read
    cHelp = memoedit(cHelp,9,12,20,68, .t., 'help_udf') // edit help memo
    @7,60 clear to 7,74
    reclock('Data dictionary')            // store vars back to fields
    dd->descriptn := cDescr
    dd->help := trim(cHelp)
    dbunlock()

  case aEdit_opt[nCh] = cOption2          // add current field
    @6,10 say 'Help for '                 // create heading
    @6,20 say trim(cIn_var) + ' in ' + cIn_proc
    cDescr = space(30)
    cHelp = ''
    @9,12 clear to 20,68
    @7,60 say 'F10 to finish'
    while empty(cDescr)
      @7,10 say 'Description ' get cDescr // get description
      read
    enddo
    while empty(cHelp)
      cHelp = memoedit(cHelp,9,12,20,68, .t., 'help_udf') // edit help memo
    enddo
    @7,60 clear to 7,74
    goto lastrec()
    nRec = dd->rec_code
    nRec++
    dbappend()                            // add record
    reclock('Data dictionary')
    dd->file := cIn_proc                  // create fields
    dd->name := cIn_var
    dd->rec_code := nRec
    dd->descriptn := cDescr
    dd->help := trim(cHelp)
    dbunlock()
    
  case aEdit_opt[nCh] = cOption3          // add current screen record
    @6,10 say 'Help for '                 // create heading
    @6,20 say cIn_proc
    cDescr = space(30)
    cHelp = ''
    @9,12 clear to 20,68
    @7,60 say 'F10 to finish'
    while empty(cDescr)
      @7,10 say 'Description ' get cDescr // get description
      read
    enddo
    while empty(cHelp)
      cHelp = memoedit(cHelp,9,12,20,68, .t., 'help_udf')  // edit help memo
    enddo
    @7,60 clear to 7,74
    dbgoto(lastrec())
    nRec = dd->rec_code
    nRec++
    dbappend()                            // add record
    reclock('Data dictionary')
    dd->file := cIn_proc                  // create fields
    dd->rec_code := nRec
    dd->descriptn := cDescr
    dd->help := trim(cHelp)
    dbunlock()
    
  case aEdit_opt[nCh] = cOption4          // delete current help rec
    if make_sure(17,, 'Are you sure you want to delete this help screen')
      reclock('HELP')
      dbdelete()
      dbunlock()
    endif

endcase
restsector(cSect)                         // restore screen
setcolor(cSave_col)                       // restore colour
setcursor(nCurs_save)                     // restore cursor
return

*f**********************************************************
* PROCEDURE LINK_EDIT
*
*  This procedure allows help/data dictionary records to be linked to
*  other help records (program(.PRG) or database (.DBF)). The help system
*  will then allow the user to browse through related items.

static procedure link_edit
local nRec, nChoice := 0, nLink
local cFile, nRec_code
local aLink[4]                          // available links

local aTY1 := {'Link to program',;
    'Link to database',;
    'Remove link',;
    'Quit'}, nTy1
// types of links
local aFld[0], nFld                       // array of field names
local nCnt
memvar cVar
memvar aProg_list, aFile_list
memvar arr_cy_bl

dbsetorder(2)                             // set index to 'dd_recs'
nRec = recno()                            // store orig rec no
for nCnt = 1 to 3                         // set up available link table
  cVar = 'LINK' + ltrim(str(nCnt,1,0))
  nLink = &cVar
  link_descr(aLink, nLink, nCnt)
next
aLink[4] = 'Quit'                         // with a quit
while nChoice != len(aLink) .and. nChoice != 0   // while not quit
  nChoice = get_arr(aLink,,,memvar->white_red,.t.)      // get link to work on
  if nChoice != len(aLink) .and. nChoice != 0
    nTy1 = get_arr(aTy1,,,memvar->white_red, .t.)  // get type of link to make/delete
    if nTy1 = 1                           // program link
      nFld = get_arr(aProg_list,,,arr_cy_bl, .t.)  // select program
      if nFld = 0                         // quit
        loop
      else
        cFile = trim(aProg_list[nFld]) + '.PRG' // extract variable
      endif
    elseif nTy1 = 2                       // database link
      nFld = get_arr(aFile_list,,,arr_cy_bl, .t.)
      if nFld = 0                         // Escape
        loop
      else
        cFile = trim(aFile_list[nFld]) + '.DBF' // set up variable
      endif
    elseif nTy1 = 3                       // delete link
      if make_sure(20,,'Delete this link ?')
        reclock('Data dictionary')
        cVar = 'dd->LINK' + ltrim(str(nChoice,1,0))
        &cVar := 0                        // delete link
        dbunlock()
        link_descr(aLink, 0, nChoice)     // change link description
      endif
      loop
    else
      loop
    endif
    dbsetorder(1)                         // set index to 'dd_file'
    dbseek(cFile)                         // find file name
    aFld := {}                            // reset field table
    while dd->file = cFile .and. !eof()       // load field table
      aadd(aFld, dd->name)
      dbskip()
    enddo
    nFld = get_arr(aFld,,,arr_cy_bl, .t.)  // get field
    if nFld != 0
      dbseek(cFile + space(15-len(cFile)) + aFld[nFld])   // find record
      nRec_code = dd->rec_code                // get record code
      dbgoto(nRec)                        // return to orig rec
      if make_sure(20,,'Add this link ?')
        reclock('Data dictionary')        // insert link value
        cVar = 'dd->LINK' + ltrim(str(nChoice,1,0))
        &cVar := nRec_code
        dbunlock()
        link_descr(aLink, nRec_code, nChoice)   // reset description
      endif
    endif
  endif
enddo
dbsetorder(1)                             // set index to 'dd_file'
return

*f**********************************************************
* PROCEDURE LINK_DESCR
* This procedure inserts a description of the records pointed to by
* the various link fields into an array for later choice
* Parameters :
*         aDescr = array of link descriptions
*         nRec_cd = Record no of record linked to
*         nInx = no of link (1, 2 or 3)
static procedure link_descr(aDescr, nRec_cd, nInx)

local cSeek, nAt, cExt, nRec, nOrd_save
dbsetorder(2)                             // set index to 'dd_recs'
aDescr[nInx] = 'Link ' + str(nInx,1,0) + '  '   // des of link no
nRec = recno()                            // store orig rec
cSeek = str(nRec_cd,5,0)
dbseek(cSeek)                             // find linked rec
if !found()
  aDescr[nInx] += 'None'                  // if not found (or 0) - none
  dbgoto(nRec)                            // return to orig rec
  return
endif
nAt = at('.', dd->File)
if nAt = 0                                // invalid fields name
  aDescr[nInx] += 'None'
  dbgoto(nRec)                            // return to orig rec
  return
else
  cExt = substr(dd->File,nAt+1,3)
  if cExt = 'PRG'                         // if program record
    if empty(dd->name)                    // if no name - prog descr
      aDescr[nInx] += 'Program description - ' + substr(dd->file,1,nAt-1)
    else                                  // variable descr
      aDescr[nInx] += 'Variable description - ' + trim(dd->name) +;
          ' (in program ' + substr(dd->file,1,nAt-1) + ')'
    endif
  elseif cExt = 'DBF'                     // if database record
    if empty(dd->name)                    // if no name - database descr
      aDescr[nInx] += 'Database description - ' + substr(dd->file,1,nAt-1)
    else                                  // field descr
      aDescr[nInx] += 'Field description - ' + trim(dd->name) +;
          ' (in database ' + substr(dd->file,1,nAt-1) + ')'
    endif
  endif
endif
dbgoto(nRec)                              // return to orig rec
return
*eof

*f**********************************************************
* PROCEDURE BUILD_LISTS
*  This procedure is used to initailise two arrays, one of program files (.PRG)
*  and the other of database files (.DBF)

static procedure build_lists
local nAt, cFile, cExt
memvar aProg_list, aFile_list
dbsetorder(1)                             // set index to 'dd_file'
aProg_list := {}                          // initialise Program array
aFile_list := {}                          // initialise File array
dbgotop()                                 // go to the top
while !eof()
  cFile = dd->file                            // store file name
  nAt = at('.', cFile)                    // find . for start of extension
  if nAt != 0
    cExt = substr(cFile,nAt+1,3)          // store extension
    if cExt = 'PRG'                       // if prog add to prog list
      aadd(aProg_list, substr(cFile,1,nAt-1))
    elseif cExt = 'DBF'                   // if file add to file list
      aadd(aFile_list, substr(cFile,1,nAt-1))
    endif
  endif
  while cFile = dd->file .and. !eof()         // move to next file name
    dbskip()
  enddo
enddo
return

* eof

*f**********************************************************
* I wrote this udf as memoedit sometimes would not finish
* with Ctrl W or Esc so I redefined F10 as Ctrl W and F9 as Esc

function help_udf (pMode, pLine, pCol)
local nRet := 0
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
elseif pMode = 3
  readinsert(.t.)
endif
return(nRet)
