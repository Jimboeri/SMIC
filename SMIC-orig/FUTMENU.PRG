*******************************************************************************
*PROGRAM 'FUTMENU' - FUTURES AND OPTIONS MENU
* Author - Jim West
* 1/2/88

local aCh := {'Add Future',;
    'Edit future',;
    'Delete future',;
    'Print futures',;
    'Return'}
local nCh := 1

while nCh != 0 .and. nCh != len(aCh)
  simhead(memvar->pscr_title)
  nCh = get_arr(aCh,,,,.t.,'SMIC - FUTURES MENU', nch)
  do case
    case nCh = 1
      do futadd
    case nCh = 2
      do futedit
    case nCh = 3
      do futdelet
  endcase
enddo
return

*eof
