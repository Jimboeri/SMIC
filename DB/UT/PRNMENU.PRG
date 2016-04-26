*******************************************************************************
* PRNMENU

local aCh := {'Select printer', 'Alter printer file', 'Return'}
local nCh := 1
while nCh != 0 .and. nCh != len(aCh)
  jw_screen('PRINTER MENU')
  nCh = mget_arr(aCh,10,,,.t.)
  do case
    case nCh = 1
      do pr_ch
    case nCh = 2
      do prnupd
  endcase
enddo
return

*eof()
