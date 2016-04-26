*******************************************************************************
*
* ACCDISP1 - DISPLAYS STUDENT PAYMENT SCHEDULE
*            CALLED FROM STDMENU2 WHICH IS CALLED FROM TWIM
*
*******************************************************************************

local cOrig_col
memvar aDisp, aValid, cStd_code, nMax, nNtx, cAcc_type

clear typeahead
public aDisp[0], cStd_code, nMax, nNtx, cAcc_type := memvar->portfol_type
nMax = 0

select 11
if !net_use('account', .f.,, 'acccode')
  return
endif

select Student

simhead(memvar->pscr_title)
@2,0 clear
cOrig_col = setcolor(memvar->white_black)
cStd_code = student->std_code
@2,10 say 'Accounts for '
@3,10 say 'Account no   '
@5,3 say 'Pmt type        Pmt date          Amount   Chq held          Paid on'
@6,0 to 24,79
setcolor(memvar->yell_black)
@2,24 say trim(Student->title) + ' ' + trim(Student->name) + ' ' +;
    trim(Student->surname)
setcolor(memvar->cyan_black)
@3,24 say Student->std_code + ' ' + Student->rep
if memvar->portfol_type = 'T'
  @2,70 say str_stat(Student->status)
  if Student->deal_ref = 'S' .or. Student->deal_ref = 'T'
    @3,70 say 'Splt dep'
  endif
  if Student->deal_ref = 'R' .or. Student->Deal_ref = 'T'
    @4,70 say 'Referal'
  endif
  setcolor(memvar->yell_black)
  @4,10 say 'STUDENT ACCOUNTS'
  setcolor(memvar->cyan_black)
else
  @2,70 say str_stat(Student->p_stat)
  setcolor(memvar->yell_black)
  @4,10 say 'PORTFOLIO ADVISORY ACCOUNTS'
  setcolor(memvar->cyan_black)
endif

a9_load_array()

setcolor(memvar->cyan_black+','+memvar->cyan_black)
nNtx = 1
while nNTX != 0
  nNtx = achoice(7,1,23,77,aDisp, .t., a8_arr_udf())
enddo
setcolor(cOrig_col)
et_close('account')
return

* EOF

*******************************************************************************
* FUNCTION A1_PMT_TYPE
*          RETURNS PAYMENT TYPE OF ACCOUNT
*******************************************************************************
static function a1_pmt_type ( cString )
do case
  case substr(cString,2,3) = 'Cre'
    return('C')
  case substr(cString,2,3) = 'Che'
    return('Q')
  case substr(cString,2,3) = 'Deb'
    return('D')
  case substr(cString,2,3) = 'Oth'
    return('O')
endcase
return('?')
* eof()

*******************************************************************************
* FUNCTION A2_PMT_DT
*          RETURNS AGREED DATE OF PAYMENT
*******************************************************************************
static function a2_pmt_dt ( cString )
local cDate
cDate = substr(cString,20,8)
return(ctod(cDate))
* EOF

*******************************************************************************
* FUNCTION A3_AMOUNT
*          RETURNS AMOUNT OF ACCOUNT
*******************************************************************************
static function a3_amount ( cString )
local cAmount
cAmount = trim(substr(cString,31,13))
return(val(cAmount))
* EOF

*******************************************************************************
* FUNCTION A4_COMMENT
*          RETURNS COMMENT FIELD OF 'D' REC
*******************************************************************************
static function a4_comment ( cString )
return(substr(cString,81,1))
* EOF

*******************************************************************************
* FUNCTION A7_C_RECNO
*          RETURNS RECORD NO OF 'C' REC
*******************************************************************************
static function a7_c_recno ( cString )
local cRecno
if len(cString) = 97
  cRecno = trim(substr(cString,90,8))
  if cRecno != space(8)
    return(val(cRecno))
  else
    return(0)
  endif
else
  return(0)
endif
return 0
* EOF

