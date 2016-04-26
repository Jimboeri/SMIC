*******************************************************************************
*PROGRAM 'ACCMENU' - ACCOUNTS MENU
* Author - Jim West
* 1/2/88

local aCh := {'Display student accounts',;
    'Print forward banking',;
    'Print commission reports',;
    'Change student debit order details',;
    'Print cheques to be banked',;
    'Print bad debt to date',;
    'Print statements for students',;
    'Print VAT report',;
    'Print Debit order report',;
    'Return'}

local nCh := 1

while nCh != 0 .and. nCh != len(aCh)
  simhead(memvar->pScr_title)
  nCh = get_arr(aCh,,,,.t.,'SMIC - VIEW/PRINT ACCOUNTS', nCh)
  do case
    case nCh = 1
      accdisp() // compiled in enqmenu
    case nCh = 2
      do accrepbk
    case nCh = 3
      do acccomm
    case nCh = 4
      do accstd
    case nCh = 5
      do accbank
    case nCh = 6
      do accunpd
    case nCh = 7
      do accstat
    case nCh = 8
      do vatrpt
    case nCh = 9
      do debitacc
  endcase
enddo
return
* EOF
