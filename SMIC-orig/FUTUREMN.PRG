*******************************************************************************
*
* FUTUREMN - MENU CALLED FROM TWIN FOR A MENU TO SELECT OTHER
*            FUTURES TYPES
* JIM WEST

local nChoice, aFuture := {'Go long (cover short)',;
    'Go short (cover long)',;
    "Display"}

nChoice = get_arr(aFuture, 4, 41, memvar->aCh_col, .t., 'Future')
do case
  case nChoice = 1
    do futlong
  case nChoice = 2
    do futshort
  case nChoice = 3
    do futdisp
endcase
return

*EOF()
