*******************************************************************************
* TRNOLD - DELETES OLD TRANSACTION FROM THE TRNSTORE FILE
* JIM WEST

local dDelete, cTitle
local aProgress := {'|', '/', '-', '\'}, nProgress := 1
memvar getlist, pLine

simhead(memvar->pscr_title)

dDelete = ctod('  /  /  ')
@5,10 say 'Delete old transactions before ' get dDelete picture '@d'
read

if !wmake_sure(12,,'Delete old transactions (Y/N) ?')
  return
endif
if !net_use('trnstore', .t.)
  return
endif

openprn()
cTitle = 'Transactions made before ' + dtoc(dDelete) +;
    ' that have been deleted'

wopen(10,15,12,65)
setcolor(memvar->black_green)
wbox()
setcursor(0)
@0,3 say 'Printing and deleteing old transactions'

while !eof()
  @0,46 say aProgress[nProgress]
  if nProgress < 4
    nProgress++
  else
    nProgress = 1
  endif
  if Trnstore->trn_dt <= dDelete
    if pline > 57
      prntitle(cTitle, 'Y')
    endif
    pr_line(Trnstore->std_code + ' ' +Trnstore->share + ' ' +;
        Trnstore->trn_type + ' ' + str(Trnstore->qty) + ' ' +;
        str(Trnstore->price) + ' ' + str(Trnstore->brokerage) + ' ' +;
        str(Trnstore->tax) + ' ' + str(Trnstore->handle) + ' ' +;
        str(Trnstore->value) + ' ' + dtoc(Trnstore->trn_dt) + ' ' +;
        str(Trnstore->cost_hold))
    dbdelete()
  endif
  dbskip()
enddo
wclose()
shutprn()
pack
dbcloseall()
return

*EOF
