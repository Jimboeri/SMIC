*******************************************************************************
* ACCDEBIT - CREATES DEBIT ORDERS DISKETTE
* JIM WEST
* 04/93

local cSect, cLine, cAmt, cType, cPr_line
local aDir
local nHandle, nRec, nTot_amt, nAmt, nUs, nVAT
local dAction, dHeader, dNext_act, dNext_cut

#include 'fileio.ch'
#include 'directry.ch'

simhead(memvar->pScr_title)

select 1
if !net_use('param', .t.)
  return
endif

if wmake_sure(4,,'Debit order run for ' + dtoc(param->nxt_do_dt),;
      'Are you sure you want to produce the diskette ? ')
  
  cSect = disp_msg(12,,'Opening and securing data files')
  
  aDir = directory('ACCOUNT.DBF')
  if aDir[1, F_SIZE] > diskspace() - 100000
    cSect = disp_msg(12,,'Not enough space on the disk')
    inkey(0)
    restsector(cSEct)
  endif
  
  // Open data files
  select 2
  if !net_use('account', .f.,, 'acccode')
    select param
    dbclosearea()
    return
  endif
  
  copy to accbu                 // make a backup copy of account file
  
  select 3
  if !net_use('student', .f.,, 'names')
    select param
    dbclosearea()
    select account
    dbclosearea()
    return
  endif
  
  nHandle = fcreate('DEBIT.TXT')
  if nHandle = -1
    cSect = disp_msg(12,,'Error opening output file')
    inkey(0)
    restsector(cSect)
    break
  endif
  
  select param
  dAction = param->nxt_do_dt
  if dAction < date()
    dAction = date()
  endif
  
  dNext_act = dAction
  if day(dNext_Act) > 20
    while day(dNext_act) != 15
      dNext_act++
    enddo
  else
    while day(dNext_act) != 1
      dNext_act++
    enddo
    dNext_act--
  endif
  dNext_cut = dNext_act - 5
  while dow(dNext_act) = 7 .or.  dow(dNext_act) = 1
    dNext_act++
  enddo
  
  dHeader = substr(dtoc(dAction),1,2) + substr(dtoc(dAction),4,2);
      + substr(dtoc(dAction),7,2)
  
  restsector(cSect)
  
  begin sequence
    if openprn()
      break
    endif
    
    nTot_amt = 0
    
    cLine = '*' + param->do_co_code + param->do_co_name + dHeader + 'Y';
        + space(10) + param->do_usr_ref + '  -360         01LIVE'
    dos_write(nHandle, cLine)
    
    select student
    while !eof()
      @10,0 clear
      @10,15 say student->surname
      select account
      dbseek(student->std_code)
      while student->std_code = account->std_code .and. !eof()
        if account->cr_dr = 'D' .and. account->pmt_dt <= dAction
          if account->pmt_type = 'D' .and. account->comment != 'B'
            cAmt = ltrim(str(account->amount*100,8,0))
            cAmt = replicate('0', (11-len(cAmt))) + cAmt
            cLine = '2' + param->do_co_code + student->bank_code + '  ' +;
                student->std_code + student->bnk_acc_no + ' ' +;
                student->acc_type + cAmt + substr(student->surname,1,20);
                + space(10) + param->do_usr_ref + '   '
            dos_write(nHandle, cLine)
            if memvar->pLine > 55
              prntitle('DEBIT ORDER ENTRIES PROCESSED  -  ACTION DATE ';
                  + dtoc(param->nxt_do_dt))
            endif
            cPr_line = student->std_code + '  ' + trim(student->surname);
                + ' ' + trim(student->title) + ' ' + trim(student->name)
            if len(cPr_line) > 55
              cPr_line = substr(cPr_line,1,55)
            endif
            cPr_line += space(50 - len(cPr_line))
            cPr_line += '  ' + str(account->amount) + '  ' +;
                dtoc(account->pmt_dt)
            pr_line(cPr_line)
            nRec = recno()
            nTot_amt += account->amount
            nAmt = account->amount
            cType = account->type
            reclock('Account')
            account->comment := 'B'
            dbunlock()
            nUs = round((nAmt * 100 / (100 + student->vat_rate)), 2)
            nVat = nAmt - nUs
            dbappend()
            reclock('Accounts')
            account->std_code := student->std_code
            account->type := cType
            account->cr_dr := 'C'
            account->amount := nUs
            account->pmt_dt := dAction
            account->pmt_type := 'D'
            account->vat := nVat
            dbunlock()
            dbgoto(nRec)
          endif
        endif
        dbskip()
      enddo
      select student
      dbskip()
    enddo (end of students)
    
    cAmt = ltrim(str(nTot_amt*100,11,0))
    cAmt = replicate('0', (13-len(cAmt))) + cAmt
    cLine = '2' + param->do_co_code + 'T' + space(30) + cAmt + space(47)
    dos_write(nHandle, cLine)
    
    select param
    param->nxt_do_dt := dNext_act
    param->nxt_cut_dt := dNext_cut
    
    select account
    prntitle('DEBIT ORDER CONTROL PAGE')
    pr_line('')
    pr_line('')
    pr_line('')
    pr_line('Please label the diskette as follows:')
    pr_line('')
    pr_line('File        = DEBIT.TXT')
    pr_line('User        = ' + param->do_co_name)
    pr_line('User code   = ' + param->do_co_code)
    pr_line('Entry class = 36')
    pr_line('Action date = ' + dtoc(dAction))
    pr_line('')
    pr_line('Batch total for the form = ' + str(nTot_amt))
    pr_line(' ')
    pr_line('')
    pr_line('The next action date is  ' + dtoc(dNext_act))
    pr_line('The next cut off date is ' + dtoc(dNext_cut))
    pr_line('')
    pr_line('')
    pr_line('')
    pr_line('Please put a blank formatted floppy into your computer and from the')
    pr_line('dos prompt type in "COPY DEBIT.TXT A:", label the diskette as the print')
    pr_line('out instructs and have it delivered to the Standard Bank with the')
    pr_line('correct form filled in.')
    pr_line('')
    pr_line('')
    pr_line('')
    pr_line('')
    pr_line('      THIS PROGRAM RAN SUCCESSFULLY')
    pr_line('')
    pr_line('')
    pr_line('      THIS PROGRAM RAN SUCCESSFULLY')
    pr_line('')
    pr_line('')
    pr_line('      THIS PROGRAM RAN SUCCESSFULLY')
    pr_line('')
    pr_line('')
    pr_line('      THIS PROGRAM RAN SUCCESSFULLY')
    shutprn()
    
    recover                       // recovery procedure
    select account
    select 2                    // open accounts exclusive
    while !net_use('account', .t.,, 'acccode')
    enddo
    zap                         // empty the file
    append from accbu           // restore from backup
    select param
    dbclosearea()
    select account
    dbclosearea()
    select student
    dbclosearea()
    pr_line('      THIS PROGRAM FAILED TO RUN')
    pr_line('')
    pr_line('  FIND OUT WHAT THE PROBLEM WAS AND RE-RUN IT')
    pr_line('')
    pr_line('')
    pr_line('')
    pr_line('      THIS PROGRAM FAILED TO RUN')
    pr_line('')
    pr_line('  FIND OUT WHAT THE PROBLEM WAS AND RE-RUN IT')
    pr_line('')
    pr_line('')
    pr_line('')
    pr_line('      THIS PROGRAM FAILED TO RUN')
    pr_line('')
    pr_line('  FIND OUT WHAT THE PROBLEM WAS AND RE-RUN IT')
    pr_line('')
    shutprn()
    return
    
  end sequence
  select account
  dbclosearea()
  select student
  dbclosearea()
  
endif           // run debit orders

select param
dbclosearea()
return

* EOF

*******************************************************************************
static procedure dos_write ( nHndl, cString)
local cSect
#define EOL     chr(13) + chr(10)
fwrite(nHndl, cString + EOL)
if ferror() != 0
  cSect = disp_msg(18,,'DOS error occured - This run has been abandoned',;
      'Press any key to continue')
  inkey(0)
  restsector(cSect)
  break
endif
return
