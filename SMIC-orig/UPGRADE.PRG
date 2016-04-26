*******************************************************************************
*
* UPGRADE

local aStru, lVers, lName, nLen, nCnt, nAddr := 0
local lDate, cDt, cSect, lSect

select 99
if !net_use('param', .t.)
  return
endif

begin sequence
  if param->version = 'V1.07'
    param->version := 'V1.08'
  endif

  if param->version = 'V1.06'
    param->version := 'V1.07'
  endif

  if param->version = 'V1.05'
    param->version := 'V1.06'
  endif

  if param->version = 'V1.04'
    lVers = .t.
    
    aStru = dbstruct()
    nLen = len(aStru)
    for nCnt = 1 to nLen
      if aStru[nCnt, 1] = 'NXT_LRS'
        aRemove(aStru, nCnt)
        exit
      endif
    next
    
    if lVers
      copy to oldparam
      dbclosearea()
      aadd(aStru, {'FINTEL_DIR', 'C', 30, 0})
      aadd(aStru, {'CNT_VER', 'C', 5, 0})
      dbcreate('param', aStru)
      net_use('param', .t.)
      append from oldparam
      param->version := 'V1.05'
      param->cnt_ver := 'V1.00'
      param->fintel_dir := 'DB\FINTEL'
      dbclosearea()
    endif
  endif
  
  if param->version = 'V1.03'
    if !file('HED.DBF')
      aStru := {}
      aadd(aStru, {'STAR', 'C', 1, 0})
      aadd(aStru, {'COMMAND', 'C', 3, 0})
      aadd(aStru, {'DATA', 'C', 80, 0})
      dbcreate('HED', aStru)
    endif
    if !file('HED_UNKN.DBF')
      aStru := {}
      aadd(aStru, {'COMMAND', 'C', 3, 0})
      aadd(aStru, {'DATE', 'D', 8, 0})
      aadd(aStru, {'DATA', 'C', 80, 0})
      dbcreate('HED_UNKN', aStru)
    endif
    select param
    param->version := 'V1.04'
  endif
  
  
  if param->version = 'V1.02'
    select 2
    if !net_use('Share')
      break
    endif
    
    lSect = .t.
    aStru = dbstruct()
    nLen = len(aStru)
    for nCnt = 1 to nLen
      if aStru[nCnt, 1] = 'SEC_CD'
        lSect = .f.
        exit
      endif
    next
    
    if lSect
      copy to oldshare
      dbclosearea()
      if lSect
        aadd(aStru, {'SEC_CD', 'C', 3, 0})
      endif
      dbcreate('Share', aStru)
      select 2
      net_use('Share', .t.)
      append from oldshare
      select 3
      if !net_use('Shrdescr', .f.,,'Shrdescr')
        break
      endif
      select share
      dbgotop()
      while !eof()
        select shrdescr
        if dbseek(share->share)
          select share
          share->sec_cd := shrdescr->sec_cd
        endif
        select share
        dbskip()
      enddo
      
      et_close('Share')
      et_close('Shrdescr')
    endif
    select param
    param->version := 'V1.03'
    dbclosearea()
  endif
end sequence

/*
if param->version = 'V1.01'
  lVers = .t.
  
  aStru = dbstruct()
  nLen = len(aStru)
  for nCnt = 1 to nLen
    if aStru[nCnt, 1] = 'GAME_DIR'
      lVers = .f.
      exit
    endif
  next
  
  if lVers
    copy to oldparam
    dbclosearea()
    if lVers
      aadd(aStru, {'GAME_DIR', 'C', 30, 0})
    endif
    dbcreate('param', aStru)
    net_use('param', .t.)
    append from oldparam
    param->version := 'V1.02'
    param->game_dir := 'SMTG'
    dbclosearea()
  endif
endif
*/

dbcloseall()

return
