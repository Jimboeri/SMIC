*******************************************************************************
*
*  Merge.prg
*

local aCh := {'Create merge file', 'Add more students', 'Abort program'}
local nCh
memvar aNames, aStudent, cRun1, cRun2, cRun3, getlist, nCnt
private aNames := {}, astudent := {}
private cRun1 := cRun2 := cRun3 := space(30)

select 1
if !net_use('student', .f.,,'names')
  return
endif

simhead(memvar->pScr_title)

@5,5 say 'S1 ' get cRun1
@6,5 say 'S2 ' get cRun2
@7,5 say 'S3 ' get cRun3
read

cRun1 = if(empty(cRun1), ' ', trim(cRun1))
cRun2 = if(empty(cRun2), ' ', trim(cRun2))
cRun3 = if(empty(cRun3), ' ', trim(cRun3))

nCh = 2
while nCh != 1 .and. nCh != len(ach)
  merge_std()
  nCh = get_arr(aCh)
enddo

if nCh = 1
  set alternate to merge.txt
  set alternate on
  set console off
  for nCnt = 1 to len(aStudent)
    ?? cRun1
    ? cRun2
    ? cRun3
    ? aStudent[nCnt,1]
    ? aStudent[nCnt,2]
    ? aStudent[nCnt,3]
    ? aStudent[nCnt,4]
    ? aStudent[nCnt,5]
    ? aStudent[nCnt,6]
    ? aStudent[nCnt,7]
    ? ''
    ? ''
  next
  set alternate off
  close alternate
  set console on
endif
dbcloseall()
return

*******************************************************************************
procedure merge_std
local cStd1, cStd2, cName1, cName2, nTemp
memvar getlist, nCnt
select student
dbgobottom()
while !eof()
  findstd()
  if !eof()
    cStd1 := cStd2 := space(30)
    cName1 := prop_noun(trim(student->title)) + ' ' +;
     prop_noun(trim(student->name));
        + ' ' + prop_noun(trim(student->Surname)) + space(30)
    cName2 := prop_noun(trim(student->name)) + space(30)
    @10,5 say 'Name 1     ' get cName1
    @11,5 say 'Name 2     ' get cName2
    @13,5 say 'Std info 1 ' get cStd1
    @14,5 say 'Std info 2 ' get cStd2
    read
    aadd(memvar->aStudent, {'','','','','','',''})
    nCnt = len(memvar->aStudent)
    memvar->aStudent[nCnt, 1] := trim(cName1)
    memvar->aStudent[nCnt, 2] := trim(cName2)
    memvar->aStudent[nCnt, 3] := trim(student->address1)
    memvar->aStudent[nCnt, 4] := trim(student->address2)
    memvar->aStudent[nCnt, 5] := trim(student->p_code + ' ' + student->address3)
    memvar->aStudent[nCnt, 6] := trim(cStd1)
    memvar->aStudent[nCnt, 7] := trim(cStd2)
    for ntemp = 1 to 7
      memvar->aStudent[nCnt, nTemp] = if(empty(memvar->aStudent[nCnt, nTemp]), ' ',;
          trim(memvar->aStudent[nCnt, nTemp]))
    next
  endif
enddo
return

* eof()
