*******************************************************************************
* PROGRAM 'SHRDIV' USED FOR ENTERING DIVIDENDS
* AUTHOR JIM WEST (E.T.)
* 1990

local cShare, nDividend, dDiv_dt, cDiv_type, lValid, cScr
memvar getlist

wopen(6,5,18,75)
setcolor(memvar->blue_cyan)
setcursor(1)
wbox(1)

begin sequence
  while !eof()
    select share
    findshr()
    cShare = share->share
    @0,0 say center(cShare + '  ' + trim(share->full_name))
    if found()
      reclock('Share')
      select shrdescr
      if !dbseek(cShare)
        dbappend()
        reclock('share comment')
        shrdescr->share := cShare
      endif
      if !empty(shrdescr->int_div_dt)
        @6,5 say 'Last interim dividend'
        @7,5 say 'L.D.R. ' + dtoc(shrdescr->int_div_dt)
        @8,5 say 'Dividend ' + str(shrdescr->int_div)
      endif
      if !empty(shrdescr->fin_div_dt)
        @6,30 say 'Last final dividend'
        @7,30 say 'L.D.R. ' + dtoc(shrdescr->fin_div_dt)
        @8,30 say 'Dividend ' + str(shrdescr->fin_div)
      endif
      reclock('Share comment')
      nDividend = shrdescr->dividend
      dDiv_dt = shrdescr->div_dt
      cDiv_type = shrdescr->div_type
      if Share->suspend = ' '
        @2,5 say 'Dividend:      ' get nDividend
        @3,5 say 'Dividend date: ' get dDiv_dt picture '@d';
         when !empty(nDividend) valid div_val_dt()
        @4,5 say 'Dividend type  ' get cDiv_type picture '!';
         when !empty(nDividend) valid div_val_type()
      endif
      *
      read
      shrdescr->dividend := nDividend
      shrdescr->div_dt   := dDiv_dt
      shrdescr->div_Type := cDiv_type
      dbunlock()
      select Share
      dbunlock()
    endif (record found)
  enddo (share != space)
end sequence
wclose()
return
* EOF

*******************************************************************************
static function div_val_dt()
local oGet, cBuffer
oGet = getactive()
cBuffer = oget:buffer
@maxrow(),0 clear
if ctod(cBuffer) < date()
  @maxrow(),0 say center('Dividend date connot be prior to today',,,.t.);
      color memvar->white_red
  return(.f.)
endif
return(.t.)

*******************************************************************************
static function div_val_type()
local oGet, cBuffer
oGet = getactive()
cBuffer = oget:buffer
@maxrow(),0 clear
if !(cBuffer $ 'IFS')
  @maxrow(),0 say center('Dividend type must be Interim, Final or Special',,,.t.);
      color memvar->white_red
  return(.f.)
endif
return(.t.)

* eof