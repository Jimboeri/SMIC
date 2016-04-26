local dStart := ctod('30/09/91')

select 1
if !net_use('student', .f., 'std', 'names')
  return
endif

openprn()
sTitle = 'students signed up since 30 September 1991'
while !eof()
  if (!empty(sold_crs_1) .and. sold_crs_1 < dStart) .or. (!empty(sold_els) .and. sold_els < dStart)
    ;
  else
    if vat_rate = 0
      if pline > 55
        prntitle(sTitle, 'N')
      endif
      ? trim(surname) + ' ' + trim(name)
      pline++
    endif
  endif
  skip
enddo
shutprn()
close databases
return
*eof