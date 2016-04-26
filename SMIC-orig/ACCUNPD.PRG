*******************************************************************************
* PROGRAM ACCUNPD - PRINTS BAD DEBTS
* 14/3/88
* JIM WEST

local nRep_type, nAcc_type, cAcc_type, cBranch, cTitle, nGrand_tot
local nTotal, cStd_store, cLine, n30_over, n60_over, n90_over, n120_over
memvar getlist, pLine

local aRep := {'All students countrywide',;
    'Students by branch'}

local aAcc_type := {'TWIN student accounts',;
    'Portfolio advisory accounts'}

simhead(memvar->pscr_title)
@4,10 say 'printing bad debts'

begin sequence
  
  nRep_type = get_arr(aRep,7)
  if nRep_type = 0
    break
  endif
  
  cBranch = ' '
  if nRep_type = 2
    @12,10 say 'Enter branch code for printout ' get cBranch picture '!'
    read
  endif
  
  nAcc_type = get_arr(aAcc_type, 16)
  if nAcc_type = 0
    break
  endif
  
  if nAcc_type = 1
    cAcc_type = 'T'
  elseif nAcc_type = 2
    cAcc_type = 'P'
  endif
  
  if !wmake_sure(21) .or. !openprn()
    @5,0 clear
    select 1
    if !net_use('account', .f.,, 'acccode')
      break
    endif
    
    select 2
    if !net_use('student', .f.,, 'names')
      break
    endif
    
    nTotal = 0
    nGrand_tot = 0
    n30_over = 0
    n60_over = 0
    n90_over = 0
    n120_over = 0
    cStd_store = SPACE(5)
    cTitle = 'BAD DEBTORS AS AT ' + dtoc(date())
    if nAcc_type = 1
      cTitle += '  TWIN STUDENTS'
    else
      cTitle += '  PORTFOLIO ADVISORY'
    endif
    
    while !eof()
      if (nRep_type = 1) .or. (cBranch = substr(Student->rep,1,1))
        @17,10 say Student->surname
        nTotal = 0
        select Account
        dbseek(Student->std_code + cAcc_type)
        while Account->std_code = Student->std_code .and.;
              Account->type = cAcc_type .and. !eof()
          if Account->cr_dr = 'D'
            if Account->pmt_dt < date() .and. Account->comment != 'B'
              if pline > 60
                prntitle(cTitle,'Y')
              endif
              if Student->std_code != cStd_store
                cStd_store = Student->std_code
                cLine = Student->std_code + ' ' + Account->type + ' ' +;
                    trim(Student->surname) + ' ' + trim(Student->name)
                cLine = TRIM(cLine)
                cLine += space(52 - len(cLine))
                cLine += '30 DAYS        60 DAYS        90 DAYS       90+ DAYS'
                pr_line(cLine)
                cLine = 'Status ' + Student->status + '  '
                if !empty(Student->phone_w)
                  cLine += 'Phone (W) ' + trim(Student->phone_w) + '  '
                endif
                if !empty(Student->phone_h)
                  cLine += 'Phone (H) ' + trim(Student->phone_h)
                ENDIF
                pr_line(cLine)
              endif
              do case
                case date() - Account->pmt_dt < 30
                  cLine = space(47) + str(Account->amount,12,2)
                  n30_over += Account->amount
                case date() - Account->pmt_dt < 60
                  cLine = space(62) + str(Account->amount,12,2)
                  n60_over += Account->amount
                case date() - Account->pmt_dt < 90
                  cLine = space(77) + str(Account->amount,12,2)
                  n90_over += Account->amount
                otherwise
                  cline = space(92) + str(Account->amount,12,2)
                  n120_over += Account->amount
              endcase
              pr_line(cLine)
              nTotal += Account->amount
            endif (BAD DEBT)
          endif (CR_DR = D)
          dbskip()
        enddo (END OF Student ACCOUNTS)
        select Student
        if nTotal > 0
          pr_line(space(112) + str(nTotal,12,2))
          pr_line(' ')
          nGrand_tot += nTotal
        endif
        nTotal = 0
      endif
      dbskip()
    enddo (end of student file)
    pr_line(' ')
    pr_line('TOTAL BAD DEBTS' + SPACE(37) +;
        '30 DAYS        60 DAYS        90 DAYS       90+ DAYS')
    pr_line(space(47) + str(n30_over,12,2) + '   ' + str(n60_over,12,2) +;
        '   ' + str(n90_over,12,2) + '   ' + str(n120_over,12,2))
    pr_line('GRAND TOTAL BAD DEBTS = ' + ltrim(str(nGrand_tot)))
  endif
end sequence
shutprn()
dbcloseall()
RETURN
*EOF
