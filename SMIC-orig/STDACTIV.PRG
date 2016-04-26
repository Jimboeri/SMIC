*******************************************************************************
* 'STDACTIV' - PRINTS OUT ACTIVE STUDENTS
* JIM WEST
* 8/89

LOCAL nCol, nStart_cd, nEnd_cd, cRep, cTitle
local nCnt, nNtx
local aStat := {'Current students',;
    'Unpaid students',;
    'Suspended std with reins dt',;
    'Suspended std without reins dt'}
local aType := {'All students',;
    'By Branch',;
    'By Rep'}
memvar getlist, pLine

select 9
if !net_use('student', .f.,,'names')
  return
endif

nCnt := nNTX := 0

begin sequence
  draw_box(4,2,20,76)
  @5,0 say center('PRINTING STUDENTS')
  
  nStart_cd = 0
  nEnd_cd = 9999
  cRep = '  '
  nCnt = 1
  
  @8,10 say 'Starting postal code ' get nStart_cd picture '9999'
  @9,10 say 'Final postal code    ' get nEnd_cd picture '9999'
  read
  
  nCnt = get_arr(aType,11,10)
  
  if nCnt = 2 .or. nCnt = 3
    @17,10 say 'Enter branch/rep code ' get cRep picture '!!'
    read
    if empty(cRep)
      break
    endif
  endif
  
  if nCnt != 0
    nNtx = get_arr(aStat,11,35)
  endif
  
  if nCnt != 0 .and. nNtx != 0 .and. make_sure()
    openprn()
    dbgotop()
    do case
      case nNtx = 1
        cTitle = 'CURRENT STUDENTS'
      case nNtx = 2
        cTitle = 'UNPAID STUDENTS'
      case nNtx = 3
        cTitle = 'SUSPENDED STUDENTS WITH REISTATEMENT DATE'
      case nNtx = 4
        cTitle = 'SUSPENDED STUDENTS WITHOUT REISTATEMENT DATE'
    endcase
    do case
      case nCnt = 1
        cTitle += '  (Country wide)'
      case nCnt = 2
        cTitle += '  (Branch ' + SUBSTR(cRep,1,1) + ')'
      case nCnt = 3
        cTitle += '  (Rep ' + cRep + ')'
    endcase
    while !eof()
      if val(Student->p_code) >= nStart_cd .and.;
            val(Student->p_code) <= nEnd_cd
        if (nCnt = 1);
              .or. ((nCnt = 2) .and. (substr(cRep,1,1) = substr(Student->rep,1,1)));
              .or. ((nCnt = 3) .and. (cRep = Student->rep))
          if (nNtx = 1 .and. Student->status = 'C');
                .or. (nNtx = 2 .and. Student->status = 'U');
                .or. (nNtx = 3 .and. Student->status = 'S' .and.;
                Student->susp_dt != ctod('  /  /  '));
                .or. (nNtx = 4 .and. Student->status = 'S' .and.;
                Student->susp_dt = ctod('  /  /  '))
            @15,10 clear to 15,68
            @15,10 say trim(Student->title) + ' ' + trim(Student->name) + ' ';
                + trim(Student->surname)
            if pline > 58
              prntitle(cTitle, 'Y')
              ? 'NAME                                                   ADDRESS                               PHONE NUMBERS'
              ? ' '
            ENDIF
            ? trim(Student->title) + ' ' + trim(Student->name) + ' ' +;
                trim(Student->surname)
            nCol = 55 - pcol()
            ?? replicate(' ',nCol) + Student->address1 + '             Ph(w) ';
                + Student->phone_w + ' Wk on Course ' + str(Student->wk_smltn,2,0)
            ? 'Current performance    ' + str(Student->perc_chang,8,2) + '%';
                + space(23) + Student->address2 + '             Ph(h) ' +;
                Student->phone_h + ' Wk unactive  ' + str(Student->wk_unact,2,0)
            ? 'Annualised performance ' +;
                str((Student->perc_chang * 52 / Student->wk_smltn),8,2) + '%' +;
                space(23) + Student->p_code + ' ' + Student->address3 +;
                '        Status ' + str_stat(Student->status)
            if Student->status = 'C'
              ?? '      Last trn '
            else
              ?? '      Susp dt  '
            endif
            ?? dtoc(Student->last_tran)
            ? ' '
            pline += 4
          endif
        endif
      endif
      dbskip()
    enddo
  endif
end sequence
closeprn()
dbcloseall()
return

* eof
