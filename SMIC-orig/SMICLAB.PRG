***********************************************************
* SMICLAB

local aCh := {'Address stickers',;
 'MSF program stickers',;
  'MSF data stickers'}
local nCh, nCnt, nNo_lab
local cAddr1, cAddr2, cAddr3, cP_code, cSt_addr1, cSt_addr2, cSt_addr3
local cSt_p_code, cPhone
memvar getlist

if !net_use('param', .f.)
  return
endif

cAddr1 = param->p_addr1
cAddr2 = param->p_addr2
cAddr3 = param->p_addr3
cP_code = param->p_code
cSt_addr1 = param->st_addr1
cSt_addr2 = param->st_addr2
cSt_addr3 = param->st_addr3
cSt_p_code = param->st_p_code
cPhone = param->phone_no
et_close('param')

simhead(memvar->pscr_title)

nCnt = 1
nNo_lab = 0
@10,20 say 'PRINTING ADDRESS STICKERS'
@12,10 say 'Enter number of stickers to be printed' get nNo_lab picture '9999'
read
nCh = get_arr(aCh,,,,.t.)
nNo_lab = abs(nNo_lab)

if nCh = 0
  return
endif

@23,0 say ' '
set console off
set print on
?? chr(15)

for nCnt = 1 to nNo_lab
  do case
    case nCh = 1
      ? memvar->cco_name
      ? cAddr1
      ? trim(cAddr2) + ' ' + trim(cAddr3) + ' ' + cP_code
      ? 'Physical address'
      ? cSt_addr1
      ? trim(cSt_addr2) + ' ' + trim(cSt_addr3) + ' ' + cSt_p_code
      ? 'Tel ' + cPhone
      ? ' ' 
      ? ' '
    case nCh = 2
      ? memvar->cco_name
      ? ''
      ? '    MINI SHARE FRIEND'
      ? 'To install: place disk in "A" drive'
      ? 'and type "INSTALL C <enter>.'
      ? 'To run program type "MINI <enter>'
      ? ' '
      ? ' ' 
      ? ' '
    case nCh = 3
      ? memvar->cco_name
      ? ''
      ? '    MINI SHARE FRIEND'
      ? ''
      ? '       DATA DISK'
      ? ' '
      ? ' '
      ? ' ' 
      ? ' '
  endcase
  @15,30 say str(nCnt)
next
shutprn()
return
* eof()

