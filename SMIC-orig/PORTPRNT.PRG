*******************************************************************************
* PROGRAM 'PORTPRNT' PRINT STUDENT PORTFOLIOS
* AUTHOR JIM WEST
* 19/2/88

local nWeeks_to_move, mMessage, nJse_index, nArea_cnt, lProc_std
local cP_addr1, cP_addr2, cP_addr3, cP_code, cPhone_no, cTwin_cont
local cStd_code, nLec, cLec, lTraded, lPrt_lec, nWork, nWork1, nTemp
local cLec_cd, nCnt, nPcnt, cLine, cGrp_store, cGrp_no, nRec, cTitle
local nValue, nProfit, nSum_len, nTot_cash, nTot_val, nTot_profit
local nLast_pr, nPerc_prof, nTot_cost, nBr_cover, nBr_sell, nBr_buy, nBr_prof
local nBrokerage, nHandle, nMst, nStd_perc, nMark_perf, nPort_val, nPerform
local nT1, nT2
local aStru

memvar force_bw, force_prfile, nCurr_std, nPrint_std

#include 'defcolor.ch'
#include 'defprint.ch'
#include 'ctnnet.ch'

private force_bw := .f., force_prfile := .f., nTime_out := 10000
private nCurr_std := 0, nPrint_std := 0

#include "colour.ch"
#include "printer.ch"
#include "smic.ch"

set deleted on
set date british

security(procname())

simhead(memvar->pscr_title)
begin sequence
  
  if !make_sure(10,10,'Are you REALLY sure you want to print the students portfolios ')
    break
  endif
  
  while !net_use('student', .t.,)
    @23,10 say 'WAITING FOR STUDENT FILE'
    break
  enddo
  @22,0 clear
  rem_tts('Stdactiv.ntx')
  index on str(student->wk_smltn,3,0) + student->group_cd + Student->group_no;
      + substr(student->surname,1,10) to stdactiv
  dbclosearea()
  @21,10 say 'Finished indexing'
  
  select 9
  if !net_use('param', .f.)
    break
  endif
  
  cP_addr1       = param->p_addr1
  cP_addr2       = param->p_addr2
  cP_addr3       = param->p_addr3
  cP_code        = param->p_code
  cPhone_no      = trim(param->phone_no)
  cTwin_cont     = trim(param->twin_cont)
  nWeeks_to_move = 2                    // default move for first time
  if !empty(param->lst_portpr)          // if not empty
    nT1 = week(param->lst_portpr)       // week number
    nT2 = week(date())
    if nT2 < nT1                        // over year end
      nT2 += 52
    endif
    nWeeks_to_move = nT2 - nT1
  endif
  mMessage       = param->message
  dbclosearea()
  
  if memvar->pLst_f_updt = date()
    do futprnt
  endif
  
  @4,0 clear
  @6,10 say 'STUDENT PORTFOLIO PRINTOUT IN PROGRESS'
  
  select 6
  while !net_use('student', .t.,, 'stdactiv')
    @23,10 say 'WAITING FOR STUDENT FILE'
  enddo
  @22,0 clear
  
  select 1
  while !net_use('transact', .t.,, 'trancode')
    @23,0 say 'WAITING FOR TRANSACTION FILE'
  enddo
  @22,0 clear
  
  select 2
  while !net_use('share', .t.,, 'shrname')
    @23,10 say 'WAITING FOR SHARE FILE'
  enddo
  @22,0 clear
  
  select 3
  while !net_use('trnstore', .t.)
    @23,10 say 'WAITING FOR TRANSACTION STORAGE FILE'
  enddo
  @22,0 clear
  
  select 4
  while !net_use('portfol', .t.,, 'portfol')
    @23,10 say 'WAITING FOR THE PORTFOLIO FILE'
  enddo
  @22,0 clear
  
  select 5
  while !net_use('shrdescr', .t.,, 'shrdescr')
    @23,10 say 'WAITING FOR THE SHARE COMMENT FILE'
  enddo
  @22,0 clear
  
  select 8
  while !net_use('bear', .t.,, 'bear')
    @23,10 say 'WAITING FOR THE BEAR FILE'
  enddo
  @22,0 clear
  
  select share
  dbseek('JSE-OVER')
  nJse_index = share->price
  
  nArea_cnt = 0
  while nArea_cnt < 4
    nArea_cnt++
    @8,0 clear
    do case
      case nArea_cnt = 1
        set alternate to dport.txt
        @10,10 say 'Durban printout in progress'
      case nArea_cnt = 2
        set alternate to cport.txt
        @10,10 say 'Cape Town printout in progress'
      case nArea_cnt = 3
        set alternate to staff.txt
        @10,10 say 'Staff printout in progress'
      case nArea_cnt = 4
        set alternate to jport.txt
        @10,10 say 'Johannesburg printout in progress'
    endcase
    set alternate on
    set consol off
    select student
    dbgotop()
    while !eof()
      lProc_std = .F.
      do case
        case (Student->p_code > '2899' .and. Student->p_code < '4700')
          if nArea_cnt = 1 .and. Student->group_no = '01'
            lProc_std = .t.
          endif
        case (Student->p_code > '6699' .and. Student->p_code < '8300')
          if nArea_cnt = 2 .and. Student->group_no = '01'
            lProc_std = .t.
          endif
        case Student->p_code = 'QQQQ'
          if nArea_cnt = 3 .and. Student->group_no = '01'
            lProc_std = .t.
          endif
        otherwise
          if nArea_cnt = 4 .and. Student->group_no = '01'
            lProc_std = .t.
          endif
      endcase
      cStd_code = Student->std_code
      if !empty(Student->sold_els)
        if date() - student->lst_portpr < 28    // only send monthly prints
          lProc_std = .f.
        endif
      endif
      if Student->lec_stat = 'N' .or. Student->lec_stat = 'A'
        if date() - student->lst_portpr < 28    // only send monthly prints
          lProc_std = .f.
        endif
      endif
      if Student->status = 'C' .and. lProc_std
        lTraded = .f.
        if !empty(Student->sold_els)
          do case
            case Student->wk_smltn < 5 .and. student->lec3 != 'Y'
              cLec = 'lec3'
              student->lec3 := 'Y'
              nLec = 3
            case Student->wk_smltn < 9 .and. student->lec4 != 'Y'
              cLec = 'lec4'
              student->lec4 := 'Y'
              nLec = 4
            case Student->wk_smltn < 13 .and. student->lec5 != 'Y'
              cLec = 'lec5'
              student->lec5 := 'Y'
              nLec = 5
            case Student->wk_smltn < 17 .and. student->lec7 != 'Y'
              cLec = 'lec7'
              student->lec7 := 'Y'
              nLec = 7
          endcase
          lPrt_lec = .t.
        else
          nWork = (Student->wk_smltn + 1) / 2
          nWork1 = nWork - int(nWork)
          nLec = (Student->wk_smltn + 5) / 2
          lPrt_lec = .f.
          cLec_cd = ''
          for nTemp = 1 to nLec
            if nTemp > 20
              exit
            endif
            cLec = 'student->lec' + ltrim(str(nTemp,2,0))
            if nWork1 = 0 .and. &cLec = 'P'
              &cLec := 'Y'
              lPrt_lec = .t.
              cLec_cd += 'LEC ' + ltrim(str(nTemp,2,0)) + '    '
            endif
          next
        endif
        if Student->p_code != 'QQQQ'
          if lPrt_lec
            ? cLec_cd
          endif
          cLine = trim(Student->title) + ' ' + substr(Student->name,1,1) +;
              ' ' + Student->surname + replicate(' ',30)
          nPcnt = 1
          ? ' '
          ? space(65) + 'R S A'
          ? space(61) + 'POSTAGE PAID'
          for nPcnt = 1 to 14
            ? ' '
          next
          ? space(9) + cLine
          ? space(9) + Student->address1
          ? space(9) + Student->address2
          ? space(9) + Student->address3
          ? space(9) + Student->p_code
          ? ' '
          for nPcnt = 1 to 15
            ? ' '
          next
          nCnt = mlcount(mMessage, 60)
          for nPcnt = 1 to nCnt
            ? space(5) + memoline(mMessage, 60, nPcnt)
          next
          for nPcnt = nCnt + 1 to 14
            ? ' '
          next
          ? '     From ' + memvar->cCo_name
          ? '     ' + cP_addr1
          ? '     ' + cP_addr2
          ? '     ' + cP_code + ' ' + cP_addr3
          ? ' '
          ? '     Telephone ' + cPhone_no
          * Page Throw
          jw_eject()
        endif
        cGrp_store = Student->group_cd
        nRec = recno()
        cGrp_no = '  '
        memvar->pLine = 70
        memvar->pPage = 0
        while cGrp_store = Student->group_cd .and. cGrp_no != '01' .and. !eof()
          cTitle = 'PORTFOLIO PRINTOUT FOR ' + trim(Student->title) + ' ';
              + trim(Student->name) + ' ' + trim(Student->surname) + ' week';
              + str(Student->wk_smltn)
          if memvar->pPage != 0
            ? ' '
            ? ' '
            ? cTitle + memvar->pr_comp_of
            ? ' '
            memvar->pLine += 4
          endif
          cStd_code = Student->std_code
          @12,0 clear
          @12,10 say trim(Student->title) + ' ' + trim(Student->name) +;
              ' ' + trim(Student->surname)
          @14,10 say 'Week no ' + ltrim(str(Student->wk_smltn,3,0))
          nPrint_std++
          @16,10 say 'Approx % students processed = ' +;
              str((nPrint_std/nCurr_std*100),3,0) + '%'
          if (Student->wk_smltn) >= Student->simln_len
            student->status    := 'F'
            student->last_tran := date()
            select transact
            dbappend()
            transact->std_code := cStd_code
            transact->type     := 'T'
            transact->trn_type := 'FIN'
            transact->qty      := nJse_index
            transact->trn_dt   := date()
            select student
          endif
          select transact
          dbseek(cStd_code + 'T')
          while transact->std_code = cStd_code .and. transact->type = 'T';
                .and. !eof()
            do case
              case transact->trn_type = 'BF '   // BROUGHT FORWARD
                if pLine > 60
                  prntitle(cTitle,'N')
                endif
                ? 'CASH AVAILABLE AT THE WEEK START = ' + str(transact->value)
                ? memvar->pr_comp_of
                memvar->pLine += 3
                ? ' '
              case transact->trn_type = 'BUY'   // BUY SHARES
                lTraded = .T.
                if pLine > 41
                  prntitle(cTitle,'N')
                endif
                select shrdescr
                dbseek(transact->share)
                select share
                dbseek(transact->share)
                ?? memvar->pr_comp_of
                ? 'PURCHASE OF SHARES ON ' + dtoc(transact->trn_dt)
                ? ' '
                ? ltrim(str(transact->qty,8,0)) , trim(share->full_name) ,;
                    'at' , ltrim(str((transact->price * 100),14,0)) , 'cents/share'
                ? '     SECTOR : ' + shrdescr->sector
                ? ' '
                ?? memvar->pr_compres
                ? replicate('-',101)
                ? ' NO OF SHARES     PRICE PAID      BROKERAGE       HANDLING            TAX    TOTAL COST     AVE. COST'
                ? ' '
                select transact
                nValue = transact->value * -1
                ? '    '+ str(transact->qty) + '  ' + str(transact->price) +;
                    ' ' + str(transact->brokerage) + ' ' + str(transact->handle);
                    + ' ' + str(transact->tax) + '  ' + str(nValue,12,2) +;
                    '  ' + str((nValue / transact->qty),12,2)
                ? replicate('-',101)
                ?? memvar->pr_comp_of
                ? 'TIMING SIGNAL - BUY    Close ' + ltrim(str(share->y_cl_pr));
                    + 'c'
                ? shrdescr->buy_1
                ? shrdescr->buy_2
                ? ' '
                ? 'COMPANY BACKGROUND'
                ? shrdescr->fundamnt_1
                ? shrdescr->fundamnt_2
                ? shrdescr->fundamnt_3
                ? shrdescr->fundamnt_4
                ? shrdescr->fundamnt_5
                ? shrdescr->fundamnt_6
                ? shrdescr->fundamnt_7
                ? shrdescr->fundamnt_8
                ?? memvar->pr_comp_of
                ? ' '
                memvar->pLine += 24
                select share
              case transact->trn_type = 'SEL'   // SELL SHARES
                lTraded = .t.
                if memvar->pLine > 48
                  prntitle(cTitle,'N')
                endif
                select shrdescr
                dbseek(transact->share)
                select share
                dbseek(transact->share)
                ?? pr_comp_of
                ? 'SALE OF SHARES ON ' + dtoc(transact->trn_dt)
                ? ' '
                ? ltrim(str(transact->qty,8,0)) , trim(share->full_name) ,;
                    'at' , ltrim(str((transact->price * 100),14,0)) ,;
                    'cents/share'
                ? '     SECTOR : ' + shrdescr->sector
                ? ' '
                ?? memvar->pr_compres
                ? replicate('-',119)
                ? ' NO OF SHARES     PRICE RCVD      BROKERAGE       HANDLING    TOTAL VALUE     AVE.VALUE    RLSD GAIN/LOSS      % PROFIT'
                ? ' '
                select transact
                nProfit = transact->value - transact->cost_hold
                ? '    ',transact->qty, transact->price, transact->brokerage,;
                    transact->handle, transact->value,;
                    (transact->value / transact->qty),'   ', nProfit
                if transact->cost_hold != 0
                  ?? ' ' + str((nProfit / transact->cost_hold) * 100,13,2)
                endif
                ? replicate('-',119)
                ? ' '
                ?? memvar->pr_comp_of
                ? 'TIMING SIGNAL - SELL    Close ' + ltrim(str(share->y_cl_pr));
                    + 'c'
                ? shrdescr->sell_1
                ? shrdescr->sell_2
                ? ' '
                ? ' '
                memvar->pLine += 16
                select share
              case transact->trn_type = 'SSL'   // BEAR SALE
                lTraded = .t.
                if memvar->pLine > 40
                  prntitle(cTitle,'N')
                endif
                select shrdescr
                dbseek(transact->share)
                select share
                dbseek(transact->share)
                ?? memvar->pr_comp_of
                ? 'SHORT SALE OF SHARES ON ' + dtoc(transact->trn_dt)
                ? ' '
                ? ltrim(str(transact->qty,8,0)) , trim(share->full_name) ,;
                    'at' , ltrim(str((transact->price * 100),14,0)) ,;
                    'cents/share'
                ? '     SECTOR : ' + shrdescr->sector
                ? ' '
                ?? memvar->pr_compres
                ? replicate('-',120)
                ? ' NO OF SHARES     PRICE RCVD      BROKERAGE       HANDLING    TOTAL VALUE     AVE.VALUE         COVER HELD     AVE COVER'
                ? ' '
                select transact
                ? '    ',transact->qty, transact->price, transact->brokerage,;
                    transact->handle, transact->value,;
                    (transact->value / transact->qty), '   ', transact->cost_hold,;
                    (transact->cost_hold / transact->qty)
                ? replicate('-',120)
                ? ' '
                ?? memvar->pr_comp_of
                ? 'TIMING SIGNAL - SELL'
                ? shrdescr->sell_1
                ? shrdescr->sell_2
                ? ' '
                ? 'COMPANY BACKGROUND'
                ? shrdescr->fundamnt_1
                ? shrdescr->fundamnt_2
                ? shrdescr->fundamnt_3
                ? shrdescr->fundamnt_4
                ? shrdescr->fundamnt_5
                ? shrdescr->fundamnt_6
                ? shrdescr->fundamnt_7
                ? shrdescr->fundamnt_8
                ?? memvar->pr_comp_of
                ? ' '
                pLine += 25
                select share
              case transact->trn_type = 'SDV'   // DELIVERY OF BEAR SALE
                lTraded = .t.
                if memvar->pLine > 50
                  prntitle(cTitle,'N')
                endif
                select shrdescr
                dbseek(transact->share)
                select share
                dbseek(transact->share)
                ?? memvar->pr_comp_of
                ? 'DELIVERY OF SHORT SOLD SHARES ON ' + dtoc(transact->trn_dt)
                ? ' '
                ? ltrim(str(transact->qty,8,0)) , trim(share->full_name) ,;
                    'at' , ltrim(str((transact->price * 100),14,0)) , 'cents/share'
                ? '     SECTOR : ' + shrdescr->sector
                ? ' '
                ?? memvar->pr_compres
                ? replicate('-',131)
                ? ' NO OF SHARES     PRICE PAID      BROKERAGE       HANDLING            TAX    TOTAL COST     SELL VALUE    DIFFERENCE      % PROFIT'
                ? ' '
                select transact
                nValue = transact->value * -1
                ? '    ', transact->qty, transact->price, transact->brokerage,;
                    transact->handle, transact->tax, nValue, transact->cost_hold,;
                    (transact->cost_hold - nValue),;
                    ((transact->cost_hold - nValue)/transact->cost_hold)*100
                ? replicate('-',131)
                ?? memvar->pr_comp_of
                ? 'TIMING SIGNAL - BUY'
                ? shrdescr->buy_1
                ? shrdescr->buy_2
                ? ' '
                ? ' '
                memvar->pLine += 15
                select share
              case transact->trn_type = 'FDV'   // FORCED DELIVERY OF BEAR SALE
                lTraded = .t.
                if memvar->pLine > 50
                  prntitle(cTitle,'N')
                endif
                select shrdescr
                dbseek(transact->share)
                select share
                dbseek(transact->share)
                ?? pr_comp_of
                ? 'FORCED DELIVERY OF SHORT SOLD SHARES ON ' +;
                    dtoc(transact->trn_dt)
                ? ' '
                ? ltrim(str(transact->qty,8,0)) , trim(share->full_name) ,;
                    'at' , ltrim(str((transact->price * 100),14,0)) , 'cents/share'
                ? '     SECTOR : ' + shrdescr->sector
                ? ' '
                ?? pr_compres
                ? replicate('-',131)
                ? ' NO OF SHARES     PRICE PAID      BROKERAGE       HANDLING            TAX    TOTAL COST     SELL VALUE    DIFFERENCE      % PROFIT'
                ? ' '
                select transact
                nValue = transact->value * -1
                ? '    ', transact->qty, transact->price, transact->brokerage,;
                    transact->handle, transact->tax, nValue, transact->cost_hold,;
                    (transact->cost_hold - nValue),;
                    ((transact->cost_hold - nValue)/transact->cost_hold)*100
                ? replicate('-',131)
                ? memvar->pr_comp_of
                ? 'This share was bought on your behalf as your delivery date has expired'
                ? 'and you are required to deliver the shares.'
                ? ' '
                ? ' '
                pLine += 15
                select share
              case transact->trn_type = 'DIV'   // DIVIDEND
                if pLine > 55
                  prntitle(cTitle,'N')
                endif
                select share
                dbseek(transact->share)
                ?? pr_comp_of
                ? 'DIVIDEND RECIEVED THIS WEEK'
                ? ' '
                ? 'DIVIDEND FROM ', share->full_name
                ? ' '
                ? 'NO OF SHARES     DIVIDEND PER SHARE     VALUE OF DIVIDEND'
                select transact
                ? '   ',transact->qty, ' ', transact->price, 'CENTS       ',;
                    transact->value
                ? ' '
                ? ' '
                ? ' '
                pLine += 9
              case transact->trn_type = 'NEX'   // RIGHTS OPTIONS EXERCISED
                lTraded = .t.
                if pLine > 55
                  prntitle(cTitle,'N')
                endif
                select share
                dbseek(transact->share)
                ?? memvar->pr_comp_of
                ? 'RIGHTS OPTION EXERCISED ON ' + dtoc(transact->trn_dt)
                ? ' '
                ? 'OPTION EXCERCISED ON ', share->full_name
                ? ' '
                ? 'NO OF SHARES           OPTION PRICE      VALUE OF TRANSACTION'
                select transact
                ? '   ', transact->qty,'    ', (transact->price*100),;
                    'c     ', transact->value * (-1)
                ? ' '
                ? ' '
                ? ' '
                memvar->pLine += 9
              case transact->trn_type = 'NLP'   // RIGHTS OPTIONS ABANDONED
                if pLine > 55
                  prntitle(cTitle,'N')
                endif
                select share
                dbseek(transact->share)
                ?? pr_comp_of
                ? 'RIGHTS OPTION ABANDONED ON ' + dtoc(transact->trn_dt)
                ? ' '
                ? 'OPTION ABANDONED ON ', share->full_name
                ? ' '
                ? 'NO OF SHARES           OPTION PRICE      VALUE ABANDONED (LOST)'
                select transact
                ? '   ', transact->qty, '    ', transact->price, '      ',;
                    transact->value
                ? ' '
                ? ' '
                ? ' '
                pLine += 9
              case transact->trn_type = 'INT'    // INTEREST
                if pLine > 58
                  prntitle(cTitle,'N')
                endif
                ?? pr_comp_of
                ? 'INTEREST ON CASH ON HAND AS AT ' + dtoc(transact->trn_dt)
                ? ' '
                ? 'RATE OF INTEREST    CASH ON HAND   INTEREST PAID TO YOU'
                ? '  ', (transact->qty / 100), '', transact->price, '       ',;
                    transact->value
                ? ' '
                ? ' '
                pLine += 6
              case transact->trn_type = 'OVD'   // OVERDRAFT INTEREST
                if pLine > 57
                  prntitle(cTitle,'N')
                endif
                ?? pr_comp_of
                ? 'INTEREST ON OVERDRAFT AS AT ' + dtoc(transact->trn_dt)
                ? ' '
                ? 'INTEREST ON OVERDRAFT'
                ? ' '
                ? 'RATE OF INTEREST    AMOUNT OVERDRAWN   INTEREST PAID BY YOU'
                ? '  ', (transact->qty / 100), '    ', (transact->price*-1),;
                    '       ',(transact->value*-1)
                ? ' '
                ? ' '
                pLine += 8
              case transact->trn_type = 'SIN'   // INTEREST ON COVER FOR BEAR SALES
                if pLine > 57
                  prntitle(cTitle,'N')
                endif
                select share
                dbseek(transact->share)
                ?? pr_comp_of
                ? 'INTEREST ON COVER HELD AS AT ' + dtoc(transact->trn_dt)
                ? ' '
                ? 'COVER HELD FOR ', share->full_name
                ? ' '
                select transact
                ? 'RATE OF INTEREST    COVER HELD     INTEREST PAID TO YOU'
                ? '  ',(transact->qty / 100), '', transact->price, '       ',;
                    transact->value
                ? ' '
                ? ' '
                pLine += 8
              case transact->trn_type = 'SCV'   // EXTRA COVER REQUIRED
                if pLine > 57
                  prntitle(cTitle,'N')
                endif
                select share
                dbseek(transact->share)
                ?? pr_comp_of
                ? 'EXTRA COVER REQUIRED FOR SHORT SALE ON ' + dtoc(transact->trn_dt)
                ? ' '
                ? 'COVER REQUIRED FOR  ', share->full_name
                ? ' '
                select transact
                ? 'ORIGINAL COVER    EXTRA COVER     SHARES SHORT SOLD    CURRENT PRICE'
                ? transact->cost_hold, transact->value, '     ' , transact->qty,;
                    '    ', transact->price
                ? ' '
                ? ' '
                pLine += 8
              case transact->trn_type = 'NRC'   // NPL's recieved
                lTraded = .t.
                if pLine > 49
                  prntitle(cTitle,'N')
                endif
                select shrdescr
                dbseek(transact->share)
                select share
                dbseek(transact->share)
                ?? pr_comp_of
                ? 'Options/Nil Paid Letters recieved on ' + dtoc(transact->trn_dt)
                ? ' '
                ? "OPTIONS/NPL's RECIEVED  ", share->full_name
                ? ' '
                select transact
                ? 'OPTIONS RECIEVED        PRICE TO BE EXERCISED AT'
                ? '     ' , transact->qty, '    ', transact->price
                ? ' '
                ? shrdescr->FUNDAMNT_1
                ? shrdescr->FUNDAMNT_2
                ? shrdescr->FUNDAMNT_3
                ? shrdescr->FUNDAMNT_4
                ? shrdescr->FUNDAMNT_5
                ? shrdescr->FUNDAMNT_6
                ? shrdescr->FUNDAMNT_7
                ? shrdescr->FUNDAMNT_8
                ?? pr_comp_of
                ? ' '
                ? ' '
                pLine += 17
                select transact
              case transact->trn_type = 'MBK'   // MONEY BACK ON UNTRADABLE SHARES
                if pLine > 54
                  prntitle(cTitle,'N')
                endif
                ?? pr_comp_of
                ? 'MONEY RETURNED ON UNTRADEABLE SHARES ON ' +;
                    dtoc(transact->trn_dt)
                ? ' '
                ? 'MONEY RETURNED ON '+ transact->share
                ? ' '
                ? 'NO OF SHARES                  PRICE      VALUE RETURNED TO CASH'
                select transact
                ? '   ', transact->qty,'      ', transact->price,'      ',;
                    transact->value
                ? ' '
                ? 'In view of the restructuring of the company and as it is no longer trading'
                ? 'you have been refunded your investment at the last market price.'
                ? ' '
                ? ' '
                pLine += 11
            endcase
            select transact
            if student->status != 'F'
              if transact->trn_type != 'BF ' .and. transact->trn_type != 'INT'
                select trnstore
                dbappend()
                trnstore->std_code  := transact->std_code
                trnstore->share     := transact->share
                trnstore->trn_type  := transact->trn_type
                trnstore->qty       := transact->qty
                trnstore->price     := transact->price
                trnstore->brokerage := transact->brokerage
                trnstore->tax       := transact->tax
                trnstore->handle    := transact->handle
                trnstore->value     := transact->value
                trnstore->trn_dt    := transact->trn_dt
                trnstore->cost_hold := transact->cost_hold
              endif
              select transact
              dbdelete()
            endif
            select transact
            dbskip()
          enddo (std_code = cStd_code)
          * CHECK TRN TOTAL = CASH
          dbappend()
          transact->std_code := cStd_code
          transact->type     := 'T'
          transact->trn_type := 'BF '
          transact->value    := student->cash
          transact->trn_dt   := date()
          select student
          reclock()
          student->lst_portpr := date()
          dbunlock()
          dbskip()
          cGrp_no = Student->group_no
        enddo  (group members)
        dbgoto(nRec)
        
        * PORTFOLIO SUMMARY SECTION
        
        if lTraded
          pLine = 70
        endif
        cGrp_no = '  '
        while cGrp_store = Student->group_cd .and. cGrp_no != '01' .and. !eof()
          cTitle = 'PORTFOLIO PRINTOUT FOR ' + trim(Student->title) + ' ' +;
              trim(Student->name) + ' ' + trim(Student->surname) + ' week';
              + str(Student->wk_smltn)
          cStd_code = Student->std_code
          nSum_len = port_sum_len(cStd_code)
          select portfol
          dbseek(cStd_code + 'T')
          if pLine + nSum_len > 55
            pLine = 50
          else
            pr_line(' ')
            pr_line(' ')
            pr_line(cTitle)
            pr_line(' ')
            pr_line(pr_bold + 'PORTFOLIO SUMMARY' + pr_bold_of + pr_compres)
            pr_line(' ')
            pr_line('             NO OF         COST OF   AVERAGE   CURRENT     CURRENT      %           PROFIT          WKS                    DIVIDEND')
            pr_line('SHARE       SHARES         HOLDING    PRICE     PRICE       VALUE     CHANGE        / LOSS          MOVE%     DIVIDEND       DATE')
            pr_line(replicate('-',132))
          endif
          nTot_cost = 0
          nTot_val = 0
          nTot_profit = 0
          while portfol->std_code = cStd_code .and. portfol->type = 'T';
                .and. !eof()
            if pLine > 45
              prntitle(cTitle,'N')
              pr_line(' ')
              pr_line(pr_bold + 'PORTFOLIO SUMMARY' + pr_bold_of + pr_compres)
              pr_line(' ')
              pr_line('             NO OF         COST OF   AVERAGE   CURRENT     CURRENT      %           PROFIT          WKS                    DIVIDEND')
              pr_line('SHARE       SHARES         HOLDING    PRICE     PRICE       VALUE     CHANGE        / LOSS          MOVE%     DIVIDEND       DATE')
              pr_line(replicate('-',132))
            endif
            select share
            dbseek(portfol->Share)
            select shrdescr
            dbseek(portfol->Share)
            if shrdescr->lst_wk_pr = 0
              shrdescr->lst_wk_pr := share->y_cl_pr
            endif
            nLast_pr = if(shrdescr->lst_wk_pr > 0, shrdescr->lst_wk_pr, 1)
            select share
            nValue = (portfol->qty * share->y_cl_pr / 100)
            cLine = share->share + ' ' + str(portfol->qty) + ' ' +;
                str(portfol->cost_hold) + ' ' +;
                str(portfol->cost_hold/portfol->qty,9,2) + ' ' +;
                str(share->y_cl_pr / 100,9,2) + ' ' + str(nValue,11,2)
            nPerc_prof = 0
            if portfol->cost_hold != 0
              nPerc_prof = (nValue / portfol->cost_hold * 100) - 100
            endif
            cLine += '   ' + str(nPerc_prof,7,2) + ' ' +;
                str(nValue - portfol->cost_hold) + ' ' +;
                str(((share->y_cl_pr/nLast_pr) * 100) - 100)
            if !empty(shrdescr->div_dt) .and. share->suspend != 'N'
              cLine += '      ' + str(shrdescr->dividend) + '      ' +;
                  dtoc(shrdescr->div_dt)
            endif
            pr_line(cLine)
            lTraded = .T.
            nTot_cost += portfol->cost_hold
            nTot_val += nValue
            nTot_profit += nValue - portfol->cost_hold
            select portfol
            dbskip()
          enddo
          pr_line(replicate('-',132))
          pr_line('                     ' + str(nTot_cost) +;
              '                   ' + str(nTot_val) + '           ' +;
              str(nTot_profit))
          pr_line(replicate('-',132))
          
          
          * BEAR SALES
          nBr_cover = 0
          nBr_sell = 0
          nBr_buy = 0
          nBr_prof = 0
          select bear
          if dbseek(cStd_code + 'T')
            if pLine > 40
              prntitle(cTitle, 'N')
            endif
            pr_line(' ')
            pr_line(pr_bold + 'BEAR SALES' + pr_bold_of + pr_compres)
            pr_line('             NO OF          COVER    AVERAGE   CURRENT     SELLING    BUYING       %           PROFIT           WKS       DELIVERY')
            pr_line('SHARE       SHARES           HELD     COVER     PRICE       VALUE      VALUE     CHANGE        / LOSS          MOVE%        DATE')
            pr_line(replicate('-',132))
            while bear->std_code = cStd_code .and. bear->type = 'T' .and. !eof()
              select shrdescr
              dbseek(bear->Share)
              select share
              dbseek(bear->Share)
              nValue = (bear->qty * share->y_cl_pr / 100)
              nBrokerage = broker(nValue)
              nHandle = handle(bear->qty)
              nMst = mst(nValue)
              nValue = nValue + nBrokerage +nHandle + nMst
              cLine = bear->share + ' ' + str(bear->qty) + ' ' +;
                  str(bear->cov_hld) + ' ' + str(bear->cov_hld/bear->qty,9,2);
                  + ' ' + str(share->y_cl_pr / 100,9,2) + ' ' +;
                  str(bear->sell_val,10,2) + ' ' + str(nValue,10,2)
              select shrdescr
              if shrdescr->lst_wk_pr = 0
                shrdescr->lst_wk_pr := share->y_cl_pr
              endif
              select share
              cLine += '    ' + str((bear->sell_val / nValue * 100) - 100,7,2);
                  + ' ' + str(bear->sell_val - nValue,14,2) + ' ' +;
                  str(((share->y_cl_pr/shrdescr->lst_wk_pr) * 100) - 100) +;
                  '     ' + dtoc(bear->deliv_dt)
              pr_line(cLine)
              lTraded = .T.
              nBr_cover += bear->cov_hld
              nBr_sell += bear->sell_val
              nBr_buy += nValue
              nBr_prof += bear->sell_val - nValue
              select bear
              dbskip()
            enddo
            pr_line(replicate('-',132))
            pr_line('                     ' + str(nBr_cover) +;
                '                  ' + str(nBr_sell) + ' ' + str(nBr_buy,10,2) +;
                '            ' + str(nBr_prof,14,2))
            pr_line(replicate('-',132))
          endif
          pr_line(pr_comp_of + ' ')
          pr_line(' ')
          pr_line('PORTFOLIO STATISTICS')
          pr_line('--------------------')
          nPort_val = nTot_val + student->CASH + nBr_cover + nBr_prof
          pr_line('PORTFOLIO VALUE                                     = ' +;
              str(nPort_val,12,2))
          pr_line('CASH ON HAND                                        = ' +;
              str(student->cash,12,2))
          nStd_perc = if(student->initl_val != 0,;
              ((nPort_val / student->initl_val) * 100 ) - 100, 0)
          pr_line('PORTFOLIO PERCENTAGE CHANGE                         = ' +;
              str(nStd_perc,12,2) , '%')
          nMark_perf =((nJse_index / student->start_indx) * 100) - 100
          pr_line('MARKET PERCENTAGE CHANGE - FROM ' +;
              str(student->start_indx,4,0) + ' TO ' + str(nJse_index,4,0);
              + '        = ' + str(nMark_perf,12,2) + '%')
          pr_line('PERFORMANCE VERSUS MARKET                           = ' +;
              str((nStd_perc - nMark_perf),12,2) + '%')
          nPerform = 0
          if student->WEEK_4 != 0
            nPerform = (((nPort_val) / student->week_4) *100) - 100
            pr_line('PERFORMANCE ANNUALISED OVER PREV MONTHS PERFORMANCE = ' +;
                str((nPerform * 12),12,2) + '%')
          endif
          pr_line(' ')
          pr_line(' ')
          select student
          student->week_4     := Student->week_3
          student->week_3     := Student->week_2
          student->week_2     := Student->week_1
          student->week_1     := nPort_val
          student->wk_unact   := Student->wk_unact + 1
          student->perc_chang := nStd_perc
          student->mnth_chang := nPerform * 12
          dbskip()
          cGrp_no = Student->group_no
        enddo
        dbgoto(nRec)
        if student->wk_unact != student->wk_smltn
          lTraded = .t.
        endif
        if !lTraded
          pr_line(' ')
          pr_line(' ')
          pr_line(' ')
          pr_line('We notice that you have not as yet transacted on the electronic T W I N.')
          pr_line('if you wish to make a transaction please phone the club on ' + cPHONE_NO)
          pr_line('between 9.00 a.m. and 4.00 p.m. on weekdays and ask for ' + cTWIN_CONT + '.')
        endif
        select student
        if Student->lec_stat = ' '
          if Student->wk_unact > 11
            student->lec_stat := 'A'
            pr_line(' ')
            pr_line('We notice that you have not traded on the electronic T W I N for three')
            pr_line('months. We will be sending your course material once a month from now on.')
            pr_line('if you phone us us and request it we will be glad to resume sending you')
            pr_line('your porfolio on a weekly basis.')
          endif
        endif
        jw_eject()
        * THIS EJECT IS NECCESSARY AS NO PAGE THROW OCCURS ON PAGE 1
      ENDif (STATUS = 'C')
      select student
      dbskip()
    ENDDO (SERIAL READ THROUGH STUDENT FILE)
    pr_line(' ')
    pr_line(' ')
    pr_line(' ')
    pr_line('        THIS IS THE LAST PAGE OF THE STUDENT PRINT RUN')
    pr_line(' ')
    pr_line(' ')
    pr_line(' ')
    pr_line('        THIS IS THE LAST PAGE OF THE STUDENT PRINT RUN')
    pr_line(' ')
    pr_line(' ')
    pr_line(' ')
    pr_line('        THIS IS THE LAST PAGE OF THE STUDENT PRINT RUN')
    pr_line(' ')
    pr_line(' ')
    pr_line(' ')
    pr_line('        THIS IS THE LAST PAGE OF THE STUDENT PRINT RUN')
    pr_line(' ')
    pr_line(' ')
    pr_line(' ')
    pr_line('        THIS IS THE LAST PAGE OF THE STUDENT PRINT RUN')
    jw_eject()
    set alternate off
    close alternate
  enddo (nArea_cnt < 4)
  dbcloseall()
  set consol on
  
  simhead(memvar->pscr_title)
  
  *F*****************************************************************************
  
  @12,0 clear
  @12,12 say 'UPDATING STUDENT FILE'
  while !net_use('student', .f.,)
    @23,0 say 'Waiting for the student file'
  enddo
  @23,0 clear
  while !eof()
    if Student->status = 'C'
      reclock('Student')
      student->wk_smltn := Student->wk_smltn + nWeeks_to_move
      dbunlock()
    endif
    dbskip()
  enddo
  dbcloseall()
  
  select 9
  net_use('param', .f.)
  reclock('param')
  param->stop_trans := 'N'
  param->lst_portpr := date()
  param->message    := ''
  dbunlock()
  
  @12,0 clear
  @12,12 say 'UPDATING SHARE FILE'
  
  select 1
  while !net_use('share', .f.)
    @23,0 SAY 'Waiting for the Share file'
  enddo
  
  select 2
  while !net_use('shrdescr', .t.,, 'shrdescr')
    @23,0 SAY 'Waiting for the Share comment file'
  enddo
  
  select share
  while !eof()
    if Share->suspend = ' ' .or. Share->suspend = 'N'
      select Shrdescr
      if dbseek(share->share)
        reclock('Share comment')
        shrdescr->lst_wk_pr := share->y_cl_pr
        dbunlock()
      else
        dbappend()
        reclock('Share comment')
        shrdescr->share := share->share
        shrdescr->lst_wk_pr := share->y_cl_pr
        dbunlock()
      endif
    endif
    select share
    dbskip()
  enddo
  dbcloseall()
  
  *F*****************************************************************************
  
  @12,0 clear
  @ 12,12 say 'PACKING AND INDEXING TRANSACTION FILE'
  
  rem_tts('TRANSACT.DBF')               // Remove transactional status
  rem_tts('TRANCODE.NTX')               // Remove transactional status
  
  while !net_use('transact', .t.)
    @23,0 say 'Waiting for the Transaction file'
  enddo
  pack
  index on transact->std_code + transact->type to trancode
  dbcloseall()
  
  add_tts('TRANSACT.DBF')                       // Flag as transactional
  add_tts('TRANCODE.NTX')                       // Flag as transactional
  
  @ 12,0 clear
  @ 12,12 say 'PACKING AND INDEXING PORTFOLIO FILE'
  
  rem_tts('PORTFOL.DBF')                // Remove transactional status
  rem_tts('PORTFOL.NTX')                // Remove transactional status
  
  while !net_use('portfol', .t.)
    @23,0 say 'Waiting for the Portfolio file'
  enddo
  pack
  index on portfol->std_code + portfol->type + portfol->share to portfol
  dbcloseall()
  
  add_tts('PORTFOL.DBF')          // Flag as transactional
  add_tts('PORTFOL.NTX')          // Flag as transactional
  
  @ 12,0 clear
  @ 12,12 say 'PACKING AND INDEXING BEAR FILE'
  
  rem_tts('BEAR.DBF')                   // Remove transactional status
  rem_tts('BEAR.NTX')                   // Remove transactional status
  
  while !net_use('bear', .t.)
    @23,0 SAY 'Waiting for the Bear file'
  enddo
  pack
  index on bear->std_code + bear->type + bear->share to bear
  dbcloseall()
  
  add_tts('BEAR.DBF')             // Flag as transactional
  add_tts('BEAR.NTX')             // Flag as transactional
  
  @ 12,0 clear
  @ 12,12 say 'PACKING AND INDEXING ORDER FILE'
  
  rem_tts('ORDER.DBF')                  // Remove transactional status
  rem_tts('ORDER.NTX')                  // Remove transactional status
  
  while !net_use('order', .t.)
    @23,0 say 'Waiting for the Order file'
  enddo
  pack
  index on order->std_code + order->share to order
  
  add_tts('ORDER.DBF')            // Flag as transactional
  add_tts('ORDER.NTX')            // Flag as transactional
  
end sequence
dbcloseall()

return

*eof

*f*****************************************************************************
function port_sum_len ( cStd_code )
local cAlias, nLen
cAlias = alias()
nLen = 12
select portfol
dbseek(cStd_code + 'T')
while portfol->std_code = cStd_code .and. portfol->type = 'T' .and. !eof()
  nLen++
  dbskip()
enddo
select bear
if dbseek(cStd_code + 'T')
  nLen += 8
  while bear->std_code = cStd_code .and. bear->type = 'T' .and. !eof()
    nLen++
    dbskip()
  enddo
endif
nLen += 12
return(nLen)
