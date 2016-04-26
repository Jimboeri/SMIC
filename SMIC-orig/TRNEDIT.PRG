*******************************************************************************
*
* TRNEDIT - EDIT TRANSACTIONS DONE BY STUDENTS
*

local cType, nMax, lCan_edit, nArr_len, cOrig_col, nChoice
local aTrn := {}, aRec := {}

cType = 'T'

select Transact
dbseek(Student->std_code + cType)
      lCan_edit = .f.
while transact->std_code = Student->std_code .and. transact->type = cType;
 .and. !eof()
  aadd(aRec, recno())
  aadd(aTrn, '')
  nMax = len(aTrn)
  do case
    case transact->trn_type = 'BF '
      aTrn[nMax] = 'Brought forward    '
    case transact->trn_type = 'BUY'
      aTrn[nMax] = 'Buy shares         '
      lCan_edit = .t.
    case transact->trn_type = 'SEL'
      aTrn[nMax] = 'Sell shares        '
      lCan_edit = .t.
    case transact->trn_type = 'SSL'
      aTrn[nMax] = 'Bear sale          '
    case transact->trn_type = 'SDV'
      aTrn[nMax] = 'Bear delivery      '
    case transact->trn_type = 'FDV'
      aTrn[nMax] = 'Forced delivery    '
    case transact->trn_type = 'DIV'
      aTrn[nMax] = 'Dividend           '
    case transact->trn_type = 'NEX'
      aTrn[nMax] = "NPL's exercised    "
    case transact->trn_type = 'NLP'
      aTrn[nMax] = "NPL's abandoned    "
    case transact->trn_type = 'INT'
      aTrn[nMax] = 'Interest           '
    case transact->trn_type = 'ODV'
      aTrn[nMax] = 'Overdraft interest '
    case transact->trn_type = 'SIN'
      aTrn[nMax] = 'Interest on cover  '
    case transact->trn_type = 'SCV'
      aTrn[nMax] = 'Extra cover        '
    case transact->trn_type = 'NRC'
      aTrn[nMax] = "NPL's recieved     "
    case transact->trn_type = 'MBK'
      aTrn[nMax] = 'Money back         '
    case transact->trn_type = 'FIN'
      aTrn[nMax] = 'Finished           '
  endcase
  aTrn[nMax] += transact->share + ' ' + str(transact->qty) + ' ' +;
   str(transact->value) + ' ' + dtoc(transact->trn_dt) + ' ' +;
    str(transact->price)
  dbskip()
enddo

if !lCan_edit
  wait_msg(15, 'No transactions to edit',,,20)
  return
endif

if len(aTrn) > 13
  nArr_len = 13
else
  nArr_len = len(aTrn)
endif
cOrig_col = setcolor(memvar->black_cyan)
@7,1 clear to 9 + nArr_len,78
@7,1 to 9 + nArr_len,78
@8,3 say 'Trn type          Share          Qty          Value   Date            Price'
setcolor(memvar->ach_col)
nChoice = achoice(9, 2, 8 + nArr_len, 77, aTrn)
setcolor(cOrig_col)

if nChoice != 0
  if make_sure()
    select Transact
    goto aRec[nChoice]
    do case
      case transact->trn_type = 'BUY'
        select Portfol
        dbseek(Student->std_code + cType + transact->share)
        reclock('Portfolio')
        if transact->qty = portfol->qty
          dbdelete()
        else
          portfol->qty := portfol->qty - transact->qty
          portfol->cost_hold := portfol->cost_hold - abs(transact->value)
        endif
        dbunlock()
        select Student
        reclock('student')
        Student->cash := Student->cash + abs(transact->value)
        dbunlock()
        select Transact
        reclock('Transaction')
        dbdelete()
        dbunlock()
      case transact->trn_type = 'SEL'
        select Portfol
        if !dbseek(Student->std_code + cType + transact->share)
          dbappend()
          reclock('Portfolio')
          portfol->std_code := Student->std_code
          portfol->type     := cType
          portfol->share    := transact->share
          dbunlock()
        endif
        reclock('Portfolio')
        portfol->qty       := portfol->qty + transact->qty
        portfol->cost_hold := portfol->cost_hold + transact->cost_hold
        dbunlock()
        select Student
        reclock('student')
        Student->cash := Student->cash - abs(transact->value)
        dbunlock()
        select Transact
        reclock('Transaction')
        dbdelete()
        dbunlock()
    endcase
  endif
endif

return

* eof