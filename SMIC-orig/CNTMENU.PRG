*******************************************************************************
* PROGRAM 'CNTMENU' - CLIENT MENU
* Author - Jim West
* 1/2/88

local aCh := {'Add new client',;
    'Edit new clients',;
    'Print cover pages for clients',;
    'Print client list',;
    'Print clients who are not Club members',;
    'Delete clients',;
    'Return'}

local nCh := 1

begin sequence
  if empty(et_use_dbf('param'))
    break
  endif
  
  if empty(et_use_dbf('product'))
    break
  endif
  
  if empty(et_use_dbf('clients'))
    break
  endif
  
  if empty(et_use_dbf('cl_prod'))
    break
  endif
  
  while nCh != 0 .and. nCh != len(aCh)
    nCh = get_arr(aCh,,,,.t.,'SMIC - CLIENT MENU', nCh)
    do case
      case nCh = 1
        do cntadd
      case nCh = 2
        do cntedit
      case nCh = 3
        do cntprnt
      case nCh = 4
        do cntlist
      case nCh = 5
        do cntlist1
      case nCh = 6
        do cntdel
    endcase
  enddo
end sequence
dbcloseall()
return

*eof
