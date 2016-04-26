*******************************************************************************
*PROGRAM 'REPMENU' - SALES REP HANDLING MENU
* Author - Jim West
* 23/9/87

local aCh := {'Add new rep',;
    'Edit existing rep',;
    'Return'}
local nCh := 1

while nCh != 0 .and. nCh != len(aCh)
  simhead(memvar->pscr_title)
  nCh = get_arr(aCh,,,,.t.,'SMIC - REP CONTROL MENU', nCh)
  do case
    case nCh = 1
      do repadd
    case nCh = 2
      do repedit
  endcase
enddo
return

*EOF
