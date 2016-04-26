*******************************************************************************
*
* StdLect - control of lectures

local cCol, cSect, nCnt, cFld
memvar getlist, cErrsect, aLec

select Student
if !rlock()
  wait_msg(20, 'Student already in use - Please try later',,,20)
  return
endif

cCol = setcolor(memvar->blue_cyan)

cSect = draw_box(1,10,23,60)
aLec = {}
for nCnt = 1 to 20
  cFld = 'LEC' + ltrim(str(nCnt,2,0))
  aadd(aLec, &cFld)
next

for nCnt = 1 to 20
  @1+nCnt, 15 say 'Lecture ' + str(nCnt,2,0) + ' ' get aLec[nCnt] picture '!';
      valid val_stdlect()
next
cErrSect = savesector(20,10,24,70)
read

for nCnt = 1 to 20
  cFld = 'Student->LEC' + ltrim(str(nCnt,2,0))
  &cFld = aLec[nCnt]
next

dbunlock()

restsector(cSect)
setcolor(cCol)

return

***********************************************************
function val_stdlect
local cVar, cVal
restsector(memvar->cErrSect)
cVar = readvar()
cVal = &cVar
if cVal $ 'YP '
  return(.t.)
endif
disp_msg(20,, "Entries can be : space - not paid for & not received",;
    "'P' - paid for, not recieved or 'Y' - the lecture has been sent")
return(.f.)
