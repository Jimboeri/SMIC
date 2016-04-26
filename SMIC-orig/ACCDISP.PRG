*******************************************************************************
* PROGRAM ACCDISP - DISPLAYS STUDENT ACCOUNT DETAILS
* 14/3/88
* JIM WEST

local cOrig_col, nAcc_type, lStudent, lPas, nNtx
local aAcc_type := {'Student accounts',;
    'Advisory service accounts'}

memvar aDisp, cAcc_type

clear typeahead
public aDisp[0], cAcc_type
setkey(-2, {|| a12_pay_hist()})

#include 'inkey.ch'

begin sequence
  
  select 1
  if !net_use('account', .f.,, 'acccode')
    break
  endif
  
  select 2
  if !net_use('student', .f.,, 'names')
    break
  endif
  
  simhead(memvar->pscr_title)
  findstd()
  if eof()
    break
  endif
  select student
  
  if !empty(student->sold_crs_1) .or. !empty(student->sold_crs_2);
        .or. !empty(student->sold_els)
    lStudent = .t.
    cAcc_type = 'T'
  else
    lStudent = .f.
  endif
  if !empty(student->sold_pas)
    lPas = .t.
    cAcc_type = 'P'
  else
    lPas = .f.
  endif
  if !lStudent .and. !lPas
    break
  endif
  
  simhead(memvar->pscr_title)
  @2,0 clear
  cOrig_col = setcolor(memvar->white_black)
  @2,10 say 'Accounts for '
  @3,10 say 'Account no   '
  @5,3 say 'Pmt type        Pmt date          Amount   Chq held          Paid on'
  @6,0 to 24,79
  setcolor(memvar->yell_black)
  @2,24 say trim(student->title) + ' ' + trim(student->name) + ' ';
      + trim(student->surname)
  setcolor(memvar->cyan_black)
  if lStudent .and. lPas
    nAcc_type = get_arr(aAcc_type, 8,21, memvar->aCh_col3)
    do case
      case nAcc_type = 1
        cAcc_type = 'T'
      case nAcc_type = 2
        cAcc_type = 'P'
      otherwise
        break
    endcase
  endif
  
  @3,24 say student->std_code + ' ' + student->rep
  if cAcc_type = 'T'
    @2,70 say str_stat(student->status)
    if student->deal_ref = 'S' .or. student->deal_ref = 'T'
      @3,70 say 'Splt dep'
    endif
    if student->deal_ref = 'R' .or. student->deal_ref = 'T'
      @4,70 say 'Referal'
    endif
    setcolor(memvar->yell_black)
    @4,10 SAY 'STUDENT ACCOUNTS'
    setcolor(memvar->cyan_black)
  else
    @2,70 say str_stat(student->p_stat)
    setcolor(memvar->yell_black)
    @4,10 say 'PORTFOLIO ADVISORY ACCOUNTS'
    setcolor(memvar->cyan_black)
  endif
  
  a9_load_array()
  
  setcolor(memvar->cyan_black)
  nNtx = 1
  if len(aDisp) > 0
    while nNtx != 0
      nNtx = achoice(7,1,23,77,aDisp, .t., a8_arr_udf())
    enddo
  else
    inkey(0)
  endif
  setcolor(cOrig_col)
end sequence
close databases
setkey(-2, nil)
return

* EOF

*******************************************************************************
* FUNCTION A8_ARR_UDF
*          USER DEFINED FUNCTION USED TO CONTROL ACHOICE
*          DISPLAYS OPTION ON TOP OF SCREEN AND
*          ALLOWS EXIT ON CORRECT KEYS
*
*******************************************************************************
function a8_arr_udf (pmode, pinx, prow)
local cChar, cOrig_col
cChar = upper(chr(lastkey()))
cOrig_col = setcolor(memvar->yell_black)
setcolor(cOrig_col)
do case
  case lastkey() = K_ESC
    return(0)
  otherwise
    return(1)
endcase
return(2)

* EOF

