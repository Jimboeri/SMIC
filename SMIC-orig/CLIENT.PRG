*******************************************************************************
* Client handling menu
* Author - Jim West
* 5/5/92
* ----     SET UP SYSTEM DEFAULTS

parameter param_1, param_2

LOCAL nChoice := 1, nNtx := 1
local nCnt, cParam, val_param, aMain_menu
memvar force_bw, force_prfile, nTime_out, getlist

#include "defcolor.ch"
#include "defprint.ch"

public force_bw := force_prfile := .f.

#include "colour.ch"
#include "smic.ch"
#include 'printer.ch'

for nCnt = 1 to 2
  cParam = 'param_' + ltrim(str(nCnt,2,0))
  val_param = &cParam
  if valtype(val_param) = 'C'
    do case
      case upper(val_param) = '/B'
        force_bw = .t.
      case upper(val_param) = '/P'
        force_prfile := .t.
    endcase
  endif
next

set date british
set deleted on

aMain_menu := {'CLIENT MENU'}
aadd(aMain_menu, 'New client menu')
aadd(aMain_menu, 'Accounts menu')
aadd(aMain_menu, 'Product control')

aadd(aMain_menu, 'Quit to DOS')

setcolor(yell_blue)
wopen(0, 0, 2, maxcol())
wbox(0)
@0,0 say center('Client handling system V2.0',,,.t.)
setcolor(cyan_blue)
wopen(3, 0, 24, 79)
dispbox(0, 0, maxrow(), maxcol(), "같같같같�")

while nNtx != len(aMain_menu)
  nNtx = get_arr(aMain_menu,,,,,'SMIC - Client Main menu',nNtx)
  nChoice = nNtx
  do case
    case nChoice = 1
      do cntmenu
    case nChoice = 2
      if upper(getenv('TEST')) = 'OMEGA3'
        clntmenu()
      endif
    case nChoice = 3
      if upper(getenv('TEST')) = 'OMEGA3'
        cl_ac_mn()
      endif
    case nChoice = 4
      prdmenu()
  endcase
enddo

setcolor(white_black)
clear
clear all
quit

*eof
