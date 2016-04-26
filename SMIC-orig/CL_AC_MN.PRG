*******************************************************************************
* PROGRAM 'CL_AC_MNU' - CLIENT ACCOUNTS MENU
* Author - Jim West
* 7/4/96

local aCh := {'Modify account details',;
        'Generate debit orders',;
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
  
  if empty(et_use_dbf('cl_acc'))
    break
  endif
  
  while nCh != 0 .and. nCh != len(aCh)
    nCh = get_arr(aCh,,,,.t.,'SMIC - CLIENT ACCOUNTS MENU', nCh)
    do case
      case nCh = 1
*        do cl_ac_chg
      case nCh = 2
        do clgendeb
    endcase
  enddo
end sequence
dbcloseall()
return

*eof
