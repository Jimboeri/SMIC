*******************************************************************************
* PROGRAM 'PFOLLDT'
*

local dSt_dt, dEnd_dt, cRep, cTitle
memvar getlist, pLine

select 2
if !net_use('student', .f., , 'stdarc')
  return
endif

select 1
if !net_use('newleads', .f., , 'rleads')
  return
endif

simhead(memvar->pScr_title)
begin sequence
  @4,10 say '****** PRINTS LEADS TO BE FOLLOWED UP BY SALESPERSON ******'
  dSt_dt := dEnd_dt := ctod('  /  /  ')
  
  cRep = '  '
  @6,0 SAY 'Enter sales person code or agent code' get cRep picture '!!'
  read
  if !empty(cRep)
    @10,10 say 'SALESPERSON/AGENT CODE = ' + cRep
    @12,0 say 'Enter start date for report ' get dSt_dt picture '@D'
    @13,0 say 'Enter end date for report   ' get dEnd_dt picture '@D'
    read
    
    if wmake_sure(17)
      @18,10 say 'Printing follow up  report for ' + cRep
      if openprn()
        break
      endif
      cTitle := 'LEADS TO BE FOLLOWED UP FOR SALESPERSON/AGENT ' + cRep +;
          '   ' + DTOC(dSt_dt) + ' TO ' + DTOC(dEnd_dt)
      dbseek(cRep)
      while cRep = Newleads->salespsn .and. !eof()
        if Newleads->follow_dt >= dSt_dt .and. Newleads->follow_dt <= dEnd_dt
          if pline > 52
            prntitle(cTitle,'Y')
            pline = 6
            ? '                                                            ' +;
                '                                    FOLLOW          SOLD     SOLD'
            ? 'SP ALLOC-DT ARCHIV            NAME                           ADDRESS3   ' +;
                '               CHGE SRCE  DATE INT      MOD1     MOD2'
            ? ' '
          endif
          ? Newleads->salespsn + ' ' + dtoc(Newleads->alloc_dt) + ' ' +;
              Newleads->archiv + ' ' + Newleads->title + ' ' + Newleads->initls;
              + ' ' + Newleads->surname + ' ' + Newleads->address3 + ' ' +;
              Newleads->misc_cd + ' ' + Newleads->source_cd + ' ' +;
              dtoc(Newleads->follow_dt) + '  ' + Newleads->intview
          select student
          if dbseek(newleads->archiv)
            ?? '      ' + dtoc(student->sold_crs_1) + ' ';
                + dtoc(student->sold_crs_2)
          endif
          select newleads
          pline++
        endif
        dbskip()
      enddo
      shutprn()
    endif (yesno = 'y')
  endif (cRep <> '  ')
end sequence
dbcloseall()
return
*eof
