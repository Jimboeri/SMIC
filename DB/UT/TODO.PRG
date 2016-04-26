*****
*
*       TO_DO.prg
*       Returns an existing agent code
*       Note:  compile with /n/w/a
*

parameter in_name

local column, cType, n, to_do_var, nRow, cSec, dFin, getlist := {}
local cColorSave, nCursSave, cSectSave, cSect1, cCol1
local lMore, nKey, cto_do_cd
private force_bw := .f., force_prfile := .f., test_env := .f.
public ppnt_title := 'Jobs to do', cPrint_name

private b                               // browse block
private cName
cName = upper(if(valtype(in_name) = 'C', in_name, space(15)))
cName += space(15-len(cName))

set date british
set scoreboard off
set deleted on

PUBLIC PLINE := 0               // Line counter
PUBLIC PPAGE := 0               // Page counter

restore from printer additive

cPath = getenv("PATH")
set path to (cPath)
restore from &cPrint_name additive
set path to

#include "inkey.ch"
#include "colour.ch"
#include "setcurs.ch"
#include "mouse.ch"

public oMouse := mousenew()                     // create mouse object
public _is_mouse := .f.                         // and initialize it
m_init(oMouse)
m_goto(oMouse)

#define MY_HSEP         "мям"
#define MY_CSEP         " Ё "
#define MY_FSEP         "мом"

setkey(-1, {|| prn_change()})
setkey(-35, {|| jw_pri_sw()})

jw_screen('Jobs to do')
cColorSave := SetColor('N/W,W/N,,,B/W')
cSectSave = draw_box(6, 4, 23, 73)
@22,7 say 'Enter - edit    Ins - insert    Alt-F - finish    Alt P - print'
nCursSave := SetCursor(0)
setcancel(.f.)

if !file('to_do.dbf')
  declare aDDict[0]
  AADD(aDDict, {'NAME      ', 'C', 15, 0})
  AADD(aDDict, {'DATE_IN   ', 'D', 8, 0})
  AADD(aDDict, {'DATE_OUT  ', 'D', 8, 2})
  AADD(aDDict, {'PRIORITY  ', 'N', 1, 0})
  AADD(aDDict, {'MESS_TYPE ', 'C', 1, 0})
  AADD(aDDict, {'FIN_CAN   ', 'C', 1, 0})
  AADD(aDDict, {'DEADLINE  ', 'D', 8, 0})
  AADD(aDDict, {'FROM      ', 'C', 15, 0})
  AADD(aDDict, {'DESCR     ', 'C', 30, 0})
  AADD(aDDict, {'COMMENT   ', 'M', 10, 0})
  DBCREATE('to_do', aDDict)
  release aDDict
endif

if !file('to_do.ntx')
  select 201
  if !net_use('to_do', .t.)
    return
  endif
  dbcreateind('to_do', 'name + mess_type + str(priority) + dtos(date_in)',;
      {||name + mess_type + str(priority) + dtos(date_in)})
  dbclosearea()
endif

select 201
if !net_use('to_do', .f., , 'to_do')
  return
endif

/* make new browse object */
b := TBrowseDB(7, 5, 21, 72)

/* default heading and column separators */
b:headSep := MY_HSEP
b:colSep := MY_CSEP
b:footSep := MY_FSEP

/* add custom 'skip_to_do' (to handle append mode) */
b:skipBlock := {|x| skip_to_do(x)}

/* colors */
b:colorSpec := 'N/W,W/N,,N*/W,B/W'

/* add a column for priority */
column := TBColumnNew( "Priority", {|| str(priority)} )
b:addColumn(column)

/* add a column for date recieved */
column := TBColumnNew( "Date rcv", {|| dtoc(date_in)} )
b:addColumn(column)

/* add a column for description */
column := TBColumnNew( "Description", {|| descr} )
b:addColumn(column)

/* add a column for deadline */
column := TBColumnNew( "Deadline", {|| dtoc(deadline)} )
b:addColumn(column)

lMore := .t.
while (lMore)
  
  /* don't allow cursor to move out of description column */
  b:colPos := 3
  
  /* stabilize the display */
  while ( !b:stabilize() )
    nKey := InKey()
    if ( nKey != 0 )
      exit                    /* (abort if a key is waiting) */
    end
  end
  
  if ( b:stable )
    /* display is stable */
    if ( b:hitTop .or. b:hitBottom )
      Tone(125, 0)
    end
    
    /* everything's done; just wait for a key */
    nKey := InKey(0)
    
  end
  
  /* process key */
  do case
    case ( nKey == K_RETURN )
      edit_todo()
      
    case ( nKey == K_INS ) .or. (nKey = K_DOWN .and. b:hitbottom())
      dbappend()
      reclock('to_do')
      to_do->name := cName
      to_do->mess_type := 'T'
      dbunlock()
      dbcommit()
      edit_todo()
      
    case ( nKey == K_ALT_F )
      cSec = draw_box(10,20,17,60)
      @12,25 say to_do->descr
      if make_sure(14,,'Have you finished this job ?')
        dFin = date()
        @14,25 say 'Date finished on ' get dFin
        read
        reclock('to_do')
        to_do->fin_can := 'F'
        to_do->date_out := dFin
        dbunlock()
        b:up()
        b:refreshall()
      endif
      restsector(cSec)
      
    case ( nKey == K_ALT_C )
      if make_sure(,,'Do you want to cancel this job ?')
        reclock('to_do')
        to_do->fin_can := 'F'
        dbunlock()
        b:up()
        b:refreshall()
      endif
      
    case ( nKey == K_DEL )
      if make_sure(,,'Do you want to delete this job ?')
        cSect1 = disp_msg(17,white_red,  'Compacting and reindexing to do file')
        reclock('to_do')
        dbdelete()
        dbunlock()
        declare aStru[0]
        aStru = dbstruct()
        dbcreate('to_do_tmp', aStru)
        copy to to_do_tmp
        dbclosearea()                     // close to do file
        run del to_do.db?
        run ren to_do_tm.db? to_do.db?
        select 201
        if !net_use('to_do', .t.)
          return
        endif
        dbcreateind('to_do', 'name + mess_type + str(priority) + dtos(date_in)',;
            {||name + mess_type + str(priority) + dtos(date_in)})
        dbclosearea()
        select 201
        if !net_use('to_do', .f.,,'to_do')
          return
        endif
        restsector(cSect1)
        b:up()
        b:refreshall()
      endif
      
    case ( nKey == K_ALT_P )
      to_do_print()
      
    case ( nKey == K_F1 )
      help(procname(), procline(), '')
      
    case ( nKey == K_DOWN )
      b:down()
      
    case ( nKey == K_UP )
      b:up()
      
    case ( nKey == K_PGDN )
      b:pageDown()
      
    case ( nKey == K_PGUP )
      b:pageUp()
      
    case ( nKey == K_CTRL_PGUP ) .or. ( nKey == K_HOME )
      b:goTop()
      
    case ( nKey == K_CTRL_PGDN ) .or. ( nKey == K_END )
      b:goBottom()
      
    case ( nKey == K_ESC )
      lMore := .f.
      
    case (bAction := SETKEY(nKey)) != NIL
      EVAL(bAction, Procname(), Procline(), readvar())
      
  endcase
enddo

setcancel(.t.)
setcolor(cColorSave)
SetCursor(nCursSave)
restsector(cSectSave)
select to_do
dbclosearea()
return


*******************************************************************************
*       skip_to_do()
*

func skip_to_do(n)
local i, nLine

// nFld_type is a public variable in agtedit to show which agt type to display

i := 0
if ( LastRec() != 0 )
  if ( n == 0 )
    while (fin_can != ' ' .or. name != cName .or. mess_type != 'T';
          .or. date_in > date()) .and. !eof()
      dbskip()
    enddo
    dbskip(0)
    
  elseif ( n > 0 .and. Recno() != LastRec() + 1 )
    while ( i < n )
      dbskip(1)
      while (fin_can != ' ' .or. name != cName .or. mess_type != 'T';
            .or. date_in > date()) .and. !eof()
        dbskip(1)
      enddo
      if ( Eof() )
        dbskip(-1)
        while (fin_can != ' ' .or. name != cName .or. mess_type != 'T';
              .or. date_in > date()) .and. !bof()
          dbskip(-1)
        enddo
        exit
      end
      i++
    end
    
  elseif ( n < 0 )
    while ( i > n )
      dbskip(-1)
      while (fin_can != ' ' .or. name != cName .or. mess_type != 'T';
            .or. date_in > date()) .and. !bof()
        dbskip(-1)
      enddo
      if ( Bof() )
        while (fin_can != ' ' .or. name != cName .or. mess_type != 'T';
              .or. date_in > date()) .and. !eof()
          dbskip()
        enddo
        exit
      end
      i--
    end
  end
end
return (i)

*******************************************************************************
procedure edit_todo
local cCol, nCurs, cSect, getlist := {}
private dIn, dOut, nPrior, cFin_can, dDeadline, cDescr, mComment
cCol = setcolor('W/N,N/W,,,N/w')
nCurs = setcursor(1)
cSect = draw_box(9,15,23,65)
@14,18 to 21,63
dIn = date_in
dOut = date_out
nPrior = priority
cFin_can = fin_can
dDeadline = deadline
cDescr = descr
mComment = comment
if dIn = ctod('  /  /  ')
  dIn = date()
endif
memoedit(mComment,15,20,20,61,.f.,.f.)
setcursor(1)
@10,18 say 'Date received ' get dIn
@10,45 say 'Priority ' get nPrior picture '9'
@11,18 say 'Deadline      ' get dDeadline
@13,18 say 'Description   ' get cDescr
read
@22,25 say 'Press Control and "W" to save'
mComment = memoedit(mComment,15,20,20,61,.t.)
setcursor(0)
reclock('to_do')
if cDescr = space(30)
  dbdelete()
  b:up()
else
  to_do->date_In = dIn
  to_do->Priority = nPrior
  to_do->Deadline = dDeadline
  to_do->Descr = cDescr
  to_do->Comment = mComment
endif
unlock
commit
b:refreshall()
restsector(cSect)
setcursor(nCurs)
setcolor(cCol)
return

***********************************************************
procedure to_do_print
local nRec, aCh := {'Current jobs', 'All jobs', 'Quit'}, nCh, dSt, dEnd
local cSect, getlist := {}
nRec = recno()
nCh = mget_arr(aCh)
if nCh = 3
  return
endif
if nCh = 2
  cSect = draw_box(14,20,18,50)
  dSt = ctod('  /  /  ')
  dEnd = date()
  @15,22 say 'Enter start and finish dates'
  @16,22 say 'Start date ' get dSt
  @17,22 say 'End date   ' get dEnd
  read
  restsector(cSect)
endif
begin sequence
  openprn()
  if valtype(ppnt_title) != 'C'
    ppnt_title = 'LIST OF THINGS TO DO'
  endif
  dbseek(cName + 'T')
  while cName = name .and. mess_type = 'T' .and. !eof()
    do case
      case nCh = 1
        if fin_can = ' '
          pr_to_do(1)
        endif
      case nCh = 2
        if date_in >= dSt .and. date_in <= dEnd
          pr_to_do(2)
        endif
    endcase
    dbskip()
  enddo
  shutprn()
end sequence

goto nRec
return

*******************************************************************************
procedure pr_to_do( nType)
local nCom, nCnt
if pline > 54
  prntitle('LIST OF THINGS TO DO')
  ? 'Dt Rcvd Prty   Description                     Status     Deadline'
endif
? dtoc(date_in) + '  ' + str(priority) + '    ' + descr + '  '
do case
  case fin_can = ' '
    ?? 'Current  '
  case fin_can = 'F'
    ?? 'Finished '
  case fin_can = 'C'
    ?? 'Cancelled'
endcase
if deadline != ctod('  /  /  ')
  ?? '  ' + dtoc(deadline)
endif
pline++
if nType = 1 .and. !empty(comment)
  nCom = mlcount(comment, 75)
  nCom = if(nCom > 5,5,nCom)
  for nCnt = 1 to nCom
    ? '   ' + memoline(comment, 75, nCnt)
    pline++
  next
  ? ''
  pline++
endif
return

*******************************************************************************
procedure prn_change()
local aMem := {}, nAt, nCnt, aShort := {}
aMem = directory('*.MEM')
for nCnt = 1 to len(aMem)
  if upper(aMem[nCnt, 1]) != 'PRINTER.MEM'
    nAt = at('.', aMem[nCnt, 1])
    aadd(aShort, substr(aMem[nCnt, 1], 1, nAt-1))
  endif
next
nAt = mget_arr(aShort,,,arr_bl_cy,.t.,;
'Select printer type to use (current ' + trim(cPrint_name) + ')')
if nAt != 0
  cPrint_name = aShort[nAt]
  restore from &cPrint_name additive
  save all like cPrint_n* to printer
endif

return
