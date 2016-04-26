*******************************************************************************
*
*  cntlist
*
*

local cLine, nCnt, nLen
memvar pLine

begin sequence
  openprn()
  
  select clients
  while !eof()
    select cl_prod
    @10,10 say clients->surname
    if dbseek(clients->cnt_code + 'CB1')  .and. cl_prod->status = 'C'
      if pLine > 58
        prntitle('Client list')
      endif
      select clients
      cLine = trim(clients->title) + ' ' + trim(clients->name) +;
          ' ' + clients->surname
      ? cLine
      ? 'Phone (W) ' + clients->phone_w + '   Phone (H) ' + clients->phone_h;
          + '   Post code ' + clients->p_code
      nLen = mlcount(clients->comment,75)
      for nCnt = 1 to nLen
        ? memoline(clients->comment,75,nCnt)
        pline++
      next
      ? ' '
      ? ' '
      pline += 4
    endif
    select clients
    dbskip()
  enddo
  shutprn()
end sequence

return
