*******************************************************************************
*
* CNTDEL - Client deletion program
*
*******************************************************************************

local cCnt_cd

cCnt_cd = findcnt()

if !empty(cCnt_cd)
  if wmake_sure(12,,'Delete ' + trim(clients->title) + ' ' +;
        trim(clients->name) + ' ' + trim(clients->surname))
    select clients
    reclock()
    dbdelete()
    dbunlock()
  endif
endif
return
*eof()

