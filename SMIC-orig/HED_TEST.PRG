*******************************************************************************
* SIMPLE PROGRAM FOR REPS
* Author - Jim West
* 1/2/88
* ----     SET UP SYSTEM DEFAULTS

parameter param_1, param_2

LOCAL nChoice := 1, nNtx := 1
local cParam, val_param, aDir
local nCnt, cInput := '        '
memvar aMain_menu, getlist

memvar force_bw, force_prfile, nTime_out, Info_col
memvar disp_test, aCh_col, aCh_col1, aCh_col2, pScr_title, pPrnt_title
memvar scr_heading, scr_title, pLst_price, pLst_f_upd, pOvrdrft_l, cCo_name
memvar mPw_nme, mPw_pas, mPw_lev
memvar pLst_order, pLst_reins, pLst_rleads, pLst_unall, pLst_medst
memvar pLst_recck, pLst_bear, pRun_nplab, pRun_div, cDnl_dir1, cDnl_dir2

#include 'defcolor.ch'
#include 'defprint.ch'

public force_bw := force_prfile := .f.

#include "colour.ch"
#include "printer.ch"
#include "inkey.ch"

set date british
set deleted on

for nCnt = 1 to 2
  cParam = 'param_' + ltrim(str(nCnt,2,0))
  val_param = &cParam
  if valtype(val_param) = 'C'
    do case
      case upper(val_param) = '/B'
        force_bw = .t.
      case upper(val_param) = '/P'
        force_prfile := .t.
    endcase
  endif
next

do upgrade

if !net_use('param', .f.)
  return
endif

plst_order := param->lst_order
plst_reins := param->lst_reins
plst_rleads := param->lst_rleads
plst_unall := param->lst_unall
plst_medst := param->lst_medst
plst_recck := param->lst_recck
plst_bear := param->lst_bear
dLst_int := param->lst_int
prun_div := param->run_div
prun_nplab := param->run_nplab
cDnl_dir1 := trim(param->dnl_dir)
cDnl_dir2 := trim(param->net_dnldir)
dbclosearea()

clear screen
@5,5 get cInput
read

if !empty(cInput)
  do hed_upd with cInput
else
  adir = directory('*.HED')
  for nCnt = 1 to len(aDir)
    cInput = substr(aDir[nCnt, 1],1,8)
    do hed_upd with cInput
  next
endif

#include "smic.ch"

clear screen
quit

*EOF

*******************************************************************************
function shr_date ( dIn_dt)
local dReference := ctod('01/01/80')
return(dIn_dt - dReference)

