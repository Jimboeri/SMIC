*******************************************************************************
* DIVIDEND - PAY DIVIDENDS TO STUDENTS AFTER LAST DIVIDEND DATE
* JIM WEST
* 5/91

LOCAL aDividend := {}, nCnt, nGEN_NTX, nVAL, nPORT_RECS := 0
LOCAL nNO_CURR_HLD, nRecs
memvar cMessage

#define EOL             chr(13) + chr(10)
#define SHR_NAME        1
#define SHR_DIVIDEND    2
#define SHR_PAYS        3
#define SHR_VALUE       4

simhead(memvar->pscr_title)
disp_msg(5,,'DIVIDEND EXTRACT')

wopen(8,10,14,70)
setcursor(0)
wbox(0)
@0,0 say center('SEARCHING FOR DIVIDENDS')

begin sequence
  select 1
  if !net_use('shrdescr', .f.,, 'shrdescr')
    break
  endif
  
  select 2
  if !net_use('transact', .f.,, 'trancode')
    break
  endif
  
  select 3
  if !net_use('student', .f.,, 'stdcode')
    break
  endif
  
  select 4
  if !net_use('portfol', .f.,, 'portfol')
    break
  endif
  
  select 5
  if !net_use('share', .f.,, 'shrname')
    break
  endif
  
  select Shrdescr
  nRecs = 0
  while !eof()
    @1,0 say replicate('±', int(nRecs / lastrec() * 60))
    nRecs++
    if !empty(Shrdescr->div_dt) .and. Shrdescr->div_dt < date()
      select Share
      dbseek(Shrdescr->share)
      if found() .and. Share->suspend != 'N'
        aadd(aDividend, {Shrdescr->share, Shrdescr->dividend, 0, 0})
      endif
    endif
    select Shrdescr
    dbskip()
  enddo
  
  @0,0 say center('SCANNING PORTFOLIO DATABASE', .t.)
  
  if len(aDividend) > 0
    nRecs = 0
    select Portfol
    dbgotop()
    while !eof()
      @2,0 say replicate('±', int(nRecs / lastrec() * 60))
      nRecs++
      for nCnt = 1 to len(aDividend)
        if aDividend[nCnt, SHR_NAME] = Portfol->share
          exit
        endif
      next
      if nCnt > len(aDividend)
        dbskip()
        loop
      endif
      if aDividend[nCnt, SHR_NAME] = Portfol->share
        tts_on()
        select Student
        dbseek(Portfol->std_code)
        if student->status = 'C'
          nVal = aDividend[nCnt, SHR_DIVIDEND] * Portfol->qty / 100
          reclock('Student')
          Student->cash := Student->cash + nVal
          dbunlock()
          select Transact
          dbappend()
          reclock('Transaction')
          Transact->std_code  := Student->std_code
          Transact->share     := Portfol->share
          Transact->type      := 'T'
          Transact->trn_type  := 'DIV'
          Transact->qty       := Portfol->qty
          Transact->price     := aDividend[nCnt, SHR_DIVIDEND]
          Transact->value     := nVal
          Transact->brokerage := 0
          Transact->tax       := 0
          Transact->handle    := 0
          Transact->cost_hold := 0
          Transact->trn_dt    := date()
          dbunlock()
          aDividend[nCnt, SHR_PAYS]++
          aDividend[nCnt, SHR_VALUE] += nVal
        endif
        tts_off()
      endif
      select Portfol
      nPort_recs++
      dbskip()
    enddo
    
    select Shrdescr
    tts_on()
    for nGen_ntx = 1 to Len(aDividend)
      if dbseek(aDividend[nGen_ntx, SHR_NAME])
        reclock('Share comment')
        if Shrdescr->div_type = 'I'
          Shrdescr->int_div := Shrdescr->dividend
          Shrdescr->int_div_dt := Shrdescr->div_dt
        elseif Shrdescr->div_type = 'F'
          Shrdescr->fin_div := Shrdescr->dividend
          Shrdescr->fin_div_dt := Shrdescr->div_dt
        endif
        Shrdescr->div_type := ' '
        Shrdescr->div_dt := ctod('  /  /  ')
        Shrdescr->dividend := 0
        dbunlock()
        cMessage += aDividend[nGEN_NTX, SHR_NAME] + '  No of dividends ' +;
            str(aDividend[nGen_ntx, SHR_PAYS],4,0) + ' TOTAL VALUE ' +;
            str(aDividend[nGen_ntx, SHR_VALUE],12,2) + EOL
      endif
    next
    tts_off()
  endif
  
  @0,0 say center('INDEXING PORTFOLIO DATABASE', .t.)
  et_close('Portfol')  
  select 4
  if !net_use('portfol', .t.)
    break
  endif

  index on portfol->share to port_tmp eval ind_prog(3) every 5
  
  @0,0 say center('SCANNING FOR DELETEABLE SHARES', .t.)
  select Shrdescr
  dbgotop()
  nRecs = 0
  while !eof()
    @4,0 say replicate('±', int(nRecs / lastrec() * 60))
    nRecs++
    if !empty(Shrdescr->kill_dt) .and. Shrdescr->kill_dt + 14 < date()
      tts_on()
      select portfol
      if !dbseek(shrdescr->share)
        select Share
        if dbseek(Shrdescr->share)
          reclock('share')
          dbdelete()
          dbunlock()
        endif
        select Shrdescr
        reclock('share comment')
        dbdelete()
        dbunlock()
      endif
      tts_off()
    endif
    select Shrdescr
    dbskip()
  enddo
  
  if net_use('param', .f.)
    reclock('Parameter')
    param->run_div := 'N'
    memvar->prun_div := 'N'
    dbunlock()
  endif
end sequence
et_close('Shrdescr')
et_close('Transact')
et_close('Student')
et_close('Portfol')
et_close('Share')
et_close('Param')

wclose()

return

* eof
