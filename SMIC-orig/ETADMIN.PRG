*******************************************************************************
* SYSTEM ADMINISTRATOR MENU MENU
* Author - Jim West
* 1/2/88

local aCh := {'Reindex files',;
    'Security menu',;
    'Futures menu',;
    'Reps menu',;
    'System parameters',;
    'Data archiving',;
    'Share duplicate deletion',;
    'Quit'}
local nCh := 1
local aVal := {}, nCnt

For nCnt = 1 to len(aCh)
  aadd(aVal, .f.)
next

if net_use('security', .f.,,'secure')
  seek memvar->mPw_nme
  if found()
    if scram(security->reindex) = 'Y'
      aVal[1] = .t.
    endif
    if scram(security->security) = 'Y' .or. security->name = 'JIM'
      aVal[2] = .t.
    endif
    if scram(security->fut_menu) = 'Y'
      aVal[3] = .t.
    endif
    if scram(security->rep_menu) = 'Y'
      aVal[4] = .t.
    endif
    if scram(security->sys_param) = 'Y'
      aVal[5] = .t.
    endif
    if scram(security->data_arc) = 'Y'
      aVal[6] = .t.
    endif
  endif
  aVal[7] := .t. 
  aVal[8] := .t. 
  dbclosearea()
endif

while nCh != len(aCh) .and. nCh != 0
  simhead(memvar->pscr_title)
  nCh = get_arr(aCh,,,,.t.,'SMIC - SYSTEM CONTROL MENU',nCh)
  do case
    case nCh = 1
      if make_sure(17,,'Are you sure you want to re-index the file',;
            'This will take some tine !!??')
        do re_index
      endif
    case nCh = 2
      do secmenu
    case nCh = 3
      do futmenu
    case nCh = 4
      repmenu()
    case nCh = 5
      do sysparam
    case nCh = 6
      datamenu()
    case nCh = 7
      do shr_dup
  endcase
enddo

return


* eof
