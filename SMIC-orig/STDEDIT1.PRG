*******************************************************************************
* PROGRAM 'STDEDIT'
* AUTHOR JIM WEST (E.T.)
* 1/2/88

local cOrig_col, cTitle, cP_code, cName, cAddr1, cAddr2, cAddr3, cSurname
local cPhone_h, cPhone_w, dStart, nInitl_val, cRep, cS_m, cN_s_m
local nRecno, cLook, lValid, cScr, cGroup
memvar getlist

begin sequence
  select Student
  if !rlock()
    wait_msg(20, 'Student already in use - Please try later',,,20)
    break
  endif
  
  select 13
  if !net_use('reps', .f.,, 'reps')
    break
  endif
  
  select 14
  if !net_use('newleads', .f.,, 'archives', 'rleads', 'media')
    break
  endif
  
  dbseek(Student->archiv)
  select Student
  nRecno = recno()
  cTitle = student->title
  cP_code = Student->p_code
  cName = Student->name
  cAddr1 = Student->address1
  cAddr2 = Student->address2
  cAddr3 = Student->address3
  cSurname = Student->surname
  cPhone_H = Student->phone_h
  cPhone_W = Student->phone_w
  dStart = Student->start_dt
  nInitl_val = Student->initl_val
  cRep = Student->rep
  cS_m = Student->s_m
  cN_s_m = Student->n_s_m
  cOrig_col = setcolor(memvar->brown_black + ',' + memvar->black_brown)
  @5,10 clear to 6,40
  @5,10 get cTitle picture '!!!!'
  @5,15 get cName picture '!!!!!!!!!!!!!!!!!!!!'
  @6,10 get cSurname picture '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
  if Student->group_no = '01'
    @7,11 get cAddr1 picture  '!!!!!!!!!!!!!!!!!!!!!!!!!'
    @8,11 get cAddr2 picture '!!!!!!!!!!!!!!!!!!!!!!!!!'
    @9,11 get cP_code picture '!!!!'
    @9,16 get cAddr3 picture '!!!!!!!!!!!!!!!!!!!!!!!!!'
  endif
  @10,13 get cPhone_W picture '!!!!!!!!!!!!!!!'
  @11,13 get cPhone_H picture '!!!!!!!!!!!!!!!'
  if Student->group_no = '01'
    @15,7 get cRep picture '!!'
    @15,16 get cS_m picture '!!'
    @15,27 get cN_s_m picture '!!'
    if Student->status = 'N'
      @11,51 get dStart picture '@D'
      @15,47 get nInitl_val
    endif
  else
    nRecno = recno()
    dbsetorder(4)
    dbseek(student->group_cd + '01')
    
    disp_msg(19,, 'The group leader for this group is:', ;
    trim(student->title) + ' ' + trim(student->name) + ' ' +;
     trim(student->surname))
    dbsetorder(2)
    dbgoto(nRecno)
  endif
  *
  read
  lValid = .F.
  while !lValid
    lValid = .t.
    if empty(cSurname)
      lValid = .F.
      cScr = disp_msg(20,, 'Surname must not be blank')
      @6,10 get cSurname picture '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
      read
      restsector(cScr)
    endif
    if empty(cName)
      lValid = .F.
      cScr = disp_msg(20,, 'First Name must not be blank')
      @5,15 get cName picture '!!!!!!!!!!!!!!!!!!!!'
      read
      restsector(cScr)
    endif
    if cRep != Student->rep
      select reps
      if !dbseek(cRep)
        lValid = .F.
        cScr = disp_msg(20,, cRep + ' - Sales person does not exist')
        cRep = Student->rep
        @15,7 get cRep picture '!!'
        read
        restsector(cScr)
      else
        if reps->status != 'C' .and. (reps->end_dt + 60) < date()
          lValid = .F.
          cScr = disp_msg(20,, cRep + ' - Sales person is not current')
          @15,7 get cRep picture '!!'
          read
          restsector(cScr)
        endif
        if !(reps->level $ 'RSN')
          lValid = .F.
          cScr = disp_msg(20,, cRep + ' - Sales person is not a sales person !!')
          @15,7 get cRep picture '!!'
          read
          restsector(cScr)
        endif
      endif
    endif
    if cS_m != Student->s_m
      select reps
      if!dbseek(cS_m)
        lValid = .F.
        cScr = disp_msg(20, , cS_m + ' - Sales manager does not exist')
        cS_m = Student->s_m
        @15,16 get cS_m picture '!!'
        read
        restsector(cScr)
      else
        if reps->status != 'C' .and. (reps->end_dt + 60) < date()
          lValid = .F.
          cScr = disp_msg(20,, cS_m + ' - Sales manager is not current')
          cS_m = Student->s_m
          @15,16 get cS_m picture '!!'
          read
          restsector(cScr)
        endif
        if !(reps->level $ 'RSN')
          lValid = .F.
          cScr = disp_msg(20,, cS_m + ' - Sales manager is not a sales manager !!')
          cS_m = Student->S_M
          @15,16 get cS_m picture '!!'
          read
          restsector(cScr)
        endif
      endif
    endif
    IF cN_s_m != Student->n_s_m
      select reps
      if !dbseek(cN_s_m)
        lValid = .F.
        cScr = disp_msg(20,, cN_s_m + ' - National sales manager does not exist')
        cN_s_m = Student->N_S_M
        @15,27 get cN_s_m picture '!!'
        read
        restsector(cScr)
      else
        if reps->status != 'C' .and. (reps->end_dt + 60) < date()
          lValid = .F.
          cScr = disp_msg(20,, cN_s_m + ' - National sales manager is not current')
          cN_s_m = Student->N_S_M
          @15,27 get cN_s_m picture '!!'
          read
          restsector(cScr)
        endif
        if !(reps->level $ 'RSN')
          lValid = .F.
          cScr = disp_msg(20,, cN_s_m + ' - National sales manager is not a N.S.M. !!')
          cN_s_m = Student->N_S_M
          @15,27 get cN_s_m picture '!!'
          read
          restsector(cScr)
        endif
      endif
    endif
    select Student
  enddo
  select student
  dbgoto(nRecno)
  reclock('Student')
  Student->title   := cTitle
  Student->name    := cName
  Student->surname := cSurname
  if cAddr1 != Student->address1 .or. cAddr2 != Student->address2 .or.;
   cAddr3 != Student->address3 .or. cP_code != Student->p_code
    Student->addr_incor := ' '
  endif
  Student->address1 := cAddr1
  Student->address2 := cAddr2
  Student->address3 := cAddr3
  Student->p_code   := cP_code
  Student->phone_h  := cPhone_H
  Student->phone_w  := cPhone_W
  Student->start_dt := dStart
  Student->rep      := cRep
  Student->s_m      := cS_m
  Student->n_s_m    := cN_s_m
  if Student->status = 'N'
    Student->cash   := nInitl_val
  endif
  Student->initl_val := nInitl_val
  dbunlock()
  if Student->group_no = '01'
    select Newleads
    if dbseek(Student->archiv)
      reclock('Newleads')
      newleads->salespsn := cRep
      newleads->title    := cTitle
      newleads->initls   := substr(cName,1,1)
      newleads->surname  := cSurname
      newleads->address1 := cAddr1
      newleads->address2 := cAddr2
      newleads->address3 := cAddr3
      newleads->p_code   := cP_code
      IF cAddr1 != newleads->address1 .or. cAddr2 != newleads->address2;
       .or. cAddr3 != newleads->address3 .or. cP_code != newleads->p_code
        newleads->killed := ' '
      endif
      newleads->phone_h  := cPhone_H
      newleads->phone_w  := CpHONE_w
      newleads->salespsn := CrEP
      dbunlock()
      select Student
      if student->group_cd != '     '
        nRecno = recno()
        cGroup = student->group_cd
        dbsetorder(4)
        dbgoto(nRecno)
        dbskip()
        while student->group_cd =  cGroup .and. !eof()
          reclock('Student')
          if cAddr1 != Student->address1 .or. cAddr2 != Student->address2;
           .or. cAddr3 != Student->address3 .or. cP_code != Student->p_code
            Student->addr_incor := ' '
          endif
          Student->address1 := cAddr1
          Student->address2 := cAddr2
          Student->address3 := cAddr3
          Student->p_code   := cP_code
          Student->phone_h  := cPhone_h
          Student->phone_w  := cPhone_w
          Student->start_dt := dStart
          Student->rep      := cRep
          Student->s_m      := cS_m
          Student->n_s_m    := cN_s_m
          if student->status = 'N'
            Student->cash := nInitl_val
          endif
          Student->Initl_val := nInitl_val
          dbunlock()
          dbskip()
        enddo
        dbsetorder(2)
        dbgoto(nRecno)
      endif
    endif
  endif
  setcolor(cOrig_col)
end sequence
select student
dbunlock()
et_close('Newleads')
et_close('Reps')
return
* eof
