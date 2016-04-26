********************************************************************************
* PROGRAM ACCCOMM PRINTS REPS COMMISSIONS
* 14/3/88
* JIM WEST

local dStart_comm, dEnd_comm, cRep, lRep_fnd, cType, cCons, nRun_type, cTitle
local dOld, lFin_pay, d1DT, nFirst, nMth, cStd
local nNew_bank, nOld_bank, nSM_tot, nNSM_tot, nDeals, nSM_deals, nRef, nGrand
local dDate1, dPmt, nRec, cLine, nCnt, nComm

memvar getlist
memvar pLine

begin sequence
  if empty(et_use_dbf('Account'))
    break
  endif
  
  if empty(et_use_dbf('Reps'))
    break
  endif
  
  if empty(et_use_dbf('student'))
    break
  endif
  dbsetorder(2)
  
  if empty(et_use_dbf('Param'))
    break
  endif
  
  simhead(memvar->pscr_title)
  dStart_comm = param->start_comm
  dEnd_comm = param->end_comm
  @4,15 say 'Sales reps monthly banking'
  
  @7,10 say 'Commission period from ' + dtoc(dStart_comm) + ' to ' +;
      dtoc(dEnd_comm)
  if wmake_sure(10,,'Do you want to change this ? ')
    @11,10 say 'Start of commission period ' get dStart_comm
    @13,10 say 'End of commission period   ' get dEnd_comm
    read
    reclock('Parameter')
    param->start_comm := dStart_comm
    param->end_comm := dEnd_comm
    dbunlock()
    @7,0 clear
    @7,10 say 'Commission period from ' + dtoc(dStart_comm) + ' to ' +;
        dtoc(dEnd_comm)
  endif
  @8,0 clear
  
  cRep = 'XX'
  while cRep != '  '
    lRep_fnd = .F.
    while !lRep_fnd
      cRep = '  '
      @10,0 clear
      @11,10 say 'or enter to leave program'
      @10,10 say 'Input sales person code ' get cRep picture '@!'
      read
      if empty(cRep)
        lRep_fnd = .T.
      else
        select Reps
        if dbseek(cRep) .and. reps->level != 'B'
          lRep_fnd = .T.
        endif
      endif
    enddo
    if cRep != '  '
      cType = reps->level
      nSM_tot = 0
      nSM_deals = 0
      nNSM_tot = 0
      openprn()
      do case
        case cType = 'R'
          nRun_type = 3
        case cType = 'S'
          nRun_type = 2
        case cType = 'N'
          nRun_type = 1
      endcase
      while nRun_type <= 3
        do case
          case nRun_type = 3
            cType = 'R'
          case nRun_type = 2
            cType = 'S'
          case nRun_type = 1
            cType = 'N'
        endcase
        nRun_type++
        nDeals = 0
        nNew_bank = 0
        nOld_bank = 0
        nRef     = 0
        cTitle = 'COMMISSION FOR ' + cRep + ' FROM ' + dtoc(dStart_comm) +;
            ' TO ' + dtoc(dEnd_comm)
        if cType = 'S'
          cTitle = '(SM) ' + cTitle
        endif
        if cType = 'N'
          cTitle = '(NSM) ' + cTitle
        endif
        prntitle(cTitle,'Y')
        select Student
        pr_line(' ACC   NAME                                                       NEW      OLD       DATE     PMT       REP    SM   NSM')
        pr_line('  NO                                                              BANK     BANK     BANKED    TYPE')
        pr_line(' ')
        dbgotop()
        while !eof()
          dOld = ctod('01/01/80')
          @12,30 say Student->surname
          do case
            case cType = 'R'
              cCons = Student->REP
            case cType = 'S'
              cCons = Student->S_M
            case cType = 'N'
              cCons = Student->N_S_M
          endcase
          lFin_pay = .T.
          if cCons = cRep
            nFirst = 0
            dDate1 = ctod('  /  /  ')
            nMth = month(Student->sold_crs_1)
            select Account
            dbseek(Student->std_code)
            while account->std_code = Student->std_code .and. !eof()
              if account->cr_dr = 'C' .and. account->type = 'T'
                dPmt = account->pmt_dt
                if nFirst = 0
                  nFirst = Account->amount
                  dDate1 = Account->pmt_dt
                  if Student->deal_ref = 'S' .or. Student->deal_ref = 'T'
                    nRec = recno()
                    dbskip()
                    while Account->cr_dr != 'C' .and.;
                          Account->std_code = Student->std_code .and. !eof()
                      dbskip()
                    enddo
                    if !eof() .and. Account->std_code = Student->std_code
                      dPmt = Account->pmt_dt
                      dDate1 = Account->pmt_dt
                    else
                      dPmt = ctod('31/12/1999')
                      dDate1 = ctod('31/12/1999')
                    endif
                    dbgoto(nRec)
                  endif (split deposit)
                endif (nFirst)
                if dPmt >= dStart_comm .and. dPmt <= dEnd_comm
                  if pline > 50
                    prntitle(cTitle,'Y')
                    pr_line(' ACC   NAME                                                       NEW      OLD       DATE     PMT       REP    SM   NSM')
                    pr_line('  NO                                                              BANK     BANK     BANKED    TYPE')
                    pr_line(' ')
                  endif
                  cLine = account->std_code + ' ' + trim(Student->surname);
                      + ' ' + trim(student->name)
                  cLine += space(60 - len(cLine))
                  if nMth = month(account->pmt_dt)
                    cLine += str(account->amount,10,2) + '          '
                    nNew_bank += account->amount
                  else
                    cLine += '          ' + str(account->amount,10,2)
                    nOld_bank += account->amount
                  endif
                  cLine += '    ' + dtoc(account->pmt_dt) + '     ' +;
                      account->pmt_type + '       ' + Student->rep + '    ' +;
                      Student->s_m + '    ' + Student->n_s_m
                  if cType = 'R'
                    if Student->deal_ref = 'R' .or. Student->deal_ref = 'T'
                      nRef += account->amount
                      cLine += '  R'
                    else
                      cLine += '   '
                    endif
                  endif
                  ? cline
                  pLine++
                endif (date correct)
              else
                if account->comment != 'B' .and. account->cr_dr = 'C'
                  lFin_pay = .F.
                endif
              endif (forward bank acc rec)
              if account->pmt_dt > dOld
                dOld = Account->pmt_dt
              endif
              dbskip()
            enddo (Student->std_code = STD_CODE)
            if dDate1 >= dStart_comm .and. dDate1 <= dEnd_comm .and.;
                  Account->comment != 'C'
              nDeals++
              ?? '  *'
            endif
            nCnt = 1
            for nCnt = 1 to 3
              dOld = et_addmonth(dOld)
            next
            if dOld >= date()
              lFin_pay = .f.
            endif
            select Student
            if lFin_pay
              reclock('Student')
              Student->fin_pay := 'Y'
              dbunlock()
            endif
          endif (REP = cRep)
          select Student
          dbskip()
        enddo
        pr_line(' ')
        ? 'TOTALS                                              ' +;
            str(nNew_bank,14,2) + str(nOld_bank,14,2)
        if cType = 'R'
          ??  '     Referals = ' + str(nRef)
        endif
        nGrand = nNew_bank + nOld_bank
        ? 'GRAND TOTAL                                                        ';
            + str(nGrand)
        ? '                                                                                     Orders for this month = ' + str(nDeals)
        ? ' '
        do case
          case cType = 'R'
            ? 'Commission at 20% of ' + str(nGrand) + ' = ' + str(nGrand / 5)
            nComm = nGrand / 5
            if nRef != 0
              ? 'Referal fee at 5% of ' + str(nRef) + ' = ' + str(nRef / 20)
              nComm += (nRef / 20)
            endif
          case cType = 'S'
            ? 'Commission at 10% of ' + str(nGrand) + ' = ' + str(nGrand / 10)
            nSM_tot = nGrand
            nSM_deals = nDeals
          case cType = 'N'
            ? 'Commission at 5% of ' + str(nGrand) + ' = ' + str(nGrand / 20)
            nNSM_tot = nGrand
        endcase
      enddo
      cTitle = 'COMMISSION SHEET FOR ' + cRep + ' FROM ' + dtoc(dStart_comm);
          + ' TO ' + dtoc(dEnd_comm)
      prntitle(cTitle,'Y')
      ? ' '
      ? 'Commission at 20% of                 ' + str(nGrand) + ' = ' +;
          str(nGrand / 5)
      if nDeals < 16
        ? 'Commission at 15% of                 ' + str(nGrand) + ' = ' +;
            str(nGrand * 3 / 20)
        ? 'Commission at 10% of                 ' + str(nGrand) + ' = ' +;
            str(nGrand / 10)
      endif
      ? space(80) + replicate('_',20)
      ? ' '
      IF nRef != 0
        ? 'Referal fee at 5% of                 ' + str(nRef) + ' = ' +;
            str(nRef / 20)
        nComm += (nRef / 20)
        ? space(80) + replicate('_',20)
        ? ' '
      endif
      if nSM_tot != 0
        ? 'Sales manager commission at 10 % of ' + str(nSM_tot) + ' = ' +;
            str(nSM_tot / 10)
        if nSM_deals < 26
          ? 'Sales manager commission at  5 % of ' + str(nSM_tot) + ' = ' +;
              str(nSM_tot / 20)
        endif
        ? space(80) + replicate('_',20)
        ? ' '
      endif
      if nNSM_tot != 0
        ? 'NSM commission at 5% of             ' + str(nNSM_tot) + ' = ' +;
            str(nNSM_tot / 20)
        if nNSM_tot < 400000
          ? 'NSM commission at 4% of             ' + str(nNSM_tot) + ' = ' +;
              str(nNSM_tot * 4 / 100)
        endif
        if nNSM_tot < 300000
          ? 'NSM commission at 3% of             ' + str(nNSM_tot) + ' = ' +;
              str(nNSM_tot * 3 / 100)
        endif
        ? space(80) + replicate('_',20)
        ? ' '
      endif
      ? ' '
      ? ' '
      ? space(80) + 'TOTAL' + space(23) + replicate('_',20)
      ? ' '
      ? ' '
      ? ' '
      ? 'DEDUCTIONS'
      ? '----------'
      ? '      P A Y E'
      ? space(80) + replicate('_',20)
      ? ' '
      ? '      Loan account'
      ? space(80) + replicate('_',20)
      ? ' '
      ? '      Others'
      ? space(13) + replicate('_',50) + space(17) + replicate('_',20)
      ? ' '
      ? ' '
      ? space(13) + replicate('_',50) + space(17) + replicate('_',20)
      ? ' '
      ? ' '
      ? space(80) + 'TOTAL' + space(23) + replicate('_',20)
      ? ' '
      ? ' '
      ? ' '
      ? space(80) + 'TOTAL COMMISSION' + space(12) + replicate('_',20)
      ? ' '
      ? ' '
      ? 'Checked & signed    ' + replicate('_',40) + space(20) +;
          replicate('_',40)
      ? space(25) + 'Sales Manager/National Sales Manger' + space(30) +;
          'General Manager'
      ? ' '
      ? '             PAID  Beltel / Cheque no  ________________'
      select Reps
      reclock('reps')
      Reps->banking := nGrand
      if nSM_tot != 0
        Reps->banking := nSM_tot
      endif
      IF nNSM_tot != 0
        Reps->banking := nNSM_tot
      endif
      if reps->banking > 0
        Reps->last_comm := date()
      endif
      dbunlock()
    endif (cRep = SPACE)
  enddo (cRep != SPACE)
end sequence
shutprn()
et_close('Param')
et_close('Student')
et_close('Account')
et_close('Reps')

return
*EOF
