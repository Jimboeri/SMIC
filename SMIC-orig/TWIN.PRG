*******************************************************************************
* 'TWIN' STUDENt AND TRADING PROGRAM
* Author - Jim West
* 1/2/88
* ----     SET UP SYSTEM DEFAULTS

local cName, nKey, cChar, cScr, bSave_f4, mcomment
memvar aOth_trn, portfol_type, lTrade, lPrice, cStop_trans, aVal_std

#include 'inkey.ch'

private PORTFOL_TYPE     // TYPE OF PORTFOLIO TO WORK ON
private lTrade, lPrice, cStop_trans
private aVal_std[6]
nKey = 0

begin sequence
  select 1
  if empty(et_use_dbf('param'))
    break
  endif
  
  cName = param->lst_std
  if param->lst_price = date()
    lPrice = .t.
  else
    lPrice = .f.
  endif
  
  cStop_trans = param->stop_trans
  dbclosearea()
  
  select 1
  if !net_use('transact', .f., , 'trancode')
    break
  endif
  
  select 2
  if !net_use('student', .f.,, 'stdcode', 'names', 'stdarc', 'stdgroup')
    break
  endif
  dbsetorder(2)
  
  select 3
  if !net_use('share', .f.,, 'shrname')
    break
  endif
  
  select 4
  if !net_use('portfol', .f.,, 'portfol')
    break
  endif
  
  select 5
  if !net_use('bear', .f.,, 'bear')
    break
  endif
  
  select 6
  if !net_use('order', .f.,, 'order')
    break
  endif
  
  select 7
  if !net_use('shrdescr', .f.,, 'shrdescr')
    break
  endif
  
  select student
  if !dbseek(cName)
    dbgotop()
  endif
  cName = student->surname + student->name
  
  if Student->status != 'C' .or. !lPrice
    lTrade = .f.
  else
    lTrade = .t.
  endif
  
  if cStop_trans = 'Y'
    lTrade = .f.
  endif
  
  PORTFOL_TYPE = 'T'      // 'T' = TWIN
  if !empty(Student->sold_pas)
    PORTFOL_TYPE = 'P'    // 'P' = PORTFOLIO ADVISORY SERVICE
  endif
  if (!empty(Student->sold_els) .or. !empty(student->sold_crs_1)) .and.;
        Student->status = 'C'
    PORTFOL_TYPE = 'T'    // 'T' = TWIN
  endif
  backdisp()
  twndisp()
  
  bSave_f4 = setkey(K_F4, nil)
  
  while nKey != K_ESC
    cScr = savesector(0,0,24,79)
    set cursor off
    nKey = inwait()
    cChar = chr(nKey)
    set cursor on
    do case
      case isalpha(cChar)  // character entered - choose new student
        cChar = upper(cChar)
        select Student
        findstd(cChar)
        if eof()
          dbseek(cName)
        else
          cName = Student->surname + Student->name
        endif
        if Student->status != 'C' .or. !lPrice
          lTrade = .f.
        else
          lTrade = .t.
        endif
        select 11
        if net_use('param', .f.)
          cStop_trans = param->stop_trans
          if cStop_trans = 'Y'
            lTrade = .f.
          endif
          dbclosearea()
        endif
        select Student
        PORTFOL_TYPE = 'T'        // 'T' = TWIN
        if !empty(Student->sold_pas)
          PORTFOL_TYPE = 'P'      // 'P' = PORTFOLIO ADVISORY SERVICE
        endif
        if (!empty(Student->sold_els) .or. !empty(student->sold_crs_1)) .and.;
              Student->status = 'C'
          PORTFOL_TYPE = 'T'      // 'T' = TWIN
        endif
        backdisp()
        twndisp()
      case nKey = K_LEFT .or. nKey = K_RIGHT  // left or right arrow - change from
        if PORTFOL_TYPE = 'T'     // TWIN TO PAS AND VISA VERSA
          if !empty(Student->sold_pas)
            PORTFOL_TYPE = 'P'
          ENDIF
        ELSEIF PORTFOL_TYPE = 'P'
          if (!empty(Student->sold_els) .or. !empty(student->sold_crs_1)) .and.;
                Student->status = 'C'
            PORTFOL_TYPE = 'T'
          endif
        endif
        twndisp()
      case nKey = K_F2 .OR. nKey = K_ALT_B      // F2 OR Alt B
        if LTrade .and. PORTFOL_TYPE = 'T'
          do trnbuy
        elseif portfol_type = 'P'
          do trnpas
        endif
        restsector(cScr)
        twndisp()
      case nKey = K_F3 .or. nKey = K_ALT_S      // F3 OR Alt S
        if lTrade .and. portfol_type = 'T'
          do trnsell
        endif
        restsector(cScr)
        twndisp()
      case nKey = K_F4 .or. nKey = K_ALT_D      // F4 OR Alt D
        do trndisp with portfol_type
        restsector(cScr)
      case nKey = K_F5 .or. nKey = K_ALT_O      // F5 OR Alt O
        if lTrade
          do othtrnmn
        endif
        restsector(cScr)
        twndisp()
      case nKey = K_F6 .or. nKey = K_ALT_F      // F6 OR Alt F
        if lTrade
          do futuremn
        endif
        restsector(cScr)
      case nKey = K_F7 .or. nKey = K_ALT_T      // F7 OR Alt T
        do stdmenu2
        if Student->status != 'C' .or. !lPrice
          lTrade = .f.
        else
          lTrade = .t.
        endif
        backdisp()
        twndisp()
      case nKey = K_F8 .or. nKey = K_ALT_H      // F8 OR Alt H
        do shrmenu
        restsector(cScr)
        twndisp()
      case nKey = K_F10      // F10
        if !empty(Student->comment)
          draw_box(10,5,22,47)
          mComment = Student->comment
          mComment = memoedit(mComment, 11, 6, 21, 46, .f., 'justview')
          inkey(0)
          inwait(0)
          restsector(cScr)
        endif
      case nKey = K_ESC
        if !make_sure(10,,'Return to menu ?')
          nKey = 0
        endif
    endcase
  enddo
end sequence
dbcloseall()

setkey(K_F4, bSave_f4)

if net_use('param', .f.)
  reclock('param')
  param->lst_std = cName
  dbunlock()
endif
dbclosearea()
clear screen

RETURN

* EOF()

***********************************************************
* TWNDISP DISPLAYS STUDENT DETAILS

procedure twndisp

local cName
select Student
setcolor(memvar->WHITE_BLACK)
@4,1 clear to 23,40
@5,3 say 'Name'
@7,3 say 'Address'
@10,3 say 'Phone (W)'
@11,3 say 'Phone (H)'
@13,3 say 'Archive no'
@13,26 say 'Acc no'
@15,3 say 'Rep     S.M.     N.S.M.'
@17,3 say 'ELS'
@18,3 say 'M1'
@19,3 say 'M2'
@17,18 say 'PORT'
@18,18 say 'LEC'
@19,18 say 'SS'

setcolor(memvar->yell_black)
cName = trim(Student->title) + ' ' + trim(Student->name) + ' ' +;
    trim(Student->surname)
if len(cName) < 28
  @5,10 say cName
else
  @5,10 say trim(Student->title) + ' ' + trim(Student->name)
  @6,10 say trim(Student->surname)
endif
setcolor(memvar->cyan_black)
@7,11 say Student->address1
@8,11 say Student->address2
@9,11 say Student->p_code + ' ' + trim(Student->address3)
@10,13 say Student->phone_w
@11,13 say Student->phone_h
@13,14 say Student->archiv
@13,33 say Student->std_code
@15,7 say Student->rep
@15,16 say Student->s_m
@15,27 say Student->n_s_m
@17,7 say dtoc(Student->sold_els)
@18,7 say dtoc(Student->sold_crs_1)
@19,7 say dtoc(Student->sold_crs_2)
@17,24 say dtoc(Student->sold_pas)
@18,24 say dtoc(Student->sold_lectr)
@19,24 say dtoc(Student->sold_ss)
if !empty(Student->comment)
  @21,8 say 'Comment exists - press F10'
endif

if memvar->Portfol_type = 'T'
  setcolor(memvar->black_cyan)
else
  setcolor(memvar->cyan_black)
endif
@4,42 clear to 23,59
if !empty(Student->sold_crs_1)
  @5,48 say 'TWIN'
elseif !empty(Student->sold_els)
  @5,44 say 'ENTRY LEV SERV'
endif
@6,43 say 'Status'

@8,43 say 'Sim length'
@9,43 say 'Wks on sim'
@10,43 say 'Wks unact'
@11,43 say 'St dt'
@12,43 say 'Lst trn'
@14,43 say 'Initial value'
@16,43 say 'Cash available'
if Student->stp_ls_lev != 0
  @21,43 say 'Stp ls lev'
endif

@6,50 say str_stat(student->status)
@8,56 say str(Student->simln_len,3,0)
@9,56 say str(Student->wk_smltn,3,0)
@10,56 say str(Student->wk_unact,3,0)
@11,51 say dtoc(Student->start_dt)
@12,51 say dtoc(Student->last_tran)
@15,47 say str(Student->initl_val,12,2)
@17,47 say str(Student->cash,12,2)
if Student->stp_ls_lev != 0
  @21,56 say str(Student->stp_ls_lev,2,0) + '%'
ENDIF

if !empty(Student->sold_pas)
  if memvar->Portfol_type = 'P'
    setcolor(memvar->black_cyan)
  else
    setcolor(memvar->cyan_black)
  endif
  @4,61 clear to 23,78
  @6,63 say 'PORTFOLIO'
  @8,63 say 'ADVISORY'
  @10,63 say 'SERVICE'
endif

setcolor(memvar->white_black+','+memvar->black_brown)

if !memvar->lPrice
  disp_msg(20,, 'Share prices not yet captured')
endif

if memvar->cStop_trans = 'Y'
  disp_msg(20,, 'Transactions stopped for portfolio printout')
endif

* INITIALIZE ALL RELEVANT VARIABLES
afill(memvar->aVal_std, .T.)
if Student->status != 'C' .or. Student->group_no != '01'
  memvar->aVal_std[2] = .f.     // suspend
endif
if (Student->status != 'S' .and. Student->status != 'U') .or.;
      student->group_no != '01'
  memvar->aVal_std[3] = .f.     // reinstate
endif
return

***********************************************************
* BACKDISP - CREATES BACKGROUND DISPLAY FOR TWIN
procedure backdisp
local nCnt
setcolor(memvar->white_black)
clear screen
@0,0 to 24,79
@0,0 to 3,79
@3,0 say 'Ã'
@3,79 say '´'
@3,41 say 'Â'
@24,41 say 'Á'
for nCnt = 4 to 23
  @nCnt,41 say '³'
next
@3,60 say 'Â'
@24,60 say 'Á'
for nCnt = 4 TO 23
  @nCnt,60 say '³'
next
@1,2 say 'F1'
@1,10 say 'F2'
@1,17 say 'F3'
@1,24 say 'F4'
@1,34 say 'F5'
@1,43 say 'F6'
@1,52 say 'F7'
@1,61 say 'F8'
@1,70 say 'F10'

@2,2 say 'help' // F1
@2,11 say 'uy'  // F2
@2,18 say 'ell' // F3
@2,25 say 'isplay'      // F4
@2,35 say 'th trn'      // F5
@2,44 say 'uture'       // F6
@2,52 say 'S udent'     // F7
@2,61 say 'S are'       // F8
@2,72 say 'omment'      // F10

IF !memvar->lTrade .AND. memvar->Portfol_type != 'P'
  @2,10 say 'B' // F2
  @2,17 say 'S' // F3
  @2,34 say 'O' // F5
  @2,43 say 'F' // F6
ENDIF

setcolor(memvar->yell_black)
@0,34 say ' T W I N '
if memvar->lTrade .or. memvar->Portfol_type = 'P'
  @2,10 say 'B' // F2
  @2,17 say 'S' // F3
  @2,34 say 'O' // F5
  @2,43 say 'F' // F6
endif
@2,24 say 'D'   // F4
@2,53 say 'T'   // F7
@2,62 say 'H'   // F8
@2,71 say 'C'   // F10
setcolor(memvar->disp_text)
return
