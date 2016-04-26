if !net_use('Security', .f.)
  return
endif

while !eof()
  reclock()
  Security->Pass_word := scram(Security->pass_word)
  Security->acc_1      := scram(Security->acc_1)
  Security->acc_2      := scram(Security->acc_2)
  Security->acc_3      := scram(Security->acc_3)
  Security->acc_4      := scram(Security->acc_4)
  Security->acc_5      := scram(Security->acc_5)
  Security->acc_6      := scram(Security->acc_6)
  Security->acc_7      := scram(Security->acc_7)
  Security->acc_8      := scram(Security->acc_8)
  Security->acc_9      := scram(Security->acc_9)
  Security->Rep_lds   := scram(Security->Rep_lds)
  Security->Sale_rep  := scram(Security->Sale_rep)
  Security->Reindex   := scram(Security->Reindex)
  Security->Security  := scram(Security->Security)
  Security->Sys_param := scram(Security->Sys_param)
  Security->Fut_menu  := scram(Security->Fut_menu)
  Security->Rep_menu  := scram(Security->Rep_menu)
  Security->Data_arc  := scram(Security->Data_arc)
  Security->view_acc  := scram(Security->view_acc)
  Security->edit_acc  := scram(Security->edit_acc)
  Security->Add_std   := scram(Security->Add_std)
  Security->leads     := scram(Security->leads)
  Security->media     := scram(Security->media)
  Security->adverts   := scram(Security->adverts)
  Security->Twin      := scram(Security->Twin)
  Security->Std_print := scram(Security->std_print)
  Security->Share     := scram(Security->Share)
  Security->Std_Twin  := scram(Security->std_Twin)

  dbunlock()
  dbskip()
enddo

quit
