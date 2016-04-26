*******************************************************************************
* PROGRAM 'SHRHOLD' - EDIT HOLDING COMMENTS FOR PAS STUDENTS
* AUTHOR JIM WEST (E.T.)
* 1/2/88

local nCnt, cMem_Field, cRec_Field
memvar cHold1, cHold2, cHold3, cHold4, cHold5, cHold6
memvar getlist

select 2
if !net_use('shrdescr', .f.,, 'shrdescr')
  return
endif

select 1
if !net_use('share', .f.,, 'shrname')
  close database
  return
endif

simhead(memvar->pscr_title)
findshr()
if !eof()
  simhead(memvar->pscr_title)
  @2,30 say 'Share edit screen'
  select shrdescr
  if !dbseek(Share->share)
    dbappend()
    reclock('Share comment')
    shrdescr->share := Share->share
    dbunlock()
  endif
  @3,1 say 'Share name:  ' + Share->share
  @3,50 say 'Price ' + str(share->price)
  @4,1 say 'Full name: ' + share->full_name
  @5,1 say 'Sector:    ' + shrdescr->sector
  if share->suspend = ' '
    if !empty(Shrdescr->div_dt)
      @6,1 say 'Dividend:      ' + str(Shrdescr->dividend)
      @7,1 say 'Dividend date: ' + dtoc(Shrdescr->div_dt)
    endif
    if !empty(Shrdescr->int_div_dt)
      @6,26 say 'Last int div ' + ltrim(str(Shrdescr->int_div)) + 'c'
      @7,26 say 'Last int LDR ' + dtoc(Shrdescr->int_div_dt)
    endif
    if !empty(Shrdescr->fin_div_dt)
      @6,53 say 'Last fin div ' + ltrim(str(Shrdescr->fin_div)) + 'c'
      @7,53 say 'Last fin LDR ' + dtoc(Shrdescr->fin_div_dt)
    endif
  endif
  cHold1 = Shrdescr->hold_1
  cHold2 = Shrdescr->hold_2
  cHold3 = Shrdescr->hold_3
  cHold4 = Shrdescr->hold_4
  cHold5 = Shrdescr->hold_5
  cHold6 = Shrdescr->hold_6
  @8,0 say 'Holding comment'
  @8,70 say Shrdescr->lst_h_chg
  @9,0 get cHold1
  @10,0 get cHold2
  @11,0 get cHold3
  @12,0 get cHold4
  @13,0 get cHold5
  @14,0 get cHold6
  @15,0 say 'Fundamental Comment'
  @15,70 say Shrdescr->lst_f_chg
  @16,0 say Shrdescr->fundamnt_1
  @17,0 say Shrdescr->fundamnt_2
  @18,0 say Shrdescr->fundamnt_3
  @19,0 say Shrdescr->fundamnt_4
  @20,0 say Shrdescr->fundamnt_5
  @21,0 say Shrdescr->fundamnt_6
  @22,0 say Shrdescr->fundamnt_7
  @23,0 say Shrdescr->fundamnt_8
  *
  read
  reclock('share comment')
  for nCnt = 1 to 2
    cMem_Field = 'cHold' + ltrim(str(nCnt))
    cRec_Field = 'SHRDESCR->HOLD_' + ltrim(str(nCnt))
    if &cMem_Field != cRec_Field
      shrdescr->lst_h_chg := date()
      exit
    endif
  next
  shrdescr->HOLD_1 := cHold1
  shrdescr->HOLD_2 := cHold2
  shrdescr->HOLD_3 := cHold3
  shrdescr->HOLD_4 := cHold4
  shrdescr->HOLD_5 := cHold5
  shrdescr->HOLD_6 := cHold6
  dbunlock()
endif (SHARE Found)
dbcloseall()
return
* eof
