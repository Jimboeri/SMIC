*******************************************************************************
* Program 'STDEXPL'
*
*******************************************************************************

local cPass, cStd_code, lExpel, nRecno, cGroup
memvar getlist, mPw_Pas

simhead(memvar->pscr_title)
cPass = '      '
@7,15 say 'PASSWORD ' get cPass picture '!!!!!!' color 'W/N,N/N'
read
@7,15 clear

begin sequence
  if cPass != mPw_Pas
    break
  endif
  select 3
  if !net_use('account', .f.,, 'acccode')
    break
  endif
  
  select 5
  if !net_use('transact', .f.,, 'trancode')
    break
  endif
  
  select 6
  if !net_use('portfol', .f.,, 'portfol')
    break
  endif
  
  select 2
  if !net_use('newleads', .f.,, 'archives')
    break
  endif
  
  select 1
  if !net_use('student', .f.,, 'stdcode', 'names', 'stdarc', 'stdgroup')
    break
  endif
  
  simhead(memvar->pscr_title)
  @3,1 say space(12) + 'Expulsion of a Student'
  cStd_code = SPACE(5)
  @5,1 say 'Student No: ' get cStd_code picture '!!!!!'
  @10,5 say 'Enter student number or hit enter to return to menu'
  read
  if empty(cStd_code)
    break
  endif
  if !dbseek(cStd_code)
    disp_msg(20,,'student not foumd')
    inkey(10)
    break
  endif
  if Student->group_no != '01'
    disp_msg(20,'STUDENT IS NOT THE GROUP LEADER')
    inkey(10)
    break
  endif
  if !rlock()
    disp_msg(20,,'Student already in use - Please try later')
    inkey(10)
    break
  endif
  select Newleads
  dbseek(Student->archiv)
  select Student
  @5,14 clear
  @6,1 clear
  @5,14 say cStd_code
  @9,8 say rtrim(Student->title) + '  ' + rtrim(Student->name) + '  ';
      + Student->surname
  @10,8 say Student->address1
  @11,8 say Student->address2
  @12,8 say Student->address3
  *
  lExpel = .T.
  if !empty(Student->group_cd)
    if !wmake_sure(20,,'EXPEL WHOLE GROUP ? ')
      lExpel = .F.
    endif
  endif
  
  if wmake_sure(17,20,'EXPEL STUDENT (Y/N) ? ') .and. lExpel
    nRecno = recno()
    
    select Newleads
    reclock('Lead')
    Newleads->killed := 'Y'
    Newleads->mem_comnt := 'This student was expelled'
    dbunlock()
    
    select Account
    dbseek(cStd_code)
    while Account->std_code = cStd_code .and. !eof()
      reclock('Account')
      dbdelete()
      dbunlock()
      dbskip()
    enddo
    
    select Transact
    dbseek(cStd_code)
    while Transact->std_code = cStd_code .and. !eof()
      reclock('Transaction')
      dbdelete()
      dbunlock()
      dbskip()
    enddo
    
    select Portfol
    dbseek(cStd_code)
    while Portfol->std_code = cStd_code .and. !eof()
      reclock('Portfolio')
      dbdelete()
      dbunlock()
      dbskip()
    enddo
    
    select Student
    if !empty(Student->group_cd)
      dbsetorder(4)
      dbgoto(nRecno)
      cGroup = Student->group_cd
      dbskip()
      while cGroup = Student->group_cd .and. !eof()
        select Student
        cStd_code = Student->std_code
        
        select Account
        dbseek(cStd_code)
        while Account->std_code = cStd_code .and. !eof()
          reclock('Account')
          dbdelete()
          dbunlock()
          dbskip()
        enddo
        
        select Transact
        dbseek(cStd_code)
        while Transact->std_code = cStd_code .and. !eof()
          reclock('Transaction')
          dbdelete()
          dbunlock()
          dbskip()
        enddo
        
        select Portfol
        dbseek(cStd_code)
        while portfol->std_code = cStd_code .and. !eof()
          reclock('Portfolio')
          dbdelete()
          dbunlock()
          dbskip()
        enddo
        
        select Student
        reclock('student')
        dbdelete()
        dbunlock()
        dbskip()
      enddo
    endif
    goto nRecno
    reclock('Student')
    dbdelete()
    disp_msg(20,,'STUDENT IS NOW CLASSIFIED AS EXPELLED',;
        'AND ALL ASSOCIATED RECORDS DELETED')
    inkey(10)
  endif
  select Newleads
  dbunlock()
  select Student
  dbunlock()
end sequence
dbcloseall()
return
* eof
