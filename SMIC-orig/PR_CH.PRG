*******************************************************************************
*
*  PR_CH - printer control
*

local cPrinter, cSect

select 1
if !net_use('param', .f.)
  return
endif

select 2
if !net_use('printer', .f.)
  dbcloseall()
  return
endif

disp_msg(2, memvar->yell_blue,trim(param->printer) + ' Currently selected')

cPrinter = et_seek('printer', {1})

if !empty(cPrinter) .and. wmake_sure(16,,trim(cPrinter) + ' selected',;
      'Press "Y" to select or "Esc" to quit')
  select param
  reclock()
  param->printer := cPrinter
  dbunlock()
  select printer
  dbgotop()
  while printer->gc_psname != cPrinter
    dbskip()
  enddo
  memvar->pr_form_fe  := trim(printer->gc_psff)
  memvar->pr_reset    := trim(printer->gc_psreset)
  memvar->pr_compres  := trim(printer->gc_pscompr)
  memvar->pr_comp_of  := trim(printer->gc_pscom_o)
  memvar->pr_bold     := trim(printer->gc_psbdon)
  memvar->pr_bold_of  := trim(printer->gc_psbdoff)
  memvar->pr_ul       := trim(printer->gc_psulon)
  memvar->pr_ul_of    := trim(printer->gc_psuloff)
  memvar->pr_10_cpi   := trim(printer->gc_ps10cpi)
  memvar->pr_12_cpi   := trim(printer->gc_ps12cpi)
  memvar->pr_setup    := trim(printer->gc_pssetup)
  memvar->pr_flen     := trim(printer->gc_psflen)
  memvar->pr_port     := trim(printer->gc_psport)
  memvar->pr_land     := trim(printer->gc_psland)
  memvar->pr_lines    := printer->gc_formlen             // no of portrait ines
  save all like pr_* to printer
  cSect = disp_msg(12, memvar->white_red, ;
      trim(cPrinter) + ' selected for use, Press any key to proceed')
  inkey(0)
  restsector(cSect)
endif
dbcloseall()
return

* eof()
