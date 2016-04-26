*******************************************************************************
* Program 'SECDELET'
* JIM WEST
* 1989

local cName
memvar getlist

if !net_use('security', .f.,, 'secure')
  return
endif

simhead(memvar->pscr_title)
@3,12 say  'Deletion of a card'
cName = space(10)
@5,1 say 'Card holder ' get cName PIcture '!!!!!!!!!!'
@10,5 say 'Enter name or hit enter to return to main menu'
read
if !empty(cName)
  if !dbseek(cName)
    @23,1
    @23,10 say 'CARD DOES NOT EXIST'
    inkey(10)
  else
    if !rlock()
      disp_msg(20,, 'SECURITY RECORD LOCKED - PLEASE TRY LATER')
      inkey(10)
    else
      @5,14 clear
      @5,14 say cName
      @6,1 clear
      if wmake_sure(10,, 'Delete this card ? (Y/N)')
        dbdelete()
        disp_msg(16,, 'RECORD IS NOW MARKED FOR DELETION')
        inkey(10)
      endif 
    endif (rec locked)
  endif (record not found)
endif
dbcloseall()
return
* eof()
