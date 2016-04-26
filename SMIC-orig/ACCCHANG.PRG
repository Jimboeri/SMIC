*******************************************************************************
*
* ACCCHANG - CHANGE STUDENT PAYMENT SCHEDULE
*
*******************************************************************************

local nInkey, nKey, nLast_inx, nDisp, cOrig, nAcc_type/*, cSect*/
local nRow, cChar, nAmount, cComm
local nBank_type, nCharge, nRetain, nUs, nVat, cChq_col, nCnt
local cAcc_std, nAcc_amt, dAcc_dt, nExplain, cType, dLst_dt, cCh_oth
local cResched, cAcc_pmt_ty

memvar aDisp, aAcc_type, aCred_card, lStudent, cAcc_type, lPas
memvar getlist, aRev_type, cPmt_type, dDate, dDt

#include "inkey.ch"

aCred_card := {'Bank this credit card now', 'Bank this in the future'}
private aRev_type           // array used for reversal reasons
private aDisp[0]            // array to hold display details

clear typeahead
setkey(K_F3, {|| a12_pay_hist()})

aAcc_type := {'Student accounts', 'Advisory service accounts'}
*                   // selection of type of account

*                   // open datafiles
begin sequence
  select 3
  if !net_use('cardcomm', .f.,, 'cardcomm')
    break
  endif
  
  select 1
  if !net_use('account', .f.,, 'acccode')
    break
  endif
  
  select 2
  if !net_use('student', .f.,, 'names')
    break
  endif
  
  simhead(memvar->pscr_title)
  findstd()                   // find student for accounts
  if eof()                    // if not selected go back
    break
  endif
  
  if !rlock()         // lock student or go back if locked
    disp_msg(20,memvar->info_col,'Student already in use - Please try later')
    InKey(10)
    break
  endif
  
  simhead(memvar->pscr_title)
  cAcc_type = ' '
  *               // work out what student has been sold
  if !empty(student->sold_crs_1) .or. !empty(student->sold_crs_2);
        .or. !empty(student->sold_els)
    lStudent = .T.        // sold TWIN
    cAcc_type = 'T'
  else
    lStudent = .F.
  endif
  if !empty(student->sold_pas)
    lPAS = .T.            // sold PAS
    cAcc_type = 'P'
  else
    lPAS = .F.
  endif
  
  if !lStudent .AND. !lPAS    // if sold nothing go back
    dbcloseall()
    break
  endif
  *               // set up display
  @2,10 SAY 'Accounts for ' + trim(student->title) + ' ' + trim(student->name);
      + ' ' + trim(student->surname)
  @3,10 SAY 'Account no   ' + student->std_code + ' ' + student->rep
  
  if lStudent .and. lPAS      // if choice of accounts, find which
    nAcc_type = get_arr(aAcc_type, 8,21, memvar->aCh_col3)
    do case
      case nAcc_type = 1
        cAcc_type = 'T'       // twin
      case nAcc_type = 2
        cAcc_type = 'P'       // pas
      otherwise
        break
    endcase
  endif
  
  @2,70 say str_stat(student->status)     // set up screen display
  if student->deal_ref = 'S' .or. student->deal_ref = 'T'
    @3,70 say 'Splt dep'
  endif
  if student->deal_ref = 'R' .or. student->deal_ref = 'T'
    @4,70 say 'Referal'
  endif
  @5,3 say 'Pmt type        Pmt date          Amount   Chq held          Paid on'
  @6,0 say replicate('-',80)
  @24,57 say 'F3 - payment history'
  
  a9_load_array()         // loads display array
  
  nDisp = 1
  
  p8_arr_udf(0,1,1)       // creates display at top
  
  while nDisp != 0 .and. lastkey() != K_ESC   // until Esc is pressed
    IF len(aDisp) < 14
      nRow = nDisp
    else
      nRow = 7
    endif
    @7,0 clear to 22,79
    p8_arr_udf(0,nDisp,nRow)      // creates display at top
    nLast_inx = nDisp         // store last selection
    nDisp = achoice(7,0,22,79,aDisp, .T., 'P8_ARR_UDF', nDisp, nRow)  // get next selection
    cChar = upper(chr(lastkey()))     // store last key pressed
    *    save screen to cTemp_scr        // save screen to restore later
    if lastkey() = K_INS .or. (lastkey() = K_DOWN .and. nDisp = nLast_inx);
          .or. len(aDisp) = 0                   // INSERT RECORD
      if wmake_sure(8,, 'Do you want to add another',;
            'payment ? (Y/N) or Escape ')
        wopen(10,15, 17,65)
        wbox(1)
        cPmt_type = ' '               // initialise and get vars
        nAmount = 0
        dDate = ctod('  /  /  ')
        @1,5 say 'Pmt type ' get cPmt_type picture '!';
            valid a10_val_pmt_type()
        @1,25 say 'Date ' get dDate picture '@D' valid a11_val_pmt_dt()
        @2,5 say 'Amount   ' get nAmount picture '9999999999.99'
        read
        tts_on()                        // start explicit transaction
        select student
        student->fin_pay := ' '           // reset finished payment ind
        select account
        nAmount = abs(nAmount)
        wclose()
        if nAmount != 0           // if amount > 0
          nDisp++
          do case
            case cPmt_type = 'O'      // other payment
              dbappend()
              reclock('Account')      // just add the record
              account->pmt_type := 'O'
              account->type     := cAcc_type
              account->comment  := ' '
              account->std_code := student->std_code
              account->pmt_dt   := dDate
              account->amount   := nAmount
              account->cr_dr    := 'D'
              select account
            case cPmt_type = 'Q'      // cheque
              cComm = ' '
              wopen(12,20,15,60)   // find out if we have the cheque
              wbox(1)
              @0,0 say center('Do we have the cheque ? (Y/N)')
              while cComm != 'Y' .and. cComm != 'N'
                nKey = inwait()
                if nKey = 0
                  cComm = 'N'
                else
                  cComm = upper(chr(nKey))
                endif
              enddo
              wclose()
              dbappend()                // store the record.
              reclock('Account')
              account->pmt_type := 'Q'
              account->type     := cAcc_type
              account->comment  := cComm
              account->std_code := student->std_code
              account->pmt_dt   := dDate
              account->amount   := nAmount
              account->cr_dr    := 'D'
              if empty(student->bank_code) .or. empty(student->bnk_acc_no)
                get_cheque()
              endif
              select account
            case cPmt_type = 'D'
              if empty(Student->bank_code) .or. empty(student->bnk_acc_no);
                    .or. empty(student->acc_type)
                wopen(10,20,16,60)     // cannot add deb order if no details
                setcolor(memvar->white_red)
                wbox(1)
                @1,0 say center('Student bank details not completed')
                @2,0 say center('cannot change to debit order')
                inwait()
                wclose()
              else
                dbappend()
                reclock('Account')        // add the record
                account->pmt_type := 'D'
                account->type     := cAcc_type
                account->comment  := ' '
                account->std_code := student->std_code
                account->pmt_dt   := dDate
                account->amount   := nAmount
                account->cr_dr    := 'D'
                select account
              endif
            case cPmt_type = 'C'
              nBank_type = get_arr(aCred_card,,, memvar->aCh_col3)
              if nBank_type = 1           // bank CC now
                nCharge = 3.5
                wopen(10,10,16,70)     // get Credit card commission charges
                wbox(1)
                @1,2 say 'This will automatically bank the money'
                @2,2 say 'Enter % charges ' get nCharge picture '9.99'
                read
                nRetain = 100 - nCharge        // perc to retain
                cComm = nAmount * nCharge / 100 // commission value
                nAmount = nAmount * nRetain / 100    // value to retain
                select cardcomm
                dbappend()
                reclock('Commission')     // store commission record
                cardcomm->std_code  := student->STD_CODE
                cardcomm->pmt_DT    := date()
                cardcomm->commision := cComm
                dbunlock()
                select account            // calc VAT and what remains
                nUs = round((nAmount * 100 / (100 + student->vat_rate)), 2)
                nVat = nAmount - nUs
                dbappend()
                reclock('Account')        // store record of payment
                account->pmt_type := 'C'
                account->type     := cAcc_type
                account->comment  := 'Q'
                account->amount   := nUs
                account->std_code := student->std_code
                account->pmt_dt   := date()
                account->cr_dr    := 'C'
                account->vat      := nVat
                dbunlock()
                wclose()
              endif
              select account
              dbappend()
              reclock('Account')          // store payment due record
              account->std_code  := student->std_code
              account->type      := cAcc_type
              account->cr_dr     := 'D'
              account->amount    := nAmount
              account->pmt_dt    := dDate
              account->pmt_type  := 'C'
              if nBank_type = 1
                account->comment := 'B'       // if banked
              else
                account->comment := ' '
              endif
              dbunlock()
              if empty(student->bank_code) .or. empty(student->bnk_acc_no)
                get_credit()
              endif
              select account
          endcase
        endif
        tts_off()
        a9_load_array()
      endif
    elseif nDisp != 0             // selection made
      if a7_c_recno(aDisp[nDisp]) = 0     // account not yet paid
        * account not paid yet
        goto a6_d_recno(aDisp[nDisp])     // goto corresponding rec
        do case
          case cChar = 'A'            // enter new amount
            if account->comment != 'B'         // must not be banked
              wopen(11,21,15,59)
              wbox(1)
              nAmount = account->amount
              @1,3 say 'Enter new amount ' get nAmount picture '9999999999.99'
              read
              wclose()
              if nAmount != account->amount .and. nAmount > 0
                aDisp[nDisp] = stuff(aDisp[nDisp], 31, 13, str(nAmount,13,2))
                reclock('Account')
                account->amount := nAmount
                dbunlock()
                select account
              endif (amount changed)
            endif (payment not banked)
          case cChar = 'D'            // enter new date
            if account->comment != 'B'
              wopen(10,18, 14,62)
              wbox(1)
              *              cSect = draw_box(10,18, 14,62)
              dDt = account->pmt_dt
              @1,5 say 'Enter new date ' get dDt picture '@D';
                  valid a11_val_pmt_dt()
              read
              wclose()
              *              restsector(cSect)
              if dDt != account->pmt_dt
                reclock('Account')
                account->pmt_dt := dDt
                dbunlock()
                select account
                a9_load_array()
              endif (date changed)
            endif (payment not banked)
          case cChar = 'B'            // bank the payment
            // if account->comment != 'B' .and. account->pmt_dt <= date()  // date <= today
            // commented out as comment = 'B' check was causing failures
            
            if account->pmt_dt <= date()        // date <= today
              if (account->pmt_type = 'Q' .or. account->pmt_type = 'E');
                    .and. account->comment = 'Y'
                if wmake_sure(10,, 'Are you SURE you want to bank this check ?')
                  tts_on()
                  reclock('Account')
                  account->comment := 'B'     // mark as paid
                  if account->pmt_type = 'E'
                    account->pmt_type := 'Q'
                  endif
                  nAmount = account->amount
                  dbunlock()              // calc VAT and our portion
                  nUs = round((nAmount * 100 / (100 + student->vat_rate)), 2)
                  nVat = nAmount - nUs
                  dbappend()            // store payment record
                  reclock('Account')
                  account->std_code := student->std_code
                  account->type     := cAcc_type
                  account->cr_dr    := 'C'
                  account->amount   := nUs
                  account->pmt_dt   := date()
                  account->pmt_type := 'Q'
                  account->comment  := 'Q'
                  account->vat      := nVat
                  tts_off()
                  select account
                  *       // update display
                  aDisp[nDisp] = stuff(aDisp[nDisp], 66, 8, dtoc(date()))
                  aDisp[nDisp] = stuff(aDisp[nDisp], 90, 8, str(recno(),8,0))
                  aDisp[nDisp] = stuff(aDisp[nDisp], 50, 1, ' ')
                  aDisp[nDisp] = stuff(aDisp[nDisp], 81, 1, account->comment)
                  if empty(student->bank_code) .or. empty(student->bnk_acc_no)
                    get_cheque()
                  endif
                endif
              endif (payment is a check)
              if account->pmt_type = 'O'           // other payment type
                if wmake_sure(10,, 'Have we recieved R ' +;
                      ltrim(str(account->amount)))
                  tts_on()
                  nAmount = account->amount
                  reclock('Account')
                  account->comment := 'B'     // mark as banked
                  dbunlock()              // calc VAT and our portion
                  nUs = round((nAmount * 100 / (100 + student->vat_rate)), 2)
                  nVat = nAmount - nUs
                  dbappend()            // store payment record
                  reclock('Account')
                  account->std_code := student->std_code
                  account->type     := cAcc_type
                  account->cr_dr    := 'C'
                  account->amount   := nUs
                  account->pmt_dt   := date()
                  account->pmt_type := 'O'
                  account->comment  := 'Q'
                  account->vat      := nVat
                  dbunlock()
                  tts_off()
                  select account
                  *           // update display
                  aDisp[nDisp] = stuff(aDisp[nDisp], 66, 8, dtoc(date()))
                  aDisp[nDisp] = stuff(aDisp[nDisp], 90, 8, str(recno(),8,0))
                  aDisp[nDisp] = stuff(aDisp[nDisp], 81, 1, account->comment)
                endif (payment received)
              endif (payment is cash)
              if account->pmt_type = 'C'           // credit card
                if wmake_sure(10,, 'Bank this credit card now ?')
                  nAmount = account->amount
                  nCharge = 3.5
                  wopen(11,20,16,60)       // get Credit card commission charges
                  wbox(1)
                  @1,5 say 'Enter % charges ' get nCharge picture '9.99'
                  read
                  wclose()
                  nRetain = 100 - nCharge      // perc to retain
                  cComm = nAmount * nCharge / 100   // commission value
                  nAmount = nAmount * nRetain / 100  // value to retain
                  tts_on()
                  select cardcomm
                  dbappend()
                  reclock('Commission')       // store commission record
                  cardcomm->std_code  := student->std_code
                  cardcomm->pmt_dt    := date()
                  cardcomm->commision := CcOMM
                  dbunlock()
                  select account          // calc VAT and what remains
                  nUs = round((nAmount * 100 / (100 + student->vat_rate)), 2)
                  nVat = nAmount - nUs
                  reclock('Account')      // payment due record
                  account->comment := 'B'     // mark as banked
                  account->amount  := nAmount
                  dbunlock()
                  dbappend()
                  reclock('Account')      // store record of payment
                  account->pmt_type := 'C'
                  account->type     := cAcc_type
                  account->comment  := 'Q'
                  account->amount   := nUs
                  account->std_code := student->std_code
                  account->pmt_dt   := date()
                  account->cr_dr    := 'C'
                  account->vat      := nVat
                  dbunlock()
                  tts_off()
                  if empty(student->bank_code) .or. empty(student->bnk_acc_no)
                    get_credit()
                  endif
                  select account
                  *           // update display
                  aDisp[nDisp] = stuff(aDisp[nDisp], 31, 13, str(nAmount,13,2))
                  aDisp[nDisp] = stuff(aDisp[nDisp], 66, 8, dtoc(date()))
                  aDisp[nDisp] = stuff(aDisp[nDisp], 90, 8, str(recno(),8,0))
                  aDisp[nDisp] = stuff(aDisp[nDisp], 81, 1, account->comment)
                endif (payment received)
              endif (payment is Credit card)
              select account
            endif (payment not banked)
          case cChar = 'H'            // hold cheque or not
            if Account->comment != 'B'
              if account->pmt_type = 'Q' .or. account->pmt_type = 'E'   // only for cheques
                wopen(11,21,15,59)
                wbox(1)
                cComm = ' '
                @1,3 say center('Do we have the cheque ?')
                while cComm != 'N' .and. cComm != 'Y'
                  nKey = inwait()
                  if nKey = 0
                    cComm = 'N'
                  else
                    cComm = upper(chr(nKey))
                  endif
                enddo
                wclose()
                if cComm != Account->comment
                  reclock('Account')
                  account->comment := cComm
                  dbunlock()
                  aDisp[nDisp] = stuff(aDisp[nDisp], 50, 1, Account->comment)
                  aDisp[nDisp] = stuff(aDisp[nDisp], 81, 1, Account->comment)
                endif (amount changed)
              endif (payment is cheque)
            endif (payment not banked)
          case cChar = 'E' .or. lastkey() = K_DEL // delete payment
            if Account->comment != 'B'
              if wmake_sure(13,,;
                    'Are you SURE you want to delete this payment ?')
                select account
                reclock('Account')
                dbdelete()
                dbunlock()
                dbgotop()
                adel(aDisp, nDisp)
                asize(aDisp, len(aDisp)-1)
              endif (delete record)
            endif (payment not banked)
          case cChar = 'P'        // change payment type
            if Account->comment != 'B'
              wopen(10,10,15,70)
              wbox(1)
              cPmt_type = account->pmt_type
              @1,10 say 'Enter new payment type ' get cPmt_type picture '!';
                  valid a10_val_pmt_type()
              read
              wclose()
              if cPmt_type != account->pmt_type
                do case
                  case cPmt_type = 'O'
                    reclock('Account')
                    account->pmt_type := 'O'
                    account->comment := ' '
                    dbunlock()
                    aDisp[nDisp] = stuff(aDisp[nDisp] ,1 ,19 , ' Other             ')
                    aDisp[nDisp] = stuff(aDisp[nDisp], 50, 1, ' ')
                    @0,57 SAY '        '
                  case cPmt_type = 'Q'
                    wopen(12,21,14,59)
                    setcolor(memvar->white_red)
                    wbox(1)
                    cComm = ' '
                    while cComm != 'N' .and. cComm != 'Y'
                      @0,0 say center('Do we have the cheque ?')
                      nKey = inwait()
                      if nKey = 0
                        cComm = 'N'
                      else
                        cComm = upper(chr(nKey))
                      endif
                    enddo
                    wclose()
                    reclock('Account')
                    account->pmt_type := 'Q'
                    account->comment  := cComm
                    aDisp[nDisp] = stuff(aDisp[nDisp] ,1 ,19 , ' Cheque            ')
                    aDisp[nDisp] = stuff(aDisp[nDisp], 50, 1, Account->comment)
                    aDisp[nDisp] = stuff(aDisp[nDisp], 81, 1, Account->comment)
                    @0,57 say 'H' color memvar->yell_black
                    @0,58  say 'old chq'
                    dbunlock()
                  case cPmt_type = 'D'
                    if empty(student->bank_code) .or. empty(student->bnk_acc_no);
                          .or. empty(student->acc_type)
                      wait_msg(10, 'Student bank details not completed',;
                          'cannot change to debit order',,15)
                    else
                      reclock('Account')
                      account->pmt_type := 'D'
                      account->comment  := ' '
                      dbunlock()
                      aDisp[nDisp] = stuff(aDisp[nDisp] ,1 ,19 , ' Debit order       ')
                      aDisp[nDisp] = stuff(aDisp[nDisp], 50, 1, ' ')
                      aDisp[nDisp] = stuff(aDisp[nDisp], 81, 1, Account->comment)
                      @0,57 say '        '
                    endif
                  case cPmt_type = 'C'
                    reclock('Account')
                    account->pmt_type := 'C'
                    account->comment  := ' '
                    aDisp[nDisp] = stuff(aDisp[nDisp] ,1 ,19 , ' Credit card       ')
                    aDisp[nDisp] = stuff(aDisp[nDisp], 50, 1, ' ')
                    dbunlock()
                    @0,57 say '        '
                endcase
              endif (payment changed)
            endif
        endcase
      else                // payment record exists
        * paid up account
        goto a7_c_recno(aDisp[nDisp]) // go to the record
        do case
          case cChar = 'P'        // change date of payment
            dDt = Account->pmt_dt          // store original date
            wopen(11,11,16,69)
            wbox(1)
            @1,0 say center('WARNING - This will change commission reports')
            @2,10 say 'Enter new date ' get dDt picture '@d'
            read
            wclose()
            if dDt != Account->pmt_dt      // if date has changed
              tts_on()
              select student
              student->fin_pay := ' '       // RESET FINISHED PAYMENT IND
              select account
              cAcc_std = Account->std_code     // store orig details
              nAcc_amt = Account->amount
              dAcc_dt = Account->pmt_dt
              cAcc_pmt_ty= Account->pmt_type
              nVat = Account->vat
              reclock('Account')
              account->comment := 'C'     // mark orig as hidden
              account->explain := 13      // date change
              dbunlock()
              dbappend()
              reclock('Account')      // store reversal as negative
              account->std_code := cAcc_std   // and hidden basically deletes original
              account->type     := cAcc_type
              account->cr_dr    := 'C'
              account->amount   := nAcc_amt * -1
              account->pmt_dt   := dAcc_dt
              account->pmt_type := cAcc_pmt_ty
              account->comment  := 'C'
              account->explain  := 13      // date change
              account->vat      := nVat * -1
              dbunlock()
              dbappend()
              reclock('Account')      // store new record with new date
              account->std_code := cAcc_std
              account->type     := cAcc_type
              account->cr_dr    := 'C'
              account->amount   := nAcc_amt
              account->pmt_dt   := dDt
              account->pmt_type := cAcc_pmt_ty
              account->comment  := ' '
              account->vat      := nVat
              dbunlock()
              select account
              aDisp[nDisp] = stuff(aDisp[nDisp], 66, 8, dtoc(DdT))
              aDisp[nDisp] = stuff(aDisp[nDisp], 90, 8, str(recno(),8,0))
              aDisp[nDisp] = stuff(aDisp[nDisp], 81, 1, Account->comment)
              tts_off()
            endif (date changed)
          case cChar = 'R'            // reverse payment
            *            save screen to cTemp_scr
            if wmake_sure(11,,;
                  'Are you SURE you want to reverse this payment ?')
              aRev_type := {}         // set up pos explanations
              do case             // num - string equivalents
                case account->pmt_type = 'D'       // in smicproc and spec for acc file
                  aadd(aRev_type, rev_n_to_c(1))  // ins funds
                  aadd(aRev_type, rev_n_to_c(2))  // pay stopped
                  aadd(aRev_type, rev_n_to_c(3))  // acc closed
                  aadd(aRev_type, rev_n_to_c(4))  // no such acc
                  aadd(aRev_type, rev_n_to_c(5))  // acc !cleared
                  aadd(aRev_type, rev_n_to_c(6))  // incor acc dets
                  aadd(aRev_type, rev_n_to_c(7))  // incor bank code
                  aadd(aRev_type, rev_n_to_c(8))  // savings acc
                case account->pmt_type = 'Q'
                  aadd(aRev_type, rev_n_to_c(9))  // R.D.
                  aadd(aRev_type, rev_n_to_c(10)) // stopped
                  aadd(aRev_type, rev_n_to_c(11)) // incor bank dets
                  aadd(aRev_type, rev_n_to_c(3))  // acc closed
                  aadd(aRev_type, rev_n_to_c(4))  // no such acc
              endcase
              aadd(aRev_type, rev_n_to_c(12)) // operator error
              nCnt = get_arr(aRev_type)
              nExplain = rev_c_to_n(aRev_type[nCnt])
              tts_on()
              select student
              student->fin_pay := ' '         // RESET STUDENT PAID UP IND
              select account
              cAcc_std = Account->std_code
              nAcc_amt = Account->amount
              dAcc_dt = Account->pmt_dt
              cAcc_pmt_ty= account->pmt_type
              nVat = Account->vat
              if Account->pmt_dt != date() .or. nExplain != 12 // operator error
                reclock('Account')
                nAmount = Account->amount              // mark record as hidden
                account->comment := 'C'
                account->explain := nExplain
                dbunlock()
                dbappend()          // store hidden reversal rec
                reclock('Account')
                account->std_code := cAcc_std
                account->type     := cAcc_type
                account->cr_dr    := 'C'
                account->amount   := nAmount * -1
                account->pmt_dt   := date()
                account->pmt_type := cAcc_pmt_ty
                account->comment  := 'C'
                account->vat      := nVat * -1
                account->explain  := nExplain
                dbunlock()
              else
                select account
                reclock('Account')
                dbdelete()
                dbunlock()
              endif
              aDisp[nDisp] = stuff(aDisp[nDisp], 66, 8, space(8))
              aDisp[nDisp] = stuff(aDisp[nDisp], 90, 8, space(8))
              goto a6_d_recno(aDisp[len(aDisp)])
              dLst_dt = Account->pmt_dt
              dbgoto(a6_d_recno(aDisp[nDisp]))
              do case
                case account->pmt_type = 'C'
                  * DELETE CORRESPONDING DEBIT
                  select account
                  reclock('Account')
                  dbdelete()
                  dbunlock()
                  a9_load_array()
                case account->pmt_type = 'D'
                  reclock('Account')
                  account->comment := ' '
                  wopen(11,21,15,59)
                  setcolor(memvar->black_red)
                  wbox(0)
                  cCh_oth = ' '
                  @0,2 say 'Do you want change payment to'
                  @1,2 say ' ther or leave as  ebit order'
                  @1,2 say 'O' color memvar->red_black
                  @1,20 say 'D' color memvar->red_black
                  while cCh_oth != 'O' .and. cCh_oth != 'D'
                    nKey = inwait()
                    cCh_oth = upper(chr(nKey))
                  enddo
                  wclose()
                  if cCh_oth = 'O'
                    account->pmt_type := 'O'
                  else
                    wopen(11,21,15,59)
                    setcolor(memvar->black_cyan)
                    wbox(1)
                    *                    draw_box(11,21,15,59)
                    cResched = ' '
                    @0,0 say center('Do you want to re-schedule')
                    @1,0 say center('the payment (Y/N)?')
                    while cResched != 'N' .and. cResched != 'Y'
                      nKey = inwait()
                      if nKey = 0
                        cResched = 'N'
                      else
                        cResched = upper(chr(nKey))
                      endif
                    enddo
                    wclose()
                    if cResched = 'Y'
                      account->pmt_dt := et_addmonth(dLst_dt)
                    endif
                  endif
                  dbunlock()
                  a9_load_array()
                case account->pmt_type = 'Q' .or. account->pmt_type = 'E';
                      .or. account->pmt_type = 'I'
                  cComm = wmake_sure(12,,'Can we rebank the cheque ?')
                  reclock('Account')
                  if cComm
                    account->comment := 'Y'
                  else
                    account->comment := 'N'
                  endif
                  dbunlock()
                  aDisp[nDisp] = stuff(aDisp[nDisp], 81, 1, Account->comment)
                case account->pmt_type = 'O'
                  * CHANGE PAYMENT TO UNBANKED
                  reclock('Account')
                  account->comment := ' '
                  dbunlock()
                  aDisp[nDisp] = stuff(aDisp[nDisp], 81, 1, Account->comment)
              endcase
              tts_off()
            endif
        endcase
      endif
    endif
  enddo
end sequence
setkey(-2, NIL)
dbcloseall()
return

* EOF

*******************************************************************************
* FUNCTION A1_PMT_TYPE
*          RETURNS PAYMENT TYPE OF ACCOUNT
*******************************************************************************
static function a1_pmt_type ( cString )
do case
  case substr(cString,2,3) = 'Cre'
    return('C')
  case substr(cString,2,3) = 'Che'
    return('Q')
  case substr(cString,2,3) = 'Deb'
    return('D')
  case substr(cString,2,3) = 'Oth'
    return('O')
endcase
return('?')
* EOF()

*******************************************************************************
* FUNCTION A2_PMT_DT
*          RETURNS AGREED DATE OF PAYMENT
*******************************************************************************
static function a2_pmt_dt ( cString )
local dDate
dDate = substr(cString,20,8)
return(ctod(dDate))
* EOF

*******************************************************************************
* FUNCTION A3_AMOUNT
*          RETURNS AMOUNT OF ACCOUNT
*******************************************************************************
static function a3_amount ( cString )
local cAmount
cAmount = trim(substr(cString,31,13))
return(val(camount))
* EOF

*******************************************************************************
* FUNCTION A4_COMMENT
*          RETURNS COMMENT FIELD OF 'D' REC
*******************************************************************************
static function a4_comment ( cString )
return(substr(cString,81,1))
* EOF

*******************************************************************************
* FUNCTION A6_D_RECNO
*          RETURNS RECORD NO OF 'D' REC
*******************************************************************************
static function a6_d_recno ( cString )
local cRecno
cRecno = trim(substr(cString,82,8))
return(val(cRecno))
* EOF

*******************************************************************************
* FUNCTION A7_C_RECNO
*          RETURNS RECORD NO OF 'C' REC
*******************************************************************************
static function a7_c_recno ( cString )
local nRecno
if len(cString) = 97
  nRecno = trim(substr(cString,90,8))
  if nRecno != space(8)
    return(val(nRecno))
  else
    return(0)
  endif
else
  return(0)
endif
return nil
* EOF

*******************************************************************************
* FUNCTION P8_ARR_UDF
*          USER DEFINED FUNCTION USED TO CONTROL ACHOICE
*          DISPLAYS OPTION ON TOP OF SCREEN AND
*          ALLOWS EXIT ON CORRECT KEYS
*
*******************************************************************************
function p8_arr_udf ( nMode, nInx, nRow )
local cChar, cOrig
memvar yell_black
cChar = upper(chr(lastkey()))
@0,0 clear to 0,79
*cOrig = setcolor()
@0,70 SAY 'Esc' color yell_black
@0,73 SAY 'ape'
nInx = if(nInx > len(memvar->aDisp), len(memvar->aDisp), nInx)
if len(memvar->aDisp) = 0 .or. nInx = 0
  return(1)
endif
if a7_c_recno(memvar->aDisp[nInx]) = 0
  @0,1 SAY 'D' color yell_black
  @0,10 SAY 'A' color yell_black
  @0,20 SAY 'P' color yell_black
  @0,36 SAY 'E' color yell_black
  @0,73 SAY 'ape'
  @0,2 SAY 'ate'
  @0,11 SAY 'mount'
  @0,21 SAY 'ayment type'
  @0,35 SAY 'd'
  @0,37 SAY 'lete'
  if a1_pmt_type(memvar->aDisp[nInx]) = 'Q' .or.;
        a1_pmt_type(memvar->aDisp[nInx]) = 'E'
    @0,57 say 'H' color yell_black
    @0,58 say 'old chq'
  endif
  if (((a1_pmt_type(memvar->aDisp[nInx]) = 'Q' .or.;
        a1_pmt_type(memvar->aDisp[nInx]) = 'E');
        .and. a4_comment(memvar->aDisp[nInx]) = 'Y');
        .or. a1_pmt_type(memvar->aDisp[nInx]) = 'O' .or.;
        a1_pmt_type(memvar->aDisp[nInx]) = 'C');
        .and. a2_pmt_dt(memvar->aDisp[nInx]) <= date()
    @0,46 say 'B' color yell_black
    @0,47 say 'ank'
  endif
else
  @0,1 SAY 'P' color yell_black
  @0,2 SAY 'aid on date'
  @0,35 SAY 'R' color yell_black
  @0,36 SAY 'everse payment'
endif
*setcolor(cOrig)
do case
  case nMode = 2 .and. lastkey() = K_DOWN
    return(1)
  case nMode = 3
    do case
      case lastkey() = K_ESC
        return(0)
      case lastkey() = K_INS
        return(1)
      case lastkey() = K_DEL
        return(1)
      case a7_c_recno(memvar->aDisp[nInx]) = 0
        do case
          case cChar = 'D'
            return(1)
          case cChar = 'A'
            return(1)
          case cChar = 'P'
            return(1)
          case cChar = 'E'
            return(1)
          case cChar = 'H'
            if a1_pmt_type(memvar->aDisp[nInx]) = 'Q' .or.;
                  a1_pmt_type(memvar->aDisp[nInx]) = 'E'
              return(1)
            else
              return(2)
            endif
          case cChar = 'B'
            if (((a1_pmt_type(memvar->aDisp[nInx]) = 'Q' .or.;
                  a1_pmt_type(memvar->aDisp[nInx]) = 'E');
                  .and. a4_comment(memvar->aDisp[nInx]) = 'Y');
                  .or. a1_pmt_type(memvar->aDisp[nInx]) = 'O' .or.;
                  a1_pmt_type(memvar->aDisp[nInx]) = 'C');
                  .and. a2_pmt_dt(memvar->aDisp[nInx]) <= date()
              return(1)
            else
              return(2)
            endif
          otherwise
            return(2)
        endcase
      otherwise
        do case
          case cChar = 'P'
            return(1)
          case cChar = 'R'
            return(1)
        endcase
    endcase
    *
  otherwise
    return(2)
endcase
return(2)

* EOF

*******************************************************************************
*
* FUNCTION A9_LOAD_ARRAY - LOADS ACCOUNT INFO INTO ARRAY
*
*******************************************************************************
procedure a9_load_array
local nCnt, lFnd, nNtx
memvar aDisp
asize(aDisp, 0)
select account
dbseek(student->std_code + memvar->cAcc_type)
while student->std_code = account->std_code .and.;
      account->type = memvar->cAcc_type .and. !eof()
  if account->cr_dr = 'D'
    aadd(aDisp, '')
    nNtx = len(aDisp)                   // Number of fields in array
    aDisp[nNtx] = ' ' + str_type(account->pmt_type) + '      '
    aDisp[nNtx] += dtoc(account->pmt_dt) + '   ' +;
        str(account->amount,13,2) + '      '
    if account->pmt_type = 'Q' .and. account->comment != 'B'
      aDisp[nNtx] += account->comment
    else
      aDisp[nNtx] += ' '
    endif
    aDisp[nNtx] += space(30) + account->comment + str(recno(),8,0) + space(8)
  endif
  dbskip()
enddo
dbseek(student->std_code + memvar->cAcc_type)
while student->std_code = account->std_code .and.;
      account->type = memvar->cAcc_type .and. !eof()
  if account->cr_dr = 'C' .and. account->comment != 'C'
    nCnt = 1
    while nCnt <= len(aDisp)
      if account->amount + account->vat = A3_AMOUNT(aDisp[nCnt]) .and.;
            account->pmt_type = A1_PMT_TYPE(aDisp[nCnt]) .and.;
            a7_c_recno(aDisp[nCnt]) = 0 .and. a4_comment(aDisp[nCnt]) = 'B'
        aDisp[nCnt] = stuff(aDisp[nCnt], 66, 8, dtoc(account->pmt_dt))
        aDisp[nCnt] = stuff(aDisp[nCnt], 90, 8, str(recno(),8,0))
        exit
      endif
      nCnt++
    enddo
  endif
  dbskip()
enddo
return
* EOF

*********************************************************************
function a10_val_pmt_type
local cName, cVal
cName = readvar()
cVal = &cName
@maxrow()-1,0 clear
if !(cVal $ 'DOQC')
  @maxrow()-1,0 say center("Payment type must be 'C'redit card, che'Q'ue,")
  @maxrow(),0 say center("'D'ebit order or 'O'ther")
  return(.f.)
endif
return(.t.)

* eof - a10_val_pmt_type


*********************************************************************
function a11_val_pmt_dt
local cName, dVal
cName = readvar()
dVal = &cName
@maxrow(),0 clear
if empty(dVal)
  @maxrow(),0 say center("Payment date must be entered")
  return(.f.)
endif
return(.t.)

* eof - a11_val_pmt_dt

*********************************************************************
function a12_pay_hist
local cSect, aPays := {}, nTop, nBott, nRow, nCnt, nKey
cSect = savesector(5,0,24,79)
@5,0 clear to 24,79
select account
dbseek(student->std_code + memvar->cAcc_type)
while student->std_code = account->std_code .and.;
      account->type = memvar->cAcc_type .and. !eof()
  if account->cr_dr = 'C'
    aadd(aPays, str_type(account->pmt_type) + '  ' + dtoc(account->pmt_dt);
        + str(account->amount,14,2) + '  ')
    if account->comment = 'C'
      aPays[len(aPays)] += rev_n_to_c(account->explain)
    else
      aPays[len(aPays)] += 'COURSE PAYMENT'
    endif
  endif
  dbskip()
enddo
nTop = 1
for nCnt = 1 to len(aPays)
  if nCnt > 17
    exit
  endif
  @5+nCnt,0 say aPays[nCnt]
next
nBott = nCnt
while nKey != 27
  if nBott < len(aPays)
    @23,60 say 'More '
  else
    @23,60 say '      '
  endif
  if nTop != 1
    @5,60 say 'More '
  else
    @5,60 say '      '
  endif
  nKey = inwait()
  if nKey = 24 .and. nBott < len(aPays)
    nBott++
    nTop++
    scroll(6,0,22,79,1)
    @22,0 say aPays[nBott]
  endif
  if nKey = 5 .and. nTop != 1
    nBott--
    nTop--
    scroll(6,0,22,79,-1)
    @6,0 say aPays[nTop]
  endif
enddo
restsector(cSect)
return nil
* eof - a12_pay_hist

*******************************************************************************
procedure get_cheque
local cBank_code, cBank_acc, getlist := {}
wopen(16,20,22,60)
setcolor(memvar->blue_cyan)
wbox(1)
select student
@0,0 say center('Cheque details')
cBank_code := student->bank_code
cBank_acc := student->bnk_acc_no
@1,2 say 'Bank code  ' get cBank_code
@2,2 say 'Account no ' get cBank_acc
@maxrow(),0 say center('Press Esc to quit')
read
reclock('Student')
student->bank_code := cBank_code
student->bnk_acc_no := cBank_acc
student->acc_type := '1'
wclose()
return

*******************************************************************************
procedure get_credit
local cBank_code, cBank_acc, getlist := {}
wopen(16,20,22,60)
setcolor(memvar->blue_cyan)
wbox(1)
select student
@0,0 say center('Credit card details')
cBank_code := student->bank_code
cBank_acc := student->bnk_acc_no
@1,2 say 'Expiry date ' get cBank_code picture '99/99'
@2,2 say 'Card no     ' get cBank_acc picture '9999/9999/9999/9999'
@maxrow(),0 say center('Press Esc to quit')
read
reclock('Student')
student->bank_code := cBank_code
student->bnk_acc_no := cBank_acc
student->acc_type := '1'
wclose()
return

