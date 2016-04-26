*******************************************************************************
* PROGRAM 'ACCSTD' - EDIT DEBIT ORDER DETAILS
* AUTHOR JIM WEST (E.T.)
* 1/2/88

local cSect, cBank_cd, cBnk_Acc_No, cAcc_type, nWidth
memvar getlist

if !net_use('student', .f., , 'names')
  return
endif

simhead(memvar->pscr_title)
findstd()
if eof()
  dbclosearea()
  return
endif

if !rlock()
  cSect = disp_msg(20,,'Student already in use - Please try later')
  inkey(10)
  dbclosearea()
  restsector(cSect)
  return
endif

@3,1 say space(12) + 'Student Debit Order Detail Edit Screen'

@4,1 clear
@5,5 say 'Account no. ' + student->std_code
cBank_cd = student->bank_code
cBnk_Acc_No := student->bnk_acc_no
cAcc_Type := student->acc_type
@6,1 say 'Title: ' + student->title
@6,15 say 'First name: ' + student->name
@7,15 say 'Surname:    ' + student->surname

@10,10 SAY 'Bank / Building society account details'
@12,10 say 'Enter bank code ' get cBank_cd picture '999999'
@14,10 say 'Enter account number ' get cBnk_Acc_No;
    picture '9999999999999999999'
@16,10 say 'Enter account type ' get cAcc_Type picture '9';
    valid cAcc_Type $ '123'
@17,10 say "'1' for current acc, '2' for savings  or '3' for transmission acc"
read

@16,0 clear
@12,40 say 'Account type ' + cAcc_Type
if wmake_sure(19)
  cBank_cd = alltrim(cBank_cd)
  nWidth = len(cBank_cd)
  if nWidth != 6
    cBank_cd = replicate('0',6-nWidth) + cBank_cd
  endif
  cBnk_Acc_No = rtrim(cBnk_Acc_No)
  cBnk_Acc_No = ltrim(cBnk_Acc_No)
  nWidth =  len(cBnk_Acc_No)
  if nWidth != 19
    cBnk_Acc_No = replicate('0',19-nWidth) + cBnk_Acc_No
  endif
  student->bank_code := cBank_cd
  student->bnk_acc_no := cBnk_Acc_No
  student->acc_type := cAcc_Type
endif
*
dbunlock()
dbclosearea()
return
* eof
