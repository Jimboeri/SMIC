*******************************************************************************
*
*  RECCHECK - CHECKS FOR, AND DELETES OLD LEAD RECORDS
*
*******************************************************************************

local nLd_del := 0, nRec
memvar cMessage

simhead(memvar->pscr_title)
wopen(8,10,12,70)
wcenter()
wbox(0)
setcursor(0)
@0,0 say center('CHECKING FOR OLD RECORDS')

begin sequence
  
  select 1
  if !net_use('adverts', .f.,, 'advmedia')
    break
  endif
  
  select 2
  if !net_use('newleads', .f.,, 'archives', 'media', 'rleads')
    break
  endif
  
  select 3
  if !net_use('student', .f.,, 'stdarc')
    break
  endif
  
  select 4
  if !net_use('oldleads', .f.,, 'oldarc')
    break
  endif
  
  select newleads
  nRec = 0
  while !eof()
    nRec++
    @1,0 say replicate('±', nRec / lastrec() * 60)
    select Adverts
    dbseek(newleads->source_cd + dtos(newleads->source_dt))
    if !found() .or. adverts->ld_gen = 'K'
      if newleads->date_rcvd+365 < date()
        select Student
        if !dbseek(newleads->archiv)
          select Oldleads
          if !dbseek(newleads->archiv)
            if newleads->killed != 'Y'
              dbappend()
              reclock('OLDLEADS')
              Oldleads->archiv     := Newleads->archiv
              Oldleads->title      := newleads->title
              Oldleads->initls     := newleads->initls
              Oldleads->surname    := Newleads->surname
              Oldleads->address1   := Newleads->address1
              Oldleads->address2   := Newleads->address2
              Oldleads->address3   := Newleads->address3
              Oldleads->p_code     := Newleads->p_code
              Oldleads->phone_h    := Newleads->phone_h
              Oldleads->phone_w    := Newleads->phone_w
              Oldleads->race       := Newleads->race
              Oldleads->sex        := Newleads->sex
              Oldleads->occupation := Newleads->occupation
              Oldleads->self_emp   := Newleads->self_emp
              Oldleads->source_cd  := Newleads->source_cd
              Oldleads->source_dt  := Newleads->source_dt
*              Oldleads->rcvd_dt    := Newleads->date_rcvd
*              Oldleads->lead_gen_c := newleads->lead_gen_c
              Oldleads->salespsn   := Newleads->salespsn
              Oldleads->misc_cd    := Newleads->misc_cd
              dbunlock()
            endif (lead not killed)
          endif (old lead found)
          select Newleads
          reclock('newleads')
          dbdelete()
          dbunlock()
          nLd_del++
        endif (student not found)
      endif (more than 1 year old)
    endif (advert not found or killed)
    select Newleads
    dbskip()
  enddo
  cMessage += 'Leads deleted = ' + LTRIM(STR(nLd_del)) + chr(13) + chr(10)
  et_close('Oldleads')
  et_close('Adverts')
  et_close('Student')
  
  *******************************************************************************
  *
  *  THIS SECTION DELETES VERY OLD REPS
  *
  *
  *
  *******************************************************************************
  
  select 1
  if !net_use('reps', .f.,, 'reps')
    break
  endif
  
  select newleads
  dbsetorder(2)           // media
  
  select Reps
  nrec = 0
  while !eof()
    nRec++
    @2,0 say replicate('±', nRec / lastrec() * 60)
    if reps->banking = 0 .and. reps->last_comm + 90 < date()
      if reps->status = 'F'
        select Newleads
        if !dbseek(reps->salespsn)
          select Reps
          reclock('reps')
          dbdelete()
          dbunlock()
        endif
      endif
    endif (0 banking)
    select Reps
    dbskip()
  enddo
  et_close('Reps')
  
  rem_tts('REPS.NTX')
  
  if net_use('reps',.t.)
    @2,0 say center('NOW COMPACTING REPS DATABASE', .t.)
    pack
    @2,0 say center('NOW PACKING REPS DATABASE', .t.)
    index on reps->salespsn to reps
  endif
  
  add_tts('REPS.DBF')
  add_tts('REPS.NTX')

  select 6
  if !net_use('Param', .f.)
    break
  endif
  reclock()
  param->lst_recck := date()
  dbunlock()
end sequence
et_close('Oldleads')
et_close('Adverts')
et_close('Student')
et_close('Newleads')
et_close('Reps')
wclose()

return

* eof
