*******************************************************************************
*
*  CLGENDEB - generates debit order entries from monthly clients
*
*
*******************************************************************************

local dPay, nTotal, cLine
memvar pLine

if !wmake_sure(8,,'Are you sure you want to generate debit orders',;
      'for this month ? ')
  return
endif

wopen(8,10,18,70)
wbox()

dPay = date()
while month(dPay) = month(date())
  dPay++
enddo
dPay--
nTotal = 0

begin sequence
  if openprn()
    break
  endif
  
  select cl_prod
  while !eof()
    if cl_prod->cnt_code = clients->cnt_code
      select clients
      dbseek(cl_prod->cnt_code)
      @2,2 say trim(clients->surname) + ' ' + trim(clients->name) + space(40)
      select cl_prod
    endif
    
    if cl_prod->status = 'C'                    // prod is current
      if cl_prod->mth_yr_pay = "M"              // Monthly payment type
        select cl_acc
        dbappend()
        reclock()
        cl_acc->cnt_cde  := cl_prod->cnt_code
        cl_acc->prd_cde  := cl_prod->prod_code
        cl_acc->cr_dr    := 'D'
        cl_acc->amount   := cl_prod->payment
        cl_acc->pmt_dt   := dPay
        cl_acc->pmt_type := 'D'
        cl_acc->comment  := ' '
        dbunlock()
        if pLine > 55
          pr_line('Debit orders raised on ' + dtoc(date()))
        endif
        cLine = trim(clients->surname) + ' ' + trim(clients->name)
        cLine += space(60 - len(cLine))
        cLine = str(cl_prod->payment) + '  ' + cl_prod->prod_code
        pr_line(cLine)
        nTotal += cl_prod->payment
      endif
    endif
    select cl_prod
    dbskip()
  enddo
  pr_line(' ')
  pr_line('Total debits raised = ' + str(nTotal))
end sequence
shutprn()
wclose()

return
