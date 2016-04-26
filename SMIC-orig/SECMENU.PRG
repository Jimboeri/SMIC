*******************************************************************************
*PROGRAM 'SECMENU' - SECURITY MENU
* Author - Jim West
* 23/9/87

local aCh := {'Add/edit new security cards',;
    'Delete security cards',;
    'Display security cards',;
    'Print security list',;
    'Return'}
local nCh := 1

while nCh != 0 .and. nCh != len(aCh)
  simhead(memvar->pscr_title)
  nCh = get_arr(aCh,,,,.t.,'SMIC - SECURITY MENU',nCh)
  do case
    case nCh = 1
      do secedit
    case nCh = 2
      do secdelet
    case nCh = 3
      do secdisp
    case nCh = 4
      do secprnt
  endcase
enddo
return
* eof
