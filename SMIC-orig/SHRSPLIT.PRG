*******************************************************************************
* PROGRAM SHRSPLIT - CALCULATES SHARE SPLITS IN PORTFOLIO FILE
* 9/3/88
* JIM WEST

local nSplit, nCnt
memvar getlist

select 1
if !net_use('portfol', .f.,, 'portfol')
  return
endif

select 2
if !net_use('share', .f., , 'shrname')
  close databases
  return
endif

simhead(memvar->pscr_title)
findshr()
if !eof()
  @3,0 clear
  @4,10 say share->full_name
  nSplit = 1
  @8,10 say 'Enter split value ' get nSplit picture '99.9999'
  read
  nSplit = abs(nSplit)
  if nSplit != 0 .and. nSplit != 1
    @10,1 say 'We are going to create ' + ltrim(str(nSplit,7,4)) +;
     ' new shares for every existing share'
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
          @16,20 say 'Records changed = ' + ltrim(str(nCnt))
          reclock('Portfolio')
          Portfol->qty := Portfol->qty * nSplit
          dbunlock()
        endif
        dbskip()
      enddo
      ?? chr(7)
    endif (yesno = y)
  endif (split != 1 or 0)
endif (record found)
dbcloseall()
return

*EOF