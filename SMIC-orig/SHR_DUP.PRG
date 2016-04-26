*******************************************************************************
*
* SHR_DUP - removes duplications in share databases
*
*
*******************************************************************************

local cShare, nShare, nShrdescr

wopen(10,10,16,70)
setcolor(memvar->white_red)
wbox()
@0,0 say center('Removing share database duplicates')

begin sequence
  if empty(et_use_dbf('Share'))
    break
  endif
  
  nShare := nShrdescr := 0
  
  @2,10 say 'Share file duplicates deleted = '
  while !eof()
    cShare = share->share
    @1,10 say cShare
    dbskip()
    while cShare = share->share .and. !eof()
      reclock()
      dbdelete()
      dbunlock()
      nShare++
      @2,43 say str(nShare)
      dbskip()
    enddo
  enddo
  
  dbclosearea()
  
  if empty(et_use_dbf('Shrdescr'))
    break
  endif
  
  @3,10 say 'Share descr duplicates deleted = '
  while !eof()
    cShare = shrdescr->share
    @1,10 say cShare
    dbskip()
    while cShare = shrdescr->share .and. !eof()
      reclock()
      dbdelete()
      dbunlock()
      nShrdescr++
      @3,44 say str(nShrdescr)
      dbskip()
    enddo
  enddo
  
  dbclosearea()
  
end sequence
wclose()
return
