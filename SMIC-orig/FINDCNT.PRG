*******************************************************************************
* THIS PROGRAM SELECTS A PARTICULAR client
* 1/5/92
* JIM WEST

local cSurname, nRec, cName

select clients
dbsetorder(2)
cSurname = et_seek('clients', {4,3}, .t.)

if empty(cSurname)
  return(' ')
endif

dbseek(cSurname)
nRec = recno()
dbskip()
if cSurname != clients->surname
  dbgoto(nRec)
  return(clients->cnt_code)
endif

cName = et_seek('clients', {3, 4}, .t.,, cSurname)

if empty(cName)
  return(' ')
endif

dbseek(cSurname + cName)
return(clients->cnt_code)

* eof()

