*******************************************************************************
* PROGRAM SHRCONS - CALCULATES SHARE CONSOLIDATIONS IN PORTFOLIO FILE
* 9/3/88
* JIM WEST

local nCons, nCnt
memvar getlist

select 1
if !net_use('portfol', .f., 'Portfol', 'portfol')
  return
endif

select 2
if !net_use('share', .f.,, 'shrname')
  close database
  return
endif

simhead(memvar->pscr_title)
findshr()
if !eof()
  @3,0 clear
  @4,10 say Share->full_name
  nCons = 1
  @8,10 say 'Enter consolidation value ' get nCons picture '99.9999'
  read
  nCons = abs(nCons)
  IF nCons != 0 .and. nCons != 1
    @10,1 say 'We are going to create 1 new share for every ' + LTRIM(STR(nCons,7,4)) + ' shares already held'
    if wmake_sure(13,,'Is this correct ? (Y/N)')
      setcolor('W*+/N')
      @14,10 say 'CHANGING'
      setcolor('W/N')
      @14,19 say 'the portfolio file'
      select Portfol
      dbgotop()
      nCnt = 0
      while !eof()
        if Portfol->share = Share->share
          nCnt++
          @16,20 say 'Records changed = ' + LTRIM(STR(nCnt))
          reclock('Portfolio')
          Portfol->qty := Portfol->qty / nCons
          dbunlock()
        endif (share = Share->share)
        dbskip()
      enddo (end of portfol file)
      ?? chr(7)
    endif (yesno)
  endif (consolidation != 1 or 0)
endif (record found)
dbcloseall()
return

*eof