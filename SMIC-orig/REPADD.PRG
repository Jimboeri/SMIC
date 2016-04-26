*******************************************************************************
* PROGRAM 'REPADD'
* AUTHOR JIM WEST (E.T.)
* 7/89

local cRep, cLevel, cStatus, cName, dStart
memvar getlist

if !net_use('Reps', .f.,, 'reps')
  return
endif

simhead(memvar->pscr_title)
@3,10 say 'Initial data capture of a new sales person'
cRep = '  '
@5,10 say 'Enter sales persons code ' get cRep picture '!!'
read
if !empty(cRep)
  if dbseek(cRep)
    wait_msg(18, 'Reps code already exists',,,30)
  else
    if !dbseek(substr(cRep,1,1) + ' ') .and. substr(cRep,1,1) + ' ' != cRep
      wait_msg(18, 'Branch does not exist',,,30)
    else
      if substr(cRep,2,1) = ' '
        cLevel := 'B'
      else
        cLevel := 'R'
      endif
      cStatus := 'C'
      cName := space(30)
      dStart := date()
      @7,10 say 'Name ' get cName picture '@!' valid !empty(cName)
      @9,10 say 'Start date ' get dStart
      read
      dbappend()
      reclock('Reps')
      Reps->salespsn := cRep
      Reps->name     := cName
      Reps->level    := cLevel
      Reps->status   := cStatus
      Reps->start_dt := dStart
      dbunlock()
    endif
  endif
endif
et_close('Reps')
return
* EOF
