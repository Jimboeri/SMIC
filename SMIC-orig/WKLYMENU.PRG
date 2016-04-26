*******************************************************************************
* PROGRAM 'WKLYMENU' - WEEKLY MENU
* Author - Jim West
* 1/2/88
STORE ' ' TO CHOICE
INKEY = 200
DO WHILE INKEY <> 27 .AND. INKEY <> 0
  DO SIMHEAD WITH PSCR_TITLE
  @ 3,15 
  TEXT
                    WEEKLY MENU

            Choose from the menu below :

            1 = Print Student Portfolios

            4 = Print future portfolios


          Esc = Return to Main Menu
  endtext
  @21,5 SAY 'Enter selection '
  INKEY = INKEY(300)
  CHOICE = UPPER(CHR(INKEY))
  DO CASE
    CASE CHOICE = '1'
      DO PORTPRNT
      INKEY = 0
    CASE CHOICE = '4'
      DO FUTPRNT
      INKEY = 0
  ENDCASE
ENDDO
RETURN
* EOF