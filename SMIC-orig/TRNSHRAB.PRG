*******************************************************************************
* PROGRAM 'TRNSHRAB' - MONEY BACK ON NON TRADING SHARES
* AUTHOR JIM WEST
* 9/2/88

local nCnt, nValue

select 1
if !net_use('transact', .f.,, 'trancode')
  return
endif

select 4
if !net_use('portfol', .f.,, 'portfol')
  close databases
  return
endif

select 5
if !net_use('student', .f.,, 'stdcode')
  close databases
  return
endif

select 3
if !net_use('share', .f.,, 'shrname')
  close database
  return
  endif

simhead(memvar->pscr_title)
findshr()
if !eof()
  @3,0 clear
  @3,10 say 'MONEY BACK ON ' + share->full_name
  if wmake_sure(12,,'Are you SURE you want to continue ?')
    @5,0 clear
    @6,10 say 'This will take some time - have a coffee break'
    setcolor('W*+/N')
    @10,35 say 'SEARCHING'
    setcolor('W/N')
    @12,10 say 'Changing portfolio file'
    nCnt = 0
    select Portfol
    while !eof()
      if portfol->share = Share->share
        nCnt++
        @12,37 say 'Changes = ' + ltrim(str(nCnt))
        select Transact
        dbappend()
        reclock('Transaction')
        Transact->std_code := Portfol->std_code
        Transact->type     := Portfol->type
        Transact->share    := Share->share
        Transact->trn_type := 'MBK'
        Transact->qty      := Portfol->qty
        Transact->trn_dt   := date()
        Transact->price    := Share->price / 100
        Transact->value    := Portfol->qty * Share->price / 100
        dbunlock()
        if Portfol->type = 'T'
          select Student
          seek Portfol->std_code
          reclock('Student')
          nValue = Portfol->qty * Share->price / 100
          Student->cash := Student->cash + nValue
          dbunlock()
        endif
        select Portfol
        reclock('Portfolio')
        dbdelete()
        dbunlock()
      endif
      dbskip()
    enddo
    ?? chr(7)
  endif (yn = y)
endif (share != space)
dbcloseall()
return
*eof
