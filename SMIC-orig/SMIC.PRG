*******************************************************************************
* SIMPLE PROGRAM FOR REPS
* Author - Jim West
* 1/2/88
* ----     SET UP SYSTEM DEFAULTS

parameter param_1, param_2

LOCAL nChoice := 1, nNtx := 1
local cParam, val_param
local nCnt
local aDir                      // Array for deleteion of temp files
memvar aMain_menu

memvar force_prfile
memvar force_bw
memvar pScr_title

#include 'defcolor.ch'
#include 'defprint.ch'

public force_bw := force_prfile := .f.
private aMain_menu := {}

#include "colour.ch"
*#include "mouseini.ch"
#include "printer.ch"
#include "inkey.ch"

set date british
set deleted on

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

aDir = directory("$T*")
for nCnt = 1 to len(aDir)
  deletefile(aDir[nCnt, 1])
next

do upgrade

#include "smic.ch"

security(procname())

aadd(aMain_menu, 'Quit to DOS')

setkey(K_ALT_F6, {|| jw_pri_sw()} )

begin sequence
  while nNtx != len(aMain_menu)
    simhead(pscr_title)
    nNtx = get_arr(aMain_menu,6,,,,'SMIC - Main menu',nNtx)
    nChoice = smic_c_to_n(aMain_menu[nNtx])
    do case
      case nChoice = 1
        enqmenu()
      case nChoice = 3
        prntmenu()
      case nChoice = 4
        etadmin()
      case nChoice = 5
        accmenu()
      case nChoice = 6
        accsubmn()
      case nChoice = 7
        ldmenu()
      case nChoice = 8
        stdmenu()
      case nChoice = 9
        medmenu()
      case nChoice = 10
        advmenu()
      case nChoice = 11
        do notes
      case nChoice = 12
        twin()
      case nChoice = 13
        stdpmenu()
      case nChoice = 14
        crs1()
      case nChoice = 15
        crs3()
    endcase
  enddo
end sequence

clear screen
quit

*EOF
