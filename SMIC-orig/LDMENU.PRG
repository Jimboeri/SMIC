*******************************************************************************
*PROGRAM 'LDMENU' - LEADS MENU
* Author - Jim West
* 23/9/87

local aCh := {'Add new leads',;
    'Edit existing records',;
    'Display similar surnames',;
    'Rep allocation program',;
    'Remove leads with wrong addresses',;
    'Return'}

local nCh := 1

begin sequence
  
  select 1
  if !net_use('adverts', .f.,, 'advmedia')
    break
  endif
  
  select 2
  if !net_use('reps', .f.,, 'reps')
    break
  endif
  
  select 3
  if !net_use('newleads', .f.,, 'archives', 'media', 'rleads')
    break
  endif
  
  select 4
  if .not. net_use('student', .f., , 'stdarc')
    break
  endif
  
  select 5              // used only by ldremove
  if .not. net_use('oldleads', .f., , 'oldarc')
    break
  endif
  
  while nCh != 0 .and. nCh != len(aCh)
    simhead(memvar->pScr_title)
    nCh = get_arr(aCh,,,,.t.,'SMIC - LEADS MENU', nCh)
    do case
      case nCh = 1
        do ldadd
      case nCh = 2
        do ldedit
      case nCh = 3
        do lddisp
      case nCh = 4
        do ldrep
      case nCh = 5
        do ldremove
    endcase
  enddo
end sequence

et_close('ADVERTS')
et_close('NEWLEADS')
et_close('REPS')
et_close('STUDENT')
et_close('OLDLEADS')
et_close('REPNUMS')

return

*EOF

