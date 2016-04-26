*******************************************************************************
* 'CNTEDIT' - CLIENT EDIT PROGRAM
* JIM WEST
* 25/09/89

local aCh := {'Edit Payment', 'Edit comment', 'Edit address'}
local nCh, cCnt_cd
memvar mComment
memvar cPaid, dPaid_dt, cRefund, cBounce, cBank_code, cBnk_acc, cMember
memvar cTitle, cName, cSurname, cAddr1, cAddr2, cAddr3, cP_code
memvar cPhone_w, cPhone_h, dBirth

private cPaid, dPaid_dt, cRefund, cBounce, cBank_code, cBnk_acc, cMember
private cTitle, cName, cSurname, cAddr1, cAddr2, cAddr3, cP_code
private cPhone_w, cPhone_h, dBirth

nCh := 1

if .f.
  do findcnt
endif

wopen(3,0,24,79)
wbox(1)

cCnt_cd = findcnt()

while !empty(cCnt_cd)
  cTitle := clients->title
  cName := clients->name
  cSurname := clients->surname
  cAddr1 := clients->address1
  cAddr2 := clients->address2
  cAddr3 := clients->address3
  cP_code := clients->p_code
  cPhone_W := clients->phone_w
  cPhone_H := clients->phone_h
  dBirth := clients->birth_dt
  cPaid := if(clients->paid = 'Y', 'Y', 'N')
  dPaid_dt := clients->paid_dt
  cRefund := if(clients->refund = 'Y', 'Y', 'N')
  cBounce := if(clients->bounce = 'Y', 'Y', 'N')
  mComment = clients->comment
  cBnk_acc := clients->bnk_acc_no
  cbank_code := substr(clients->bank_code,1,5)
  select cl_prod
  cMember = 'N'
  if dbseek(clients->cnt_code + 'CB1') .and. cl_prod->status = 'C'
    cMember = 'Y'
  endif
  while nCh != 0 .and. nCh != len(aCh)
    select clients
    @1,1 say 'Title  ' + cTitle
    @1,20 say 'First name  ' + cName
    @2,20 say 'Surname     ' + cSurname
    @3,10 say 'Postal address'
    @4,10 say cAddr1
    @5,10 say cAddr2
    @6,10 say cAddr3
    @7,10 say 'Postal Code:     ' + cP_code
    @8,10 say 'Phone-Home:  ' + cPhone_H
    @9,10 say 'Phone-Work:  ' + cPhone_W
    @10,10 say 'Birth date:  ' + dtoc(dBirth)
    @4,40 say 'Paid  ' + cPaid
    @4,55 say 'Paid date  ' + dtoc(dPaid_dt)
    @5,40 say 'Refund   ' + cRefund
    @6,40 say 'Bounced  ' + cBounce
    @7,40 say 'Expiry date  ' + cBank_code
    @8,40 say 'Card no      ' + cBnk_acc
    @10,40 say 'Club member :  ' + cMember
    @11,1 to maxrow(),maxcol()
    memoedit(mComment,12,2,maxrow()-1,maxcol()-1, .f., .f.)
    nCh = get_arr(aCh, 3, 60,,.t.,,nCh)
    do case
      case nCh = 1
        cntedit2()
      case nCh = 2
        cntedit3()
      case nCh = 3
        cntedit1()
    endcase
    reclock()
    clients->title := cTitle
    clients->name := cName
    clients->surname := cSurname
    clients->address1 := cAddr1
    clients->address2 := cAddr2
    clients->address3 := cAddr3
    clients->p_code := cP_code
    clients->phone_h := cPhone_h
    clients->phone_w := cPhone_w
    clients->birth_dt := dBirth
    clients->paid := cPaid
    clients->paid_dt := dPaid_dt
    clients->refund := crefund
    clients->bounce := cbounce
    clients->bank_code := cBank_code
    clients->bnk_acc_no := cbnk_acc
    clients->comment := mComment
    dbunlock()
    select cl_prod
    if !dbseek(clients->cnt_code + 'CB1')
      dbappend()
      reclock()
      cl_prod->cnt_code = clients->cnt_code
      cl_prod->prod_code = 'CB1'
      dbunlock()
    endif
    reclock()
    if cMember = 'Y'
      cl_prod->status := 'C'
    else
      cl_prod->status := 'F'
    endif
    dbunlock()
  enddo
  cCnt_cd = findcnt()
  nCh = 1
enddo
wclose()
return

*eof

*******************************************************************************
procedure cntedit1

memvar cTitle, cName, cSurname, cAddr1, cAddr2, cAddr3, cP_code
memvar cPhone_w, cPhone_h, dBirth
memvar getlist

@1,1 say 'Title ' get cTitle picture '!!!!'
@1,20 say 'First name ' get cName picture '!!!!!!!!!!!!!!!!!!!!'
@2,20 say 'Surname    ' get cSurname picture '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
@3,10 say 'Postal address'
@4,10 get cAddr1 picture '!!!!!!!!!!!!!!!!!!!!!!!!!'
@5,10 get cAddr2 picture '!!!!!!!!!!!!!!!!!!!!!!!!!'
@6,10 get cAddr3 picture '!!!!!!!!!!!!!!!!!!!!!!!!!'
@7,10 say 'Postal Code:    ' get cP_code picture '!!!!'
@8,10 say 'Phone-Home: ' get cPhone_H picture '!!!!!!!!!!!!!!!'
@9,10 say 'Phone-Work: ' get cPhone_W picture '!!!!!!!!!!!!!!!'
@10,10 say 'Birth date: ' get dBirth picture '@d'
read
return

*******************************************************************************
procedure cntedit2

memvar getlist
memvar cPaid, dPaid_dt, cRefund, cBounce, cBank_code, cBnk_acc, cMember

@4,40 say 'Paid ' get cPaid picture '!' valid jw_val_yn()
@4,55 say 'Paid date ' get dPaid_dt
@5,40 say 'Refund  ' get cRefund picture '!' valid jw_val_yn()
@6,40 say 'Bounced ' get cBounce picture '!' valid jw_val_yn()
@7,40 say 'Expiry date ' get cBank_code picture '99/99'
@8,40 say 'Card no     ' get cBnk_acc picture '9999/9999/9999/9999'
@10,40 SAY 'Club member : ' GET cMember picture '!' valid jw_val_yn()
read
return

*******************************************************************************
procedure cntedit3
memvar mComment
@11,1 to maxrow(),maxcol()
mComment = memoedit(mComment,12,2,maxrow()-1,maxcol()-1, .t.)
return
