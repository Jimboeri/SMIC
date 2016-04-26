*******************************************************************************
* LDspcLB - PRINT LABELS BY area and dates
* JIM WEST

SIMHEAD(PSCR_TITLE)

@5,10 SAY 'Printing labels by archive no'

select 1
if !net_use('student', .f., 'std', 'stdarc')
  return
endif

select 2
IF .NOT. NET_USE('NEWLEADS', .f., 'LD', 'ldname')
  RETURN
ENDIF

nSt_cd = 0
nEnd_cd = 9999
dSt_dt := dEnd_dt := ctod('  /  /  ')
cBro_code = ' '
@8,10 say 'Start postal code' get nSt_cd picture '9999'
@9,10 say 'End postal code  ' get nEnd_cd picture '9999'
@11,10 say 'Start date' get dSt_dt
@12,10 say 'End date' get dEnd_dt
@14,10 say 'Brochure code ' get cBro_code picture '!' valid !empty(cBro_code)
read

OPENPRN()
PLINE = 1

DO WHILE !eof()
  if date_rcvd <= dEnd_dt .and. date_rcvd >= dSt_dt
    if val(p_code) <= nEnd_cd .and. val(p_code) >= nSt_cd
      if substr(misc_cd,2,1) = 'G'
        cArc = archiv
        select 1
        seek cArc
        if !found()
          select 2
          ? SPACE(20) + 'SMC ' + archiv
          ? TRIM(TITLE) + ' ' + TRIM(INiTLS) + ' ' + SURname
          ? ADDress1
          ? ADDress2
          ? ADDress3
          ? P_CODE
          ? ' '
          ? ' '
          ? ' '
          reclock('newleads')
          ld->bro_let := cBro_code
          unlock
        endif
	  endif
    endif
  endif
  select 2
  skip
ENDDO
SET CONSOL ON
SET PRINT OFF
CLOSE DATABASES
RETURN

*EOF