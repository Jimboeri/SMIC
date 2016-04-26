*******************************************************************************
* SELFDEST - DESTROYS PRG & EXE FILE IF DATE INCORECT
local nChoice := 0, cDt, dClose
if !net_use('param')
  while nChoice != 1
    nChoice = alert('Internal error 381 (File)', {'Quit', 'Retry'})
  enddo
  quit
endif

dbclosearea()

*if nnetserno() != '090389880000'        // serial no of smic novell lan
*  while nChoice != 1
*    nChoice = alert('Internal error 381 (Network)', {'Quit', 'Retry'})
*  enddo
*  quit
*endif

return
*eof
