*******************************************************************************
*
*  cnt_prnt
*
*

local cLine, nCnt

set alternate to club
set alternate on
set print off
set console off

select clients
while !eof()
  select cl_prod
  @10,10 say clients->surname
  if dbseek(clients->cnt_code + 'CB1')  .and. cl_prod->status = 'C'
    select clients
    cLine = trim(clients->title) + ' ' + substr(clients->name,1,1) +;
        ' ' + clients->surname
    ? ' '
    ? ' '
    ? SPACE(65) + 'R S A'
    ? SPACE(61) + 'POSTAGE PAID'
    FOR nCnt = 1 TO 14
      ? ' '
    NEXT
    ? space(9) + cLine
    ? space(9) + clients->address1
    ? space(9) + clients->address2
    ? space(9) + clients->address3
    ? space(9) + clients->p_code
    ? ' '
    nCnt = 1
    FOR nCnt = 1 TO 29
      ? ' '
    NEXT
    ? '     From ' + param->prnt_title
    ? '     ' + param->P_ADDR1
    ? '     ' + param->P_ADDR2
    ? '     ' + param->P_CODE + ' ' + param->P_ADDR3
    ? ' '
    ? '     Telephone ' + param->PHONE_NO
    * Page Throw
    ?? CHR(12)
  endif
  select clients
  dbskip()
enddo
set alternate off
close alternate

return
