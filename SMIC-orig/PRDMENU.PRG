*******************************************************************************
* PROGRAM 'PRDMENU' - Product Menu
* Author - Jim West
* 1/2/88

local aCh := {'Add/edit products',;
    'Return'}

local nCh := 1

begin sequence
  if empty(et_use_dbf('param'))
    break
  endif
  
  if empty(et_use_dbf('product'))
    break
  endif
  
  if empty(et_use_dbf('cl_prod'))
    break
  endif
  
  while nCh != 0 .and. nCh != len(aCh)
    nCh = get_arr(aCh,,,,.t.,'SMIC - CLIENT MENU', nCh)
    do case
      case nCh = 1
        do prdedit
    endcase
  enddo
end sequence
dbcloseall()
return

*eof
