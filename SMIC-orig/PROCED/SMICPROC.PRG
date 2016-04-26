*******************************************************************************
* SMICPROC
* Jim West
* From 1987

#include "inkey.ch"

*******************************************************************************
* FUNCTION ARR_WIDTH RETURN LENGTH OF LONGEST CHAR STRING IN AN ARRAY
FUNCTION ARR_WIDTH (IN_ARRAY, ARRAY_LEN)
local nCnt, nWidth
nCnt := nWidth := 0
if in_array = nil .or. array_len = nil
  return(0)
endif
if valtype(in_array) != 'A' .or. valtype(array_len) != 'N'
  return(0)
endif
if array_len = 0
  return(0)
endif
for nCnt = 1 to array_len
  if valtype(in_array[nCnt]) = 'C'
    if len(in_array[nCnt]) > nWidth
      nWidth = len(in_array[nCnt])
    endif
  endif
next
return(nWidth)
*EOF()


***********************************************************
PROCEDURE LAST_RUN (PRG_NAME)
LOCAL cFile_name
cFile_name = PRG_NAME + '.RUN'
set printer to &cFile_name
set print on
set console off
?? date()
set console on
set print off
set printer to
return
*EOF

*******************************************************************************
FUNCTION STR_STAT(cIn_status)    && RETURN STRING INDICATING STATUS
local cOut_stat
do case
  case cIn_status = 'C'
    cOut_stat = 'Current  '
  case cIn_status = 'N'
    cOut_stat = 'New Stud '
  case cIn_status = 'F'
    cOut_stat = 'Finished '
  case cIn_status = 'S'
    cOut_stat = 'Suspended'
  case cIn_status = 'U'
    cOut_stat = 'Unpaid   '
  otherwise
    cOut_stat = 'Unknown  '
endcase
return cOut_stat

* EOF
*******************************************************************************
FUNCTION STR_TYPE(IN_TYPE)      && RETURN STRING INDICATING TYPE
LOCAL OUT_TYPE
DO CASE
  CASE IN_TYPE = 'Q'
    OUT_TYPE = 'Cheque      '
  CASE IN_TYPE = 'O'
    OUT_TYPE = 'Other       '
  CASE IN_TYPE = 'C'
    OUT_TYPE = 'Credit card '
  CASE IN_TYPE = 'D'
    OUT_TYPE = 'Debit order '
  OTHERWISE
    OUT_TYPE = 'Unknown     '
ENDCASE
RETURN OUT_TYPE

* EOF

*******************************************************************************
* PROCEDURE RATIOS - PRINTS SALES TO LEADS RATIOS AT THE END OF A LINE
*
*******************************************************************************
PROCEDURE RATIOS (nLeads, nSales)
LOCAL nRatio
nRatio = 0
if nSales = 0
  ?? '            '
else
  nRatio = nLeads / nSales
  ?? str(nRatio,12,2)
endif
return
* EOF (RATIOS)

*******************************************************************************
* PROCEDURE PERCENT - PRINT PERCENTAGE OF GOOD LEADS AT THE END OF A LINE
*
*******************************************************************************
PROCEDURE PERCENT (nLeads, nGood)
local nPerc
nPerc = 0
if nGood = 0
  ?? '              '
else
  nPerc = nGood / nLeads * 100
  ?? str(nPerc,13,2) + '%'
endif
return
* EOF (PERCENT)

*******************************************************************************
* PROCEDURE BROKER - CALCULATES BROKERAGES UP TO 1,000,000
*
*******************************************************************************
FUNCTION BROKER (nVal)
LOCAL nValue, nBroker
nBroker := 0
nValue := nVal

if nValue > 5000
  nBroker = 60
  nValue = nValue - 5000
else
  nBroker = nValue * 0.012
  return nBroker
endif

if nValue > 5000
  nBroker = nBroker + 42.5
  nValue = nValue - 5000
else
  nBroker = nBroker + (nValue * 0.0085)
  return nBroker
endif

if nValue > 90000
  nBroker = nBroker + 675
  nValue = nValue - 90000
else
  nBroker = nBroker + (nValue * 0.0075)
  return nBroker
endif

if nValue > 150000
  nBroker = nBroker + 975
  nValue = nValue - 150000
else
  nBroker = nBroker + (nValue * 0.0065)
  return nBroker
endif

if nValue > 250000
  nBroker = nBroker + 1375
  nValue = nValue - 250000
else
  nBroker = nBroker + nValue * 0.0055
  return nBroker
endif

nBroker = nBroker + (nValue * 0.0045)
return nBroker
* EOF (BROKER)

*******************************************************************************
* PROCEDURE HANDLE - CALCULATES HANDLING CHARGES
*
*******************************************************************************
function handle (quantity)

return 15.0
* eof (handle)

*******************************************************************************
* PROCEDURE MST - CALCULATES MST ON SHARE PURCHASES
*
*******************************************************************************
function mst (nVal)
  return (nVal * 0.005)
* eof(mst)

*******************************************************************************
function futval(nIn_val, nCalc)
local nVal
nVal = 0
do case
  case nCalc = 1
    nVal = nIn_val * 10
  case nCalc = 2
    nVal = 1000000 * 11 / nIn_val
  case nCalc = 3
    nVal = 10000 * nIn_val
  case nCalc = 4
    nVal = nIn_val * 100
  otherwise
    nVal = 1
endcase
return(nVal)
* EOF

*******************************************************************************
*
* FUNCTION SCRAM - CALL C PROC _scram TO ENCODE CHARACTER STRINGS
*
*******************************************************************************
function scram(INSTRING)
return(instring)
* EOF()

*******************************************************************************
function rev_n_to_c (nIn_num)
do case
  case nIn_num = 0
    return('Reason not yet entered')
  case nIn_num = 1
    return('N.P.F. or insufficient funds')
  case nIn_num = 2
    return('Payment stopped')
  case nIn_num = 3
    return('Account closed')
  case nIn_num = 4
    return('No such account')
  case nIn_num = 5
    return('Account not cleared')
  case nIn_num = 6
    return('Incorrect account dets or acc no invalid')
  case nIn_num = 7
    return('Incorrect bank/branch code')
  case nIn_num = 8
    return('Savings account / Not for DR')
  case nIn_num = 9
    return('Cheque returned R.D.')
  case nIn_num = 10
    return('Cheque stopped')
  case nIn_num = 11
    return('Incorrect banking details')
  case nIn_num = 12
    return('Operator error')
  case nIn_num = 13
    return('Payment date changed')
endcase
return('')

*******************************************************************************
function rev_c_to_n (nIn_string)
local nCounter
for nCounter = 1 to 14
  if nIn_string = rev_n_to_c(nCounter)
    return(nCounter)
  endif
next
return(0)

***********************************************************
function smic_n_to_c(nIn_num)
do case
  case nIn_num = 1
    return('Enquiries')
  case nIn_num = 2
    return('Leads : for reps')
  case nIn_num = 3
    return('Leads : Sales reports')
  case nIn_num = 4
    return('System control functions')
  case nIn_num = 5
    return('Accounts : View / Print')
  case nIn_num = 6
    return('Accounts : Change / Edit')
  case nIn_num = 7
    return('Leads : Add / Edit')
  case nIn_num = 8
    return('Student : Add / Control')
  case nIn_num = 9
    return('Adverts : Media reports')
  case nIn_num = 10
    return('Adverts : Add / Edit adverts')
  case nIn_num = 11
    return('Notes on what to do')
  case nIn_num = 12
    return('Student : Trading')
  case nIn_num = 13
    return('Student : Prints')
  case nIn_num = 14
    return('Share : Database maintaince')
  case nIn_num = 15
    return('Student : Course manager')
  case nIn_num = 16
    return('??????')
endcase
return('')
*EOF

***********************************************************
function smic_c_to_n(cIn_string)
local nCnt
for nCnt = 1 to 20              // any num bigger than max menu items
  if cIn_string = smic_n_to_c(nCnt)
    return (nCnt)
  endif
next
return(0)

* eof - smic menu functions

***********************************************************
procedure pgdnoff
setkey(K_PGDN, {|| nil })
setkey(K_PGUP, {|| nil })
setkey(K_CTRL_END, {|| nil})
setkey(K_ESC, {|| nil})
return

***********************************************************
procedure pgdnon
setkey(K_PGDN, NIL)
setkey(K_PGUP, NIL)
setkey(K_CTRL_END, NIL)
setkey(K_ESC, NIL)
return

*******************************************************************************
* PROCEDURE SIMHEAD - CLEARS SCREEN AND DISPLAYS COMPANY TITLE
*                     TIME AND DATE AT THE TOP OF THE SCREEN
*
*******************************************************************************
procedure SIMHEAD ( co_title )
local nWidth
setcolor('rb/n')
@0,0 clear to 24,79
@0,2 say time()
@0,70 say date()
co_title = ltrim(co_title)
co_title = rtrim(co_title)
co_title = ' ' + co_title + ' '
nWidth = int((80-len(co_title))/2)
@1,0 say replicate('*', nWidth-1) + co_title + replicate('*', nWidth-1)
setcolor('w/n,n/w,,,n/w')
return
* eof (simhead)

*******************************************************************************
* function 'FINDSHR' - PROGRAM TO FIND A SPECIFIC SHARE
* Author - Jim West
* 6/6/92
function findshr
local cShare

select share
set filter to share->suspend = ' ' .or. share->suspend = 'N' 

cShare = et_seek('share', {1,2}, .t.)

if empty(cShare)
  dbgobottom()
  dbskip()
  return(' ')
endif
dbseek(cShare)
return(cShare)

* EOF

*******************************************************************************
* FINDPORT - SELECT A SHARE FROM A PORTFOLIO
* JIM WEST

function findport ( cIn_key )
local cShare

select portfol

cShare = et_seek('portfol', {3}, .t.,, cIn_key)

if empty(cShare)
  dbgobottom()
  dbskip()
  return(' ')
endif
dbseek(cIn_key + cShare)
return(cShare)

*EOF()

*******************************************************************************
* FINDBEAR - SELECT A SHARE FROM A PORTFOLIO
* JIM WEST

function findbear ( cIn_key )
local cBear

select bear

cBear = et_seek('bear', {3}, .t., cIn_key)

if empty(cBear)
  dbgobottom()
  dbskip()
  return(' ')
endif
dbseek(cIn_key + cBear)
return(cBear)

*EOF()

*******************************************************************************
* function 'FINDFUT' - PROGRAM TO FIND A SPECIFIC SHARE
* Author - Jim West
* 6/6/92
function findfut
local cFut

select futoptn

cFut = et_seek('futoptn', {1,4}, .t.)

if empty(cFut)
  dbgobottom()
  dbskip()
  return(' ')
endif
  dbseek(cFut)
  return(cFut)

* EOF

*******************************************************************************
* THIS FUNCTION SELECTS A PARTICULAR student
* 1/5/92
* JIM WEST

function seekstd
local cSurname, nRec, cName

select student
cSurname = et_seek('student', {7, 6}, .t.)

if empty(cSurname)
  return(' ')
endif

dbseek(cSurname)
nRec = recno()
dbskip()
if cSurname != student->surname
  dbgoto(nRec)
  return(student->std_code)
endif

cName = et_seek('student', {6, 7}, .t., cSurname)

if empty(cName)
  return(' ')
endif

dbseek(cSurname + cName)
return(student->std_code)

* eof()

*******************************************************************************
* THIS FUNCTION SELECTS A PARTICULAR finished student
* 1/5/92
* JIM WEST

function seekfin
local cSurname, nRec, cName

select finished
cSurname = et_seek('finished', {5, 4}, .t.)

if empty(cSurname)
  return(' ')
endif

dbseek(cSurname)
nRec = recno()
dbskip()
if cSurname != finished->surname
  dbgoto(nRec)
  return(finished->std_code)
endif

cName = et_seek('finished', {4, 5}, .t., cSurname)

if empty(cName)
  return(' ')
endif

dbseek(cSurname + cName)
return(finished->std_code)

* eof()

/*
******************************************************************************
* FUNCTION ORIG_REC
*  THIS FUNCTION COPIES VALUES OF THE CURRENT DATABASES RECORD TO AN ARRAY
*  TO CHECK IF UPDATES ARE ALLOWED
*******************************************************************************
FUNCTION ORIG_REC
LOCAL REC_AR[FCOUNT()], PCNT
FOR PCNT = 1 TO FCOUNT()
  REC_AR[PCNT] := &(FIELD(PCNT))
NEXT
RETURN REC_AR

* EOF

*/

*******************************************************************************
*
* DNL_DT Returns date of download to be used
*
*******************************************************************************
function DNL_DT
local dDownload

dDownload = date()
if seconds() < 68400                    // Time < 19:00, use prev day
  dDownload -= 1
endif

do case
  case dow(dDownload) = 1               // date is Sunday, use Friday
    dDownload -= 2
  case dow(dDownload) = 7               // Date is Saturday, use Friday
    dDownload -= 1
endcase

return(dDownload)

*EOF
