*******************************************************************************
*
*  cntlist
*
*

local cMember, nCnt, nLen, cLine
memvar pLine

begin sequence
  openprn()
  
  select clients
  while !eof()
    @10,10 say clients->surname
    select cl_prod
    cMember = 'N'
    if dbseek(clients->cnt_code + 'CB1') .and. cl_prod->status = 'C'
      cMember = 'Y'
    endif
    if cMember != 'Y'
      if pLine > 58
        prntitle('Clients who are not Club Members')
      endif
      select clients
      cLine = trim(clients->title) + ' ' + trim(clients->name) + ' ';
          + clients->surname
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
