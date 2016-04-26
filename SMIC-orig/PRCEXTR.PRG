*******************************************************************************
* PROGRAM 'PRCEXTR'
* 2/2/88
* CREATES A DATA BASE OF DAILY SHARE INFORMATION
*******************************************************************************
PARAMETER cDnl_date

local cDnl, cFile, lFile, nTries, nHigh_cd, lDo_div, lDo_Npl
local cSeek, dTran
local nCnt
local lClose_data := .f., lClose_share := .f., lClose_descr := .f.
local lClose_param := .f.
memvar cMessage, getlist, cDnl_date

local nNew_shr, nDiv_shr, nNpl_shr, nKill_shr, nUndel_shr, nWin
nNew_shr := nDiv_shr := nNpl_shr := nKill_shr := nUndel_shr := 0

#define EOL     chr(13) + chr(10)

if select("PARAM") = 0
  select 21
  if !net_use('param')
    return
  endif
  lClose_param = .t.
endif

cDnl := cDnl_date
simhead(memvar->pscr_title)

@3,13 SAY 'EXTRACT OF SHARE PRICE INFORMATION FROM DOWNLOAD'
@5,0 SAY ' '
lFile = .F.
if empty(cDnl)
  if memvar->plst_price = date()
    if !wmake_sure(10,,;
          'The update has been done for today - do it again? ')
      lFile = .F.
    endif
  endif
  cDnl = 'XXXXXXXXXXXX'
  while !empty(cDnl) .and. !lFile
    cDnl = '                                     '
    @6,0 say 'Enter download file name' get cDnl picture '@!'
    read
    cDnl_date = cDnl
    cFile = cDnl
    if file(cFile)
      lFile = .t.
    else
      cFile = trim(param->dnl_dir) + cDnl
      if file(cfile)
        lFile = .t.
      else
        cFile = trim(param->net_dnldir) + cDnl
        if file(cfile)
          lFile = .t.
        endif
      endif
    endif
  enddo
else
  lFile = .f.
  if memvar->plst_price != date()
    cFile = cDnl
    if file(cFile)
      lFile = .t.
    else
      cFile = trim(param->dnl_dir) + cDnl
      if file(cfile)
        lFile = .t.
      else
        cFile = trim(param->net_dnldir) + cDnl
        if file(cfile)
          lFile = .t.
        endif
      endif
    endif
  endif
endif

if lFile
*  nnetextatt('SHRPRICE.DBF', 0)              // Remove transactional status
*  nnetextatt('SHRPRICE.NTX', 0)              // Remove transactional status
  
  select 15
  while !net_use('shrprice', .t.)
    @maxrow(),0 say center('WAITING FOR ACCESS TO SHRPRICE FILE')
  enddo
  @maxrow(),0 clear
  zap
  
  nWin = wopen(8,10,15,70)
  wbox(0)
  setcursor(0)
  
  @0,0 say center('CREATING SHAREPRICE FILE')
  append from &cFile delimited
  @0,0 say center('SHAREPRICE FILE CREATED', .t.)
  
  @1,1 say 'BUILDING INDEX'
  index on shrprice->share to shrprice eval ind_prog(1) every 5
  dbclosearea()
  
  if select("SHR_DATA") = 0
    select 16
    while !net_use('shr_data', .f.,, 'shr_data')
      @maxrow(), 0 say center('WAITING FOR ACCESS TO SHARE DATA FILE')
    enddo
    @maxrow(),0 clear
    lClose_data = .t.
  endif
  
  if select("SHRDESCR") = 0
    select 17
    while !net_use('shrdescr', .f.,, 'shrdescr')
      @maxrow(),0 say center('WAITING FOR ACCESS TO SHRDESCR FILE')
    enddo
    @maxrow(),0 clear
    lClose_descr = .t.
  endif
  
  if select("SHARE") = 0
    select 18
    while !net_use('share', .f.,, 'shrname')
      @maxrow(),0 say center('WAITING FOR ACCESS TO SHARE FILE')
    enddo
    @maxrow(),0 clear
    lClose_share = .t.
  endif
  
  select share
  @maxrow(),0 clear
  @2,1 say 'Init share file'
  dbgotop()
  nCnt = 0
  nHigh_cd = 0
  while !eof()                  // set all share volumes to 0 in case share
    nCnt++                      // not included in download.
    @2,20 say replicate('±', int(nCnt / lastrec() * 40))
    reclock()
    share->volume := 0
    if bin2i(share->shr_cd) > nHigh_cd
      nHigh_cd := bin2i(share->shr_cd)
    endif
    dbunlock()
    dbskip()
  enddo
  
  select 15
  while !net_use('shrprice', .f.,, 'shrprice')
    @maxrow(),0 say center('WAITING FOR ACCESS TO SHRPRICE FILE')
  enddo
  @maxrow(),0 clear
  lDo_Div = .F.
  lDo_Npl = .F.
  @3,1 SAY 'Updating'
  nCnt = 0
  dbgotop()
  while empty(shrprice->share)
    nCnt++
    dbskip()
  enddo
  
  while !eof()
    nCnt++
    @3,20 say replicate('±', int(nCnt / lastrec() * 40))
    tts_on()
    select share
    if !dbseek(shrprice->share)                 // share does not exist
      dbappend()
      reclock()
      share->share := shrprice->share
      share->price := shrprice->close * 100
      share->y_cl_pr := shrprice->close * 100
      share->volume := shrprice->volume
      nHigh_cd++
      share->shr_cd := i2bin(nHigh_cd)
      dbunlock()
      select shrdescr                           // add comment record
      dbappend()
      reclock('Share comment')
      shrdescr->share := shrprice->share
      shrdescr->lst_wk_pr := shrprice->close * 100
      dbunlock()
      nNew_shr++
    else
      reclock()
      share->price := shrprice->close * 100      // update prices
      share->y_cl_pr := shrprice->close * 100
      share->volume := shrprice->volume
      dbunlock()
    endif
    select share
    if !empty(shrprice->sector)              // update sector code if not empty
      reclock()
      share->sec_cd := str(shrprice->sector,3)
      dbunlock()
    endif
    
    select shrdescr
    if dbseek(shrprice->share)
      if share->suspend != 'N'
        if !empty(shrdescr->div_dt) .and. shrdescr->div_dt < date()
          lDo_Div = .t.
          nDiv_shr++
        endif
      endif
      reclock('shrdescr')
      shrdescr->kill_dt := ctod('  /  /  ')
      if !empty(shrprice->sector)
        shrdescr->sec_cd := str(shrprice->sector,3)
      endif
      dbunlock()
    endif
    dbcommitall()
    tts_off()
    select shrprice
    dbskip()
  enddo
  select share
  dbunlock()
  
  set alternate to probshr.txt
  set alternate on
  set consol off
  ? 'The following are a list of shares the system cannot delete'
  ? ' '
  
  @4,1 say 'NPL Check'
  select share
  nCnt = 0
  dbgotop()
  while !eof()
    nCnt++
    tts_on()
    @4,20 say replicate('±', int(nCnt / lastrec() * 40))
    if share->suspend = 'N'             // NPL's are indicated like this
      select shrdescr
      if dbseek(share->share)
        if shrdescr->div_dt <= date()
          if empty(shrdescr->kill_dt)
            lDo_Npl = .t.
            nNpl_shr++
          endif
        endif
      endif
    else                                // Not an NPL
      select shrprice
      if !dbseek(share->share)          // Not in download
        select shrdescr
        if !dbseek(share->share)
          select shrdescr
          dbappend()
          reclock('share comment')
          shrdescr->share := share->share
          shrdescr->kill_dt := date()
          dbunlock()
          nKill_shr++
        else
          if empty(shrdescr->kill_dt)
            reclock('share comment')
            shrdescr->kill_dt := date()
            dbunlock()
            nKill_shr++
          else
            if shrdescr->kill_dt + 21 < date()
              ? '     ' + share->share + '    ' + share->full_name
              nUndel_shr++
            endif
          endif
        endif
      else                              // Share is in download
        select shrdescr
        if dbseek(share->share)
          if !empty(shrdescr->kill_dt)
            reclock('share comment')
            shrdescr->kill_dt := ctod('  /  /  ')
            dbunlock()
          endif
        endif
      endif
    endif
    dbcommitall()
    tts_off()
    select share
    dbskip()
  enddo
  et_close('SHRPRICE')
  if lClose_data
    et_close('SHR_DATA')
  endif
  if lClose_share
    et_close('SHARE')
  endif
  if lClose_descr
    et_close('SHRDESCR')
  endif
  if lClose_param
    et_close('PARAM')
  endif
  set consol on
  set alternate off
  
  if select('PARAM') = 0
    select 15
    while !net_use('param', .f.)
      @maxrow(),0 say center('WAITING FOR PARAMETER FILE')
    enddo
    dbgotop()
    reclock('Parameter')
    memvar->plst_price = date()
    param->lst_price := date()
    param->stop_trans := 'N'
    if lDo_Div
      param->run_div := 'Y'
      memvar->prun_div = 'Y'
    endif
    if lDo_Npl
      param->run_nplab := 'Y'
      memvar->prun_nplab = 'Y'
    endif
    dbunlock()
    dbclosearea()
  endif
  
  cMessage += 'New shares added      = ' + ltrim(str(nNew_shr,8,0)) + EOL
  cMessage += 'Shares with dividends = ' + ltrim(str(nDiv_shr,8,0)) + EOL
  cMessage += 'NPLs abandoned        = ' + ltrim(str(nNpl_shr,8,0)) + EOL
  cMessage += 'Shares killed         = ' + ltrim(str(nKill_shr,8,0)) + EOL
  cMessage += 'Undeletable shares    = ' + ltrim(str(nUndel_shr,8,0)) + EOL
  
  memvar->inkey = 0
  wclose()
  
endif (cDnl != space)

return

*EOF

*******************************************************************************
function shr_date ( dIn_dt)
local dReference := ctod('01/01/80')
return(dIn_dt - dReference)

*******************************************************************************
function ind_prog(nRow)
@nRow,20 say replicate('±', int(recno() / lastrec() * 41))
return(.t.)

