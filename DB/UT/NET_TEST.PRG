*******************************************************************************
*
* Network
*

local aOpt := {'Display serial no', 'Return'}
local nOpt

nOpt = get_arr(aOpt)
do case 
  case nOpt = 1
    ser_disp()
endcase

return

*******************************************************************************
procedure ser_disp

local cSer_no, cSect

cSer_no = nnetserno()

cSect = disp_msg(10,,'Serial no = ' + cSer_no)
inkey(0)
restsector(cSect)

memowrit('serialno.net', cSer_no)

return
