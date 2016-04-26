*******************************************************************************
*PROGRAM 'REPMENU' - SALES REP HANDLING MENU
* Author - Jim West
* 23/9/87

local aCh := {'Move old leads to old leads file',;
    'Move finished students to finished students file',;
    'Delete old transactions from TRNSTORE',;
    'Return'}
local nCh := 1

while nCh != 0 .and. nCh != len(aCh)
  simhead(memvar->pscr_title)
  nCh = get_arr(aCh,,,,.t.,'SMIC - DATA ARCHIVING MENU', nCh)
  do case
    case nCh = 1
      do ldold
    case nCh = 2
      do finmove
    case nCh = 3
      do trnold
  endcase
enddo

return

* eof datamenu
