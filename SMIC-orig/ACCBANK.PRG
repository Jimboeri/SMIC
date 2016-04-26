*******************************************************************************
* PROGRAM ACCBANK - PRINTS LIST OF CHEQUES TO BE BANKED
* 7/3/88
* JIM WEST

local dExtract, cTitle

memvar getlist
memvar pLine

last_run(procname())

simhead(memvar->pscr_title)
begin sequence
  
  dExtract := date()
  @12,10 say 'Bank cheques up to' get dExtract
  read
  
  if !wmake_sure(12) .or. openprn()
    break
  endif
  cTitle := 'CHEQUES TO BE BANKED UP TO ' + dtoc(dExtract)
  
  if empty(et_use_dbf('Param'))
    break
  endif
  
  if empty(et_use_dbf('Account'))
    break
  endif
  
  if empty(et_use_dbf('Student'))
    break
  endif
  
  select student
  while !eof()
    select Account
    dbseek(Student->std_code)
    while Account->std_code = Student->std_code .and. !eof()
      if (Account->pmt_type = 'Q' .or. Account->pmt_type = 'E') .and.;
            Account->comment = 'Y' .and. Account->cr_dr = 'D'
        if Account->pmt_dt <= dExtract
          if pline > 60
            prntitle(cTitle,'n')
            pr_line('ACC NO   CQ DATE          AMOUNT       NAME')
            pr_line(' ')
          endif
          pr_line(Account->std_code + '    ' + dtoc(Account->pmt_dt) + ' ' +;
              str(Account->amount) + '    ' + Student->rep + ' ' +;
              trim(Student->surname) + ' ' + Student->name)
        endif
      endif
      dbskip()
    enddo (end of student accounts)
    select Student
    dbskip()
  enddo (end of student file)
  select param
  reclock('Parameter')
  Param->lst_bank := dExtract
  dbunlock()
  
end sequence
shutprn()
et_close('Account')
et_close('Student')
et_close('Param')
return

* eof
