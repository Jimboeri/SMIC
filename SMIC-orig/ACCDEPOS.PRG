*******************************************************************************
* ACCDEPOS
* JIM WEST
*

local cTitle, cComm
local nTries, nTot_comm, nTot_cq, nTot_card, nTot_cash

memvar pLine

begin sequence
  select 1
  if !net_use('account', .f.,)
    break
  endif
  
  select 3
  if !net_use('student', .f.,, 'stdcode')
    break
  endif
  
  select 4
  if !net_use('cardcomm', .f.,, 'cardcomm')
    break
  endif
  
  simhead(memvar->pscr_title)
  @13,13 say 'Printing deposit report'
  
  cTitle = 'Banking report to tie up with deposit book'
  select Account
  dbgobottom()
  nTries = 0
  nTot_comm = 0
  nTot_cq = 0
  nTot_card = 0
  nTot_cash = 0
  
  if openprn()
    break
  endif
  
  while !eof() .and. !bof() .and. nTries < 200
    if account->cr_dr = 'C'
      nTries++
      if account->comment = 'Q'
        reclock('Accounts')
        Account->comment := ' '
        dbunlock()
        nTries = 0
        if pline > 50
          prntitle(cTitle, 'Y')
          ? '  NAME                             Cheque       Cash       Card      Comm'
          ? ' '
          pline = 5
        endif
        select Student
        dbseek(account->std_code)
        ? student->surname
        pline++
        select Account
        do case
          case account->pmt_type = 'Q'
            ?? str(account->amount+account->vat,11,2)
            nTot_cq += account->amount+account->vat
          case account->pmt_type = 'O'
            ?? replicate(' ',11) + str(account->amount+account->vat,11,2)
            nTot_cash += account->amount+account->vat
          case account->pmt_type = 'C'
            select cardcomm
            if !dbseek(account->std_code + dtos(Account->pmt_dt))
              cComm = ' COMM NT FND'
            else
              cComm = str(cardcomm->commision,10,2)
              nTot_comm += cardcomm->commision
            endif
            select Account
            ?? replicate(' ',22) + str(Account->amount+Account->vat,11,2) +;
                cComm
            nTot_card += Account->amount+Account->vat
          otherwise
            ?? 'UNKNOWN PAYMENT TYPE'
        endcase
      endif
    endif
    dbskip(-1)
  enddo
  ? ' '
  ? 'Totals                       ' + str(nTot_cq,12,2) + ;
  str(nTot_cash,11,2) + str(nTot_card,11,2) + str(nTot_comm,10,2)
  ? ' '
  ? '                                                           Card total ' +;
      str((nTot_card + nTot_comm),14,2)
end sequence
shutprn()

close databases

return
*eof
