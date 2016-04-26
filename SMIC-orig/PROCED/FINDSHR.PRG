*******************************************************************************
*PROGRAM 'FINDSHR' - PROGRAM TO FIND A SPECIFIC SHARE
* Author - Jim West
* 6/6/92

select share
set filter to suspend = ' ' .or. suspend = 'N' 

cShare = anyseek('share', {1,2}, .t.)

if empty(cShare)
  dbgobottom()
  dbskip()
  return(' ')
else
  return(cShare)
endif

* EOF
