*******************************************************************************
*PROGRAM 'STDMENU' - STUDENT MENU
*                    CALLED FROM MENU
* Author - Jim West
* 1/2/88

local aCh := {'Add new student',;
    'Edit Student data',;
    'Expel a Student',;
    'Suspend a student',;
    'Suspend an UNPAID student',;
    'Reinstate a student',;
    'Update student comment',;
    'Return'}

local nCh := 1

while nCh != 0 .and. nCh != len(aCh)
  simhead(memvar->pScr_title)
  nCh = get_arr(aCh,,,,.t.,'SMIC - STUDENT MENU', nCh)
  do case
    case nCh = 1
      do stdadd
    case nCh = 2
      do stdedit
    case nCh = 3
      do stdexpL
    case nCh = 4
      do stdsusp
    case nCh = 5
      do stdunpd
    case nCh = 6
      do stdreins
    case nCh = 7
      do stdcomnt
  endcase
ENDDO
RETURN

*EOF
* EOF
