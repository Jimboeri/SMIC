*******************************************************************************
* SHRCHANG - CHANGES THE NAME OF A SHARE
* JIM WEST

local cOrig_shr, cNew_shr, nCnt

simhead(memvar->pscr_title)

begin sequence
  select 1
  if !net_use('share', .f., , 'shrname')
    break
  endif
  
  select 2
  if !net_use('shrdescr', .f.,, 'shrdescr')
    break
  endif
  
  select 3
  if !net_use('transact', .f.,, 'trancode')
    break
  endif
  
  select 5
  if !net_use('order', .f.,, 'order')
    break
  endif
  
  select 4
  if !net_use('portfol', .f.,, 'portfol')
    break
  endif
  
  select Share
  @4,10 SAY 'Enter name of the share which is to change'
  findshr()
  if !eof()
    cOrig_shr = share->share
    @4,0 clear
    @4,10 say 'Enter new name'
    findshr()
    if !eof()
      cNew_shr = share->share
      @3,0 clear
      if make_sure(5,27,'Change ' + cOrig_shr + ' to ' + cNew_shr + ' ?')
        wopen(8,10,14,70)
        wbox(0)
        setcursor(0)
        select Shrdescr
        if dbseek(cNew_shr)
          if empty(Shrdescr->buy_1) .and. empty(Shrdescr->sell_1) .and.;
                empty(Shrdescr->fundamnt_1)
            select share
            reclock('Share')
            dbdelete()
            dbunlock()
          endif
        endif
        select shrdescr
        if !dbseek(cNew_shr)
          if dbseek(cOrig_shr)
            reclock('Share comment')
            Shrdescr->share := cNew_shr
            dbunlock()
          endif
        endif
        dbcommit()
        @0,0 say center('Transaction File')
        select Transact
        dbgotop()
        nCnt = 0
        while !eof()
          nCnt++
          @1,0 say replicate('±', int(nCnt / lastrec() * 60))
          if transact->share = cOrig_shr
            reclock('Transaction')
            Transact->share := cNew_shr
            dbunlock()
          endif
          dbskip()
        enddo
        
        @0,0 say center('Portfolio file', .t.)
        select Portfol
        dbgotop()
        nCnt = 0
        while !eof()
          nCnt++
          @2,0 say replicate('±', int(nCnt / lastrec() * 60))
          if portfol->share = cOrig_shr
            reclock('Portfolio')
            Portfol->share := cNew_shr
            dbunlock()
          endif
          dbskip()
        enddo
        
        @0,0 say center('Order file', .t.)
        select Order
        dbgotop()
        nCnt = 0
        while !eof()
          nCnt++
          @3,0 say replicate('±', int(nCnt / lastrec() * 60))
          if order->share = cOrig_shr
            reclock('Portfolio')
            Order->share := cNew_shr
            dbunlock()
          endif
          dbskip()
        enddo
        select share
        if dbseek(cOrig_shr)
          reclock()
          dbdelete()
          dbunlock()
        endif
        select shrdescr
        if dbseek(cOrig_shr)
          reclock()
          dbdelete()
          dbunlock()
        endif
        wclose()
        ?? chr(7)
      endif
    endif (cNew_shr found)
  endif (cOrig_shr found)
end sequence
et_close('Share')
et_close('Shrdescr')
et_close('Transact')
et_close('Order')
et_close('Portfol')
return

* EOF
