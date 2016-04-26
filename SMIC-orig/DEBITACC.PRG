*******************************************************************************
* 'ACCSTAT' PRINTS STATEMENTS FOR STUDENTS
* Author Jim West
* Date unknown

local aPrint[0]                                                 // print array
local nCnt, nDebit
memvar pLine

simhead(memvar->pscr_title)
@3,10 say 'PRINTING STATEMENTS FOR STUDENTS'

begin sequence
  if !make_sure()
    break
  endif
  
  select 2
  if !net_use('account', .f., , 'acccode')
    break
  endif
  
  select 1
  if !net_use('student', .f., , 'names')
    break
  endif
  
  openprn()
  memvar->lPr_esc = .t.
  
  while !eof()
    @10,20 say Student->surname
    @3,10 say 'PRINTING debit order STUDENTS'
    asize(aPrint, 0)
    aadd(aPrint, trim(Student->title) + ' ' + trim(Student->name) + ' ' +;
        Student->surname)
    nDebit = 0
    select account
    dbseek(Student->std_code + 'T')
    while Student->std_code = Account->std_code .and. Account->type = 'T';
          .and. !eof()
      if Account->comment != 'C'
        if Account->cr_dr = 'D' .and. Account->comment != 'B'
          aadd(aPrint, dtoc(Account->pmt_dt) + '   ' + str(Account->amount))
          nDebit += Account->amount
        endif
      endif
      dbskip()
    enddo
    select student
    aadd(aPrint, ' ')
    if nDebit > 0
      if pline + len(aPrint) > 58
        prntitle('List of debit orders still to be received')
      endif
      for nCnt = 1 to len(aPrint)
        pr_line(aPrint[nCnt])
      next
    endif
    select student
    dbskip()
  enddo
end sequence
shutprn()
et_close('Account')
et_close('Student')

return

*eof
