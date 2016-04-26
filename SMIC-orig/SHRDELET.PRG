*******************************************************************************
* Program 'SHRDELET'
* JIM WEST

local lDelete, nKey

#include 'inkey.ch'

select 1
if !net_use('portfol')
  return
endif

select 3
if !net_use('shrdescr', .f.,, 'shrdescr')
  close databases
  return
endif

select 4
if !net_use('student', .f.,, 'stdcode')
  close databases
  return
endif

select 2
if !net_use('share', .f.,, 'shrname')
  close databases
  return
endif

simhead(memvar->pscr_title)
findshr()
if !eof()
  if !rlock()
    @23,10 say 'Share already in use - Please try later'
    inkey(10)
  else
    @5,0 clear
    @5,8 say 'Share ' + Share->share
    @6,8 say 'Full name ' + rtrim(Share->full_name)
    *
    lDelete = .t.
    select Portfol
    dbgotop()
    setcolor('W*+/N')
    @8,10 say 'SEARCHING'
    setcolor('W/N')
    @8,20 say 'for students that still hold this share'
    while !eof()
      if Share->share = Portfol->share
        select Student
        dbseek(Portfol->std_code)
        if Student->status != 'F'
          if lDelete = .t.
            @10,8 say 'STUDENTS THAT STILL HOLD THIS SHARE'
            ? ' '
            lDelete = .F.
          endif
          ? '   ' + trim(Student->title) + ' ' + trim(Student->name);
              + ' ' + trim(Student->surname)
        endif
      endif
      select Portfol
      dbskip()
      nKey = inkey()
      if nKey = K_ESC .and. wmake_sure(12,,;
            'Stop displaying students (Y/N) ?')
        exit
      endif
    enddo
    
    ?? chr(7)
    if lDelete = .F.
      wait
    else
      @8,10 say 'NO students currently hold this share' + SPACE(40)
      select Share
      if wmake_sure(17,,'Delete this share ? (Y/N)')
        dbdelete()
        select Shrdescr
        if dbseek(Share->share)
          reclock('Share comment')
          dbdelete()
          dbunlock()
        endif
        @20,1 say 'RECORD IS NOW MARKED FOR DELETION'
        inkey(10)
      endif
    endif
    dbunlock()
  endif
endif
dbcloseall()
return
* eof
