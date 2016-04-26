*******************************************************************************
*
* STDMENU2 - MENU CALLED FROM TWIN FOR AN ACHOICE MENU TO SELECT STUDENT
*            PROGRAMS
* JIM WEST

local aStudent := {'Edit',;
    'Suspend',;
    "Reinstate",;
    "Comment",;
    "Accounts",;
    "Lectures"}
local nChoice

nChoice = get_arr(aStudent, 4, 52,memvar->aCh_col,.t.,'STudent',,;
    memvar->aVal_std)
do case
  case nChoice = 1
    do stdedit1
  case nChoice = 2
    do stdsusp1
  case nChoice = 3
    do stdrein1
  case nChoice = 4
    do stdcomn1
  case nChoice = 5
    do accdisp1
  case nChoice = 6
    do stdlect
endcase
return

*eof()
