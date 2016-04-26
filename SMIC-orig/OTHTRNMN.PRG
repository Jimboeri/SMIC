*******************************************************************************
*
* OTHTRNMN - MENU CALLED FROM TWIN FOR AN ACHOICE MENU TO SELECT OTHER
*            TRANSACTION TYPES
* JIM WEST

local nChoice
local aOth_trn := {'Bear sale',;
    'Deliver bear sale',;
    "Exercise NPL's",;
    'Order edit',;
    'Transaction edit',;
    'Manual buy',;
    'Manual sell'}

nChoice = get_arr(aOth_trn, 4, 31,memvar->aCh_col, .t., 'Oth_trn')
do case
  case nChoice = 1
    do bearsl
  case nChoice = 2
    do bearbuy
  case nChoice = 3
    do trnnplex
  case nChoice = 4
    do ordedit
  case nChoice = 5
    do trnedit
  case nChoice = 6
    do prebuy
  case nChoice = 7
    do presell
endcase
return

*EOF()