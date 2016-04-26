*******************************************************************************
* PROGRAM  'LDUNALL'
* AUTHOR J. WEST
* 7/12/87

LOCAL nTot_ld, nTot_move, nTot_alloc, dNew, nInx, nCnt
local aBranch := {}
memvar cMessage

#define EOL     chr(13) + chr(10)

nTot_ld := nTot_move := nTot_alloc := nInx := 0
dNew = date() - 1

wopen(8,10,11,70)
wcenter()
wbox(0)
setcursor(0)
@0,0 say center('MOVING FORWARD UNALLOCATED LEADS')

begin sequence
  select 1
  if !net_use('newleads', .f.,, 'archives', 'rleads')
    break
  endif
  
  select 2
  if !net_use('param', .f.)
    break
  endif
  
  select 3
  if !net_use('reps', .f.,, 'reps')
    break
  endif
  
  while !eof()
    if reps->level = 'B'
      aadd(aBranch, substr(reps->salespsn,1,1))
      nInx = len(aBranch)
      while substr(reps->salespsn,1,1) = aBranch[nInx] .and. !eof()
      if reps->status = 'C'
        if reps->level = 'N'
          aBranch[nInx] = reps->salespsn
        endif
        if reps->level = 'S'
          aBranch[nInx] = reps->salespsn
          exit
        endif
      endif
      dbskip()
      enddo
      if len(aBranch[nInx]) = 1
        aBranch[nInx] = substr(aBranch[nInx], 1, 1) + '?'
      endif
    else
      dbskip()
    endif
  enddo
  for nCnt = 1 to len(aBranch)
    select reps
    if !dbseek(aBranch[nCnt])
      dbappend()
      reclock('rep')
      reps->salespsn := aBranch[nCnt]
      reps->level    := 'R'
      reps->status   := 'C'
      reps->name     := 'UNALLOCATED LEADS'
      reps->start_dt := date()
      dbunlock()
    endif
    if substr(aBranch[nCnt],2,1) != '?'
      dbseek(substr(aBranch[nCnt],1,1) + '?')
      if found() .and. reps->status != 'F'
        reclock('reps')
        reps->status = 'F'
        dbunlock()
      endif
    else
      dbseek(aBranch[nCnt])
      if found() .and. reps->status != 'C'
        reclock('reps')
        reps->fin_dt = ctod('  /  /  ')
        reps->status = 'C'
        dbunlock()
      endif
    endif
  next
  
  select newleads
  dbgotop()
  while !eof()
    nTot_ld++
    @1,0 say replicate('±', nTot_ld / lastrec() * 60)
    tts_on()
    if substr(newleads->salespsn,2,1) = ' '
      nTot_move++
      reclock('Leads')
      newleadS->alloc_dt := dNew
      if newleads->date_rcvd + 90 < date()
        nTot_alloc++
        nInx = ascan(aBranch, substr(newleads->salespsn,1,1))
        if nInx != 0
          newleads->salespsn := aBranch[nInx]
        else
          newleads->salespsn := 'ZZ'
        endif
        select reps
        if dbseek(newleads->salespsn)
          reclock('reps')
          reps->last_lead := date()
          dbunlock()
        endif
        select newleads
      endif
      dbunlock()
    endif (leads unallocated)
    tts_off()
    dbskip()
  enddo (end of leads)
  select param
  reclock('param')
  param->lst_unall := date()
  dbunlock()
  cMessage += 'Total leads           = ' + str(nTot_ld,10,0) + EOL
  cMessage += 'Leads brought forward = ' + str(nTot_move,10,0) + EOL
  cMessage += 'Leads re-allocated    = ' + str(nTot_alloc,10,0) + EOL
end sequence
wclose()
et_close('param')
et_close('Reps')
et_close('Newleads')
return

*eof
