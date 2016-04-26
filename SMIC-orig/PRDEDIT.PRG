*******************************************************************************
*
*  prdedit - edit of product details
local cPrd_cd, nWin
#include 'inkey.ch'

select product
dbsetorder(1)
dbgotop()

if eof()
  prdadd()
endif

cPrd_cd = ''

while .t.
  dbsetorder(1)
  nWin = wopen(20,0,23,15)
  wbox()
  @0,1 say 'Enter to edit'
  @1,1 say 'Ins to add'
  cPrd_cd = et_seek('product', {1, 2}, .t., {K_INS})
  wclose(nWin)
  do case
    case lastkey() = K_INS
      cPrd_cd = prdadd()
      prd_edit(product->product)
      cPrd_cd = product->product
      loop
      
    case empty(cPrd_cd)
      cPrd_cd = space(4)
      exit
      
    case lastkey() = K_ENTER
      prd_edit(product->product)
      cPrd_cd = product->product
      loop
      
    case lastkey() = K_ESC
      cPrd_cd = ''
      exit
      
  endcase
enddo
return

*******************************************************************************
procedure prd_edit(cIn_prd)
local nFirst, nAnnual, nMonthly, nCost, nPrice, cPay_type
memvar getlist, yell_blue

wopen(6,5,19,75)
wbox(0)
select product
@0,0 say center('Insert new product (Esc to quit)')
@1,1 say 'Product'
@1,10 say product->product + '  ' + product->descrip color yell_blue
@2,1 say 'Product type'
do case
  case product->prod_type = 'S'         // Service
    @2,15 say 'Service' color yell_blue
    nFirst =product->year_cost
    nAnnual = product->ren_cost
    nMonthly = product->mnth_cost
    cPay_type = product->pay_type
    @4,1 say 'First year cost       ' get nFirst
    @5,1 say 'Subsequent annual cost' get nAnnual
    @6,1 say 'Monthly cost          ' get nMonthly
    @7,1 say 'Payment period        ' get cPay_type picture '!';
        valid val_pay_type()
    read
    reclock()
    product->year_cost := nFirst
    product->ren_cost := nAnnual
    product->mnth_cost := nMonthly
    product->pay_type := cPay_type
    dbunlock()
    
  case product->prod_type = 'H'         // Hardware
    @2,15 say 'Hardware' color yell_blue
    nCost = product->hard_cost
    nPrice = product->sell_cost
    @4,1 say 'Cost to us' get nCost
    @5,1 say 'Recommended selling price' get nPrice
    read
    reclock()
    product->hard_cost := nCost
    product->sell_cost := nPrice
    dbunlock()
endcase

wclose()
dbcommit()
return

*******************************************************************************
procedure prdadd
local cPrd_code, cPrd_type, cDescr
memvar getlist
wopen(11,5,18,75)
wbox(0)
cPrd_code = space(3)
cDescr = space(30)
cPrd_type = ' '
@0,0 say center('Insert new product (Esc to quit)')
@1,2 say 'Product code' get cPrd_code picture '@!' valid val_prd_code()
@2,2 say 'Description ' get cDescr
@3,2 say 'Product type' get cPrd_type picture '@!' valid val_prd_type()
read
if empty(cPrd_code)
  wclose()
  return
endif
select product
dbappend()
reclock()
product->product := cPrd_code
product->descrip := cDescr
product->prod_type := cPrd_type
dbunlock()
dbcommit()
wclose()
return

*******************************************************************************
function val_prd_code
local oGet, cVal
oGet = getactive()
cVal = oget:buffer
@maxrow(),0 clear
select product
if dbseek(cVal)
  @maxrow(),0 say center('Product code already exists',,,.t.);
      color memvar->white_red
  return(.f.)
endif
return(.t.)

*******************************************************************************
function val_prd_type
local oGet, cVal
oGet = getactive()
cVal = oget:buffer
@maxrow(),0 clear
if !(cVal $  'HS')
  @maxrow(),0 say center('Product type must be "H"ardware or "S"ervice',,,.t.);
      color memvar->white_red
  return(.f.)
endif
return(.t.)

*******************************************************************************
function val_pay_type
local oGet, cVal
oGet = getactive()
cVal = oget:buffer
@maxrow(),0 clear
if !(cVal $  'MAE')
  @maxrow(),0 say center('Payment period must be "M"onthly, "A"nnual or "E"ither',,,.t.);
      color memvar->white_red
  return(.f.)
endif
return(.t.)

