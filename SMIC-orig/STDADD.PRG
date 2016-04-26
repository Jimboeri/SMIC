*******************************************************************************
* PROGRAM 'STDADD'
* AUTHOR JIM WEST (E.T.)
* 1/2/88

* MEMORY VARIABLES TO HOLD STUDENT AND LEAD DETAILS
local cArchiv, cTitle, cAddr1, cAddr2, cAddr3, cOrig, cScr
local cP_code, cPhone_h, cPhone_w, nNow, nCnt, cField, cE_mail
local nSimln_len, nIntview, cMod_1, cMod_2, cSf, cLectr, cPas, dFollow
local cComm, cRef, nArr_val, cEls, nNext_code
local nStd_recno, lGroup_port, cGroup_code
local cGrp_surname, cGrp_title, cGrp_name, cGrp_std_code, nGrp_cnt
local lWrong_money, nPmt_type, cPmt_type, nAmount, lEntry_val
local dPmt_dt, nCC_comm, nOur_perc, nAmt_rcvd, nUs, nVat
local cDeposit, nRow, nFirst, nDue, lSplit

local cPay_type

local aWhat_sold := {'Modules 1 and 2',;
    'Module 1 only',;
    'Entry level service'}
// choice array for what modules were sold

local aPayment_type := {"Credit card",;
    "Cheque",;
    "Other",;
    "Debit order"}
// choice array for payment type

local aNow_fut := {'Bank this now',;
    'Bank it in the future'}
// choice array for credit cards, others

memvar getlist
memvar cSurname, cName, dBirth
memvar cSect, dStart_dt, nInit_val, cSalespsn, cS_M, cN_S_M, cStd_code

private cName, cSurname, cSect, dStart_dt, nInit_val
private cSalespsn, cS_M, cN_S_M

#include 'inkey.ch'

select 1
if !net_use('param', .f.,)
  return
endif

select 3
if !net_use('student', .f.,, 'stdarc', 'names', 'stdcode', 'stdgroup')
  return
endif

select 4
if !net_use('newleads', .f.,, 'archives', 'rleads', 'media')
  close databases
  return
endif

select 7
if !net_use('reps', .f.,, 'reps')
  close databases
  return
endif

*
simhead(memvar->pScr_title)
@3,1 say space(12) + 'Initial data capture of a new student'
cArchiv = space(7)
@5,5 say 'Enter Archive no of lead ' get cArchiv picture '!!!!!!!'
read
if cArchiv != space(7)
  select newleads
  if !dbseek(cArchiv)
    disp_msg(18,memvar->warn_col,'LEAD NOT FOUND ON LEAD FILE', 'PLEASE RE-ENTER')
    inkey(10)
  else
    reclock('Leads')
    select student
    if dbseek(cArchiv)
      disp_msg(18,memvar->warn_col, 'STUDENT ALREADY ATTACHED TO THIS LEAD', 'CHECK ARCHIVE NO')
      inkey(10)
    else
      select newleads
      @5,31 say cArchiv
      @5,60 say newleads->title + ' ' + newleads->initls
      @6,60 say newleads->surname
      cSect = savesector(19,0,23,79)
      if wmake_sure(12,,'Are you sure this is the correct person ?')
        cSurname = space(30)
        cName = space(20)
        cTitle = space(4)
        cE_mail = space(30)
        while cName = space(20) .or. cSurname = space(30)
          @8,1 say 'Title ' get cTitle picture '!!!!'
          @8,20 say 'First name ' get cName picture '@!' valid std_v01()
          @9,20 say 'Surname    ' get cSurname picture '@!' valid std_v02()
          read
        enddo
        @8,8 say cTitle
        @8,32 say cName
        @9,32 say cSurname
        @10,0 clear
        cP_code  = newleads->p_code
        cAddr1   = newleads->address1
        cAddr2   = newleads->address2
        cAddr3   = newleads->address3
        cPhone_w = newleads->phone_w
        cPhone_h = newleads->phone_h
        dBirth   = ctod('  /  /  ')
        @11,10 say 'Postal address'
        @12,10 get cAddr1 picture '@!'
        @13,10 get cAddr2 picture '@!'
        @14,10 get cAddr3 picture '@!'
        @15,10 say 'Postal Code:    ' get cP_code picture '@!'
        @17,1 say 'Phone-Home: ' get cPhone_h picture '@!'
        @17,30 say 'Phone-Work: ' get cPhone_w picture '@!'
        @18,10 say 'Birth date: ' get dBirth picture '@d' valid std_v06()
        @19,10 say 'E Mail:     ' get cE_mail
        cSect = savesector(21,0,23,79)
        *
        read
        select student
        dbsetorder(3)                                           // stdcode
        dbgobottom()
        nNext_code = val(Student->std_code) + 1
        dbsetorder(0)                                           // reset indices
        select param
        reclock('Paramater')
        cStd_code = ltrim(str(nNext_code))
        cStd_code = replicate('0', 5 - len(cStd_code)) + cStd_code
        param->nxt_std_no := nNext_code + 1             // updated for safetys sake
        dbunlock()
        
        * ADD NEW STUDENT
        select student
        dbappend()
        reclock('Student')
        student->std_code   := cStd_code
        student->group_no   := '01'
        student->archiv     := newleads->archiv
        student->title      := cTitle
        student->name       := cName
        student->surname    := cSurname
        student->address1   := cAddr1
        student->address2   := cAddr2
        student->address3   := cAddr3
        student->p_code     := cP_code
        student->phone_h    := cPhone_h
        student->phone_w    := cPhone_w
        student->status     := 'N'
        student->birth_dt   := dBirth
        student->stp_ls_lev := 0
        student->vat_rate   := 14
        student->e_mail     := Lower(cE_mail)
        dbcommit()
        
        * SALES SCREEN
        
        simhead(memvar->pscr_title)
        @4,10 say trim(Student->title) + ' ' + trim(Student->name) + ' ';
            + trim(Student->surname)
        @6,10 say 'What was the student sold:'
        
        cMod_1 := cMod_2 := cSf := cLectr := cEls := cPas := 'N'
        nArr_val = get_arr(aWhat_sold,8,41,memvar->ach_col3,.f.)
        @6,37 say aWhat_sold[nArr_val]
        do case
          case nArr_val = 1
            cMod_1 = 'Y'
            cMod_2 = 'Y'
            nSimln_len = 52
          case nArr_val = 2
            cMod_1 = 'Y'
            nSimln_len = 26
          case nArr_val = 3
            cEls = 'Y'
            nSimln_len = 999
        endcase
        select newleads
        cSalespsn := Newleads->salespsn
        nIntview := Newleads->intview
        dFollow := Newleads->follow_dt
        cComm = trim(memoline(newleads->mem_comnt,50,1))
        cComm += space(50 - len(cComm))
        cS_M = '  '
        cN_S_M = 'J1'
        nInit_val = 150000.00
        dStart_dt = ctod('  /  /  ')
        cRef = substr(newleads->misc_cd,1,1)
        @8,10 say 'Sold Share Fnd' get cSf picture 'Y'
        @8,40 SAY 'Sold Lectures ' get cLectr picture 'Y'
        read
        cSf = upper(cSf)
        cLectr = upper(cLectr)
        @10,10 say 'Salesperson ' get cSalespsn picture '!!' valid std_v03('R')
        @10,40 SAY 'Sales manager          ' get cS_M picture '!!';
            valid std_v03('S')
        @11,40 SAY 'National sales manager ' get cN_S_M picture '!!';
            valid std_v03('N')
        @12,10 SAY 'Interview ' get nIntview picture 'Y'
        @14,10 SAY 'Start Date:      ' get dStart_dt valid std_v04()
        @14,45 SAY 'Portfolio Value: ' get nInit_val valid std_v05()
        @18,10 SAY 'Follow up date ' get dFollow picture '@d'
        @20,10 SAY 'Comment ' get cComm
        cSect = savesector(21,0,23,79)
        read
        
        select reps
        if cSalespsn != newleads->SALESPSN
          if dbseek(cSalespsn)
            reclock('reps')
            reps->last_lead := date()
            dbunlock()
          endif
        endif
        dbclosearea()
        
        if wmake_sure(21,,'Must we pay 5% referal fee to rep Y/N ')
          cRef = 'R'
        else
          cRef = ' '
        endif
        * LEADS
        select newleads
        newleads->title     := cTitle
        newleads->initls    := substr(cName,1,1)
        newleads->surname   := cSurname
        newleads->salespsn  := cSalespsn
        newleads->intview   := nIntview
        newleads->follow_dt := dFollow
        newleads->mem_comnt := trim(cComm)
        newleads->killed    := 'S'
        if empty(Newleads->alloc_dt)
          newleads->alloc_dt := date()
        endif
        if empty(Newleads->misc_cd)
          newleads->misc_cd := 'YG'
        endif
        dbunlock()
        dbclosearea()
        
        * STUDENT
        select student
        student->rep       := cSalespsn
        student->s_m       := cS_M
        student->n_s_m     := cN_S_M
        student->simln_len := nSimln_len
        student->deal_ref  := cRef
        student->start_dt  := dStart_dt
        student->initl_val := nInit_val
        student->cash      := nInit_val
        student->fut_cash  := nInit_val/4
        if cMod_1 = 'Y'
          student->sold_crs_1 := date()
          for nCnt = 0 to 11
            cField = 'Student->lec' + ltrim(str(nCnt,2,0))
            &cField := 'P'
          next
        endif
        if cMod_2 = 'Y'
          student->sold_crs_2 := date()
          for nCnt = 12 to 20
            cField = 'Student->lec' + ltrim(str(nCnt,2,0))
            &cField := 'P'
          next
        endif
        if cSf = 'Y'
          student->sold_ss := date()
        endif
        if cLectr = 'Y'
          student->sold_lectr := date()
        endif
        if cEls = 'Y'
          student->sold_els := date()
        endif
        dbcommitall()
        
        nStd_recno = recno()
        @3,0 clear
        if cEls = 'Y'
          lGroup_port = .f.
        else
          lGroup_port = wmake_sure(5,,'Is this a group portfolio (Y/N) ?')
        endif
        
        if lGroup_port
          select Param
          reclock('Parameter')
          cGroup_code = ltrim(str(param->nxt_grp_no))
          cGroup_code = replicate('0',5 - len(cGroup_code)) + cGroup_code
          param->nxt_grp_no := param->nxt_grp_no + 1
          dbunlock()
          select student
          student->group_cd := cGroup_code
          cGrp_title = space(4)
          cGrp_name = space(20)
          cGrp_surname = cSurname
          nGrp_cnt = 2
          while !empty(cGrp_surname)
            cGrp_surname = space(30)
            cGrp_title = space(4)
            cGrp_name = space(20)
            @9,10 say 'Principle ' + trim(cTitle) + ' ' + cName
            @10,21 say cSurname
            @12,0 clear
            @12,10 say 'Title   ' get cGrp_title picture '@!'
            @12,25 say 'Name ' get cGrp_name picture '@!'
            @13,10 say 'Surname 'get cGrp_surname picture '@!'
            @16,10 say 'Enter blank surname to finish adding subordinates'
            read
            if !empty(cGrp_surname)
              select student
              dbsetorder(3)                                // stdcode
              dbgobottom()
              nNext_code = val(Student->std_code) + 1
              dbsetorder(0)                                // reset indices
              select param
              reclock('Paramater')
              cGrp_std_code = LTRIM(STR(nNext_code))
              cGrp_std_code = REPLICATE('0',5 - len(cGrp_std_code)) +;
                  cGrp_std_code
              param->nxt_std_no := nNext_code + 1               // updated for safetys sake
              dbunlock()
              
              select student
              dbappend()
              reclock('Student')
              student->group_cd := cGroup_code
              if nGrp_cnt < 10
                student->group_no := '0' + ltrim(str(nGrp_cnt))
              else
                student->group_no := ltrim(str(nGrp_cnt))
              endif
              nGrp_cnt++
              student->std_code  := cGrp_std_code
              student->archiv    := cArchiv
              student->title     := cGrp_title
              student->name      := cGrp_name
              student->surname   := cGrp_surname
              student->address1  := cAddr1
              student->address2  := cAddr2
              student->address3  := cAddr3
              student->p_code    := cP_code
              student->phone_h   := cPhone_h
              student->phone_w   := cPhone_w
              student->start_dt  := dStart_dt
              student->initl_val := nInit_val
              student->cash      := nInit_val
              student->status    := 'N'
              student->fut_cash  := nInit_val / 4
              student->birth_dt  := dBirth
              student->rep       := cSalespsn
              student->s_m       := cS_M
              student->n_s_m     := cN_S_M
              student->simln_len := nSimln_len
              student->deal_ref  := cRef
              if cMod_1 = 'Y'
                student->sold_crs_1 := date()
                for nCnt = 0 to 11
                  cField = 'Student->lec' + ltrim(str(nCnt,2,0))
                  &cField := 'P'
                next
              endif
              if cMod_2 = 'Y'
                student->sold_crs_2 := date()
                for nCnt = 12 to 20
                  cField = 'Student->lec' + ltrim(str(nCnt,2,0))
                  &cField := 'P'
                next
              endif
              if cSf = 'Y'
                student->sold_ss := date()
              endif
              if cLectr = 'Y'
                student->sold_lectr := date()
              endif
              if cEls = 'Y'
                student->sold_els := date()
              endif
              if cPas = 'Y'
                student->sold_pas := date()
              endif
              student->vat_rate := 14
            endif
          enddo
        endif
        dbcommitall()
        
        * payment screen
        
        select 2
        while !net_use('account', .f.,, 'acccode')
          @23,10 say 'Waiting for the ACCOUNT file'
        enddo
        @23,0 clear
        
        select 6
        while !net_use('cardcomm', .f.,, 'cardcomm')
          @23,10 SAY 'Waiting for the CREDIT CARD COMMISSION file'
        enddo
        @23,0 clear
        
        lWrong_money = .T.
        while lWrong_money
          simhead(memvar->pscr_title)
          select student
          dbgoto(nStd_recno)
          @3,10 say trim(Student->title) + ' ' + trim(Student->name) + ' ';
              + trim(Student->surname)
          @5,0 clear
          @5,10 say 'ENTER DEPOSIT/PAYMENT TYPE '
          nPmt_type = get_arr(aPayment_type, 7, 20, memvar->aCh_col3)
          do case
            case nPmt_type = 1          // Credit card
              cPmt_type = 'C'
            case nPmt_type = 2          // Cheque
              cPmt_type = 'Q'
            case nPmt_type = 3          // Other
              cPmt_type = 'O'
            case nPmt_type = 4          // Debit order
              cPmt_type = 'D'
          endcase
          setcolor(cOrig)
          @5,0 clear
          nAmount = 0
          @5,73 say 'Cheque'
          @5,37 say 'Amount'
          @5,62 say 'Date'
          @6,74 say 'Rcvd'
          do case
            case cPmt_type = 'Q'
              nAmount = 0
              while nAmount <= 0
                nAmount = cheque_other(7, 'q', .t.)
              enddo (DEPOSIT VALID)
              
            case cPmt_type = 'O'
              nAmount = 0
              while nAmount <= 0
                nAmount = cheque_other(7, 'o', .t.)
              enddo (DEPOSIT VALID)
              
            case cPmt_type = 'D'
              debit_order(7, .T.)
              
            case cPmt_type = 'C'
              nNow = 1
              dPmt_dt = date()
              lEntry_val = .F.
              while !lEntry_val
                @9,15 say 'Enter amount payable     ' get nAmount;
                    picture '9999999999.99'
                read
                nNow = get_arr(aNow_fut, 12, 20, memvar->aCh_col3,,,nNow)
                nCC_comm = 3.5
                if nNow = 2
                  @11,10 say 'When will we bank it ? ' get dPmt_dt
                  read
                  @14,10 say 'We will bank R' + ltrim(str(nAmount,14,2));
                      + ' on ' + dtoc(dPmt_dt)
                else
                  @11,15 say 'Enter % charges payable ' get nCC_comm;
                      picture '9.99'
                  read
                  @14,10 say str(nCC_comm,4,2) +;
                      '% Charges payable on credit card payments'
                  nOur_perc = 100 - nCC_comm
                  nAmt_rcvd = round((nAmount * nOur_perc / 100), 2)
                  @16,10 SAY 'Amount to be recieved = ' + STR(nAmt_rcvd,14,2)
                  nUs = round((nAmt_rcvd * 100 / (100 + student->vat_rate)), 2)
                  nVat = nAmt_rcvd - nUs
                endif
                if nAmount != 0
                  if wmake_sure(18,10,'Is this correct ? ')
                    lEntry_val = .T.
                  endif
                endif
              enddo (ENTRY VALID)
              select account
              dbappend()
              reclock('Accounts')
              account->std_code  := cStd_code
              account->type      := 'T'
              account->cr_dr     := 'D'
              if nNow = 1                               // bank now
                account->amount  := (nAmount * nOur_perc / 100)       // less commission
                account->comment := 'B'
              else                                      // bank later
                account->amount  := nAmount             // calc comm then
              endif
              account->pmt_dt    := dPmt_dt
              account->pmt_type  := 'C'
              dbunlock()
              if nNow = 1
                dbappend()
                reclock('Accounts')
                account->std_code := cStd_code
                account->type     := 'T'
                account->cr_dr    := 'C'
                account->amount   := nUs
                account->pmt_dt   := date()
                account->pmt_type := 'C'
                account->comment  := 'Q'
                account->vat      := nVat
                select cardcomm
                dbappend()
                reclock('Commissions')
                cardcomm->std_code  := cStd_code
                cardcomm->pmt_dt    := date()
                cardcomm->commision := nAmount - (nAmount * nOur_perc / 100)
                dbunlock()
              endif
              @7,0 clear
              @7,1 say 'Credit card'
              @7,60 say dtoc(dPmt_dt)
              if nNow = 1                               // bank now
                @7,29 say str((nAmount * nOur_perc / 100),14,2)
              else
                @7,29 say str(nAmount,14,2)
              endif
              if empty(student->bank_code) .or. empty(student->bnk_acc_no)
                get_credit()                    // source in accchang.prg
              endif
          endcase (deposit)
          
          cDeposit = ' '
          while cDeposit != 'D' .and. cDeposit != 'F'
            @8,0 clear
            wait 'Was this a Deposit or the Full amount (D/F) ' to cDeposit
            cDeposit = upper(cDeposit)
          enddo
          nRow = 8
          if cDeposit = 'D'
            @8,0 clear
            @8,10 say 'ENTER BALANCE OF PAYMENT TYPE '
            nPmt_type = get_arr(aPayment_type, 11, 40, memvar->aCh_col3)
            do case
              case nPmt_type = 1
                cPmt_type = 'C'
              case nPmt_type = 2
                cPmt_type = 'Q'
              case nPmt_type = 3
                cPmt_type = 'O'
              case nPmt_type = 4
                cPmt_type = 'D'
            endcase
            setcolor(cOrig)
            @8,0 clear
            
            *
            do case
              case cPmt_type = 'Q'
                nAmount = 1.00
                while nAmount != 0
                  nAmount = cheque_other(nRow, 'Q', .F.)
                  nRow++
                enddo (nAmount != 0)
                
              case cPmt_type = 'O'
                nAmount = 1.00
                while nAmount != 0
                  nAmount = cheque_other(nRow, 'O', .F.)
                  nRow++
                enddo (nAmount != 0)
                
              case cPmt_type = 'D'
                debit_order(8, .F.)
                
              case cPmt_type = 'C'
                dPmt_dt = date()
                lEntry_val = .F.
                while !lEntry_val
                  @10,15 say 'Enter amount payable     ' get nAmount;
                      picture '9999999999.99'
                  read
                  @14,10 say 'Amount to be recieved = ' + str(nAmount,14,2)
                  @16,10 say 'When will we bank it ? ' get dPmt_dt
                  read
                  if nAmount != 0
                    if wmake_sure(18,10,'Is this correct ? ')
                      lEntry_val = .T.
                    endif
                  endif
                enddo (ENTRY VALID)
                select account
                dbappend()
                reclock('Accounts')
                account->std_code := cStd_code
                account->type     := 'T'
                account->cr_dr    := 'D'
                account->amount   := nAmount
                account->pmt_dt   := dPmt_dt
                account->pmt_type := 'C'
                dbunlock()
                if empty(student->bank_code) .or. empty(student->bnk_acc_no)
                  get_credit()                  // source in accchang.prg
                endif
                @8,0 clear
                @8,1 say 'Credit card'
                @8,29 say str(nAmount,14,2)
                @8,60 say dtoc(dPmt_dt)
            endcase
          endif (cDeposit = 'D')
          select account
          dbseek(cStd_code)
          nFirst = 0
          nDue = 0
          while cStd_code = account->std_code .and. !eof()
            if account->cr_dr = 'D'
              nDue += account->amount
              IF nFirst != 0
                nFirst = account->amount
              endif
            endif
            dbskip()
          enddo
          select student
          if cDeposit = 'D'
            if nFirst < (nDue / 2)
              lSplit = wmake_sure(19,,'Is this a split deposit ?')
              if lSplit
                if Student->deal_ref = 'r'
                  student->deal_ref := 'T'
                else
                  student->deal_ref := 'S'
                endif
              endif
            endif
          endif
          if wmake_sure(19,,'TOTAL TO BE PAID BY STUDENT IS ' +;
                str(nDue,14,2),;
                'Are you ABSOLUTELY sure you have entered the finances correctly ?')
            lWrong_money = .F.
          else
            cStd_code = cStd_code
            select account
            dbseek(cStd_code)
            while cStd_code = Account->std_code .and. !eof()
              reclock('Accounts')
              dbdelete()
              dbunlock()
              dbskip()
            enddo
            select cardcomm
            dbseek(cStd_code)
            while cStd_code = cardcomm->std_code .and. !eof()
              reclock('Commission')
              dbdelete()
              dbunlock()
              dbskip()
            enddo
          endif
        enddo (FINANCES ENTERED CORRECTLY)
        select student
        dbunlock()
      endif
    endif (STD ATTACHED TO LEAD)
  endif (LEAD DOES NOT EXIST)
endif (ARCHIV != SPACE)
dbcloseall()
return
* eof

***********************************************************
* ENSURES STUDENTS FIRST NAME IS NOT BLANK
function std_v01
local oGet
oGet := getactive()
@maxrow(),0 clear
if lastkey() = K_UP
  return(.t.)
endif
if empty(oGet:buffer)
  @maxrow(),0 say center('First Name must not be blank',,,.t.);
      color memvar->white_red
  return .f.
endif
return .t.

***********************************************************
* ENSURES STUDENTS SURNAME IS NOT BLANK
function std_v02
local oGet
oGet := getactive()
@maxrow(),0 clear
if lastkey() = K_UP
  return(.t.)
endif
if empty(oGet:buffer)
  @maxrow(),0 say center('Surname must be entered',,,.t.);
      color memvar->white_red
  return .f.
endif
return .t.

*******************************************************************************
* VALIDATES REP DETAILS
function std_v03 ( cRep_type )
local cRep, cType, oGet
oGet := getactive()
@maxrow(),0 clear
if lastkey() = K_UP
  return(.t.)
endif

cRep = oget:buffer

do case
  case cRep_type = 'R'
    cType = 'Sales person'
  case cRep_type = 'S'
    cType = 'Sales manager'
  case cRep_type = 'N'
    cType = 'National sales manager'
endcase

if empty(cRep)
  @maxrow(),0 say center('This field must be entered',,,.t.);
      color memvar->white_red
  return(.f.)
endif

if !oGet:changed        // OK if no change
  return(.t.)
endif

select reps
if !dbseek(cRep)
  @maxrow(),0 say center(cType + ' does not exist',,,.t.);
      color memvar->white_red
  return(.f.)
endif

if Reps->status != 'C' .and. (Reps->end_dt + 45) < date()
  @maxrow(),0 say center(cType + ' is not current',,,.t.);
      color memvar->white_red
  return(.f.)
endif

do case
  case cRep_type = 'R'
    if !(Reps->level $ 'RSN')
      @maxrow(),0 say center('Sales person is not a sales person !!',,,.t.);
          color memvar->white_red
      return(.f.)
    endif
  case cRep_type = 'S'
    if !(Reps->level $ 'SN')
      @maxrow(),0 say center('Sales person is not a sales manager !!',,,.t.);
          color memvar->white_red
      return(.f.)
    endif
  case cRep_type = 'N'
    if Reps->level != 'N'
      @maxrow(),0 say center('Sales person is not a national sales manager !!',,,.t.);
          color memvar->white_red
      return(.f.)
    endif
endcase

return(.t.)

***********************************************************
* ENSURES START DATE CANNOT BE PRIOR TO TODAY
function std_v04
local oGet, dVal
oGet := getactive()
@maxrow(),0 clear
if lastkey() = K_UP
  return(.t.)
endif
dVal = ctod(oGet:buffer)
if empty(dVal)
      @maxrow(),0 say center('Start date must be entered',,,.t.);
          color memvar->white_red
  return (.f.)
endif
if dVal < date()
      @maxrow(),0 say center('Start date cannot be prior to today',,,.t.);
          color memvar->white_red
  return (.f.)
endif
return (.t.)

***********************************************************
* ENSURES PORTFOLIO VALUE CANNOT BE 0
function std_v05
local oGet, nVal
oGet := getactive()
@maxrow(),0 clear
if lastkey() = K_UP
  return(.t.)
endif
nVal = val(oGet:buffer)
if nVal <= 0
      @maxrow(),0 say center('Cannot start with a 0 portfolio value',,,.t.);
          color memvar->white_red
  return (.f.)
endif
return (.t.)

***********************************************************
* ENSURES Birth date is entered
function std_v06
local oGet, dVal
oGet := getactive()
@maxrow(),0 clear
if lastkey() = K_UP
  return(.t.)
endif
dVal = ctod(oGet:buffer)
if empty(dVal)
      @maxrow(),0 say center('Birth date must be entered',,,.t.);
          color memvar->white_red
  return (.f.)
endif
if year(dVal) > 1984
      @maxrow(),0 say center('Birth date cannot be after 1984',,,.t.);
          color memvar->white_red
  return (.f.)
endif
return (.t.)

* EOF


*********************************************************************
* THIS FUNCTION GETS DETAILS FOR A CHEQUE FROM THE USER, STORES THE
*      APPROPRIATE RECORDS AND DISPLAYS THE DETAILS ON THE LINE NUMBER
*      PASSED AS A PARAMETER. NOTHING IS STORED FOR A 0 AMOUNT AND
*      THE AMOUNT INPUT IS RETURNED FOR VALIDATION PURPOSES
*
* PARAMETERS 1 - THE ROW ON WHICH TO GET AND DISPLAY THE DATA
*            2 - PAYMENT TYPE 'Q' FOR CHEQUE OR 'O' FOR OTHER
*            3 - LOGICAL VALUE, TRUE FOR DEPOSIT

static function cheque_other ( nDisp_line, cPay_type, lFirst )
local nAmount, dPmt_dt, cRcvd, nCheck, lOK, nUs, nVat
memvar getlist
nAmount = 0
dPmt_dt = ctod('  /  /  ')
if cPay_type = 'O' .and. lFirst
  dPmt_dt = date()
endif
lOK = .f.
while !lOK
  @nDisp_line,0 CLEAR
  @nDisp_line,1 SAY STR_TYPE(cPay_type)
  @nDisp_line,22 SAY 'Amount ' GET nAmount PICTURE '9999999999.99'
  @nDisp_line,46 SAY 'Payment date ' GET dPmt_dt PICTURE '@D'
  read
  if !lFirst .or. nAmount > 0
    lOK = .t.
  else
    disp_msg(nDisp_line+5,,'Deposit cannot be 0')
    inkey(10)
  endif
enddo
IF nAmount <= 0
  return ( nAmount)
endif
@nDisp_line,29 say str(nAmount,14,2)
@nDisp_line,60 say dtoc(dPmt_dt)
if cPay_type = 'O'
  if lFirst
    while (cRcvd != 'Y' .and. cRcvd != 'N')
      @nDisp_line+1,0 clear
      wait 'Have we received the money ? (Y/N) ' to cRcvd
      cRcvd = upper(cRcvd)
    enddo
    if cRcvd = 'Y'
      cRcvd = 'B'
    else
      cRcvd = ' '
    endif
  else
    cRcvd = ' '
  endif
else
  cRcvd = ' '
  while (cRcvd != 'Y' .and. cRcvd != 'N')
    @nDisp_line+1,0 clear
    wait 'Do we have the cheque ? (Y/N) ' to cRcvd
    cRcvd = upper(cRcvd)
  enddo
endif
@nDisp_line,77 say cRcvd
if nDisp_line < 14
  nCheck = nDisp_line + 5
else
  nCheck = 8
endif

if wmake_sure(nCheck,,'Is this correct ? (Y/N) ')
  select account
  dbappend()
  reclock('Accounts')
  account->std_code := STUDENT->STD_CODE
  account->type     := 'T'
  account->cr_dr    := 'D'
  account->amount   := nAmount
  account->pmt_dt   := dPmt_dt
  account->pmt_type := cPay_type
  account->comment  := cRcvd
  dbunlock()
  if cPay_type = 'O' .and. cRcvd = 'B'
    nUs = round((nAmount * 100 / (100 + student->vat_rate)), 2)
    nVat = nAmount - nUs
    select account
    dbappend()
    reclock('Accounts')
    account->std_code := student->std_code
    account->type     := 'T'
    account->cr_dr    := 'C'
    account->amount   := nUs
    account->pmt_dt   := date()
    account->pmt_type := cPay_type
    account->comment  := 'Q'
    account->vat      := nVat
    dbunlock()
  endif
else
  return ( 0 )
endif
if empty(student->bank_code) .or. empty(student->bnk_acc_no)
  get_cheque()                  // source in accchang.prg
endif
return ( nAmount )

* EOP

*******************************************************************************
static procedure debit_order ( nDISP_ROW, lDepos)

local lAcc_ok, cAcc_bnk, cAcc_no, cAcc_type, nAmount, nCnt
local dAct_dt, nSt_inx, lDt_ok, nAcc_type, nWdth, nPays, nDt, nDo_day, nDo_mth
local aSt_dt[3]
local aPmt_dt := {'End of the month', 'Middle of the month'}
local aAcc_type := {'1 - Current', '2 - Savings', '3 - Transmission'}
memvar getlist

@8,5 TO 22,75
@9,10 SAY 'Bank / Building society account details'
lAcc_ok = .F.
cAcc_bnk = student->bank_code
cAcc_no = student->bnk_acc_no
cAcc_type = student->acc_type
nAcc_type = if(student->acc_type = ' ', 1, val(student->acc_type))
while !lAcc_ok
  @11,10 say 'Enter bank code ' get cAcc_bnk
  @13,10 say 'Enter account number ' get cAcc_no
  read
  @15,10 say 'Enter account type '
  nAcc_type = get_arr(aAcc_type, 15, 40, memvar->aCh_col3, , ,nAcc_type)
  cAcc_type = str(nAcc_type,1,0)
  @14,10 clear to 16,70
  @11,40 say 'Account type ' + aAcc_type[nAcc_type]
  IF MAKE_SURE(18,,'Is this correct ')
    lAcc_ok = .T.
    cAcc_bnk = RTRIM(cAcc_bnk)
    cAcc_bnk = LTRIM(cAcc_bnk)
    STORE LEN(cAcc_bnk) TO nWdth
    IF nWdth != 6
      cAcc_bnk = REPLICATE('0',6-nWdth) + cAcc_bnk
    ENDIF
    cAcc_no = alltrim(cAcc_no)
    nWdth = len(cAcc_no)
    if nWdth != 19
      cAcc_no = replicate('0',19-nWdth) + cAcc_no
    endif
    select student
    reclock('student')
    student->bank_code  := cAcc_bnk
    student->bnk_acc_no := cAcc_no
    student->acc_type   := cAcc_type
  endif (yesno)
enddo (lAcc_ok)
@8,5 to 22,75
@9,6 clear to 21,74
@3,62 say 'Bank Code  ' + cAcc_bnk
@4,73 say 'Type ' + cAcc_type
@4,41 say 'Account no ' + cAcc_no
nAmount = 0
nPays = 0
@10,10 SAY 'Debit Order payment details'
if lDepos
  nPays = 1
  @12,10 say 'Enter the deposit payment below & the rest later'
  @14,10 SAY 'Enter deposit amount ' GET nAmount PICTURE '9999999999.99';
      valid (nAmount > 0)
else
  @12,10 SAY 'Enter number of payments' GET nPays PICTURE '99' valid (nPays > 0)
  @14,10 SAY 'Enter amount of payments ' GET nAmount PICTURE '9999999999.99';
      valid (nAmount > 0)
endif
@16,10 SAY 'When does the student want to pay ? '
read
nDt = get_arr(aPmt_dt, 16, 50, memvar->aCh_col3)
nDo_mth = month(date())
if nDT = 2
  nDo_day = 15
else
  nDo_day = endday(nDo_mth)
endif
dAct_dt = ctod(str(nDo_day,2,0) + '/' + str(nDo_mth,2,0) + '/' +;
    str(year(date()),4,0))
select param

if (date()+4) > dAct_dt
  dAct_dt = et_addmonth(dAct_dt, 1)
endif

aSt_dt[1] = dtoc(dAct_dt)
aSt_dt[2] = dtoc(et_addmonth(ctod(aSt_dt[1]), 1))
aSt_dt[3] = dtoc(et_addmonth(ctod(aSt_dt[2]), 1))

lDt_ok = .F.
while !lDt_ok
  nSt_inx = get_arr(aSt_dt, 16,60, memvar->aCh_col3)
  if nSt_inx != 0
    if wmake_sure(19,, 'First debit date = ' + aSt_dt[nSt_inx] + ' Y/N ? ')
      dAct_dt = ctod(aSt_dt[nSt_inx])
      lDt_ok = .t.
    endif
  endif
enddo (lDt_ok)
nCnt = 0
select account
while nCnt < nPays
  nCnt++
  dbappend()
  reclock('Accounts')
  account->std_code := memvar->cStd_code
  account->type     := 'T'
  account->cr_dr    := 'D'
  account->amount   := nAmount
  account->pmt_dt   := dAct_dt
  account->pmt_type := 'D'
  account->comment  := ' '
  dbunlock()
  dAct_dt = et_addmonth(dAct_dt, 1)
enddo
return
