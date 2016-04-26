*******************************************************************************
* PROGRAM 'MEDMENU' - MEDIA REPORTS MENU
* AUTHOR R.W.L.WEST  (E.T.)
* 22/09/87

local aCh := {'Print Advert statistics summary (1)',;
    'Print Advert statistics summary (2)',;
    'Print Advert area analysis',;
    'Print analysis of a specific advert',;
    'Print sales for a specific advert',;
    'Print unsold leads for an advert (label format)',;
    'Print analysis for Readers Digest',;
    'Return'}
local nCh := 1, dTemp1, dTemp2

while nCh != 0 .and. nCh != len(aCh)
  simhead(memvar->pScr_title)
  nCh = get_arr(aCh,,,,.t.,'SMIC - MEDIA MENU', nCh)
  do case
    case nCh = 1
      dTemp1 = ctod('  /  /  ')
      dTemp2 = ctod('  /  /  ')
      do medstat with dTemp1, dTemp2
      ! copy medstat.txt lpt1:
    case nCh = 2
      do medstat1
    case nCh = 3
      do medareas
    case nCh = 4
      do medanal
    case nCh = 5
      do medsales
    case nCh = 6
      do medlab
    case nCh = 7
      do medrdig
  endcase
enddo
return
* eof
