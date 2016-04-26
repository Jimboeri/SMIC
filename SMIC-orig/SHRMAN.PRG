*******************************************************************************
* PROGRAM 'SHRMAN' MANUAL SHARE PRICE CAPTURE
* AUTHOR JIM WEST (E.T.)
* 1/2/88

local nPrice, nVolume
memvar getlist

select 1
if !net_use('share', .f., , 'shrname')
  return
endif

findshr()
if !eof()
  @4,13 clear
  @5,1 clear
  @4,13 say Share->share
  if !rlock()
    @23,10 say 'Share being used - Please try later'
    inkey(10)
  else
    @8,13 say Share->full_name
    nPrice = Share->price
    nVolume = share->volume
    @10,1 say 'Price  ' get nPrice picture '9999999999'
    @13,1 say 'Volume ' get nVolume picture '9999999999'
    read
    Share->price := nPrice
    Share->volume := nVolume
    dbunlock()
  endif (record locked)
endif (share found)
dbcloseall()
return
* eof