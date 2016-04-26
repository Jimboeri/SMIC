*******************************************************************************
*
*  SHR_EXP - Exports Fundamental comments
*
*
*******************************************************************************

local aStru, dStart, dEnd, nRecs, nExport
memvar getlist

#include 'inkey.ch'

aStru := {}
dStart = ctod('')
dEnd = date()
nRecs := nExport := 0

wopen(8,10,18,70)
setcolor(memvar->cyan_blue)
wbox()
@0,0 say center('Create comment export file') color memvar->yell_blue

begin sequence
  
  @2,2 say 'Start date for extract ' get dStart
  @3,2 say 'End date for extract   ' get dEnd
  read
  
  if lastkey() = K_ESC .or. !wmake_sure(18,,'Create export file now? (Y/N)')
    break
  endif
  
  if file('SHR_EXP.DBF')
    deletefile('SHR_EXP.DBF')
  endif
  
  aadd(aStru, {'SHARE', 'C', 9, 0})
  aadd(aStru, {'CMNT_1', 'C', 80, 0})
  aadd(aStru, {'CMNT_2', 'C', 80, 0})
  aadd(aStru, {'CMNT_3', 'C', 80, 0})
  aadd(aStru, {'CMNT_4', 'C', 80, 0})
  aadd(aStru, {'CMNT_5', 'C', 80, 0})
  aadd(aStru, {'CMNT_6', 'C', 80, 0})
  aadd(aStru, {'CMNT_7', 'C', 80, 0})
  aadd(aStru, {'CMNT_8', 'C', 80, 0})
  aadd(aStru, {'CMNT_DT', 'D', 8, 0})
  dbcreate('SHR_EXP', aStru)
  
  select 1
  if !net_use('shr_exp', .f.)
    break
  endif
  
  select 4
  if !net_use('shrdescr', .f.,, 'shrdescr')
    break
  endif
  
  select shrdescr
  dbgotop()
  while !eof()
    nRecs++
    @5,3 say 'Records checked  ' + str(nRecs)
    if shrdescr->lst_f_chg >= dStart .and. shrdescr->lst_f_chg <= dEnd
      nExport++
      @6,3 say 'Records exported ' + str(nExport)
      select shr_exp
      dbappend()
      reclock()
      shr_exp->share := shrdescr->share
      shr_exp->cmnt_1 := shrdescr->fundamnt_1
      shr_exp->cmnt_2 := shrdescr->fundamnt_2
      shr_exp->cmnt_3 := shrdescr->fundamnt_3
      shr_exp->cmnt_4 := shrdescr->fundamnt_4
      shr_exp->cmnt_5 := shrdescr->fundamnt_5
      shr_exp->cmnt_6 := shrdescr->fundamnt_6
      shr_exp->cmnt_7 := shrdescr->fundamnt_7
      shr_exp->cmnt_8 := shrdescr->fundamnt_8
      shr_exp->cmnt_dt := shrdescr->lst_f_chg
      dbunlock()
    endif
    select shrdescr
    dbskip()
  enddo

wait_msg(17, 'A file called SHR_EXP.DBF has been created.',;
  'This may be E Mailed or copied on a diskette for the person who needs it.')
  
end sequence
wclose()
et_close('shr_exp')
et_close('shrdescr')

return

* eof()
