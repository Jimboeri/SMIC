*******************************************************************************
* SMIC.CH - HEADER FILE FOR SMIC PROGRAMS

errorblock({| in_error | sys_error(in_error)})

public pr_compress := chr(15), pr_form_fe := chr(12), pr_reset := chr(18)
pr_comp_off = chr(18)
memvar->cPath = getenv("PATH")
set path to (memvar->cPath)
if file('printer.mem')
  restore from printer additive
endif
set path to

set deleted on
set date british

public lPr_esc := .f.
public nTime_out := 300

PUBLIC PLINE, PPAGE
PUBLIC MPW_NME, MPW_PAS, MPW_LEV
PUBLIC disp_text, scr_heading, ach_col, ach_col2, ach_col3, info_col
public warn_col, scr_title, cCo_name

memvar->disp_test := memvar->info_col := memvar->white_black
memvar->scr_heading := memvar->scr_title := memvar->magen_black
memvar->ach_col := memvar->ach_col2 := memvar->ach_col3 := memvar->white_black
memvar->warn_col := memvar->white_red

memvar->pline := memvar->ppage := 0

if !net_use('param', .f.)
  return
endif

memvar->pscr_title := trim(param->scr_title) + ' ' + trim(param->version)
memvar->ppnt_title := param->prnt_title
memvar->plst_price := param->lst_price
memvar->plst_f_upd := param->lst_f_updt
memvar->povrdrft_l := param->ovrdrft_lm
memvar->cCo_name   := trim(param->co_name)
dbclosearea()

memvar->mpw_nme = space(10)
memvar->mpw_pas = space(6)
memvar->mpw_lev = 9

* EOF()
