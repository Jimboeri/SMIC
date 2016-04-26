*******************************************************************************
* PRGMENU

local aCh := {'Structure check',;
    'Program specs',;
    'Common procedures',;
    'Return'}
local nCh := 1
while nCh != 0 .and. nCh != len(aCh)
  begin sequence
    jw_screen('PROGRAM MENU')
    nCh = mget_arr(aCh,10,,,.t.)
    do case
      case nCh = 1
        do prgchk
      case nCh = 2
        do prgspec
      case nCh = 3
        do prgproc
    endcase
  end sequence
enddo
return

*eof()
