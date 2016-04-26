*******************************************************************************
*
*  SECPRNT - Prints details of security access
*
*

local nCnt, cTitle
memvar aTitles, aSec_nm
private aTitles := {'Name',;
    'Reps leads',;
    'Sales reports',;
    'Reindex files',;
    'System parameters',;
    'Rep control menu',;
    'Future control menu',;
    'System security',;
    'Data archiving',;
    'View Accounts',;
    'Edit accounts'}
private aSec_nm[0]

if !wmake_sure(15,,'Print security list')
  return
endif

if !net_use('security', .f.,,'secure')
  return
endif

cTitle = 'Security accesses'

openprn()

while !eof()
  nCnt = 0
  while nCnt < 10 .and. !eof()
    aadd(aSec_nm, {scram(Security->name), Security->rep_lds,;
        Security->sale_rep, Security->reindex, Security->sys_param,;
        Security->rep_menu, Security->fut_menu, Security->security,;
        Security->data_arc, Security->view_acc, Security->edit_acc})
    // These must be in corresponding order to aTitles
    dbskip()
  enddo
  if len(aSec_nm) > 1
    prntitle(cTitle, 'Y')
    sec_pr_line(1)
    ? ' '
    for nCnt = 2 to len(aSec_nm[1])
      sec_pr_line(nCnt)
    next
  endif
enddo
shutprn()
close databases

return

* eof secprnt

***********************************************************
procedure sec_pr_line(nNtx)
local cTitle, nCount, cPr
memvar aTitles, aSec_nm
cPr = aTitles[nNtx]
cPr += space(30-len(cPr))
? cPr
for nCount = 1 to len(aSec_nm)
  cPr = scram(aSec_nm[nCount, nNtx])
  if len(cPr) = 1       // control code
    cPr = if(cPr = 'Y', 'Y', 'N')
  endif
  ?? cPr + space(10-len(cPr))
next
return
