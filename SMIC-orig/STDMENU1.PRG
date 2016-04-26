*******************************************************************************
* PROGRAM 'STDMENU1' - STUDENT MENU #1 - CALLED FROM MIA
* CALLED FROM MIA
* Author - Jim West
* 1/2/88

local nKey, cChoice

STORE ' ' TO cChoice
nKey = 200
DO WHILE nKey <> 27 .AND. nKey <> 0
  SIMHEAD(PSCR_TITLE)
  @ 3,15 
  TEXT
                STUDENT MENU

            Choose from the menu below :

            1 = Add new student
            2 = Edit Student data
            3 = Display student data
            4 = Suspend a student
            5 = Reinstate a student
            6 = Add members to group portfolio


          Esc = Return to Main Menu
  endtext
  @21,5 SAY 'Enter selection '
  nKey = inwait()
  cChoice = UPPER(CHR(nKey))
  DO CASE
    CASE cChoice = '1'
      DO STDADD
    CASE cChoice = '2'
      DO STDEDIT
    CASE cChoice = '3'
      DO STDLOOK
    CASE cChoice = '4'
      DO STDSUSP
    CASE cChoice = '5'
      DO STDREINS
    CASE cChoice = '6'
      DO STDGRADD
  ENDCASE
ENDDO
RETURN

*EOF
