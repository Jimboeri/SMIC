*******************************************************************************
* PROGRAM 'ACCREF' - CHANGES STD REFERRAL RATING
* AUTHOR JIM WEST (E.T.)
* 1/2/88

local cRef, cSplit, lValid
memvar getlist

select 2
if !net_use('student', .f.,, 'names')
  return
endif

simhead(memvar->pscr_title)
findstd()

if eof()
  close database
  return
endif

if !rlock()
  @23,10 say 'Student already in use - Please try later'
  inkey(10)
  close databases
  return
endif

*simhead(memvar->pscr_title)

@3,1 clear
@6,1 say 'Title: ' + Student->title
@6,15 say 'First name: ' + Student->name
@7,15 say 'Surname:    ' + Student->surname
@5,5 say 'Account no. ' + Student->std_code
@5,50 say 'Archive no ' + Student->archiv
if Student->deal_ref = 'R' .or. Student->deal_ref = 'T'
  cRef = 'Y'
else
  cRef = 'N'
endif
if Student->deal_ref = 'S' .or. Student->deal_ref = 'T'
  cSplit = 'Y'
else
  cSplit = 'N'
endif
@10,10 say 'Referal       ' get cRef picture '!'
@12,10 say 'Split deposit ' get cSplit picture '!'
read
lValid = .f.
while !lValid
  lValid = .t.
  if cRef != 'N' .and. cRef != 'Y'
    lValid = .f.
    @23,10 say 'Referal must be Y or N'
    @10,10 say 'Referal       ' get cRef picture '!'
    read
    @23,0 clear
  endif
  if cSplit != 'N' .and. cSplit != 'Y'
    lValid = .F.
    @23,10 say 'Split deposit must be Y or N'
    @12,10 say 'Split deposit ' get cSplit picture '!'
    read
    @23,0 clear
  endif
enddo
Student->deal_ref := ' '
if cRef = 'Y' .and. cSplit = 'Y'
  Student->deal_ref := 'T'
else
  if cRef = 'Y'
    Student->deal_ref := 'R'
  endif
  if cSplit = 'Y'
    Student->deal_ref := 'S'
  endif
endif
dbunlock()
close database
return
* eof
