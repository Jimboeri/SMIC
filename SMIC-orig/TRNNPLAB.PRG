*******************************************************************************
* PROGRAM 'TRNNPLAB' - RIGHTS OPTION ABANDONED
* AUTHOR JIM WEST
* 9/2/88

local nNo_npl, nRec, dExpire, nCnt
memvar cMessage
nNo_npl := 0

simhead(memvar->pscr_title)
wopen(8,10,12,70)
wcenter()
wbox(0)
setcursor(0)
@0,0 say center('LOOKING FOR NIL PAID LETTERS TO ABANDON')

begin sequence
  
  if empty(et_use_dbf('transact'))
    break
  endif
  
  if empty(et_use_dbf('shrdescr'))
    break
  endif
  
  if empty(et_use_dbf('portfol'))
    break
  endif
  
  if empty(et_use_dbf('share'))
    break
  endif
  
  nRec = 0
  select share
  while !eof()
    nRec++
    tts_on()
    @1,0 say replicate('±', nRec / lastrec() * 60)
    select shrdescr
    if dbseek(Share->share)
      dExpire = shrdescr->div_dt
    else
      dExpire = ctod('  /  /  ')
    endif
    if Share->suspend = 'N' .and. dExpire <= date()     // NPL's that need to
      select shrdescr                                   // be abandoned
      if !found() .or. empty(shrdescr->kill_dt)         // create comment rec
        nNo_npl := 0
        if !found()
          dbappend()
          reclock('Share comment')
          shrdescr->share   := Share->share
          shrdescr->kill_dt := date()
          dbunlock()
        else
          reclock('Share comment')
          shrdescr->kill_dt := date()
          dbunlock()
        endif
      endif
      select portfol                  // search portfol file for NPL's
      dbgotop()                       // to be abandoned
      nCnt = 0
      while !eof()
        nCnt++
        @2,0 say replicate('±', nCnt / lastrec() * 60)
        if portfol->share = Share->share
          nNo_npl++
          select transact
          dbappend()
          reclock('Transaction')
          transact->std_code := portfol->std_code
          transact->type     := portfol->type
          transact->share    := Share->share
          transact->trn_type := 'NLP'
          transact->qty      := portfol->qty
          transact->trn_dt   := date()
          transact->price    := Share->price / 100
          transact->value    := portfol->qty * Share->price / 100
          dbunlock()
          select portfol
          reclock('Portfolio')
          dbdelete()
          dbunlock()
        endif
        dbskip()
      enddo
      @2,0 clear
      cMessage += Share->share + '   Students with abandoned NPLs = ';
          + ltrim(str(nNo_npl)) + chr(13) + chr(10)
    endif (share is a npl)
    dbcommitall()
    tts_off()
    select Share
    dbskip()
  enddo (share found)
  
  if net_use('param', .f.)
    reclock('Parameter')
    param->run_nplab := 'N'
    memvar->pRun_nplab := 'N'
  endif
end sequence
et_close('Transact')
et_close('Shrdescr')
et_close('Portfol')
et_close('Share')
et_close('Param')
wclose()

RETURN

*EOF
