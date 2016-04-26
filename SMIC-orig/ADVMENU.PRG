*******************************************************************************
* PROGRAM 'ADVMENU' - ADVERTS HANDLING MENU
* Author - Jim West
* 23/9/87

local aCh := {'Add new advert',;
    'Edit advert',;
    'Delete advert',;
    'Display similar adverts',;
    'Print no cost adverts',;
    'Print adverts for a period',;
    'Change advert codes',;
    'Return'}

local nCh := 1

while nCh != 0 .and. nCh != len(aCh)
  simhead(memvar->pScr_title)
  nCh = get_arr(aCh,,,,.t.,'SMIC - ADVERT MENU', nCh)
  do case
    case nCh = 1
      do advadd
    case nCh = 2
      do advedit
    case nCh = 3
      do advdelet
    case nCh = 4
      do advdisp
    case nCh = 5
      do advncost
    case nCh = 6
      do advlist
    case nCh = 7
      do advchang
  endcase
enddo
return

*EOF
