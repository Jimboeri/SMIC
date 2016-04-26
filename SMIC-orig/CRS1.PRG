*******************************************************************************
* PROGRAM 'CRS1' - Share maintance menu
* Author - Jim West
* 1/2/88

local aCh := {'1 = Edit Share data',;
    '2 = Print shares bought/sold this week',;
    '3 = Delete a share',;
    '4 = Calculate a share split',;
    '5 = Calculate a share consolidation',;
    "6 = Allocate NPL's for a share",;
    '7 = Allocate new shares for existing shareholders',;
    '8 = Change price of a share',;
    '9 = Edit Holding comment',;
    '10 = Return money on untradable shares',;
    '11 = Start/Stop trading on TWIN',;
    '12 = Display Datashare messages',;
    '13 = Rename share',;
    '14 = Export share comments',;
    'Return'}
local nCh := 1

while nCh != 0 .and. nCh != len(aCh)
  simhead(memvar->pscr_title)
  nCh = Get_arr(aCh,,,,.t.,'SMIC - SHARE MAINTAINCE',nCh)
  do case
    case nCh = 1
      do shredit
    case nCh = 2
      do wkshrprn
    case nCh = 3
      do shrdelet
    case nCh = 4
      do shrsplit
    case nCh = 5
      do shrcons
    case nCh = 6
      do trnnpl
    case nCh = 7
      do shralloc
    case nCh = 8
      do shrman
    case nCh = 9
      do shrhold
    case nCh = 10
      do trnshrab
    case nCh = 11
      do trnstop
    case nCh = 12
      do msg_disp
    case nCh = 13
      do shrchang
    case nCh = 14
      do shr_exp
  endcase
enddo
return

*EOF
