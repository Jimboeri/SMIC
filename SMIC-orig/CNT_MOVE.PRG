select 1
if !net_use('std_temp', .f.)
  return
endif

select 2
if !net_use('clients', .t.,,'cnt_code', 'cnt_name', 'cntarc')
  dbcloseall()
  return
endif

zap

nNext = 1

select 3
if !net_use('cl_prod', .t.,,'cl_prod', 'prod_cl')
  dbcloseall()
  return
endif

zap

select 4
if !net_use('student', .t.,,'stdcode')
  dbcloseall()
  return
endif

select std_temp
while !eof()
  if cc
    select student
    lFind_std = .f.
    if dbseek(std_temp->std_code)
      lFind_std = .t.
    endif
    select clients
    dbappend()
    clients->cnt_code := str(nNext,5,0)
    nNext++
    clients->title := std_temp->title
    clients->name := std_temp->name
    clients->surname := std_temp->surname
    clients->address1 := std_temp->addr1
    clients->address2 := std_temp->addr2
    clients->address3 := std_temp->addr3
    clients->p_code := std_temp->p_code
    clients->std_code := std_temp->std_code
    if lFind_std
      clients->phone_w  := student->phone_w
      clients->phone_h  := student->phone_h
      clients->birth_dt := student->birth_dt
      clients->archiv   := student->archiv
      clients->comment  := student->comment
    endif
    select cl_prod
    dbappend()
    cl_prod->cnt_code := clients->cnt_code
    cl_prod->prod_code := 'CB1'
    cl_prod->init_dt := ctod('01/05/92')
    cl_prod->renewal_dt := ctod('01/06/93')
    cl_prod->status := 'C'
  endif
  select std_temp
  dbskip()
enddo

dbcloseall()

if net_use('products', .t.,,'products')
  zap
  dbappend()
  products->product := 'CB1'
endif

dbcloseall()

return
