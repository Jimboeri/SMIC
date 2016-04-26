*******************************************************************************
* 'STDCLASS' - PRINT TOP 10 STUDENTS
* JIM WEST
* 4/88

local aTop[10], aStd_code[10], nLowest, nNtx, lIns, cSub_title, nCol
local nOver_perc, cLine
nLowest = -999999999
AFILL(aTop, -999999999)

simhead(memvar->pscr_title)
@5,10 say 'PRINTING TEN BEST STUDENTS OF THE WEEK'

begin sequence
  if !make_sure(12,25,'Do you want to continue ?')
    break
  endif
  if !net_use('student', .f.,, 'stdcode')
    break
  endif
  
  openprn()
  cSub_title = 'The Top Ten Students on "TWIN"'
  while !eof()
    @15,20 say Student->std_code + ' ' + Student->surname
    if Student->status = 'C'
      if Student->mnth_chang > nLowest
        nNtx = 1
        lIns = .F.
        while nNtx < 11 .and. !lIns
          if Student->mnth_chang > aTop[nNtx]
            ains(aTop, nNtx)
            ains(aStd_code, nNtx)
            aTop[nNtx] = Student->mnth_chang
            aStd_code[nNtx] = Student->std_code
            nLowest = aTop[10]
            lIns = .T.
          endif
          nNtx++
        enddo
      endif
    endif
    dbskip()
  enddo
  
  prntitle(cSub_title, 'Y')
  pr_line('NAME                                                        ANN - MNTH           OVERALL      OVERALL - ANN')
  pr_line(' ')
  for nNtx = 1 to 10
    if dbseek(aStd_code[nNtx])
      ? trim(Student->surname) + ' ' + trim(Student->name)
      nCol = 60 - pcol()
      nOver_perc = (Student->week_1 / Student->initl_val * 100) - 100
      ?? replicate(' ',nCol) + str(Student->mnth_chang,8,2) + '     ' +;
          str(nOver_perc) + '      ' + str(nOver_perc * 52 / Student->wk_smltn)
    endif
  next
  ? ' '
  ? ' '
  ? ' '
  ?? memvar->pr_comp_of
  ? 'Please note that students are ranked according to the rate of growth in the'
  ? 'value of their portfolios OVER THE PREVIOUS MONTH ( i.e. the left hand'
  ? 'column). This allows relatively recent beginners on "TWIN" to be compared'
  ? 'with students who have been trading several months.'
  ? ' '
  ? 'The middle column (Overall) indicates the overall rate of growth in the'
  ? 'value of the portfolio. The right-hand column indicates the overall rate'
  ? 'of growth annualised for a 12 month period. In other words, if the student'
  ? 'continues to perform at his/her current rate of growth, this is the return'
  ? 'he/she is likely to achieve over the full year.'
  ? ' '
  ? 'In order to appear on the list, therefore, you must show good growth on a'
  ? 'month to month basis. If the rate of growth slackens off in any one month,'
  ? 'chances are that you will disappear from the list. It is also important'
  ? 'to remember that many students are making high overall returns, but do not'
  ? 'appear on this list because their performance over the last month slowed'
  ? 'down.'
end sequence
close database
shutprn()
return
* eof
