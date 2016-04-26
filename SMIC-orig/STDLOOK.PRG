*******************************************************************************
* PROGRAM 'STDLOOK'
* AUTHOR JIM WEST (E.T.)
* 1/2/88

select 1
if !net_use('student', .f.,, 'names')
  return
endif

simhead(memvar->pscr_title)
findstd()

if !eof()
  @2,30 say 'Student view screen'
  setcolor(memvar->scr_title)
  @4,50 say 'Group'
  @5,5 say 'Account no.'
  @5,50 say 'Archive no'
  @6,1 say 'Title:'
  @6,15 say 'First name:'
  @7,15 say 'Surname:'
  @8,63 say 'Status'
  @9,1 say 'Postal address'
  @13,1 say 'Postal Code:'
  @15,1 say 'Phone-Home:'
  @15,30 say 'Phone-Work:'
  if Student->stp_ls_lev != 0
    @15,60 say 'Stop loss level '
  endif
  @17,1 say 'Rep'
  @17,10 say 'Sales manager'
  @17,30 say 'Nat sales manager'
  @18,1 say 'Length of Simulation'
  @19,1 say 'Start Date:'
  @20,1 say 'Weeks on simultn'
  @21,1 say 'Unactive weeks'
  @19,30 say 'Initial value'
  @21,30 say 'Last Transaction'
  @18,65 say 'M1'
  @19,65 say 'M2'
  @20,65 say 'SS'
  @21,65 say 'LC'
  setcolor(memvar->disp_text)
  @4,56 say Student->group_cd + ' ' + Student->group_no
  @5,17 say Student->std_code
  @5,61 say Student->archiv
  @6,8 say Student->title
  @6,27 say Student->name
  @7,27 say Student->surname
  @8,63 say 'Status'
  do case
    case Student->status = 'C'
      @8,70 say 'Current'
    case Student->status = 'N'
      @8,70 say 'New stud'
    case Student->status = 'S'
      @8,70 say 'Suspended'
    case Student->status = 'F'
      @8,70 say 'Finished'
    case Student->status = 'U'
      @8,70 say 'Unpaid'
    otherwise
      @8,70 say 'INVALID'
  endcase
  @10,1 say Student->address1
  @11,1 say Student->address2
  @12,1 say Student->address3
  @13,17 say Student->p_code
  @15,13 say Student->phone_h
  @15,42 say Student->phone_w
  if Student->stp_ls_lev != 0
    @15,76 say str(Student->stp_ls_lev,2,0)
  endif
  @17,5 say Student->rep
  @17,24 say Student->s_m
  @17,48 say Student->n_s_m
  @18,23 say str(Student->simln_len,3,0)
  @19,19 say dtoc(Student->start_dt)
  @20,19 say str(Student->wk_smltn,3,0)
  @21,19 say str(Student->wk_unact,3,0)
  @19,49 say str(Student->initl_val,12,2)
  @21,49 say dtoc(Student->last_tran)
  @18,68 say dtoc(Student->sold_crs_1)
  @19,68 say dtoc(Student->sold_crs_2)
  @20,68 say dtoc(Student->sold_ss)
  @21,68 say dtoc(Student->sold_lectr)
  @22,0
  inkey(600)
*
endif (not eof)
close databases
return
* eof
