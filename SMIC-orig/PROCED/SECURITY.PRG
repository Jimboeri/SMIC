*******************************************************************************
* SECURITY - Keeps programs safe
* JIM WEST
* 02/89

parameters cProgram

local lRight, nTries, cPass, cPW_pas, cPW_pas1, cPW_pas2, cAccess, cDt
local cChange, cNew
memvar mPw_nme, getlist, mPW_lev, cProgram
memvar white_black, black_brown, warn_col
memvar aMain_menu

select 1
while !net_use('security', .f.,, 'secure')
  @23,10 say 'WAITING FOR SECURITY FILE'
enddo

simhead(memvar->pscr_title)
lRight = .F.
nTries = 0

MPW_NME = space(10)
do while !lRight .and. nTries < 3
  nTries++
  MPW_NME = space(10)
  @8,10 say 'Enter your name ' get mpw_nme picture '@!'
  read
  if dbseek(mpw_nme)
    lRight = .T.
    @8,27 say MPW_NME
  endif
enddo

if !lRight
  @20,10 say "If you don't know what your name is, you can't use this program"
  wait
  close database
  clear all
  quit
endif

lRight = .T.
if !empty(scram(security->pass_word)) .or. security->level != 0
  cPW_pas = space(6)
  nTries = 0
  lRight = .F.
  setcolor('W/N,N/N')
  do while !lRight .and. nTries < 3
    nTries++
    cPW_pas = space(6)
    @12,10 say 'Enter password ' get cPW_pas picture '@!'
    read
    @12,26 say space(6)
    cPass = scram(security->pass_word)
    IF cPW_pas = cPass
      lRight = .T.
    endif
  enddo
  setcolor(white_black+','+black_brown)
endif

if !lRight
  @20,10 say 'Incorrect password - Access denied'
  wait
  close database
  clear all
  quit
endif

mpw_lev = security->level

do case
  case cProgram = 'PORTPRNT'
    cAccess = scram(security->acc_7)
    if upper(cAccess) != 'Y'
      disp_msg(19, warn_col, 'You are not authorised for this program - contact E.T.')
      inkey(20)
      close database
      clear
      clear all
      quit
    endif
  case cProgram = 'SMIC'
    aadd(aMain_menu, smic_n_to_c(1))           // enquires
    aadd(aMain_menu, smic_n_to_c(11))          // computer notes
    if scram(security->twin) = 'Y'
      aadd(aMain_menu, smic_n_to_c(12))        // twin trading
    endif
    if scram(security->edit_acc) = 'Y'
      aadd(aMain_menu, smic_n_to_c(6))         // edit accounts
    endif
    if scram(security->view_acc) = 'Y'
      aadd(aMain_menu, smic_n_to_c(5))         // view accounts
    endif
    if scram(security->add_std) = 'Y'
      aadd(aMain_menu, smic_n_to_c(8))         // add edit students
    endif
    if scram(security->std_print) = 'Y'
      aadd(aMain_menu, smic_n_to_c(13))        // students prints
    endif
    if scram(security->leads) = 'Y'
      aadd(aMain_menu, smic_n_to_c(7))         // leads
    endif
    if scram(security->sale_rep) = 'Y'
      aadd(aMain_menu, smic_n_to_c(3))         // sales reports
    endif
    if scram(security->adverts) = 'Y'
      aadd(aMain_menu, smic_n_to_c(10))        // adverts
    endif
    if scram(security->media) = 'Y'
      aadd(aMain_menu, smic_n_to_c(9))         // media reports
    endif
    if scram(security->rep_lds) = 'Y'
      aadd(aMain_menu, smic_n_to_c(2))         // reps leads menu
    endif
    if scram(security->share) = 'Y'
      aadd(aMain_menu, smic_n_to_c(14))        // share maintance
    endif
    if scram(security->std_twin) = 'Y'
      aadd(aMain_menu, smic_n_to_c(15))        // student transaction
    endif
    if scram(security->reindex) = 'Y';
     .or. scram(security->security) = 'Y';
     .or. scram(security->sys_param) = 'Y';
     .or. scram(security->fut_menu) = 'Y';
     .or. scram(security->rep_menu) = 'Y';
     .or. scram(security->data_arc) = 'Y'
      aadd(aMain_menu, smic_n_to_c(4))         // system control functions
    endif
  otherwise
    @19,10 SAY 'This program not included - contact E.T.'
    wait
    close database
    clear all
    quit
endcase

cChange = 'N'
if !empty(scram(security->pass_word)) .or. security->level != 0
  @15,10 say 'Do you want to change your password ' get cChange picture '!'
  read
endif

if cChange = 'Y'
  cPW_pas1 = space(6)
  @2,0 clear
  @5,10 say 'Enter your OLD password ' get cPW_pas1 picture '@!'
  read
  cPass = scram(security->pass_word)
  if cPW_pas1 != cPass
    @10,10 say 'OLD pass word incorrectly entered - No changes made'
    wait
  else
    cNew = space(6)
    cPW_pas2 = space(6)
    @10,10 say 'Enter new pass word ' get cNew picture '@!'
    read
    @10,31 say space(6)
    @12,10 say 'Enter new pass word again ' GET cPW_pas2 PICTURE '!!!!!!'
    read
    @12,37 say space(6)
    IF cNew = cPW_pas2
      reclock('Security')
      security->pass_word := scram(cNew)
      security->lst_pw_dt := date()
      cPW_pas = cPW_pas2
      dbunlock()
    else
      @20,10 say 'You must enter it in correctly TWICE - Nothing has changed'
      wait
    endif (new password correct)
  endif (old password correct)
  @2,0 clear
endif

close database
return

*EOF
