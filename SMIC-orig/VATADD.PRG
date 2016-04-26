*******************************************************************************
*
*  VATADD - temporary program to clasify students as vat payers
*

local dStart := ctod('30/09/91')

select 1
if !net_use('student', .f., 'std', 'names')
  return
endif

select 2
if !net_use('account', .f., 'acc', 'acccode')
  close databases
  return
endif

simhead(pscr_title)
@ 5,10 say 'Enter the students you have collected VAT for and then press'
@ 6,10 say 'ESC when you have finished.  Please be careful as reversing this'
@ 7,10 say 'will be very difficult'
@9,10
wait

select std
while !eof()
simhead(pscr_title)
  findstd()
  if !eof()
    if (!empty(sold_crs_1) .and. sold_crs_1 < dStart) .or. (!empty(sold_els) .and. sold_els < dStart)
      disp_msg(10,,'Student signed up before 30 September 1991','Cannot change to VAT')
      inkey(0)
    elseif std->vat_rate != 0
      disp_msg(10,,'Student already VAT rated')
      inkey(0)
    else
      if make_sure(14,,'Change ' + trim(title) + ' ' + trim(name) + ' ' + trim(surname) + ' to VAT')
        reclock('student')
        std->vat_rate := 10
        unlock
        select acc
        seek std->std_code
        while acc->std_code = std->std_code .and. !eof()
          if cr_dr = 'C'
            nUs = round((amount * 100 / (100 + std->vat_rate)), 2)
            nVat = amount - nUs
            reclock('account')
            acc->amount := nUs
            acc->vat := nVat
            unlock
          endif
          skip
        enddo
        select std
      endif
    endif
  endif
enddo
close databases
return
*eof()