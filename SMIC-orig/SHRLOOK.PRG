*******************************************************************************
* PROGRAM 'SHRLOOK'
* AUTHOR JIM WEST (E.T.)
* 1/2/88

local cOrig_col, lDes

select share
findshr()

if found()
  simhead(memvar->pscr_title)
  cOrig_col = setcolor(memvar->scr_heading)
  @2,30 say 'Share Display screen'
  @4,0 clear
  setcolor(memvar->cyan_black)
  @4,1 say 'Share name: '
  select shrdescr
  if !dbseek(share->share)
    lDes = .F.
  else
    lDes = .T.
  endif
  select Share
  @5,1 say 'Full name: '
  @4,63 say 'Price'
  @5,63 say 'Volume'
  @9,0 say 'Buy comment'
  @12,0 say 'Sell comment'
  @15,0 say 'Fundamental Comment'
  if lDes
    select shrdescr
    @6,1 say 'Sector:    '
    if !empty(shrdescr->div_dt)
      @7,1 SAY 'Dividend:      '
      @8,1 SAY 'Dividend date: '
    endif
    if !empty(shrdescr->int_div_dt)
      @7,26 say 'Last int div '
      @8,26 say 'Last int LDR '
    endif
    if !empty(shrdescr->fin_div_dt)
      @7,53 say 'Last fin div '
      @8,53 say 'Last fin LDR '
    endif

    setcolor(memvar->white_black)
    if !empty(shrdescr->div_dt)
      @7,17 say str(shrdescr->dividend)
      @8,17 say dtoc(shrdescr->div_dt)
    endif
    if !empty(shrdescr->int_div_dt)
      @7,40 say ltrim(str(shrdescr->int_div)) + 'c'
      @8,40 say dtoc(shrdescr->int_div_dt)
    endif
    if !empty(shrdescr->fin_div_dt)
      @7,68 say ltrim(str(shrdescr->fin_div)) + 'c'
      @8,68 say dtoc(shrdescr->fin_div_dt)
    endif
    @4,13 say share->share
    @5,13 say share->full_name
    @4,70 say ltrim(str(share->price))
    @5,70 say ltrim(str(share->volume))
    @6,13 say shrdescr->sector
    @9,70 say shrdescr->lst_b_chg
    @10,0 say shrdescr->buy_1
    @11,0 say shrdescr->buy_2
    @12,70 say shrdescr->lst_s_chg
    @13,0 say shrdescr->sell_1
    @14,0 say shrdescr->sell_2
    @15,70 say shrdescr->lst_f_chg
    @16,0 say shrdescr->fundamnt_1
    @17,0 say shrdescr->fundamnt_2
    @18,0 say shrdescr->fundamnt_3
    @19,0 say shrdescr->fundamnt_4
    @20,0 say shrdescr->fundamnt_5
    @21,0 say shrdescr->fundamnt_6
    @22,0 say shrdescr->fundamnt_7
    @23,0 say shrdescr->fundamnt_8
  endif
  wait ' '
  setcolor(cOrig_col)
endif (share != space)
return
* eof