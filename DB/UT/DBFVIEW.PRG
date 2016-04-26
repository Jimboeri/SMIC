*******************************************************************************
* dbfview

#include 'inkey.ch'

select &cAlias

cCol = setcolor(black_green)
cSect = draw_box(5,10,22,70)
while .t.
  for nCnt = 1 to 16
    @5+nCnt,12 say fieldname(nCnt)
    nVal = fieldget(nCnt)
    if valtype(nVal) = 'C'
      @5+nCnt,25 say nVal
    elseif valtype(nVal) = 'N'
      @5+nCnt,25 say str(nVal)
    elseif valtype(nVal) = 'D'
      @5+nCnt,25 say dtoc(nVal)
    endif
  next
  nKey = inkey(0)
  do case
    Case nkey = K_ESC
      exit
    case nKey = K_DOWN
      dbskip()
    case nKey = K_UP
      dbskip(-1)
    case nKey = K_ALT_P
      pr_rec()
  endcase
enddo
restsector(cSect)
setcolor(cCol)
return

