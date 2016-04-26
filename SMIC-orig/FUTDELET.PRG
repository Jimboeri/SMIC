*******************************************************************************
* Program 'FUTDELET' - DELETION OF FUTURE/OPTION RECORDS
* Author - Jim West

if !net_use('futoptn', .f.,, 'futoptn')
  return
endif

findfut()

if !eof()
  simhead(memvar->pscr_title)
  @3,20 say 'Deletion of a FUTURE RECORD'
  if !rlock()
    @23,10 say 'RECORD IS IN USE - TRY LATER CAREFULLY'
    inkey(20)
    close database
    return
  else
    @6,1 clear
    @5,16 say futoptn->fut_optn
    @5,55 say futoptn->exp_date
    @8,1 say 'Full Name : ' + futoptn->full_name
    *
    if wmake_sure(16,,'Delete future ?')
      dbdelete()
      @20,1 say 'RECORD IS NOW MARKED FOR DELETION'
      inkey(10)
    endif
    dbunlock()
  endif
endif
close databases
return

* eof
