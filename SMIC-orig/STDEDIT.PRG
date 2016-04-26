*******************************************************************************
* PROGRAM 'STDEDIT'
* AUTHOR JIM WEST (E.T.)
* 1/2/88

local cTitle, cP_code, cName, cAddr1, cAddr2, cAddr3, nRecno
local cPhone_w, cPhone_h, nInitl_val, nSIm_len, cSeek
local dSold_crs1, dSold_crs2, dSold_ss, dSold_lec, cE_mail
local cGroup, cRep, cS_M, cN_S_M, dBirth, cSurname, dStart
memvar getlist

begin sequence

  select 2
  if !net_use('student', .f.,, 'names', 'stdcode', 'stdgroup')
    break
  endif
  
  simhead(memvar->pscr_title)
  
  findstd()
  
  if eof()
    break
  endif
  
  if !rlock()
    @23,10 SAY 'Student already in use - Please try later'
    inkey(10)
    break
  endif
  
  Select 3
  if !net_use('reps', .f.,, 'reps')
    break
  endif
  
  select 1
  if !net_use('newleads', .f.,, 'archives', 'rleads')
    break
  endif
  dbseek(Student->archiv)
  
  simhead(memvar->pscr_title)
  
  @3,1 say space(12) + 'Student edit screen'
  select student
  @4,1 clear
  @4,50 say 'Group ' + Student->group_cd + ' ' + Student->group_no
  @5,5 say 'Account no. ' + Student->std_code
  @5,50 say 'Archive no ' + Student->archiv
  cTitle      := Student->title
  cP_code     := Student->p_code
  cName       := Student->name
  cAddr1      := Student->address1
  cAddr2      := Student->address2
  cAddr3      := Student->address3
  cSurname    := Student->surname
  cPhone_H    := Student->phone_h
  cPhone_W    := Student->phone_w
  dStart      := Student->start_dt
  nInitl_val  := Student->initl_val
  cRep        := Student->rep
  cS_M        := Student->S_M
  cN_S_M      := Student->N_S_M
  nSim_len    := Student->simln_len
  dBirth      := Student->birth_dt
  dSold_crs1  := Student->sold_crs_1
  dSold_crs2  := Student->sold_crs_2
  dSold_ss    := Student->sold_ss
  dSold_lec   := Student->sold_lectr
  cE_mail     := student->E_mail
  
  @6,1 say 'Title: ' get cTitle picture '@!'
  @6,15 say 'First name: ' get cName picture '@!' valid std_v01()
  @7,15 say 'Surname:    ' get cSurname picture '@!' valid std_v02()
  @8,63 say 'Status'
  
  if Student->group_no != '01'
    nRecno = recno()
    cSeek = Student->group_cd + '01'
    dbsetorder(3)               // stdgroup
    dbseek(cSeek)
    @13,30 say 'The group leader for this group is:'
    @14,30 say trim(Student->title) + ' ' + trim(Student->name) + ' ' +;
        Student->surname
    dbsetorder(1)
    dbgoto(nRecno)
  endif
  
  do case
    case Student->status = 'C'
      @8,70 say 'Current'
    case Student->status = 'N'
      @8,70 say 'New stud'
    case Student->status = 'S'
      @8,70 say 'Suspended'
    case Student->status = 'F'
      @8,70 say 'Finished'
    case Student->status = 'U'
      @8,70 say 'Unpaid'
    otherwise
      @8,70 say 'INVALID'
  endcase
  @9,1 say 'Postal address'
  @10,1 get cAddr1 picture  '@!' when Student->group_no = '01'
  @11,1 get cAddr2 picture '@!' when Student->group_no = '01'
  @12,1 get cAddr3 picture '@!' when Student->group_no = '01'
  @13,1 say 'Postal Code:    ' get cP_code Picture '@!';
      when Student->group_no = '01'
  @10,30 say 'Sold Module 1 ' get dSold_crs1 when Student->group_no = '01'
  @11,30 say 'Sold Module 2 ' get dSold_crs2 when Student->group_no = '01'
  @10,55 say 'Sold lectures  ' get dSold_lec when Student->group_no = '01'
  @11,55 say 'Sold Mini Disc ' get dSold_ss when Student->group_no = '01'
  @14,30 say 'E Mail addr:' get cE_mail
  @15,1 SAY 'Phone-Home: ' get cPhone_h picture '@!';
      when Student->group_no = '01'
  @15,30 SAY 'Phone-Work: ' get cPhone_w picture '@!';
      when Student->group_no = '01'
  @17,1 say 'Rep ' get cRep picture '@!' when Student->group_no = '01';
      valid std_v03('R')
  @17,25 say 'Sales manager' get cS_M picture '@!';
      when Student->group_no = '01' valid std_v03('S')
  @17,50 say 'Nat sales manager' get cN_S_M picture '@!';
      when Student->group_no = '01' valid std_v03('N')
  @18,1 say 'Length of Simulation ' get nSim_len picture '999';
      when Student->group_no = '01' .and. Student->status = 'N'
  @19,1 say 'Start Date:      ' get dStart picture '@d';
      when Student->group_no = '01' .and. Student->status = 'N' valid std_v04()
  @19,40 SAY 'Date of birth ' get dBirth picture '@d' valid std_v06()
  @20,40 say 'Initial value    ' get nInitl_val;
      when Student->group_no = '01' .and. Student->status = 'N' valid std_v05()
  @20,1 SAY 'Weeks on simultn       ' + str(Student->wk_smltn,3,0)
  @21,1 SAY 'Unactive weeks         ' + str(Student->wk_unact,3,0)
  @21,40 SAY 'Last Transaction       ' + dtoc(Student->last_tran)
  *
  read
  reclock('Student')
  Student->title      := cTitle
  Student->name       := cName
  Student->surname    := cSurname
  Student->address1   := cAddr1
  Student->address2   := cAddr2
  Student->address3   := cAddr3
  Student->p_code     := cP_code
  if cAddr1 != Student->address1 .or. cAddr2 != Student->address2 .or.;
        cAddr3 != Student->address3 .or. cP_code != Student->p_code
    Student->addr_incor := ' '
  endif
  Student->Phone_H    := cPhone_h
  Student->phone_w    := cPhone_W
  Student->start_dt   := dStart
  Student->rep        := cRep
  Student->s_m        := cS_M
  Student->n_s_m      := cN_S_M
  Student->simln_len  := nSim_len
  if Student->status = 'N'
    Student->cash     := nInitl_val
  endif
  Student->initl_val  := nInitl_val
  Student->birth_dt   := dBirth
  Student->sold_crs_1 := dSold_crs1
  Student->sold_crs_2 := dSold_crs2
  Student->sold_ss    := dSold_ss
  Student->sold_lectr := dSold_lec
  Student->e_mail     := lower(cE_mail)
  dbunlock()
  dbcommit()
  IF Student->group_no = '01'
    select Newleads
    if found()
      reclock('Newleads')
      Newleads->salespsn := cRep
      Newleads->title    := cTitle
      Newleads->initls   := substr(cName,1,1)
      Newleads->surname  := cSurname
      Newleads->address1 := cAddr1
      Newleads->address2 := cAddr2
      Newleads->address3 := cAddr3
      Newleads->p_code   := cP_code
      IF cAddr1 != Newleads->address1 .or. cAddr2 != Newleads->address2 .or.;
            cAddr3 != Newleads->address3 .or. cP_code != Newleads->p_code
        Newleads->killed := ' '
      endif
      Newleads->phone_h := cPhone_H
      Newleads->phone_w := cPhone_W
      dbunlock()
      dbcommit()
      
      select Student
      if !empty(Student->group_cd)
        nRecno = recno()
        cGroup = Student->group_cd
        dbsetorder(3)           // stdgroup
        dbgoto(nRecno)
        dbskip()
        while Student->group_cd = cGroup .and. !eof()
          reclock('Student')
          Student->address1 := CaDDR1
          Student->address2 := CaDDR2
          Student->address3 := CaDDR3
          Student->p_code   := Cp_CODE
          if cAddr1 != Student->address1 .or. cAddr2 != Student->address2 .or.;
                cAddr3 != Student->address3 .or. cP_code != Student->p_code
            Student->addr_incor := ' '
          endif
          Student->phone_h   := cPhone_H
          Student->phone_w   := cPhone_W
          Student->start_dt  := dStart
          Student->rep       := cRep
          Student->s_m       := cS_M
          Student->n_s_m     := cN_S_M
          Student->simln_len := nSim_len
          if Student->status = 'N'
            Student->cash := nInitl_val
          endif
          Student->initl_val  := nInitl_val
          Student->sold_crs_1 := dSold_crs1
          Student->sold_crs_2 := dSold_crs2
          Student->sold_ss    := dSold_ss
          Student->sold_lectr := dSold_lec
          dbunlock()
          dbskip()
        enddo
        dbsetorder(1)           // names
        dbgoto(nRecno)
      endif
    endif
  endif
end sequence
dbcloseall()
return
* eof
