*******************************************************************************
* 'ACCSTAT' PRINTS STATEMENTS FOR STUDENTS
* JIM WEST

local aPrint[0]                                                 // print array
local nCnt, cLine1, cLine2, dTemp, cRef
local nArrear, nCurrent, nDebit, nCredit, cLine, nRow

simhead(memvar->pscr_title)
@3,10 say 'PRINTING STATEMENTS FOR STUDENTS'

begin sequence
  
  if !wmake_sure()
    break
  endif
  
  select 3
  if !net_use('param', .f.,)
    break
  endif
  
  select 2
  if !net_use('account', .f.,, 'acccode')
    break
  endif
  
  select 1
  if !net_use('student', .f.,, 'names')
    break
  endif
  
  while !eof()
    @10,20 say Student->surname
    @3,10 say 'PRINTING STATEMENTS FOR STUDENTS'
    asize(aPrint, 0)
    cLine1 = space(70)
    cLine2 = space(70)
    *  @5,20 SAY 'Statement for ' + TRIM(TITLE) + ' ' + SUBSTR(NAME,1,1) + ' ' + SURNAME
    *  @7,5 SAY 'Enter any comment below'
    *  @8,5 GET cLine1
    *  @9,5 GET cLine2
    *  READ
    *  cLine1 = TRIM(cLine1)
    *  cLine2 = TRIM(cLine2)
    aadd(aPrint, space(35) + 'STATEMENT')
    aadd(aPrint, ' ')
    aadd(aPrint, space(25) + upper(memvar->cCo_name))
    aadd(aPrint, memvar->pr_comp + space(58) + 'Reg no CK 88/12001/23' +;
        memvar->pr_comp_of)
    aadd(aPrint, space(60) + trim(Param->p_addr1))
    aadd(aPrint, space(60) + trim(Param->p_addr2))
    aadd(aPrint, space(60) + trim(Param->p_code))
    aadd(aPrint, space(60) + 'Phone 011 ' + trim(Param->phone_no))
    aadd(aPrint, space(60) + 'Fax   011 ' + trim(Param->fax_no))
    aadd(aPrint, ' ')
    aadd(aPrint, ' ')
    aadd(aPrint, '        ' + trim(Student->title) + ' ' +;
        substr(Student->name,1,1) + ' ' + Student->surname)
    aadd(aPrint, '        ' + Student->address1)
    aadd(aPrint, '        ' + Student->address2)
    aadd(aPrint, '        ' + Student->address3)
    aadd(aPrint, '        ' + Student->p_code)
    aadd(aPrint, ' ')
    dTemp = dtoc(date())
    cRef = Student->std_code + substr(dTemp,1,2) + substr(dTemp,4,2) +;
        substr(dTemp,7,2)
    aadd(aPrint, space(50) + 'Account no ' + Student->std_code)
    aadd(aPrint, space(50) + 'Date ' + dtoc(date()))
    aadd(aPrint, space(50) + 'Ref ' + cRef)
    aadd(aPrint, replicate('-',80))
    aadd(aPrint, memvar->pr_comp + 'Date         Reference                                                                   Debit             Credit')
    aadd(aPrint, ' ')
    nArrear = 0
    nCurrent = 0
    nDebit = 0
    nCredit = 0
    select account
    dbseek(Student->std_code + 'T')
    while Student->std_code = Account->std_code .and. Account->type = 'T';
     .and. !eof()
      if Account->comment != 'C'
        cLine = dtoc(Account->pmt_dt)
        if Account->cr_dr = 'D'
          cLine += '     Payment for Stock Market Investors Course                          ';
           + str(Account->amount)
          nDebit += Account->amount
          if Account->comment != 'B' .and. Account->pmt_dt < date()
            dTemp = Account->pmt_dt
            dTemp = et_addmonth(dTemp)
            IF dTemp < date()
              nArrear += Account->amount
            else
              nCurrent += Account->amount
            endif
          endif
        else
          if Account->cr_dr = 'C'
            cLine += '     Payment received                                                                      ';
             + str(Account->amount)
            nCredit += Account->amount + Account->vat
          endif
        endif
        aadd(aPrint, cLine)
      endif
      dbskip()
    enddo
    select student
    aadd(aPrint, memvar->pr_comp + replicate('-',80) + memvar->pr_comp_of)
    aadd(aPrint, 'Totals' + space(75) + str(nDebit) + '      ' + str(nCredit))
    if (nArrear + nCurrent) > 0
      nRow = 51 - len(aPrint)
      while nRow > 0
        aadd(aPrint, ' ')
        nRow--
      enddo
      aadd(aPrint, memvar->pr_comp + space(5+((70-len(cLine1))/2)) + cLine1)
      aadd(aPrint, space(5+((70-len(cLine2))/2)) + cLine2 + memvar->pr_comp_of)
      aadd(aPrint, replicate('-',80))
      aadd(aPrint, 'REMITTANCE ADVICE')
      aadd(aPrint, ' ')
      aadd(aPrint, '    Please include this remittance advice with your payment')
      aadd(aPrint, '    ' + trim(Student->title) + ' ' +;
       substr(Student->name,1,1) + ' ' + Student->surname)
      aadd(aPrint, ' ')
      aadd(aPrint, space(20) + 'Account no ' + Student->std_code)
      aadd(aPrint, ' ')
      aadd(aPrint, '     Arrears    ' + str(nArrear,14,2))
      aadd(aPrint, '     Current    ' + str(nCurrent,14,2))
      aadd(aPrint, '                 -------------')
      aadd(aPrint, '     TOTAL DUE  ' + str(nArrear + nCurrent,14,2))
    endif
    aadd(aPrint, memvar->pr_comp_of + memvar->pr_form_fe)
    if (nArrear + nCurrent) > 0
      set print on
      set consol off
      for nCnt = 1 to len(aPrint)
        ? aPrint[nCnt]
      next
      set consol on
      set print off
    endif
    select Student
    dbskip()
  enddo
end sequence
set print off
set console on
dbcloseall()

return

*EOF
