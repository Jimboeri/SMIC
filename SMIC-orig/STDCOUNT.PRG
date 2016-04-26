*******************************************************************************
* 'STDCOUNT' - PROVIDES VISUAL COUNTS OF STUDENTS BY STATUS
* JIM WEST
* 2/90

local nDbn, nCt, nJhb, nSusp, nNew, nUnp, nFin, nMonth, nCurrent, lProc_std
local nStaff

nDbn := nCt := nJhb := nSusp := nNew := nUnp := nFin := nMonth := nCurrent := 0
nStaff := 0

simhead(memvar->pScr_title)

@3,20 SAY 'Count of students by status'
if !make_sure()
  return
endif

if !net_use('student', .f.,, 'names')
  return
endif

while !eof()
  @ 10,10 say student->surname
  do case
    case student->status = 'N'
      nNew++
    case student->status = 'S'
      nSusp++
    case student->status = 'U'
      nUnp++
    case student->status = 'F'
      nFin++
    case student->status = 'C'
      nCurrent++
      lProc_std = .t.
      if !empty(Student->sold_els)
        if (Student->wk_smltn - ((int(Student->wk_smltn/4)) * 4)) != 0
          lProc_std = .F.
        endif
      endif
      if Student->lec_stat = 'N' .or. Student->lec_stat = 'A'
        if (Student->wk_smltn - ((int(Student->wk_smltn/4)) * 4)) != 0
          lProc_std = .F.
        endif
      endif
      if lProc_std
        do case
          case (Student->p_code > '2899' .and. Student->p_code < '4700')
            if Student->group_no = '01'
              nDbn++
            endif
          case (Student->p_code > '6699' .and. Student->p_code < '8300')
            if Student->group_no = '01'
              nCt++
            endif
          case Student->p_code = 'QQQQ'
            if Student->group_no = '01'
              nStaff++
            endif
          otherwise
            if Student->group_no = '01'
              nJhb++
            endif
        endcase
      endif
  endcase
  dbskip()
enddo

dbclosearea()

@4,0 clear
@5,10 say 'Current students                   ' + str(nCurrent)
@6,15 say 'Cape town mailing    ' + str(nCt)
@7,15 say 'Durban mailing       ' + str(nDbn)
@8,15 say 'Johannesburg mailing ' + str(nJhb)
@9,20 say 'Total mailing                      ' + str(nCt + nDbn + nJhb)
@11,10 say 'Suspended students        ' + str(nSusp)
@13,10 say 'New students              ' + str(nNew)
@15,10 say 'Finished students         ' + str(nFin)
@17,10 say 'Unpaid students           ' + str(nUnp)

inkey(0)

return

* eof
