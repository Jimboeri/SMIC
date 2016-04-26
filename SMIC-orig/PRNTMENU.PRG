*******************************************************************************
*PROGRAM 'PRNTMENU' - PRINT MENU
* Author - Jim West
* 23/9/87

local nCh := 1
local aCh := {'Leads by agent code', 'Sales ratios', 'Follow up leads by agent',;
    'Follow up SALES by Agent', 'Leads for agent (label format)', 'Rep statistics',;
    'Print leads by area (label format)', 'Return'}
local dDt1, dDt2

while nCh != 0 .and. nCh != len(aCh)
  simhead(memvar->pscr_title)
  nCh = get_arr(aCh,,,,.t.,'SMIC - SALES REPORT MENU', nCh)
  do case
    case nCh = 1
      dDt1 = ctod('  /  /  ')
      dDt2 = ctod('  /  /  ')
      do rleads with dDt1, dDt2
      ! copy rleads.txt lpt1:
      ! del rleads.txt
    case nCh = 2
      do repratio
    case nCh = 3
      do pfolldt
    case nCh = 4
      do rsales
    case nCh = 5
      do ldlab
    case nCh = 6
      do repstat
    case nCh = 7
      do ldprlab
  endcase
ENDDO
RETURN
* EOF

/* programs LDARCLB, STDNAMLB & LDAREALB not included at this time */
