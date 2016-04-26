*******************************************************************************
* ACCDEBIT - PRINT OF DEBIT ORDERS
* JIM WEST
* 08/88

local dAction, cTitle, nDebits, nTot_amt, nGrand_tot, lDebit, nTotal
memvar pline, ppage

simhead(memvar->pscr_title)

select 1
if !net_use('param', .f.)
  return
endif

if !flock()
  @23,10 say 'Parameter file in use - Please try later'
  inkey(10)
  close database
  return
endif

select 2
if !net_use('account', .f.,, 'acccode')
  close databases
  return
endif

select 3
if !net_use('student', .f.,, 'names')
  close databases
  return
endif

if make_sure(4,,'Are you sure you want to print this report ? ')
  select param
  dbgotop()
  dAction = param->nxt_do_dt
  if dAction < date()
    dAction = date()
  endif
  
  begin sequence
    if openprn()
      break
    endif
    nDebits = 0
    nTot_amt = 0
    nGrand_tot = 0
    cTitle = 'DEBITS FOR ' + DTOC(dAction)
    
    select Student
    dbgotop()
    while !eof()
      @10,0 clear
      @10,15 say Student->surname
      select account
      dbseek(Student->std_code)
      do while Student->std_code = account->std_code .and. !eof()
        if account->cr_dr = 'D'
          if account->pmt_type = 'D' .and. account->comment != 'B'
            if account->pmt_dt <= dAction
              if pline > 56
                if ppage != 0
                  ? ' '
                  ? 'Number of debits = ' + STR(nDebits) + '           Total debits = ' + STR(nTot_amt)
                endif
                prntitle(cTitle,'N')
                ? 'PAYEE NAME                      BR NO   ACCOUNT NO          TYPE  AMOUNT'
                ? ' '
                nDebits = 0
                nGrand_tot += nTot_amt
                nTot_amt = 0
              endif
              ? Student->surname + '  ' + Student->bank_code + '  ' +;
                  Student->bnk_acc_no + '  ' + Student->acc_type +;
                  str(account->amount,10,2)
              pline++
              nDebits++
              nTot_amt += account->amount
            endif
          endif
        endif
        dbskip()
      enddo
      select Student
      dbskip()
    enddo (end of students)
    if ppage != 0
      ? ' '
      ? 'Number of debits = ' + STR(nDebits) + '           Total debits = ' + STR(nTot_amt)
    endif
    prntitle(cTitle,'N')
    nGrand_tot += nTot_amt
    ? ' '
    ? 'GRAND TOTAL                ' + str(nGrand_tot)
    shutprn()
  end sequence
  select account
endif (yesno)

close databases

return

* EOF
