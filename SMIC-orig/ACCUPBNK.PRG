*******************************************************************************
* PROGRAM ACCUPBNK - UPDATES ACCOUNTS WITH CHEQUES BANKED
* 7/3/88
* JIM WEST

local lAuto, lUpdate, nAmount, cType, nUs, nVat

begin sequence
  select 1
  if !net_use('param')
    break
  endif
  
  simhead(memvar->pscr_title)
*  @12,10 say 'Update of all cheques dated ' + dtoc(param->lst_bank) +;
*      ' or before'
  lAuto = wmake_sure(13,,'Update of all cheques dated ' + dtoc(date()) +;
      ' or before', 'Do you want an Automatic update (Y/N)? ')
  
  if !wmake_sure(17,,'Proceed with update ? ')
    break
  endif
  select 2
  if !net_use('account', .f.,, 'acccode')
    break
  endif
  
  select 3
  if !net_use('student', .f.,, 'names')
    break
  endif
  
  while !eof()
    reclock('Student')
    select Account
    dbseek(Student->std_code)
    while Account->std_code = Student->std_code .and. !eof()
      if (Account->pmt_type = 'Q' .or. Account->pmt_type = 'E') .and.;
            Account->comment = 'Y' .and. Account->cr_dr = 'D'
        if Account->pmt_dt <= date()
          if lAuto
            lUpdate = .T.
          else
            @13,0 say account->std_code + '  ' + dtoc(account->pmt_dt) +;
                str(account->amount,14,2) + '  ' + trim(Student->surname) +;
                '  ' + Student->name
            lUpdate = wmake_sure(17,,'Have you banked the cheque ? ')
          endif (check for update)
          if lUpdate
            tts_on()
            reclock('Accounts')
            Account->comment := 'B'
            if account->pmt_type = 'E'
              Account->pmt_type := 'D'
            endif
            nAmount = Account->amount
            cType = Account->type
            dbunlock()
            nUs = round((nAmount * 100 / (100 + Student->vat_rate)), 2)
            nVat = nAmount - nUs
            dbappend()
            reclock('Accounts')
            Account->std_code := Student->std_code
            Account->type := cType
            Account->cr_dr := 'C'
            Account->amount := nUs
            Account->pmt_dt := date()
            Account->pmt_type := 'Q'
            Account->comment := 'Q'
            Account->vat := nVat
            dbunlock()
            tts_off()
          endif (lUpdate = 'Y')
        endif (pay date <= extract date)
      endif (while accounts exist for the student)
      dbskip()
    enddo (end of student accounts)
    select Student
    dbunlock()
    dbskip()
  enddo (end of student file)
end sequence
select param
reclock()
param->lst_bank := date()
dbunlock()
dbcloseall()

return

* EOF
