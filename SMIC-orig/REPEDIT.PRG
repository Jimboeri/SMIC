*******************************************************************************
* PROGRAM 'REPEDIT'
* AUTHOR JIM WEST (E.T.)
* 7/89

memvar cLevel, cStatus, dStart, cName, dEnd, cRep
memvar getlist

if !net_use('reps', .f.,, 'reps')
  return
endif

simhead(memvar->pscr_title)

cRep = et_seek('Reps', {1,4}, .t.)

if empty(cRep)
  et_close('Reps')
  return
endif

if !rlock()
  wait_msg(12,'Reps record is locked, please try later',,,30)
else
  cLevel := reps->level
  cStatus := reps->status
  cName := reps->name
  dStart := reps->start_dt
  dEnd := reps->end_dt
  @7,10 say 'Name ' get cName picture '@!' valid !empty(cName)
  @9,10 say "'R'ep 'S'ales manager or 'N'SM " get cLevel picture '!';
      when !empty(substr(cRep,2,1)) valid val_rep_level()
  @11,10 say 'Status ' get cStatus picture '!' valid val_rep_stat()
  @13,10 say 'Start date ' get dStart
  @15,10 say 'End date   ' get dEnd
  read
  Reps->name     := cName
  Reps->level    := cLevel
  Reps->status   := cStatus
  Reps->start_dt := dStart
  Reps->end_dt   := dEnd
  dbunlock()
endif
et_close('Reps')
return
* EOF

*******************************************************************************
static function val_rep_stat()
local oGet, cVal
oGet = getactive()
cVal = oget:buffer
@maxrow(),0 say center(' ',,,.t.)
if cVal $ 'CF'
  return(.t.)
endif
@maxrow(),0 say center('Status must be Current or Finished',,,.t.);
    color memvar->white_red
return(.f.)

*******************************************************************************
static function val_rep_level()
local oGet, cVal
oGet = getactive()
cVal = oget:buffer
@maxrow(),0 say center(' ',,,.t.)
if cVal $ 'RSN'
  return(.t.)
endif
@maxrow(),0 say center('Must be R or S or N',,,.t.);
    color memvar->white_red
return(.f.)

