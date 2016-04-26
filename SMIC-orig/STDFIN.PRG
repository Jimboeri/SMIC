*******************************************************************************
* FINPRNT - PRINTS OUT ALL FINISHED STUDENTS
* JIM WEST
* 03/89

local dSt_dt, dEnd_dt, cTitle, cLine, nPerf, nAnn, nJSE_perf
local Nch, nCq, nDo, nCc
memvar getlist, pLine

draw_box(4,2,20,76)
@6,20 SAY 'Printing finished students'

dSt_dt = date()-31
dEnd_dt = date()

@8,10 say 'Date from which students have finished ' get dSt_dt
@9,10 say 'Date to which students have finished   ' get dEnd_dt
read

begin sequence
select 1
if !net_use('transact', .f.,, 'trancode')
  break
endif

select 3
if !net_use('account', .f.,,'acccode')
break
endif

select 2
if !net_use('student', .f.,,'names')
break
endif

if !wmake_sure(13) .or. openprn()
  break
endif
memvar->lPr_esc := .t.
  cTitle = 'STUDENTS THAT HAVE RECENTLY FINISHED'
  
  dbgotop()
  while !eof()
    @16,20 say Student->surname
    if Student->status = 'F' .and. Student->last_tran >= dSt_dt .and.;
     Student->last_tran <= dEnd_dt
      if pLine > 58
        prntitle(cTitle,'Y')
        ? 'ACC NO  NAME                                     REP FIN DT   PHONE HOME      PHONE WORK      PERFORM   ANNUAL   MARKET     DIFF'
        ? ' '
      endif
      cLine = Student->std_code + '  ' + trim(Student->surname) + ' ' +;
       trim(Student->title) + ' ' + trim(Student->name)
      cLine += space(50 - len(cLine))
      cLine += Student->rep + ' ' + dtoc(Student->last_tran) + ' ' +;
       Student->phone_h + ' ' + Student->phone_w
      nPerf = (Student->week_4 / Student->initl_val * 100) - 100
      cLine += str(nPerf,8,2) + ' '
      nAnn = nPerf * 52 / Student->wk_smltn
      cLine += str(nAnn,8,2) + ' '
      select transact
      dbseek(Student->std_code)
      while Student->std_code = Transact->std_code .and.;
       Transact->trn_type != 'FIN' .and. !eof()
        dbskip()
      enddo
      if Student->std_code = Transact->std_code .and. !eof()
        nJSE_perf = ((Transact->qty / student->start_indx)*100)-100
        cLine += str(nJSE_perf,8,2) + ' ' + str((nPerf - nJSE_perf),8,2)
      endif
pr_line(cLine)
      nCc := nDo := nCq := nCh := 0
      select account
      dbseek(student->std_code + 'T')
      while Account->std_code = student->std_code .and. Account->type = 'T';
       .and. !eof()
        if Account->cr_dr = 'C' .and. Account->comment != 'C'
          do case
            case Account->pmt_type = 'C'
              nCC += Account->amount
            case Account->pmt_type = 'Q'
              nCq += Account->amount
            case Account->pmt_type = 'D'
              nDo += Account->amount
            case Account->pmt_type = 'O'
              nCh += Account->amount
          endcase
        endif
        dbskip()
      enddo
      cLine = '  '
      cLine += if(nCc > 0, '   Paid by Credit card : R' + ltrim(str(nCc,12,2)), '')
      cLine += if(nCq > 0, '   Paid by Cheque : R' + ltrim(str(nCq,12,2)), '')
      cLine += if(nDo > 0, '   Paid by Debit order : R' + ltrim(str(nDo,12,2)), '')
      cLine += if(nCh > 0, '   Paid by Cash : R' + ltrim(str(nCh,12,2)), '')
      pr_line(cLine)
      pr_line(' ')
      select student
    endif
    dbskip()
  enddo
  
end sequence
  shutprn()
return

*EOF
