*******************************************************************************
* 'TRNSTOP' - STOPS & START TRADING SO COMMENTS CAN BE FINISHED
* JIM WEST
* 01/89

local cOrig, cQues

select 1
if empty(et_use_dbf('param'))
  return
endif

simhead(memvar->pscr_title)
setcolor(memvar->black_cyan)
draw_box(10,15,14,60)
if param->stop_trans = 'Y'
  cQues = ' '
  @12,20 SAY 'Do you wish to re-start transactions (Y/N) ?'
  while cQues != 'Y' .and. cQues != 'N'
    cQues = upper(chr(inkey(0)))
  enddo
  if cQues = 'Y'
    reclock('param')
    param->stop_trans := 'N'
    dbunlock()
  endif
else
  cQues = ' '
  @12,20 say 'Do you wish to STOP transactions (Y/N) ?'
  while cQues != 'Y' .and. cQues != 'N'
    cQues = upper(chr(inkey(0)))
  enddo
  if cQues = 'Y'
    reclock('param')
    param->stop_trans := 'Y'
    dbunlock()
  endif
endif

et_close('Param')

return
* EOF
