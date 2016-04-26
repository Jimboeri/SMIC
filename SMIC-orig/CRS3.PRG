*******************************************************************************
* PROGRAM 'CRS3' - THIRD COURSE MANAGER MENU STUDENTS
* Author - Jim West
* 1/2/88

local aCh := {'1 = Print top 10 students',;
    '2 = Add/Subtract money from students cash',;
    '3 = Give extra time on TWIN',;
    '4 = Reset students portfolio (start afresh)',;
    '5 = Counts of students by status',;
    '6 = Start new students',;
    'Return'}
local nCh := 1

while nCh != 0 .and. nCh != len(aCh)
  simhead(memvar->pscr_title)
  nCh = get_arr(aCh,,,,.t.,'SMIC - STUDENT : TWIN',nCh)
  do case
    case nCh = 1
      do stdclass
    case nCh = 2
      do stdcash
    case nCh = 3
      do stdweek
    case nCh = 4
      do stdreset
    case nCh = 5
      do stdcount
    case nCh = 6
      do stdstart
  endcase
enddo
return

*eof
