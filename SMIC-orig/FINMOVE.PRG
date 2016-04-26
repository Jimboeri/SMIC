****************************************************************************
* 'FINMOVE' - MOVE FINISHED STUDENTS TO FINISHED FILE AND DELETES OLD RECORDS
* JIM WEST

local dTemp, dTemp1, cRef
local nDebit, nCredit, nCurrent, nArrear
local nValue, nTot_value, nTot_cost

simhead(memvar->pscr_title)

if !wmake_sure(10,,'Do you want to move all finished students to archive file (Y/N) ?')
  return
endif

select 1
if !net_use('student', .f.,, 'names')
  return
endif

select 2
if !net_use('newleads', .f.,, 'archives')
  close databases
  return
endif

select 3
if !net_use('share', .f.,, 'shrname')
  close databases
  return
endif

select 4
if !net_use('finished', .f.)
  close databases
  return
endif

select 5
if !net_use('account', .f.,, 'acccode')
  close databases
  return
endif

select 6
if !net_use('portfol', .f.,, 'portfol')
  close databases
  return
endif

set alternate to finished.txt
set alternate on
set consol off
select Student
while !eof()
  @10,10 say Student->surname
  if (Student->status = 'F' .or. Student->status = 'U') .and.;
        empty(Student->sold_pas)
    if Student->simln_len > 51
      dTemp = Student->last_tran + 270
    else
      dTemp = Student->last_tran + 365
    endif
    if dTemp < date()
      ? '        ' + trim(Student->title) + ' ' + substr(Student->name,1,1) +;
          ' ' + Student->surname
      ? ' '
      ? ' '
      ? '        ' + Student->address1 + '   Phone (W) ' + Student->phone_w
      ? '        ' + Student->address2 + '   Phone (H) ' + Student->phone_h
      ? '        ' + Student->p_code + ' ' + Student->address3
      ? ' '
      ? '        ' + dtoc(Student->sold_crs_1) + '   Rep ' + Student->rep
      ? '        ' + dtoc(Student->sold_crs_2) + '   SM  ' + Student->s_m
      ? '        ' + dtoc(Student->sold_ss) + '   NSM ' + Student->n_s_m
      ? '        ' + dtoc(Student->sold_lectr)
      ? '        Sim length ' + ltrim(str(Student->wk_smltn)) +;
          '                Wk unact ' + str(Student->wk_unact)
      ? ' '
      ? space(50) + 'Account no ' + Student->std_code
      ? space(50) + 'Date ' + dtoc(date())
      ? replicate('-',80)
      ?? memvar->pr_compres
      ? ' '
      nArrear = 0
      nCurrent = 0
      nDebit = 0
      nCredit = 0
      select Account
      dbseek(Student->std_code)
      while Student->std_code = Account->std_code .and. !eof()
        if Account->cr_dr = 'D'
          ? dtoc(Account->pmt_dt) + ' ' + Account->pmt_type
          ?? '   Payment for Stock Market Investors Course                          ';
              + str(Account->amount)
          nDebit = nDebit + Account->amount
          if Account->comment != 'B' .and. Account->pmt_dt < date()
            if Account->pmt_dt < date()
              nArrear = nArrear + Account->amount
            else
              nCurrent = nCurrent + Account->amount
            endif
          endif
        else
          if Account->cr_dr = 'C' .and. Account->comment != 'C'
            ? dtoc(Account->pmt_dt) + ' ' + Account->pmt_type
            ?? '   Payment received                                                                      ';
                + str(Account->amount)
            nCredit = nCredit + Account->amount
          endif
        endif
        select account
        reclock('Account')
        dbdelete()
        dbunlock()
        dbskip()
      enddo
      select Student
      ? memvar->pr_compres + replicate('-',80) + memvar->pr_compres
      ? 'Totals' + space(75) + str(nDebit) + '      ' + str(nCredit)
      if (nArrear + nCurrent) > 0
        ?? memvar->pr_compres
        ? replicate('-',80)
        ? '     Arrears    ' + str(nArrear,14,2)
        ? '     Current    ' + str(nCurrent,14,2)
        ? '                 -------------'
        ? '     TOTAL DUE  ' + str(nArrear + nCurrent,14,2)
      endif
      ?? memvar->pr_compres
      jw_eject()
      ? 'PORTFOLIO ' + trim(Student->title) + ' ' + trim(Student->name) +;
          ' ' + Student->surname
      ? ' '
      ? '             NO OF        COST OF   AVERAGE   CURRENT     CURRENT        %    '
      ? 'SHARE       SHARES        HOLDING    PRICE     PRICE       VALUE       PROFIT'
      ? replicate('-',80)
      select portfol
      dbseek(Student->std_code + 'T')
      nTot_cost = 0
      nTot_value = 0
      while Portfol->std_code = Student->std_code .and. Portfol->type = 'T';
            .and. !eof()
        select share
        dbseek(Portfol->share)
        ? portfol->share + '   ' + str(portfol->qty,6,0) +;
            str(portfol->cost_hold,15,2) +;
            str((portfol->cost_hold/portfol->qty),10,2) +;
            str(share->price / 100,10,2)
        nValue = (portfol->qty * Share->price / 100)
        nValue -= broker(nValue)
        nValue -= handle(portfol->qty)
        ?? str(nValue,12,2)
        if portfol->cost_hold != 0
          ?? str((nValue / portfol->cost_hold * 100) - 100,12,2)
        endif
        nTot_cost = nTot_cost + portfol->COST_HOLD
        nTot_value = nTot_value + nValue
        select portfol
        reclock('Portfolio')
        dbdelete()
        dbunlock()
        dbskip()
      enddo
      ? ' '
      ? replicate('-',80)
      ? 'SHARES         Cost'
      ?? str(nTot_cost,10,2)
      ?? '            Current value'
      ?? str(nTot_value,10,2)
      if nTot_cost != 0
        ?? space(6) + str((nTot_value / nTot_cost * 100) - 100,7,2)
      endif
      ? 'PORTFOLIO      Cash'
      ?? str(Student->cash,10,2)
      ?? '            Total value  '
      ?? str(nTot_value + Student->cash,10,2)
      ?? space(6) + str(((nTot_value + Student->cash) / Student->initl_val * 100) - 100,7,2)
      ? ' '
      ? 'Value when finished ' + str(Student->week_1)
      jw_eject()
      
      select finished
      dbappend()
      reclock('Finished')
      Finished->std_code   := Student->std_code
      Finished->archiv     := Student->archiv
      Finished->title      := Student->title
      Finished->name       := Student->name
      Finished->surname    := Student->surname
      Finished->address1   := Student->address1
      Finished->address2   := Student->address2
      Finished->address3   := Student->address3
      Finished->p_code     := Student->p_code
      Finished->phone_w    := Student->phone_w
      Finished->phone_h    := Student->phone_h
      Finished->rep        := Student->rep
      Finished->s_m        := Student->s_m
      Finished->n_s_m      := Student->n_s_m
      Finished->smltn_len  := Student->simln_len
      Finished->finished   := Student->last_tran
      Finished->perform    := Student->perc_chang
      Finished->sold_crs_1 := Student->sold_crs_1
      Finished->sold_crs_2 := Student->sold_crs_2
      Finished->sold_ss    := Student->sold_ss
      Finished->sold_lec   := Student->sold_lectr
      
      select Student
      reclock('student')
      dbdelete()
      dbunlock()
    endif
  endif
  select Student
  dbskip()
enddo (student file)
dbcloseall()
shutprn(.f.)
close alternate
set alternate off
set consol on

select 1
if !net_use('student', .f.,, 'stdcode')
  select 2
  if !net_use('transact', .f.,, 'trancode')
    
    while !eof()
      select Student
      if !dbseek(Transact->std_code)
        select Transact
        reclock('transaction')
        dbdelete()
        dbunlock()
      endif
      select Transact
      dbskip()
    enddo
    
    select Transact
    dbclosearea()
  endif
  
  select 3
  if !net_use('futtrans', .f., 'ftr', 'futtrans')
    
    while !eof()
      select Student
      if !dbseek(Futtrans->std_code)
        select Futtrans
        reclock('futtrans')
        dbdelete()
        dbunlock()
      endif
      select Futtrans
      dbskip()
    enddo
    select Futtrans
    dbclosearea()
  endif
  
  select 4
  if !net_use('futport', .f.,, 'futport')
    
    while !eof()
      select Student
      if !dbseek(Futport->std_code)
        select Futport
        reclock('futtrans')
        dbdelete()
        dbunlock()
      endif
      select Futport
      dbskip()
    enddo
  endif
endif
dbcloseall()

* EOF
