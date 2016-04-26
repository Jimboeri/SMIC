*******************************************************************************
* PROGRAM 'STDPMENU' - STUDENT PRINT MENU
* CALLED FROM TWIN
* Author - Jim West
local aCh := {'Labels by area and status',;
    'Unactive students',;
    'Student list',;
    'Student by product bought',;
    'Finished students',;
    'Create mail merge file'}
local nCh := 1

while nCh != 0 .and. nCh != len(aCh)
  simhead(memvar->pScr_title)
  nCh = get_arr(aCh,,,,.t.,'SMIC - ADVERT MENU', nCh)
  do case
    case nCh = 1
      do stdareal
    case nCh = 2
      do stdunact
    case nCh = 3
      do stdactiv
    case nCh = 4
      do stdlist
    case nCh = 5
      do stdfin
    case nCh = 6
      do merge
  endcase
enddo
RETURN

*EOF
* EOF
