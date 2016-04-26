*******************************************************************************
*
* CHECKRUN - RUNS NIGHT BATCH JOBS
*
* The following progs are run
*       1: UPGRADE              TTS N/A
*       2: GM_UPD
*       3: HED_UPD
*       4: PRCEXTR              TTS
*       5: TRNORDER             TTS
*       6: BEARDLV              TTS
*       7: DIVIDEND             TTS
*       8: TRNNPLAB             TTS
*       9: FUTEXP               TTS
*       10: FUTAUTO             TTS
*       11: FUTMARG             TTS
*       12: INTEREST            TTS
*       13: LDUNALL             TTS
*       14: RECCHECK
*       15: STDREIN2            TTS
*
*******************************************************************************

parameter param_1, param_2, param_3

local cParam, nCnt, val_param

local nWeek_day, dDownload, cDownload, cMsg_dt, cExp_dt, cMsg_name, cMsg_from
local cNet_fl, aStru, dLst_int, cDisk, cDir, nAt
local lAuto := .f.              // set for automatic runs
local nKey

memvar force_bw, force_prfile, Info_col
memvar disp_test, aCh_col, aCh_col1, aCh_col2, pScr_title, pPrnt_title
memvar scr_heading, scr_title, pLst_price, pLst_f_upd, pOvrdrft_l, cCo_name
memvar mPw_nme, mPw_pas, mPw_lev

memvar cMessage, nTime_in, nMins, nSecs
memvar pLst_order, pLst_reins, pLst_rleads, pLst_unall, pLst_medst
memvar pLst_recck, pLst_bear, pRun_nplab, pRun_div, cDnl_dir1, cDnl_dir2
memvar cHed_dir

#include 'defcolor.ch'
#include 'defprint.ch'

public force_bw, force_prfile
private nTime_in, nMins, nSecs

private force_bw := .f., force_prfile := .f.

#include "colour.ch"
#include "smic.ch"
#include 'printer.ch'
#include "inkey.ch"

#define EOL     chr(13) + chr(10)

set date british
set deleted on

for nCnt = 1 to 3
  cParam = 'param_' + ltrim(str(nCnt,2,0))
  val_param = &cParam
  if valtype(val_param) = 'C'
    do case
      case upper(val_param) = '/B'
        force_bw = .t.
      case upper(val_param) = '/P'
        force_prfile = .t.
      case upper(val_param) = '/AUTO'
        lAuto = .t.
    endcase
  endif
next

if lAuto
endif

do upgrade

nTime_in := seconds()

simhead(memvar->pscr_title)

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
cHED_dir = trim(param->hed_dir)
dbclosearea()

* GAME UPDATE

do gm_upd

* PRCEXTR

set date italian

dDownload = dnl_dt()

cExp_dt = dtoc(dDownload)
deletefile('EXIST.TXT')
if file(cDnl_dir1 + cExp_dt + '.DN') .or. file(cDnl_dir2 + cExp_dt + '.DN')
  memowrit('EXIST.TXT', ' ')
else
  memowrit(cDnl_dir1 + 'DATE', cExp_dt)
endif

nWeek_day = dow(date())
if nWeek_day = 1 .or. nWeek_day = 7     // Sunday & Saturday
  nWeek_day = 6                         // Friday
endif

/*
if nWeek_day = 2                        // Monday
  dDownload = date() - 3                // Friday
else
  dDownload = date() - 1                // Yesterday
endif
*/

cMsg_dt = substr(cExp_dt,7,2) + substr(cExp_dt,4,2) + substr(cExp_dt,1,2)

cMessage = ''

if plst_price != dDownload
  cMsg_name = cMsg_dt + '.MSG'
  cMsg_from = cDnl_dir1 + cMsg_dt + '.MSG'
  if file(cMsg_from)
    if !file(cMsg_name)
      filecopy(cMsg_from,  cMsg_name)
      cMessage += 'Message file copied' + EOL
    endif
  endif
  
  cMsg_from = cDnl_dir2 + cMsg_dt + '.MSG'
  if file(cMsg_from)
    if !file(cMsg_name)
      filecopy(cMsg_from,  cMsg_name)
      cMessage += 'Message file copied' + EOL
    endif
  endif
  
  do hed_upd with cExp_dt

  if file(cExp_dt + '.DN') .or. file(cDnl_dir1 + cExp_dt + '.DN');
      .or. file(cDnl_dir2 + cExp_dt + '.DN')
    cMessage += 'Time started = ' + time() + EOL
    do prcextr with cExp_dt
    cMessage += 'Time finished = ' + time() + EOL
    xfgen('*.DN', date()-7)
    cDisk = ''
    cDir = cDnl_dir1
    if at(':', cDir) = 2
      cDisk = substr(cDir,1,1)
      cDir = stuff(cDir, 1, 2, '')
    endif
    cDir = remright(cDir, '\')
    xfgen('*.DN', date()-7, cDir, cDisk)
  else
    cMessage += 'Download file not found' + EOL
  endif
endif

nSecs := seconds() - nTime_in
nMins := int(nSecs/60)
nSecs := nSecs - (nMins*60)
cMessage += 'PRCEXTR took ' + ltrim(str(nMins,12,0)) + ' mins & ' +;
    ltrim(str(nSecs,2,0)) + ' secs to run.' + EOL

memowrit('1PRCEXTR.AAA', cMessage)
set date british

******************** TRNORDER

nTime_in = SECONDS()
cMessage = ''
if pLst_order != date() .and. pLst_price = ctod(cExp_dt)
  cMessage += 'Time started = ' + time() + EOL
  DO TRNORDER
  pLst_order = date()
  cMessage += 'Time finished = ' + time() + EOL
endif

nSecs := seconds() - nTime_in
nMins := int(nSecs/60)
nSecs := nSecs - (nMins*60)
cMessage += 'TRNORDER took ' + ltrim(str(nMins,12,0)) + ' mins & ' +;
    ltrim(str(nSecs,2,0)) + ' secs to run.' + EOL

memowrit('2TRNORDE.AAA', cMessage)

**************** BEARDLV

nTime_in = SECONDS()
cMessage = ''
if pLst_bear != date() .and. pLst_price = ctod(cExp_dt)
  cMessage += 'Date run on  = ' + dtoc(date()) + EOL
  cMessage += 'Time started = ' + time() + EOL
  do beardlv
  pLst_bear = date()
  cMessage += 'Time finished = ' + time() + EOL
  nSecs := seconds() - nTime_in
  nMins := INT(nSecs/60)
  nSecs := nSecs - (nMins*60)
  cMessage += 'BEARDLV took ' + ltrim(str(nMins,12,0)) + ' mins & ';
      + ltrim(str(nSecs,2,0)) + ' secs to run.' + EOL
  
  memowrit('3BEARDLV.AAA', cMessage)
endif

************* DIVIDEND

nTime_in = seconds()
cMessage = ''
if pRun_div = 'Y' .and. pLst_price = ctod(cExp_dt)
  cMessage += 'Date run on  = ' + dtoc(date()) + EOL
  cMessage += 'Time started = ' + time() + EOL
  DIVIDEND()
  cMessage += 'Time finished = ' + time() + EOL
  nSecs := seconds() - nTime_in
  nMins := int(nSecs/60)
  nSecs := nSecs - (nMins*60)
  cMessage += 'DIVIDEND took ' + ltrim(str(nMins,2,0)) + ' mins & ' +;
      ltrim(str(nSecs,2,0)) + ' secs to run.' + EOL
  
  memowrit('4DIVIDEN.AAA', cMessage)
endif


************* TRNNPLAB

nTime_in = SECONDS()
cMessage = ''
if pRun_nplab = 'Y' .and. plst_price = ctod(cExp_dt)
  cMessage += 'Date run on  = ' + dtoc(date()) + EOL
  cMessage += 'Time started = ' + time() + EOL
  do trnnplab
  cMessage += 'Time finished = ' + time() + EOL
  nSecs := seconds() - nTime_in
  nMins := int(nSecs/60)
  nSecs := nSecs - (nMins*60)
  cMessage += 'TRNNPLAB took ' + ltrim(str(nMins,2,0)) + ' mins & ' +;
      ltrim(str(nSecs,2,0)) + ' secs to run.' + EOL
  
  memowrit('5TRNNPLAB.AAA', cMessage)
endif

******************** FUTURES

nTime_in = seconds()
cMessage = ''
if pLst_f_upd != date() .and. pLst_price = ctod(cExp_dt)
  cMessage += 'Time started = ' + time() + EOL
  do futexp
  do futauto
  if pLst_f_upd = date()
    do futmarg
  endif
  cMessage += 'Time finished = ' + time() + EOL
endif

nSecs := seconds() - nTime_in
nMins := int(nSecs/60)
nSecs := nSecs - (nMins*60)
cMessage += 'FUTURES took ' + ltrim(str(nMins,12,0)) + ' mins & ' +;
    ltrim(str(nSecs,2,0)) + ' secs to run.' + EOL

memowrit('6FUTURE.AAA', cMessage)


*************** Interest

nTime_in = seconds()
cMessage = ''
if (dow(date()) = 3 .or. date() > dLst_int + 7) .and. dlst_int != date()
  cMessage += 'Date run on  = ' + dtoc(date()) + EOL
  cMessage += 'Time started = ' + time() + EOL
  interest()
  cMessage += 'Time finished = ' + time() + EOL
  nSecs := seconds() - nTime_in
  nMins := int(nSecs/60)
  nSecs := nSecs - (nMins*60)
  cMessage += 'INTEREST took ' + ltrim(str(nMins,2,0)) + ' mins & ';
      + ltrim(str(nSecs,2,0)) + ' secs to run.' + EOL
  
  memowrit('4INTERST.AAB', cMessage)
endif


*************** LDUNALL

nTime_in = SECONDS()
cMessage = ''
if dow(date()) = 6 .and. pLst_unall != date()
  cMessage += 'Date run on  = ' + dtoc(date()) + EOL
  cMessage += 'Time started = ' + time() + EOL
  ldunall()
  cMessage += 'Time finished = ' + time() + EOL
  nSecs := seconds() - nTime_in
  nMins := int(nSecs/60)
  nSecs := nSecs - (nMins*60)
  cMessage += 'LDUNALL took ' + ltrim(str(nMins,2,0)) + ' mins & ' +;
      ltrim(str(nSecs,2,0)) + ' secs to run.' + EOL
  
  memowrit('8LDUNALL.AAA', cMessage)
endif


*************** RECCHECK

nTime_in = SECONDS()
cMessage = ''
if (day(date()) = 1 .and. plst_recck != date()) .or. pLst_recck + 32 < date()
  cMessage += 'Date run on  = ' + dtoc(date()) + EOL
  cMessage += 'Time started = ' + time() + EOL
  reccheck()
  cMessage += 'Time finished = ' + time() + EOL
  nSecs := seconds() - nTime_in
  nMins := int(nSecs/60)
  nSecs := nSecs - (nMins*60)
  cMessage += 'RECCHECK took ' + ltrim(str(nMins,12,0)) + ' mins & ' +;
      ltrim(str(nSecs,2,0)) + ' secs to run.' + EOL
  
  memowrit('2RECCHEC.AAB', cMessage)
endif

******************** STDREIN2

nTime_in = seconds()
cMessage = ''
if pLst_reins != date()
  cMessage += 'Time started = ' + time() + EOL
  do stdrein2
  pLst_reins = date()
  cMessage += 'Time finished = ' + time() + EOL
endif

nSecs := seconds() - nTime_in
nMins := int(nSecs/60)
nSecs := nSecs - (nMins*60)
cMessage += 'STDREIN2 took ' + ltrim(str(nMins,12,0)) + ' mins & ' +;
    ltrim(str(nSecs,2,0)) + ' secs to run.' + EOL

memowrit('3STDREIN.AAB', cMessage)

clear screen

if lAuto
  clear screen
  @10,0 say center('Paused')
  while .t.
    nSecs = seconds()
    nSecs = nSecs - (int(nSecs/3600) * 3600)
    if nSecs < 60
      quit
    endif
    nKey = inkey(10)
    if nKey = K_ESC
      quit
    endif
  enddo
endif

RETURN

*EOF
