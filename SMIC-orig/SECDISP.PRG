*******************************************************************************
* Program 'SECDISP'
* JIM WEST
* 1989

#include 'inkey.ch'

if !net_use('security', .f.,, 'secure')
  return
endif

simhead(memvar->pscr_title)
@3,0 clear
while !eof() .and. lastkey() != K_ESC
  @5,0 clear
  list next 16 security->name
  @22,0 clear
  inkey(0)
enddo
close database
return
* eof
