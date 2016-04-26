*******************************************************************************
* PROGRAM 'CNTADD'
* AUTHOR JIM WEST (E.T.)
* 1/2/88

local aInput_type := {'Student file',;
    'Leads file',;
    'New entry',;
    'Quit'}

local aPay_type := {'Monthly',;
    'Annual'}

local nOpt

local cArchiv, cName, cSurname, cP_code, cTitle, cAddr1, cAddr2, cAddr3
local cPhone_h, cPhone_w, cStd_code, cCnt_code, cBnk_cd, cBnk_acc, cBnk_type
local dBirth_dt, nLst_cd, mComment, cE_Mail, cPrd_cd, cPay_type, cRep
local cS_M, cN_S_M, nPayment
memvar getlist, white_red

#include "inkey.ch"

wopen(3,1,23,78)
wbox()
@0,0 say center('ADD A NEW CLIENT',,,.t.) color memvar->yell_blue

begin sequence
  if empty(et_use_dbf('newleads'))
    break
  endif
  
  if empty(et_use_dbf('student'))
    break
  endif
  dbsetorder(2)
  *
  
  nOpt = get_arr(aInput_type,8,,,.t.)
  if nOpt = 0 .or. nOpt = len(aInput_type)
    break
  endif
  cArchiv = space(7)
  cSurname := cName := space(30)
  cTitle := cP_code := space(4)
  cAddr1 := cAddr2 := cAddr3:= space(25)
  cPhone_w := cPhone_h := space(15)
  cCnt_code := cStd_code := space(5)
  cBnk_cd := space(6)
  cBnk_acc := space(19)
  cBnk_type = ' '
  dBirth_dt := ctod('  /  /  ')
  cE_mail = space(30)
  
  do case
    case nOpt = 1
      cStd_code = seekstd()
      if empty(cStd_code)
        break
      endif
      cTitle    := student->Title
      cName     := student->Name
      cSurname  := student->Surname
      cAddr1    := student->Address1
      cAddr2    := student->Address2
      cAddr3    := student->Address3
      cP_code   := student->P_code
      cPhone_h  := student->Phone_h
      cPhone_w  := student->Phone_w
      cbnk_cd   := student->bank_code
      cbnk_acc  := student->bnk_acc_no
      cBnk_type := student->acc_type
      dBirth_dt := student->birth_dt
      cArchiv   := student->archiv
      cE_mail   := student->e_mail
    case nOpt = 2
      @5,5 say 'Enter Archive no of lead ' get cArchiv picture '!!!!!!!'
      read
      if empty(cArchiv)
        break
      endif
      
      select newleads
      if !dbseek(cArchiv)
        disp_msg(18, white_red, 'LEAD NOT FOUND ON LEAD FILE - PLEASE RE-ENTER')
        inkey(10)
        break
      endif
      reclock()
      select clients
      if dbseek(cArchiv)
        disp_msg(18, white_red,;
            'CLIENT ALREADY ATTACHED TO THIS LEAD - CHECK ARCHIVE NO')
        inkey(10)
        break
      endif
      select newleads
      @2,31 say cArchiv
      @2,60 say Newleads->title + ' ' + Newleads->initls
      @3,60 say Newleads->surname
      if !Make_sure(12,15,'Are you sure this is the correct person ?')
        break
      endif
      cTitle    := newleads->Title
      cName     := newleads->Initls
      cSurname  := newleads->Surname
      cAddr1    := newleads->Address1
      cAddr2    := newleads->Address2
      cAddr3    := newleads->Address3
      cP_code   := newleads->P_code
      cPhone_h  := newleads->Phone_h
      cPhone_w  := newleads->Phone_w
  endcase
  
  @2,10 say 'Title   ' get cTitle picture '@!'
  @3,10 say 'Name    ' get cName picture '@!' valid !empty(cName)
  @4,10 say 'Surname ' get cSurname picture '@!' valid !empty(cSurname)
  
  @6,10 SAY 'Postal address'
  @7,10 GET cAddr1 picture '@!'
  @8,10 GET cAddr2 picture '@!'
  @9,10 GET cAddr3 picture '@!'
  @10,10 SAY 'Postal Code:    ' get cP_code picture '@!'
  @12,1 SAY 'Phone-Home: ' get cPhone_h picture '@!'
  @12,30 SAY 'Phone-Work: ' get cPhone_w picture '@!'
  @13,1 say 'E Mail address: ' get cE_Mail
  @14,50 SAY 'Birth date: ' get dBirth_dt
  *
  read
  
  select clients
  dbsetorder(3)
  dbgobottom()
  nLst_cd = val(clients->cnt_code)
  nLst_cd++
  cCnt_code = str(nLst_cd,5,0)
  
  * ADD NEW CLIENT
  select clients
  dbappend()
  reclock()
  clients->cnt_code   := cCnt_code
  clients->Title      := cTitle
  clients->Name       := cName
  clients->Surname    := cSurname
  clients->address1   := caddr1
  clients->address2   := caddr2
  clients->address3   := caddr3
  clients->P_code     := cP_code
  clients->Phone_w    := cPhone_w
  clients->Phone_h    := cPhone_h
  clients->std_code   := cstd_code
  clients->Archiv     := cArchiv
  clients->Birth_dt   := dBirth_dt
  clients->bank_code  := cbnk_cd
  clients->bnk_acc_no := cbnk_acc
  clients->acc_type   := cBnk_type
  Clients->e_mail     := cE_mail
  
  * SALES SCREEN
  
  select product
  cPrd_cd = et_Seek('Product', {2,1})
  if lastkey() = K_ESC
    break
  endif
  
  cPrd_cd = product->product
  
  @5,0 clear
  @5,1 say 'Product selected ' + product->descrip
  
  cPay_type = product->pay_type
  if !(cPay_type $ 'MA')
    nOpt = get_arr(aPay_type,13)
    if nOpt = 2
      cPay_type = 'A'
    else
      cPay_type = 'M'
    endif
  endif
  
  cRep = '  '
  cS_M = '  '
  cN_S_M = '  '
  
  @7,1 say 'Rep ' get cRep picture '!!'
  @7,15 say 'Sales Manager' get cS_M picture '!!'
  @7,35 say 'Nat Sales Manager ' get cN_S_M picture '!!'
  
  if cPay_type = 'M'
    nPayment = product->mnth_cost
    @9,1 say 'Account no ' get cBnk_acc picture '9999/9999/9999/9999'
    @9,40 say 'Account type ' get cBnk_type
    @11,1 say 'Enter monthly payment' get nPayment
  else            // annual

  endif
  
  read
  
  select cl_prod
  dbappend()
  reclock()
  cl_prod->cnt_code := clients->cnt_code
  cl_prod->prod_code := cPrd_cd
  cl_prod->init_dt := date()
  cl_prod->renewal_dt := date() + 365
  cl_prod->rep := cRep
  cl_prod->S_M := cS_M
  cl_prod->N_S_M := cN_S_M
  cl_prod->mth_yr_pay := cPay_type
  cl_prod->payment := nPayment
  cl_prod->status = "C"
  dbunlock()
  
  *  @2,0 clear to 24,79
  *  @2,1 SAY 'Title  ' + cTitle
  *  @2,20 SAY 'First name  ' + cName
  *  @3,20 SAY 'Surname     ' + cSurname
  *  @4,10 SAY 'Postal address'
  *  @5,10 say cAddr1
  *  @6,10 say cAddr2
  *  @7,10 say cAddr3
  *  @8,10 SAY 'Postal Code:     ' + cP_code
  *  @9,10 SAY 'Phone-Home:  ' + cPhone_h
  *  @10,10 SAY 'Phone-Work:  ' + cPhone_w
  *  @11,10 SAY 'Birth date:  ' + dtoc(dBirth_dt)
  *  @5,40 say 'Paid  ' + cPaid
  *  @5,55 say 'Paid date  ' + dtoc(dPaid_dt)
  *  @6,40 say 'Refund   ' + cRefund
  *  @7,40 say 'Bounced  ' + cBounce
  *  @8,40 say 'Expiry date  ' + cBnk_cd
  *  @9,40 say 'Card no      ' + cBnk_acc
  *  @11,40 SAY 'Club member :  ' + cMember
  *  dispbox(12,2,maxrow()-1,maxcol())
  *  memoedit(mComment,13,3,maxrow()-2,maxcol()-1, .f., .f.)
  *
  *  @5,40 say 'Paid ' get cPaid picture '!' valid jw_val_yn()
  *  @5,55 say 'Paid date ' get dPaid_dt
  *  @6,40 say 'Refund  ' get cRefund picture '!' valid jw_val_yn()
  *  @7,40 say 'Bounced ' get cBounce picture '!' valid jw_val_yn()
  *  @8,40 say 'Expiry date  ' get cBnk_cd picture '99/99'
  *  @9,40 say 'Card no     ' get cBnk_acc picture '9999/9999/9999/9999'
  *  @11,40 say 'Club member : ' GET cMember picture '!' valid jw_val_yn()
  *  read
  *
  *  clients->paid := cPaid
  *  clients->paid_dt := dPaid_dt
  *  clients->refund := crefund
  *  clients->bounce := cbounce
  *  clients->bank_code := cBnk_cd
  *  clients->bnk_acc_no := cbnk_acc
  *  clients->comment := mComment
  *  dbunlock()
  *  select cl_prod
  *  if !dbseek(clients->cnt_code + 'CB1')
  *    dbappend()
  *    reclock()
  *    cl_prod->cnt_code = clients->cnt_code
  *    cl_prod->prod_code = 'CB1'
  *    dbunlock()
  *  endif
  *  reclock()
  *  if cMember = 'Y'
  *    cl_prod->status := 'C'
  *    cl_prod->init_dt := dPaid_dt
  *    cl_prod->renewal_dt := dPaid_dt + 395
  *  else
  *    cl_prod->status := 'F'
  *  endif
  *  dbunlock()
  *
end sequence

wclose()

et_close('student')
et_close('newleads')

return

EOF()
