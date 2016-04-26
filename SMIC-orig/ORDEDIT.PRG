*******************************************************************************
*
* ORDEDIT - EDITS EXISTING ORDERS FOR STUDENTS
*
*******************************************************************************

local cOrig_col, cEdit_scr, cShare

memvar getlist

while .t.
  
  select order
  cShare = et_seek('order', {2, 3, 4, 5, 7},,,student->std_code)
  
  if empty(cShare)
    exit
  endif
  cEdit_scr = savesector(10,10,18,70)
  setcolor(memvar->black_cyan + ',' + memvar->cyan_black)
  draw_box(10,10,18,70)
  select Share
  dbseek(order->share)
  select Order
  reclock()
  if order->trn_type = 'BUY'
    @11,15 say 'BUY ORDER OF ' +trim(order->share) + '   (Price ' +;
        ltrim(str(Share->price)) + ')'
  elseif order->trn_type = 'SEL'
    @11,15 say 'BUY ORDER OF ' + trim(order->share) + '   (Price ' +;
        ltrim(str(Share->price)) + ')'
  elseif order->trn_type = 'STP'
    @11,15 say 'STOP LOSS ORDER OF ' + trim(order->share) + '   (Price ';
        + ltrim(str(Share->price)) + ')'
  endif
  @15,20 say 'A price of 0.00 indicates an At Best order'
  @17,20 say '0 entered as No of shares will delete the order'
  @13,13 say 'No shares ' get order->qty
  @13,45 SAY 'Price ' get order->price
  read
  if updated()
    if order->qty = 0
      select order
      dbdelete()
    else
      if order->price = 0
        Order->at_best := 'Y'
      else
        Order->at_best := 'N'
      endif
      if order->trn_type = 'STP'
        Order->exp_dt := date() + 365
      else
        Order->exp_dt := date() + 7
      endif
    endif
  endif
  dbunlock()
  restscreen(cEdit_scr)
enddo
return

* eof

