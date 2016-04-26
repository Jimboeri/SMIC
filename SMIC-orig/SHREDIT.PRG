*******************************************************************************
* PROGRAM 'SHREDIT'
* AUTHOR JIM WEST (E.T.)
* 1/2/88

local nCnt, cRec_Field, cMem_Field
local cSector, cFull_name
memvar cBuy_1, cBuy_2
memvar cSell_1, cSell_2
memvar cFund_1, cFund_2, cFund_3, cFund_4, cFund_5, cFund_6, cFund_7, cFund_8
memvar getlist

select 2
if !net_use('shrdescr', .f., , 'shrdescr')
  return
endif

select 1
if !net_use('share', .f., , 'shrname')
  close database
  return
endif

if empty(et_use_dbf('sectors'))
dbcloseall()
return
endif

simhead(memvar->pscr_title)
select share
findshr()
if !eof()
  simhead(memvar->pscr_title)
  @2,30 say 'Share edit screen'
  @4,1 say 'Share name: '
  @4,13 clear
  @5,1 clear
  @4,13 say Share->share
  select Shrdescr
  if !dbseek(Share->share)
    dbappend()
    reclock('Share comment')
    shrdescr->share := Share->share
    dbunlock()
  endif
  cFull_name := share->full_name
  cSector := Shrdescr->sector
  cBuy_1  := Shrdescr->buy_1
  cBuy_2  := Shrdescr->buy_2
  cSell_1 := Shrdescr->sell_1
  cSell_2 := Shrdescr->sell_2
  cFund_1 := Shrdescr->fundamnt_1
  cFund_2 := Shrdescr->fundamnt_2
  cFund_3 := Shrdescr->fundamnt_3
  cFund_4 := Shrdescr->fundamnt_4
  cFund_5 := Shrdescr->fundamnt_5
  cFund_6 := Shrdescr->fundamnt_6
  cFund_7 := Shrdescr->fundamnt_7
  cFund_8 := Shrdescr->fundamnt_8
  select sectors
  if dbseek(share->sec_cd) .and. !empty(sectors->full_name)
    cSector := sectors->full_name
  endif
  @4,0 clear
  @4,1 say 'Share name:  ' + Share->share
  @4,50 say 'Price ' + str(share->price)
  @5,1 say 'Full name: ' get cFull_name picture '@!'
  @6,1 say 'Sector:    ' get cSector picture '@!'
  if share->suspend = ' '
    if !empty(Shrdescr->div_dt)
      @7,1 say 'Dividend:      ' + str(Shrdescr->dividend)
      @8,1 SAY 'Dividend date: ' + dtoc(Shrdescr->div_dt)
    endif
    if !empty(Shrdescr->int_div_dt)
      @7,26 say 'Last int div ' + ltrim(str(Shrdescr->int_div)) + 'c'
      @8,26 say 'Last int LDR ' + dtoc(Shrdescr->int_div_dt)
    endif
    if !empty(Shrdescr->fin_div_dt)
      @7,53 say 'Last fin div ' + ltrim(str(Shrdescr->fin_div)) + 'c'
      @8,53 say 'Last fin LDR ' + dtoc(Shrdescr->fin_div_dt)
    endif
  endif
  @9,0 say 'Buy comment'
  @9,70 say Shrdescr->lst_b_chg
  @10,0 get cBuy_1
  @11,0 get cBuy_2
  @12,0 say 'Sell comment'
  @12,70 say Shrdescr->lst_s_chg
  @13,0 get cSell_1
  @14,0 get cSell_2
  @15,0 say 'Fundamental Comment'
  @15,70 say Shrdescr->lst_f_chg
  @16,0 get cFund_1
  @17,0 get cFund_2
  @18,0 get cFund_3
  @19,0 get cFund_4
  @20,0 get cFund_5
  @21,0 get cFund_6
  @22,0 get cFund_7
  @23,0 get cFund_8
  *
  read
  select shrdescr
  tts_on()
  reclock('share comment')
  for nCnt = 1 to 2
    cMem_Field = 'cBuy_' + ltrim(str(nCnt))
    cRec_Field = 'SHRDESCR->BUY_' + ltrim(str(nCnt))
    if &cMem_Field != &cRec_Field
      shrdescr->lst_b_chg := date()
      exit
    endif
  next
  for nCnt = 1 to 2
    cMem_Field = 'cSell_' + ltrim(str(nCnt))
    cRec_Field = 'SHRDESCR->SELL_' + ltrim(str(nCnt))
    if &cMem_Field != &cRec_Field
      shrdescr->lst_s_chg := date()
      exit
    endif
  next
  for nCnt = 1 to 8
    cMem_Field = 'cFund_' + ltrim(str(nCnt))
    cRec_Field = 'SHRDESCR->FUNDAMNT_' + ltrim(str(nCnt))
    if &cMem_Field != &cRec_Field
      shrdescr->lst_f_chg := date()
      exit
    endif
  next
  shrdescr->share      := Share->share
  shrdescr->sector     := cSector
  shrdescr->buy_1      := cBuy_1
  shrdescr->buy_2      := cBuy_2
  shrdescr->sell_1     := cSell_1
  shrdescr->sell_2     := cSell_2
  shrdescr->fundamnt_1 := cFund_1
  shrdescr->fundamnt_2 := cFund_2
  shrdescr->fundamnt_3 := cFund_3
  shrdescr->fundamnt_4 := cFund_4
  shrdescr->fundamnt_5 := cFund_5
  shrdescr->fundamnt_6 := cFund_6
  shrdescr->fundamnt_7 := cFund_7
  shrdescr->fundamnt_8 := cFund_8
  dbunlock()
  select Share
  reclock('Share')
  share->full_name := cFull_name
  dbunlock()
  select sectors
  if dbseek(share->sec_cd)
    reclock()
    sectors->full_name := cSector
    dbunlock()
  endif
  tts_off()
endif
dbcloseall()
return
* EOF
