*******************************************************************************
*
* SYSPARAM - CHANGE OF SYSTEM PARAMETERS
*
*
*******************************************************************************

local aOptn, nChoice, cCol, cSect
memvar getlist

if !net_use('param', .f.)
  return
endif

@3,0 clear
@5,20 say 'Edit System Parameters'

aOptn := {'Screen heading',;
    'Print heading',;
    'Address and phone no',;
    'Overdraft limit',;
    'Interest paid on credit balance',;
    'Interest to be paid on overdraft',;
    'Debit Order Details',;
    'Change printer type',;
    ' ',;
    'Return'}

nChoice = 1
while nChoice != len(aOptn) .and. nChoice != 0
  nChoice = get_arr(aOptn,,,memvar->yell_black, .t.)
  if nChoice < 7
    wopen(10,5,22,75)
    cCol = setcolor(memvar->black_brown+',' + memvar->yell_black)
    wbox()
    do case
      case nChoice = 1
        memvar->pscr_title = param->scr_title
        @1,0 say center('Enter new screen heading')
        @2,5 get memvar->pscr_title
        read
        reclock('param')
        param->scr_title := memvar->pScr_title
        dbunlock()
      case nChoice = 2
        memvar->ppnt_title = param->prnt_title
        @1,0 say center('Enter new print heading')
        @2,5 get memvar->ppnt_title
        read
        reclock('param')
        param->prnt_title := memvar->ppnt_title
        dbunlock()
      case nChoice = 3
        memvar->pp_addr1 = param->p_addr1
        memvar->pp_addr2 = param->p_addr2
        memvar->pp_addr3 = param->p_addr3
        memvar->pp_code = param->p_code
        memvar->pst_addr1 = param->st_addr1
        memvar->pst_addr2 = param->st_addr2
        memvar->pst_addr3 = param->st_addr3
        memvar->pst_p_code = param->st_p_code
        memvar->pphone_no = param->phone_no
        memvar->pfax_no = param->fax_no
        memvar->ptwin_cont = param->twin_cont
        @1,0 say center('Company address details')
        @2,2 say 'Postal Address'
        @2,36 say 'Street address'
        @3,2 get memvar->pp_addr1
        @4,2 get memvar->pp_addr2
        @5,2 get memvar->pp_addr3
        @6,2 get memvar->pp_code
        @3,36 get memvar->pst_addr1
        @4,36 get memvar->pst_addr2
        @5,36 get memvar->pst_addr3
        @6,36 get memvar->pst_p_code
        @8,2 say 'Phone ' get memvar->pphone_no
        @8,36 say 'Fax ' get memvar->pfax_no
        @10,20 say 'Twin contact ' get memvar->ptwin_cont
        read
        reclock('param')
        param->p_addr1   := memvar->pp_addr1
        param->p_addr2   := memvar->pp_addr2
        param->p_addr3   := memvar->pp_addr3
        param->p_code    := memvar->pp_code
        param->st_addr1  := memvar->pst_addr1
        param->st_addr2  := memvar->pst_addr2
        param->st_addr3  := memvar->pst_addr3
        param->st_p_code := memvar->pst_p_code
        param->phone_no  := memvar->pphone_no
        param->fax_no    := memvar->pfax_no
        param->twin_cont := memvar->ptwin_cont
        dbunlock()
      case nChoice = 4
        memvar->povrdrft_lm = param->ovrdrft_lm
        @1,0 say center('Enter new overdraft limit')
        @2,15 get memvar->povrdrft_lm
        read
        reclock('param')
        param->ovrdrft_lm := memvar->povrdrft_lm
        dbunlock()
      case nChoice = 5
        memvar->pinterest = param->interest
        @1,0 say center('Enter new Interest rate on credit balance')
        @2,15 get memvar->pinterest
        read
        reclock('param')
        param->interest := memvar->pinterest
        dbunlock()
      case nChoice = 6
        memvar->plending = param->lending
        @1,0 say center('Enter new Lending rate on overdraft')
        @2,15 get memvar->plending
        read
        reclock('param')
        param->lending := memvar->plending
        dbunlock()
    endcase
    wclose()
  else
    do case
      case nChoice = 7
        prm_do_edit()
      case nChoice = 8
        do pr_ch
    endcase
  endif
enddo
dbcloseall()
return

* eof()

*******************************************************************************
*
* PRM_DO_EDIT - EDIT DEBIT ORDER DETAILS
*
*******************************************************************************
static procedure prm_do_edit

local aDo_optn := {'Company code',;
    'Company name',;
    'User reference',;
    'Next cut-off date',;
    'Next action date',;
    'Quit'}
local cDo_scr, nChoice
local cDo_code, cDo_name, cUsr_ref, dNxt_cut, dNxt_act
memvar getlist

nChoice = 1
while nChoice != len(aDo_optn) .and. nChoice != 0
  nChoice = get_arr(aDO_optn,7,15)
  wopen(10,5,14,75)
  setcolor(memvar->black_brown+','+memvar->yell_black)
  wbox()
  do case
    case nChoice = 1
      cDo_code = param->do_co_code
      @1,0 say center('Enter D/O Company code')
      @2,10 get cDo_code
      read
      reclock('param')
      param->do_co_code := cDo_code
      dbunlock()
    case nChoice = 2
      cDo_name = param->do_co_name
      @1,0 say center('Enter D/O Company name')
      @2,15 get cDo_name
      read
      reclock('param')
      param->do_co_name := cDo_name
      dbunlock()
    case nChoice = 3
      cUsr_ref = param->do_usr_ref
      @1,0 say center('Enter D/O User Reference')
      @2,20 get cUsr_ref
      read
      reclock('param')
      param->do_usr_ref := cUsr_ref
      dbunlock()
    CASE nChoice = 4
      dNxt_cut = param->nxt_cut_dt
      @1,0 say center('Next cut-off date for debit orders')
      @2,30 get dNxt_cut
      read
      reclock('param')
      param->nxt_cut_dt := dNxt_cut
      dbunlock()
    CASE nChoice = 5
      dNxt_act = param->nxt_do_dt
      @1,0 say center('Next action date for debit orders')
      @2,30 get dNxt_act
      read
      reclock('param')
      param->nxt_do_dt := dNxt_act
      dbunlock()
  endcase
  wclose()
enddo
return

* EOF
