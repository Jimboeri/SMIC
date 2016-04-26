*******************************************************************************
* PROGRAM 'SECEDIT'
* AUTHOR JIM WEST (E.T.)
* 1/2/88

local cName, cPass, nLevel, cRep_lds, cSale_rep, cReindex, cSecurity
local cSys_param, cFut_menu, cRep_menu, cData_arc, cview_acc, cedit_acc
local cAdd_std, cleads, cmedia, cadverts, cTwin, cStd_print, cShare, cStd_Twin

memvar getlist

if !net_use('security', .f.,, 'secure')
  return
endif

simhead(memvar->pscr_title)
@3,30 SAY 'Security edit screen'
cName = space(10)
@4,1 say 'Card holder ' get cName picture '!!!!!!!!!!'
@10,5 say 'Enter card holder or hit enter to return to menu'
read
if empty(cName)
  dbcloseall()
  return
endif
if !dbseek(cName)
  if wmake_sure(15,,'Add ' + trim(cName) + ' to the password list')
    dbappend()
    reclock('security')
    Security->name := cName
    dbunlock()
  else
    dbcloseall()
    return
  endif
endif
if !rlock()
  disp_msg(20,,'SECURITY RECORD IN USE - PLEASE TRY LATER')
  inkey(10)
else
  @4,0 clear
  @4,1 say 'Card holder  ' + cName + space(5)
  cPass      = scram(Security->pass_word)
  nLevel     = Security->level
  cRep_lds   = scram(Security->Rep_lds)
  cSale_rep  = scram(Security->Sale_rep)
  cReindex   = scram(Security->Reindex)
  cSecurity  = scram(Security->Security)
  cSys_param = scram(Security->Sys_param)
  cFut_menu  = scram(Security->Fut_menu)
  cRep_menu  = scram(Security->Rep_menu)
  cData_arc  = scram(Security->Data_arc)
  cview_acc  = scram(Security->view_acc)
  cedit_acc  = scram(Security->edit_acc)
  cAdd_std   = scram(Security->Add_std)
  cleads     = scram(Security->leads)
  cmedia     = scram(Security->media)
  cadverts   = scram(Security->adverts)
  cTwin      = scram(Security->Twin)
  cStd_print = scram(Security->std_print)
  cShare     = scram(Security->Share)
  cStd_Twin  = scram(Security->std_Twin)

  @6,0 SAY 'Password           ' GET cPass PICTURE '!!!!!!!!!!'
  @8,0 say 'Leads for reps     ' get cRep_lds picture '!' valid jw_val_yn()
  @9,0 say 'Sales reports      ' get cSale_rep picture '!' valid jw_val_yn()
  @10,0 say 'Reindexing         ' get cReindex picture '!' valid jw_val_yn()
  @11,0 say 'Security           ' get cSecurity picture '!' valid jw_val_yn()
  @12,0 say 'Rep control        ' get cRep_menu picture '!' valid jw_val_yn()
  @13,0 say 'System parameters  ' get cSys_param picture '!' valid jw_val_yn()
  @14,0 say 'Futures control prg' get cFut_menu picture '!' valid jw_val_yn()
  @15,0 say 'Data archiving     ' get cdata_arc picture '!' valid jw_val_yn()
  @16,0 say 'View accounts      ' get cView_acc picture '!' valid jw_val_yn()
  @17,0 say 'Edit accounts      ' get cedit_acc picture '!' valid jw_val_yn()
  @18,0 say 'Add students       ' get cAdd_std picture '!' valid jw_val_yn()
  @19,0 say 'Add leads          ' get cleads picture '!' valid jw_val_yn()
  @20,0 say 'Media reports      ' get cmedia picture '!' valid jw_val_yn()
  @21,0 say 'Adverts            ' get cadverts picture '!' valid jw_val_yn()
  @8,40 say 'TWIN TRADING       ' get cTwin picture '!' valid jw_val_yn()
  @9,40 say 'Student prints     ' get cStd_print picture '!' valid jw_val_yn()
  @10,40 say 'Share maintaince   ' get cShare picture '!' valid jw_val_yn()
  @11,40 say 'Student : TWIN     ' get cStd_twin picture '!' valid jw_val_yn()
  @13,40 SAY 'Security level ' GET nLevel PICTURE '9'
  
  *
  read
  Security->pass_word := scram(cPass)
  Security->Rep_lds   := scram(cRep_lds)
  Security->Sale_rep  := scram(cSale_rep)
  Security->Reindex   := scram(cReindex)
  Security->Security  := scram(cSecurity)
  Security->Sys_param := scram(cSys_param)
  Security->Fut_menu  := scram(cFut_menu)
  Security->Rep_menu  := scram(cRep_menu)
  Security->Data_arc  := scram(cData_arc)
  Security->view_acc  := scram(cView_acc)
  Security->edit_acc  := scram(cEdit_acc)
  Security->Add_std   := scram(cAdd_std)
  Security->leads     := scram(cleads)
  Security->media     := scram(cmedia)
  Security->adverts   := scram(cadverts)
  Security->twin      := scram(cTwin)
  Security->std_print := scram(cStd_print)
  Security->share     := scram(cShare)
  Security->std_twin  := scram(cstd_Twin)
  Security->level     := nLevel
  Security->lst_pw_dt := date()
  dbunlock()
endif (rec locked)
dbcloseall()
return
* eof
