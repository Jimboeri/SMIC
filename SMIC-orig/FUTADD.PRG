*******************************************************************************
* PROGRAM 'FUTADD'
* AUTHOR JIM WEST (E.T.)
* 1/10/87

local aDnl_name := {}
local nMax, nCnt, cFut_optn, dExpiry
local cVal_perc, cFull_name, nCalc_type, nMargin
memvar getlist

#include 'inkey.ch'

simhead(memvar->pscr_title)

@10,25 say 'WORKING OUT AVAILABLE FUTURES'

begin sequence
  
  select 1
  if !net_use('share', .f.,, 'shrname')
    break
  endif
  
  nMax = 0
  while !eof()
    if Share->sec_cd = ' 00'
      if Share->share = 'ALSI' .or. Share->share = 'DGLD' .or.;
            Share->share = 'E168' .or. Share->share = 'GLDI';
            .or. Share->share = 'INDI' .or. Share->share = 'LBA3'
        nMax++
        aadd(aDnl_name, Share->share)
      endif
    endif
    dbskip()
  enddo
  dbcloseall()
  
  select 2
  if !net_use('futoptn', .f.,, 'futoptn')
    break
  endif
  
  while !eof() .and. nMax != 0
    for nCnt = 1 to nMax
      if aDnl_name[nCnt] = futoptn->dnl_name
        aremove(aDnl_name, nCnt)
        nMax--
      endif
    next
    dbskip()
  enddo
  
  if nMax = 0
    @10,20 say 'NO NEW FUTURE FOUND ON INPUT FILE'
    @20,0
    wait
    break
  endif
  
  @5,0 clear
  nCnt = get_arr(aDnl_name,5,10,,,'Choose download file name')
  if nCnt != 0
    @3,0 clear
    @3,1 say center('Initial data capture of a new Future/Option')
    cFut_optn = space(15)
    dExpiry := ctod('  /  /  ')
    @5,30 say 'Download name = ' + aDnl_name[nCnt]
    @7,1 say 'Future / Option : ' get cFut_optn picture '@!' valid val_fut_nm()
    @7,40 say 'Expiry Date:  ' get dExpiry picture '@d' when !empty(cFut_optn);
        valid val_fut_dt()
    @10,5 say 'Enter Future and expiry date or hit enter to return to menu'
    read
    @8,0 clear
    if empty(cFut_optn)
      break
    endif
    @6,1 clear
    @5,20 say cFut_optn
    @5,55 say dExpiry
    cVal_perc := ' '
    cFull_name := space(50)
    nMargin := nCalc_type := 0
    @8,1 say 'Full name : ' get cFull_name picture '@!';
        valid !empty(cFull_name)
    @10,1 say 'Margin : ' get nMargin picture '99999999.9999';
        valid val_margin()
    @12,1 say 'Is the margin a Value or a Percentage (V/P) : ' get cVal_perc;
        picture '!' valid val_perc_val()
    @14,1 say 'Enter calculation type' get nCalc_type picture '99';
        valid val_calc_type()
    *
    read
    nMargin = abs(nMargin)
    select Futoptn
    dbappend()
    reclock('Futures')
    Futoptn->fut_optn   := cFut_optn
    Futoptn->exp_date   := dExpiry
    Futoptn->dnl_name   := aDnl_name[nCnt]
    Futoptn->full_name  := cFull_name
    Futoptn->f_or_o     := 'F'
    Futoptn->val_or_per := cVal_perc
    Futoptn->margin     := nMargin
    Futoptn->bid        := 0
    Futoptn->offer      := 0
    Futoptn->calc_type  := nCalc_type
    dbunlock()
  endif (nCnt != 0)
end sequence
dbcloseall()
return

*******************************************************************************
function val_fut_nm
local oGet
oGet := getactive()
@maxrow(),0 clear
if empty(oGet:buffer)
  return(.t.)
endif
if dbseek(oGet:buffer)
  @maxrow(),0 say center('Future/option alteady exists',,,.t.);
      color memvar->white_red
  return(.f.)
endif
return(.t.)

*******************************************************************************
function val_fut_dt
local oGet, dVal
oGet := getactive()
@maxrow(),0 clear
if lastkey() = K_UP
  return(.t.)
endif
dVal = ctod(oGet:buffer)
if empty(dVal)
  @maxrow(),0 say center('Expiry date must be entered',,,.t.);
      color memvar->white_red
  return(.f.)
endif
if dVal <= date()
  @maxrow(),0 say center('Expiry date cannot be earlier than today',,,.t.);
      color memvar->white_red
  return(.f.)
endif
return(.t.)

* eof

*******************************************************************************
function val_perc_val
local oGet
oGet := getactive()
@maxrow(),0 clear
if !(oGet:buffer $ 'VP')
  @maxrow(),0 say center('Must be V or P',,,.t.);
      color memvar->white_red
  return(.f.)
endif
return(.t.)

*******************************************************************************
function val_margin
local oGet, nVal
oGet := getactive()
nVal = val(oGet:buffer)
@maxrow(),0 clear
if nVal = 0
  @maxrow(),0 say center('Margin cannot be 0',,,.t.);
      color memvar->white_red
  return(.f.)
endif
return(.t.)

*******************************************************************************
function val_calc_type
local oGet, nVal
oGet := getactive()
nVal = val(oGet:buffer)
@maxrow(),0 clear
if nVal < 1 .or. nVal > 4
  @maxrow(),0 say center('Calculation type out of range - must be between 1 and 4',,,.t.);
      color memvar->white_red
  return(.f.)
endif
return(.t.)

