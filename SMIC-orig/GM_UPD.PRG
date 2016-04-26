*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
*³ GM_UPD game update program                                                 ³
*³ Author - Jim West                                                          ³
*³ Date 27/2/94                                                               ³
*ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

local cGame_dir, cCurr_dir
local dTemp, nCnt, cDnl_dir, lDnl_done, nWin, nRec, cShare_dir
memvar cField, cFile

if !net_use('Param')
  return
endif

cGame_dir = param->game_dir
cCurr_dir = dirname()

et_close('Param')

nWin = wopen(8,10,13,70)
wbox(0)
setcursor(0)
@0,0 say center('GAME PRICE UPDATE SECTION',,,.t.)

if substr(cGame_dir,1,1) != '\'
  cGame_dir = stuff(cGame_dir, 1, 0, '\')
endif

begin sequence
  
  if dirchange(cGame_dir) != 0    // not sucessful
    break
  endif
  
  select 1
  if !net_use('param')
    break
  endif
  
  cShare_dir := trim(param->shr_dir)
  if substr(cShare_dir, len(cShare_dir), 1) != '\'
    cShare_dir += '\'
  endif
  
  select 2
  if !net_use('shrprice', .t.)
    break
  endif
  zap
  
  select 3
  if !net_use(cShare_dir + 'share', .f.,,cShare_dir + 'share')
    break
  endif
  
  set date italian
  lDnl_done = .f.
  select shrprice
  for dTemp = date() to param->lst_dnl+1 step -1
    for nCnt = 1 to 3
      cField = 'PARAM->DNL_DIR' + ltrim(str(nCnt))
      if !empty(&cField)
        cDnl_dir = Trim(&cField)
        if substr(cDnl_dir,1,1) != '\'
          cDnl_dir = stuff(cDnl_dir, 1, 0, '\')
        endif
        if substr(cDnl_dir,len(cDnl_dir),1) != '\'
          cDnl_dir += '\'
        endif
        cFile = cDnl_dir + dtoc(dTemp) + '.DN'
        if file(cFile)
          @1,0 say center('CREATING SHAREPRICE FILE')
          append from &cFile sdf
          @1,0 say center('SHAREPRICE FILE CREATED', .t.)
          
          @2,1 say 'BUILDING INDEX'
          index on shrprice->share to shrprice
          
          select share
          dbgotop()
          @3,1 say 'UPDATING'
          nRec = 1
          while !eof()
            @3,20 say replicate('±', (nRec / lastrec()) * (maxcol() - 18))
            select shrprice
            if dbseek(share->shr_name)
              select share
              reclock()
              share->price := val(shrprice->close)
              share->lst_date := date()
              share->lst_time := seconds()
              dbunlock()
            endif
            select share
            dbskip()
            nRec++
          enddo
          
          lDnl_done = .t.
          select param
          reclock()
          param->lst_dnl = dTemp
          dbunlock()
        endif
      endif
      if lDnl_done
        exit
      endif
    next
    if lDnl_done
      exit
    endif
  next
  
end sequence
et_close('Param')
et_close('Share')
et_close('Shrprice')
dirchange(cCurr_dir)
set date british
wclose()
return

* eof
