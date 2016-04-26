*******************************************************************************
*
* VATRPT - Prints details of vat collected
* Author Jim West
* Date 1992

local dStart, dEnd, nTot_vat, nTot_deb, nTot_cq, nTot_cc, nTot_oth
local cTitle, cLine
memvar getlist, pLine

nTot_vat := nTot_deb := nTot_cq := nTot_cc := nTot_oth := 0

begin sequence
  select 1
  if !net_use('student', .f.,, 'names')
    break
  endif
  
  select 2
  if !net_use('account', .f.,, 'acccode')
    break
  endif
  
  simhead(memvar->pscr_title)
  @5,20 say 'Print VAT collected for a period'
  dStart = ctod('  /  /  ')
  dEnd = date()
  @7,20 say 'Period start ' get dStart
  @8,20 say 'Period end   ' get dEnd valid (dEnd > dStart)
  read
  
  if !make_sure(12,,'Print VAT report') .or. openprn()
    break
  endif
  memvar->lPr_esc := .t.
  cTitle = 'VAT collected between ' + dtoc(dStart) + ' and ' + dtoc(dEnd)
  select Student
  while !eof()
    @12,20 say Student->surname
    if Student->vat_rate > 0
      select Account
      seek Student->std_code
      while Account->std_code = Student->std_code .and. !eof()
        if Account->cr_dr = 'C' .and. Account->pmt_dt >= dStart .and.;
              Account->pmt_dt <= dEnd
          if pline > 60
            prntitle(cTitle, 'Y')
            pr_line('ACC NO  NAME                                                  DATE          CHEQUE   CRED CARD     DEB ORD       OTHER')
            pr_line('')
          endif
          cLine =Account->std_code + ' ' + trim(Student->surname) + ' ' +;
              trim(Student->name)
          cLine += space(60 - len(cLine))
          do case
            case Account->pmt_type = 'Q'
              cLine += dtoc(Account->pmt_dt) + space(4) +;
                  str(Account->vat,10,2)
              nTot_cq += Account->vat
            case Account->pmt_type = 'C'
              cLine += dtoc(Account->pmt_dt) + space(16) +;
                  str(Account->vat,10,2)
              nTot_cc += Account->vat
            case Account->pmt_type = 'D'
              cLine += dtoc(Account->pmt_dt) + space(28) +;
                  str(Account->vat,10,2)
              nTot_deb += Account->vat
            case Account->pmt_type = 'O'
              cLine += dtoc(Account->pmt_dt) + space(40) +;
                  str(Account->vat,10,2)
              nTot_oth += Account->vat
          endcase
          pr_line(cLine)
        endif
        dbskip()
      enddo
    endif
    select Student
    dbskip()
  enddo
  pr_line('')
  pr_line('TOTALS' + space(64) + str(nTot_cq,12,2) + str(nTot_cc,12,2) +;
      str(nTot_deb,12,2) + str(nTot_oth,12,2))
  pr_line('')
  pr_line('TOTAL VAT COLLECTED  = ' + str(nTot_vat,12,2))
end sequence
shutprn()

et_close('Student')
et_close('Account')

return

*eof
