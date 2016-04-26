*******************************************************************************
* PROGRAM ACCREPBK PRINTS REPS FORWARD BANKING
* 14/3/88
* JIM WEST

local aDate[12][2], nCnt, nMth, nYr, nRun_type, cLine
local aTotal[12][6], nCnt1, cCons, cStd_code, cRep, nUs, cTitle
memvar getlist, pLine
local aRun_type := {'Rep',;
    'Sales manager',;
    'National Sales Manager',;
    'Company total'}

begin sequence
  if empty(et_use_dbf('Account'))
    break
  endif
  
  if empty(et_use_dbf('Student'))
    break
  endif
  dbsetorder(2)
  
  simhead(memvar->pscr_title)
  
  disp_msg(5,, 'Printing forward banking')
  
  aDate[1, 1] = month(date())
  aDate[1, 2] = year(date())
  nMth = aDate[1, 1]
  nYr = aDate[1, 2]
  for nCnt = 2 to 12
    nMth++
    if nMth > 12
      nYr++
      nMth = 1
    endif
    aDate[nCnt, 1] = nMth
    aDate[nCnt, 2] = nYr
  next
  
  nRun_type = get_arr(aRun_type, 13, 20,)
  @10,0 clear
  cRep = '  '
  if nRun_type != 0
    if nRun_type != 4
      @11,10 say 'Input sales person code ' get cRep picture '!!'
      read
    endif
    if openprn()
      break
    endif
    memvar->lPr_esc := .t.
    cTitle = 'FORWARD BANKING FOR ' + cRep
    if nRun_type = 2
      cTitle = '(SM) ' + cTitle
    endif
    if nRun_type = 3
      cTitle = '(NSM) ' + cTitle
    endif
    if nRun_type = 4
      cTitle = 'COMPANY FORWARD BANKING'
    endif
    if cRep != '  ' .or. nRun_type = 4
      for nCnt = 1 to 12
        for nCnt1 = 1 to 6
          aTotal[nCnt, nCnt1] = 0
        next
      next
      select Student
      dbgotop()
      while !eof()
        @20,20 say Student->surname
        do case
          case nRun_type = 1
            cCons = Student->rep
          case nRun_type = 2
            cCons = Student->s_m
          case nRun_type = 3
            cCons = Student->n_s_m
          case nRun_type = 4
            cCons = cRep
        endcase
        if cCons = cRep
          cStd_code = Student->std_code
          select Account
          dbseek(cStd_code)
          while Account->std_code = cStd_code .and. !eof()
            if Account->cr_dr = 'D' .and. Account->comment != 'B'
              if nRun_type = 4 .or. Account->type = 'T'
                if month(Account->pmt_dt) = aDate[1][1] .and.;
                      year(Account->pmt_dt) = aDate[1][2]
                  if pline > 60
                    prntitle(cTitle,'Y')
                    pr_line(' ACC     NAME                               CHEQUE              DEBIT ORDERS            MONEY PMT           ADVISORY SERVICE')
                    pr_line('  NO                                         HELD         MID MONTH     END MONTH        OWED TYPE     MID MONTH       END MONTH')
                    pr_line(' ')
                  endif
                  cLine = Account->type + ' ' + account->std_code + ' ' +;
                      substr(Student->name,1,1) + ' ' + Student->surname
                  nUs = round((Account->amount * 100 / (100 + Student->vat_rate)), 2)
                  if Account->type = 'T'
                    if Account->pmt_type = 'Q' .and. Account->comment = 'Y'
                      cLine += str(nUs,10,2)
                      aTotal[1][1] += nUs
                    elseif Account->pmt_type = 'D'
                      if day(Account->pmt_dt) < 21
                        cLine += space(15) + str(nUs,10,2)
                        aTotal[1][2] += nUs
                      else
                        cLine += space(30) + str(nUs,10,2)
                        aTotal[1][3] += nUs
                      endif
                    else
                      cLine += space(45) + str(nUs,10,2) + ' ' + Account->pmt_type
                      aTotal[1][4] += nUs
                    endif
                  else
                    if day(Account->pmt_dt) < 21
                      cLine += space(62) + str(nUs,10,2)
                      aTotal[1][5] += nUs
                    else
                      cLine += space(77) + str(nUs,10,2)
                      aTotal[1][6] += nUs
                    endif
                  endif
                  pr_line(cLine)
                else
                  for nCnt = 2 to 12
                    if month(Account->pmt_dt) = aDate[nCnt][1] .and.;
                          year(Account->pmt_dt) = aDate[nCnt][2]
                      nUs = round((Account->amount * 100 /;
                       (100 + Student->vat_rate)), 2)
                      if Account->type = 'T'
                        if Account->pmt_type = 'Q' .and. Account->comment = 'Y'
                          aTotal[nCnt][1] += nUs
                        elseif Account->pmt_type = 'D'
                          if day(Account->pmt_dt) < 21
                            aTotal[nCnt][2] += nUs
                          else
                            aTotal[nCnt][3] += nUs
                          endif
                        else
                          aTotal[nCnt][4] += nUs
                        endif
                      else
                        if day(Account->pmt_dt) < 21
                          aTotal[nCnt][5] += nUs
                        else
                          aTotal[nCnt][6] += nUs
                        endif
                      endif
                    endif (date check)
                  next
                endif (date check)
              endif (company or twin record)
            endif (forward bank acc rec)
            dbskip()
          enddo
        endif (salespsn = rep)
        select Student
        dbskip()
      enddo
      pr_line(' ')
      cLine ='TOTALS                                  ' +;
          str(aTotal[1][1],10,2) + '     ' + str(aTotal[1][2],10,2) + '     ';
          + str(aTotal[1][3],10,2) + '     ' + str(aTotal[1][4],10,2)
      if nRun_type = 4
        cLine += '       ' + str(aTotal[1][5],10,2) + '     ' +;
            str(aTotal[1][6],10,2)
      endif
      pr_line(cLine)
      pr_line('')
      pr_line('N.B. These figures do not include any VAT collected')
      prntitle(cTitle,'Y')
      pr_line(' MONTH DUE                              CHEQUE             DEBIT ORDERS             MONEY               ADVISORY SERVICE')
      pr_line('                                         HELD         MID MONTH     END MONTH        OWED          MID MONTH       END MONTH')
      pr_line(' ')
      for nCnt = 2 to 12
        cLine = str(aDate[nCnt][1],2,0) + '/' + str(aDate[nCnt][2],4,0) +;
            '                           ' + str(aTotal[nCnt][1],10,2) +;
            '      ' + str(aTotal[nCnt][2],10,2) + '      ' +;
            str(aTotal[nCnt][3],10,2) + '      ' +;
            str(aTotal[nCnt][4],10,2)
        if nRun_type = 4
          cLine += '      ' + str(aTotal[nCnt][5],10,2) + '      ' +;
              str(aTotal[nCnt][6],10,2)
        endif
        pr_line(cLine)
        pr_line(' ')
      next
      pr_line(' ')
      pr_line('N.B. These figures do not include any VAT collected')
    endif (rep = space)
    shutprn()
  endif (rep != space)
end sequence
close databases
return
*eof
