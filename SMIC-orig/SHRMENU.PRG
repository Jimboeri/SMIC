*******************************************************************************
*
* STDMENU2 - MENU CALLED FROM TWIN FOR AN ACHOICE MENU TO SELECT SHARE
*            PROGRAMS
* JIM WEST

local aShare := {'View share',;
    'Enter dividends',;
    'Capture prices'}
local nShare
memvar cMessage                 // for compatability with checkrun
cMessage = ''

nShare = get_arr(aShare, 6, 52, memvar->aCh_col, .t., 'Share')
do case
  case nShare = 1
    do shrlook
  case nShare = 2
    do shrdiv
  case nShare = 3
    do prcextr
endcase
return

*EOF()
