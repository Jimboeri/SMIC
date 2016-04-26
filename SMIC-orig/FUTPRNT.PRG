*******************************************************************************
* PROGRAM 'FUTPRNT' PRINT STUDENT FUTURE PORTFOLIOS
* AUTHOR JIM WEST
* 19/2/88

local cStd_code, cTitle, lHeader, cLine, nCnt, nQty, nInt, nPercent
local nCost, nValue, nProfit, nPort_val, nBid_offer, nVal1, nVal2

set alternate to future.txt
simhead(memvar->pscr_title)

@10,0 clear
@10,10 say 'STUDENT FUTURE PORTFOLIO PRINTOUT IN PROGRESS'
select 1
if !net_use('futtrans', .t.,, 'futtrans')
  return
endif

select 2
if !net_use('futoptn', .f.,, 'futoptn')
  close databases
  return
endif

select 3
if !net_use('futstore', .t.)
  close databases
  return
endif

select 4
if !net_use(' futport', .t.,, 'futport')
  close databases
  return
endif

select 6
do while !net_use('student', .t.,, 'names')
  @23,10 say 'waiting for student file'
enddo
@22,0 clear

set alternate on
set consol off
while !eof()
  cStd_code = Student->std_code
  cTitle = 'FUTURES PRINTOUT FOR ' + trim(Student->title) + ' ' +;
      trim(Student->name) + ' ' + trim(Student->surname) + ' week' +;
      str(Student->wk_smltn)
  @15,10 say replicate(' ',80)
  @15,10 say trim(Student->title) + ' ' + trim(Student->name) + ' ' +;
      trim(Student->surname)
  if Student->status = 'C'
    lHeader = .f.
    select futtrans
    if dbseek(cStd_code)
      lHeader = .t.
      cLine = trim(Student->title) + ' ' + substr(Student->name,1,1) + ' ' +;
          Student->surname + replicate(' ',30)
      nCnt = 1
      while nCnt < 16
        ? ' '
        nCnt++
      enddo
      ? replicate(' ',6) + cLine
      ? replicate(' ',6) + Student->address1
      ? replicate(' ',6) + Student->address2
      ? replicate(' ',6) + Student->address3
      ? replicate(' ',6) + Student->p_code
      ? ' '
      * Page Throw
      jw_eject()
      memvar->pline = 70
      memvar->ppage = 0
      while futtrans->std_code = cStd_code .and. !eof()
        do case
          case futtrans->trn_type = 'FLN'
            IF memvar->pLine > 50
              prntitle(cTitle,'N')
            endif
            select futoptn
            dbseek(futtrans->fut_optn)
            ?? memvar->pr_comp_of
            ? 'LONG POSITION TAKEN ON ' + dtoc(futtrans->trn_dt)
            ?? memvar->pr_compress
            ? ' '
            ? trim(futoptn->full_name)
            ? ' '
            ?? memvar->pr_comp_of
            ? replicate('-',101)
            ? ' NO OF CONTRACTS    EXPIRY DATE        MARGIN      AVE. MARGIN     INITIAL VALUE        AVE VALUE'
            ? ' '
            select futtrans
            nQty = abs(futtrans->qty)
            nInt = abs(futtrans->int_value)
            ? '    ', nQty, '       ', futoptn->exp_date, futtrans->margin,;
                '  ', (futtrans->margin/nQty), '  ', nInt,'  ', (nInt / nQty)
            ? replicate('-',101)
            ? ' '
            ? ' '
            memvar->pLine += 11
          case futtrans->trn_type = 'FSC'
            if memvar->pLine > 50
              prntitle(cTitle,'N')
            endif
            select futoptn
            dbseek(futtrans->fut_optn)
            ?? memvar->pr_comp_of
            ? 'SHORT POSITION COVERED ON ' + dtoc(futtrans->trn_dt)
            ?? memvar->pr_compress
            ? ' '
            ? ltrim(str(futtrans->qty,8,0)) , trim(futoptn->full_name)
            ? ' '
            ?? memvar->pr_comp_of
            ? replicate('-',124)
            ? ' NO OF CONTRACTS    EXPIRY DATE      MARGIN RETURNED     INITIAL VALUE     FINAL VALUE      PROFIT/LOSS    %PROFIT ON MARGIN'
            ? ' '
            select futtrans
            nQty = abs(futtrans->qty)
            nInt = abs(futtrans->int_value)
            ? '    ', nQty, '       ', futoptn->exp_date, '      ',;
                futtrans->margin, '  ', nInt, ' ', (nInt + futtrans->profit),;
                ' ', futtrans->profit, '      ',;
                (futtrans->profit / futtrans->margin * 100)
            ? replicate('-',124)
            ? ' '
            ? ' '
            memvar->pLine += 11
          case futtrans->trn_type = 'FSP'
            if memvar->pLine > 50
              prntitle(cTitle,'N')
            endif
            select futoptn
            dbseek(futtrans->fut_optn)
            ?? memvar->pr_comp_of
            ? 'SHORT POSITION TAKEN ON ' + dtoc(futtrans->trn_dt)
            ?? memvar->pr_compress
            ? ' '
            ? trim(futoptn->full_name)
            ? ' '
            ?? memvar->pr_comp_of
            ? replicate('-',101)
            ? ' NO OF CONTRACTS    EXPIRY DATE        MARGIN      AVE. MARGIN     INITIAL VALUE        AVE VALUE'
            ? ' '
            select futtrans
            nQty = abs(futtrans->qty)
            nInt = abs(futtrans->int_value)
            ? '    ', nQty, '       ', futoptn->exp_date, futtrans->margin,;
                '  ', (futtrans->margin/nQty), '  ', nInt, '  ', (nInt / nQty)
            ? replicate('-',101)
            ? ' '
            ? ' '
            memvar->pLine += 11
          case futtrans->trn_type = 'FLC'
            if memvar->pLine > 50
              prntitle(cTitle,'N')
            endif
            select futoptn
            seek(futtrans->fut_optn)
            ?? memvar->pr_comp_of
            ? 'LONG POSITION COVERED ON ' + dtoc(futtrans->trn_dt)
            ?? memvar->pr_compress
            ? ' '
            ? ltrim(str(futtrans->qty,8,0)) , trim(futoptn->full_name)
            ? ' '
            ?? memvar->pr_comp_of
            ? replicate('-',124)
            ? ' NO OF CONTRACTS    EXPIRY DATE      MARGIN RETURNED     INITIAL VALUE     FINAL VALUE      PROFIT/LOSS    %PROFIT ON MARGIN'
            ? ' '
            select futtrans
            nQty = abs(futtrans->qty)
            nInt = abs(futtrans->int_value)
            ? '    ', nQty, '       ', futoptn->exp_date, '      ',;
                futtrans->margin, '  ', nInt, ' ', (nInt + futtrans->profit),;
                ' ', futtrans->profit, '      ',;
                (futtrans->profit / futtrans->margin * 100)
            ? replicate('-',124)
            ? ' '
            ? ' '
            memvar->pLine += 11
          case futtrans->trn_type = 'FSA'
            if memvar->pLine > 50
              prntitle(cTitle,'N')
            endif
            select futoptn
            dbseek(futtrans->fut_optn)
            ?? memvar->pr_comp_of
            ? 'SHORT POSITION AUTOMATICALLY CLOSED ON ' + dtoc(futtrans->trn_dt)
            ?? memvar->pr_compress
            ? ' '
            ? ltrim(str(futtrans->qty,8,0)) , trim(futoptn->full_name)
            ? ' '
            ?? memvar->pr_comp_of
            ? replicate('-',124)
            ? ' NO OF CONTRACTS    EXPIRY DATE      MARGIN RETURNED     INITIAL VALUE     FINAL VALUE      PROFIT/LOSS    %PROFIT ON MARGIN'
            ? ' '
            select futtrans
            nQty = abs(futtrans->qty)
            nInt = abs(futtrans->int_value)
            ? '    ', nQty, '       ', futoptn->exp_date, '      ',;
                futtrans->margin, '  ', nInt, ' ', (nInt + futtrans->profit),;
                ' ', futtrans->profit, '      ',;
                (futtrans->profit / futtrans->margin * 100)
            ? replicate('-',124)
            ?? memvar->pr_compress
            ? 'This future has been automatically closed out for you following the expiry'
            ? 'date.'
            ? ' '
            ? ' '
            memvar->pLine += 13
          case futtrans->trn_type = 'FLA'
            if memvar->pLine > 50
              prntitle(cTitle,'N')
            endif
            select futoptn
            dbseek(futtrans->fut_optn)
            ?? memvar->pr_comp_of
            ? 'LONG POSITION AUTOMATICALLY CLOSED ON ' + dtoc(futtrans->trn_dt)
            ?? memvar->pr_compress
            ? ' '
            ? ltrim(str(futtrans->qty,8,0)) , trim(futoptn->full_name)
            ? ' '
            ?? memvar->pr_comp_of
            ? replicate('-',124)
            ? ' NO OF CONTRACTS    EXPIRY DATE      MARGIN RETURNED     INITIAL VALUE     FINAL VALUE      PROFIT/LOSS    %PROFIT ON MARGIN'
            ? ' '
            select futtrans
            nQty = abs(futtrans->qty)
            nInt = abs(futtrans->int_value)
            ? '    ', nQty, '       ', futoptn->exp_date, '      ',;
                futtrans->margin, '  ', nInt, ' ', (nInt + futtrans->profit),;
                ' ', futtrans->profit, '      ',;
                (futtrans->profit / futtrans->margin * 100)
            ? replicate('-',124)
            ?? memvar->pr_compress
            ? 'This future has been automatically closed out for you following the expiry'
            ? 'date.'
            ? ' '
            ? ' '
            memvar->pLine += 13
          case futtrans->trn_type = 'FXM'
            if memvar->pLine > 52
              prntitle(cTitle,'N')
            endif
            select futoptn
            dbseek(futtrans->fut_optn)
            ?? memvar->pr_comp_of
            ? 'EXTRA MARGIN REQUIRED FOR FUTURE ON ' + DTOC(futtrans->TRN_DT)
            ?? memvar->pr_compress
            ? ' '
            ? 'EXTRA MARGIN REQUIRED FOR  ', futoptn->full_name
            ? ' '
            select futtrans
            ? 'ORIGINAL MARGIN   EXTRA MARGIN    CONTRACTS HELD       LONG/SHORT'
            ? (futtrans->margin - futtrans->profit), futtrans->profit,;
                '     ' , abs(futtrans->qty)
            if futtrans->qty > 0
              ?? '                L'
            else
              ?? '                S'
            endif
            ? ' '
            ? 'Extra margin is required for this contract as the market has moved'
            ? 'against you.'
            ? ' '
            ? ' '
            memvar->pLine += 12
        endcase
        select futstore
        dbappend()
        futstore->std_code  := futtrans->std_code
        futstore->fut_optn  := futtrans->fut_optn
        futstore->trn_type  := futtrans->trn_type
        futstore->qty       := futtrans->qty
        futstore->margin    := futtrans->margin
        futstore->int_value := futtrans->int_value
        futstore->trn_cost  := futtrans->trn_cost
        futstore->trn_dt    := futtrans->trn_dt
        futstore->profit    := futtrans->profit
        select futtrans
        dbdelete()
        dbskip()
      enddo
    endif (transaction records)
    select futport
    dbseek(cStd_code)
    if lHeader = .t. .or. found()
      if lHeader = .f.
        cLine = trim(Student->title) + ' ' + substr(Student->name,1,1) +;
            ' ' + Student->surname + replicate(' ',30)
        nCnt = 1
        for nCnt = 1 to 16
          ? ' '
        next
        ? replicate(' ',6) + cLine
        ? replicate(' ',6) + Student->address1
        ? replicate(' ',6) + Student->address2
        ? replicate(' ',6) + Student->address3
        ? replicate(' ',6) + Student->p_code
        ? ' '
        * Page Throw
        jw_eject()
        memvar->pLine = 70
        memvar->ppage = 0
      endif
      prntitle(cTitle,'N')
      ? ' '
      ? 'FUTURES PORTFOLIO SUMMARY' + memvar->pr_compress
      ? ' '
      ? '                  EXPIRY   LONG/       NO                   INITIAL            BID/       CURRENT            %          PROFIT'
      ? 'FUTURE             DATE    SHORT   CONTRACTS    MARGIN       VALUE            OFFER        VALUE           CHANGE       /LOSS'
      ? REPLICATE('-',130)
      nCost = 0
      nValue = 0
      nProfit = 0
      while futport->std_code = cStd_code .and. !eof()
        select futoptn
        dbseek(futport->fut_optn)
        ? futoptn->fut_optn + '  ' + dtoc(futoptn->exp_date)
        if futport->qty > 0
          ?? '    L  '
        else
          ?? '    S  '
        endif
        ?? str(int(abs(futport->qty)),6,0) + '  ' +;
            str(futport->margin,14,2) + str(abs(futport->int_value))
        if futport->qty > 0
          nBid_offer = futoptn->bid
        else
          nBid_offer = futoptn->offer
        endif
        nVal1 = futval(nBid_offer, futoptn->calc_type)
        ?? '  ' + str(nBid_offer,14,2) + '  ' +;
         str(abs(nVal1 * futport->qty),12,2)
        nVal2 = (futport->int_value + (nVal1 * futport->qty))
        if futoptn->margin != 0
          nPercent = nVal2 / futoptn->margin * 100
        else
          nPercent = 0
        endif
        ?? '  ' + str(nPercent,12,2)
        ?? '  ' + str(nVal2,12,2)
        nCost = nCost + futport->margin
        nProfit += nVal2
        nValue += nVal2 + futport->margin
        select futport
        dbskip()
      enddo
      ? replicate('-',130)
      ? space(44) + str(nCost,10,2)
      ?? space(63) + str(nProfit,10,2)
      ?? memvar->pr_compress
      ? ' '
      ? 'FUTURE PORTFOLIO STATISTICS'
      ? replicate('-',27)
      nPort_val = Student->fut_cash + nCost + nProfit
      ? 'PORTFOLIO VALUE               = ' + str(nPort_val,10,2)
      ? 'CASH AVAILABLE PLUS INTEREST  = ' + str(Student->fut_cash,10,2)
      ? 'PORTFOLIO PERCENTAGE CHANGE   = ' +;
       str(((nPort_val / Student->initl_val * 400) - 100),10,2)
      * FUTURE CASH = INITL_VAL / 4
      jw_eject()
    ENDIF (PORTFOLIO RECORDS)
  endif (status = 'C')
  select Student
  dbskip()
enddo (READ OF STUDENTS)
select futtrans
dbunlock()
select futstore
dbunlock()
select Student
dbunlock()
dbcloseall()
set alternate off
set consol on

@12,0 clear
@12,12 say 'PACKING AND INDEXING FUTURES TRANSACTION FILE'
while !net_use('futtrans', .t.)
  @23,0 say 'Waiting for the FUTTRANS file'
enddo
@23,0 clear
pack
index on futtrans->std_code to futtrans
close database

@12,0 clear
@ 12,12 say 'PACKING AND INDEXING FUTURES PORTFOLIO FILE'
while !net_use('futport', .t.)
  @23,0 say 'Waiting for the FUTPORT file'
enddo
@23,0 clear
pack
index on futport->std_code + futport->fut_optn to futport
close database

return
* eof
