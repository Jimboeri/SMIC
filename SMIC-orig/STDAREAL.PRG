*******************************************************************************
* STDAREAL - PRINTS LABELS BY STUDENTS BY AREA
* JIM WEST

local nP_start, nP_end, nChoice, nLab_no, nCnt1, nCnt2
local aStd_det[2][5], lPrint_ok
local aCh := {'New and current students',;
    'New students only',;
    'Current students only',;
    'Finished students',;
    'All students',;
    'Suspended students'}
memvar getlist

if !net_use('student', .f.,, 'names')
  return
endif

nP_start := nChoice := nLab_no := 0
nP_end := 9999
for nCnt1 = 1 to 2
  afill(aStd_det[nCnt1], '')
next
draw_box(4,2,20,76)
@7,10 say 'PRINTING STUDENT BY POSTAL CODES.'
@9,10 say 'Start at postal code ' get nP_start picture '9999'
@10,10 say 'End at postal code   ' get nP_end picture '9999'
read

nChoice = get_arr(aCh,13, 12,, .f.,'Choose status of students to print')

if nChoice != 0
  select student
  dbgotop()
  
  if wmake_sure(17,,'Do you want to continue ? ')
    @14,10 say 'Load labels into printer and line them up'
    inkey(0)
    set print on
    set consol off
    
    lPrint_ok = .F.
    while !lPrint_ok
      ? 'XXXXXXXXXXXXXXXXXXXXXXXXX            XXXXXXXXXXXXXXXXXXXXXXXXX'
      ? 'XXXXXXXXXXXXXXXXXXXXXXXXX            XXXXXXXXXXXXXXXXXXXXXXXXX'
      ? 'XXXXXXXXXXXXXXXXXXXXXXXXX            XXXXXXXXXXXXXXXXXXXXXXXXX'
      ? 'XXXXXXXXXXXXXXXXXXXXXXXXX            XXXXXXXXXXXXXXXXXXXXXXXXX'
      ? 'XXXX                                 XXXX'
      ? ' '
      ? ' '
      ? ' '
      ? ' '
      ?? ' '
      if wmake_sure(17,,'Are the labels correctly lined up? ')
        lPrint_ok = .T.
      endif
    enddo
    set consol off
    
    dbgotop()
    while !eof()
      if ( val(Student->p_code) >= nP_start .and.;
       val(Student->p_code) <= nP_end) .and. Student->addr_incor != 'Y'
        do case
          case nChoice = 1 .and. (Student->status = 'N' .or.;
           Student->status = 'C')
            nLab_no++
            aStd_det = LOAD_ARR(aStd_det, nLab_no)
            nLab_no = PRN_LAB(aStd_det, nLab_no)
          case nChoice = 2 .and. (Student->status = 'N')
            nLab_no++
            aStd_det = load_arr(aStd_det, nLab_no)
            nLab_no = prn_lab(aStd_det, nLab_no)
          case nChoice = 3 .and. (Student->status = 'C')
            nLab_no++
            aStd_det = load_arr(aStd_det, nLab_no)
            nLab_no = prn_lab(aStd_det, nLab_no)
          case nChoice = 4 .and. (Student->status = 'F')
            nLab_no++
            aStd_det = load_arr(aStd_det, nLab_no)
            nLab_no = prn_lab(aStd_det, nLab_no)
          case nChoice = 5
            nLab_no++
            aStd_det = load_arr(aStd_det, nLab_no)
            nLab_no = prn_lab(aStd_det, nLab_no)
          case nChoice = 6 .and. (Student->status = 'S')
            nLab_no++
            aStd_det = load_arr(aStd_det, nLab_no)
            nLab_no = prn_lab(aStd_det, nLab_no)
        endcase
      endif
      dbskip()
    enddo
    dbskip(-1)
    
    if nChoice = 4 .or. nChoice = 5
      select 1
      if net_use('finished', .f.)
        while !eof()
          if ( val(Finished->p_code) >= nP_start .and.;
           val(Finished->p_code) <= nP_end) .and. Finished->killed != 'Y'
            nLab_no++
            aStd_det = load_arr(aStd_det, nLab_no)
            nLab_no = prn_lab(aStd_det, nLab_no)
          endif
          dbskip()
        enddo
      endif
    endif
    IF nLab_no != 0
      nLab_no = prn_lab(aStd_det, nLab_no)
    endif
    
    set consol on
  endif
endif
closeprn()
select student
dbcloseall()
return

*EOF

***********************************************************
static function load_arr(aArray, nInx)
local nLen
field Std_code, title, name, surname, address1, address2, address3, p_code
aArray[nInx][1] = space(18) + 'SMC/STD' + std_code + space(7)
aArray[nInx][2] = trim(title) + ' ' + substr(name,1,1) + ' ';
    + surname
nLen = 37 - len(aArray[nInx][2])
aArray[nInx][2] += space(nLen)
aArray[nInx][3] = address1 + space(12)
aArray[nInx][4] = address2 + space(12)
aArray[nInx][5] = p_code + ' ' + address3 + space(7)
return aArray
*eof()

***********************************************************
static function prn_lab(aLab_det, nNo_lab)
local nCnt1, nCnt2
if nNo_lab != 2
  return(nNo_lab)
endif
for nCnt1 = 1 to len(aLab_det)
  pr_line(aLab_det[1][nCnt1] + aLab_det[2][nCnt1])
next
pr_line(' ')
pr_line(' ')
pr_line(' ')
pr_line(' ')
for nCnt1 = 1 to 2
  afill(aLab_det[nCnt1], '')
next
return(0)
*eof()
