*******************************************************************************
*PROGRAM 'ACCSUBMN' - ACCOUNTS SUB-MENU (PASSWORD PROTECTED)
* Author - Jim West
* 1/2/88

local cSect, cPass, cOrig_col
local aCh := {'Change student payment schedule',;
    'Update accounts with cheques banked',;
    'Print deposit report',;
    'Change student payments to Debit orders',;
    'Create debit order diskette',;
    'Print Debit Orders to be processed',;
    'Change Referal/Split deposit',;
    'Return'}

local nCh := 1, getlist := {}

simhead(memvar->pScr_title)
cSect := draw_box(10,10,20,70)
@15,15 SAY 'The programs on this menu are password protected'
@17,25 SAY 'Please enter your password'
cPass = '      '
cOrig_col = setcolor('w/n,n/n')
@12,20 say 'PASSWORD ' get cPass picture '@!'
read

setcolor(cOrig_col)

if cPass != memvar->mpw_pas
  return
endif

while nCh != 0 .and. nCh != len(aCh)
  simhead(memvar->pScr_title)
  nCh = get_arr(aCh,,,,.t.,'SMIC - CHANGE ACCOUNTS', nCh)
  do case
    case nCh = 1
      do accchang
    case nCh = 2
      do accupbnk
    case nCh = 3
      do accdepos
    case nCh = 4
      do acctodeb
    case nCh = 5
      do accdebit
    case nCh = 6
      do accdebpr
    case nCh = 7
      do accref
  endcase
enddo
return
* eof
