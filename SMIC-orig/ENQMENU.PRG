*******************************************************************************
*PROGRAM 'ENQMENU' - Enquiry MENU
* called from SMIC
* Author - Jim West
* 23/9/87

local nOPtion := 1
local aMenu := {'View lead information',;
    'View leads by surname',;
    'View student information',;
    'View student accounts',;
    'View share information',;
    'View student portfolio',;
    'Print labels',;
    'Quit'}

while nOption != 0 .and. nOption != len(aMenu)
  simhead(memvar->pscr_title)
  nOption = get_arr(aMenu,,,,.t.,'ENQUIRY MENU')
  do case
    case nOption = 1
      do ldlook
    case nOption = 2
      begin sequence
        select 2
        if !net_use('reps', .f.,, 'reps')
          break
        endif
        
        select 3
        if !net_use('newleads', .f.,, 'archives', 'media', 'rleads')
          break
        endif
        
        lddisp()
        
      end sequence
      et_close('NEWLEADS')
      et_close('REPS')
    case nOption = 3
      do stdlook
    case nOption = 4
      do accdisp
    case nOption = 5
      begin sequence
        select 2
        if !net_use('share', .f.,, 'shrname')
          break
        endif
        
        select 3
        if !net_use('shrdescr', .f.,, 'shrdescr')
          break
        endif
        
      shrlook()
        
      end sequence
      et_close('SHARE')
      et_close('SHRDESCR')
    case nOption = 6
      do trnlook
    case nOption = 7
      do smiclab
  endcase
enddo
return

*EOF
