*******************************************************************************
*PROGRAM 'TRNLOOK' - TRANSACTION VIEWER
* Author - Jim West
* 1/2/88

begin sequence
  
  select 1
  if !net_use('transact', .f., , 'trancode')
    break
  endif
  
  select 2
  if !net_use('student', .f.,, 'stdcode', 'names', 'stdarc', 'stdgroup')
    break
  endif
  dbsetorder(2)
  
  select 3
  if !net_use('share', .f.,, 'shrname')
    break
  endif
  
  select 4
  if !net_use('portfol', .f.,, 'portfol')
    break
  endif
  
  select 5
  if !net_use('bear', .f.,, 'bear')
    break
  endif
  
  select 6
  if !net_use('order', .f.,, 'order')
    break
  endif
  
  select 7
  if !net_use('shrdescr', .f.,, 'shrdescr')
    break
  endif
  
  select student
  simhead(memvar->pscr_title)
  findstd()
  
  if eof()
    @23,10 say 'STUDENT DOES NOT EXIST'
    inkey(10)
  else
    trndisp()
  endif
end sequence
dbcloseall()
return
* EOF
