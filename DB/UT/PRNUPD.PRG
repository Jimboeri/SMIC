*******************************************************************************
*
* PRNUPD - Allows updating of the printer file
*

local nCnt, cTitle, cSeek, cPrinter, cSect, nField, cSect1
memvar aTitles, aValues, aPrn_stru, getlist

private aTitles := {}, aValues := {}

#include 'inkey.ch'

select 161
if !net_use('printer', .t.)
  return
endif
index on printer->gc_psname to prn_temp
dbclosearea()
if !net_use('printer', .f.,,'prn_temp')
  return
endif

aPrn_stru = dbstruct()

select dd
for nCnt = 1 to len(aPrn_stru)
  cTitle = space(30)
  cSeek = 'PRINTER.DBF    ' + aPrn_stru[nCnt, 1]
  if dbseek('PRINTER.DBF    ' + aPrn_stru[nCnt, 1])
    cTitle := dd->descriptn
  endif
  aadd(aTitles, cTitle)
next

jw_screen(memvar->pScr_title)
select printer
aValues := {}
for nCnt = 1 to fcount()
  aadd(aValues, fieldget(nCnt))
next
@22,3 say 'Enter = edit highlighted printer'
@23,3 say 'Ins = Add new printer  Del = delete printer'
while .t.
  cPrinter = et_seek('printer', {1},,{K_INS, K_DEL})
  do case
    case lastkey() = K_INS
      cPrinter := space(30)
      cSect = draw_box(6,5,10,60)
      @8,7 say 'Printer name ' get cPrinter
      read
      if empty(cPrinter)
        restsector(cSect)
        return
      endif
      if dbseek(cPrinter)
        cSect1 = disp_msg(16,memvar->white_red,;
            'A printer record exists for this name')
        inkey(0)
        restsector(cSect1)
      else
        if make_sure(15,,'Add a new printer record')
          dbappend()
          reclock()
          printer->gc_psname := cPrinter
          for nCnt = 2 to fcount()
            fieldput(nCnt, memvar->aValues[nCnt])
          next
        endif
      endif
      restsector(cSect)
    case lastkey() = K_DEL
      if make_sure(15,,'Delete this printer record ?')
        reclock()
        dbdelete()
        dbunlock()
      endif
    case lastkey() = K_ENTER
      select printer
      dbseek(cPrinter)
      aValues := {}
      for nCnt = 1 to fcount()
        aadd(aValues, fieldget(nCnt))
      next
      cSect = draw_box(4,2,22,48)
      @5,5 say 'Printer record ' + cPrinter
      nField = 1
      while nField != 0
        nField = mget_arr(aTitles,7,5,memvar->red_white,.t.,;
            'Select field to edit',nField)
        if nField = 0
          exit
        else
          prn_edit(nField)
        endif
      enddo
      if make_sure(15,,'Is this printer record correct ?')
        if dbseek(cPrinter)
          reclock()
          for nCnt = 2 to fcount()
            fieldput(nCnt, aValues[nCnt])
          next
          dbunlock()
          dbcommit()
        endif
      endif
    otherwise
      exit
  endcase
enddo
@22,3 clear to 23,48
dbclosearea()
ferase('prn_temp.ntx')
return
* eof()
*******************************************************************************
procedure prn_edit(nOrd_no)
local nCounter, nLong := 12, getlist := {}, nTop := 8, cSect
memvar aChar
private aChar := {}
if nOrd_no = 1
  return
endif
do case
  case memvar->aPrn_stru[nOrd_no, 2] = 'C'
    cSect = draw_box(5,5,22,75)
    @6,20 say memvar->aTitles[nOrd_no]
    for nCounter = 1 to memvar->aPrn_stru[nOrd_no, 3]
      aadd(aChar, asc(substr(memvar->aValues[nOrd_no],nCounter,1)))
    next
    for nCounter = 1 to memvar->aPrn_stru[nOrd_no, 3]
      @((nCounter-1) % nLong) + nTop, int((nCounter-1) / nLong) * 20 + 10;
          say 'Char ' + str(nCounter,2) + ' ' get aChar[nCounter] picture '999';
          valid prn_chr_disp()
      @((nCounter-1) % nLong) + nTop, int((nCounter-1) / nLong) * 20 + 24;
          say "'" + chr(aChar[nCounter]) + "'"
    next
    read
    memvar->aValues[nOrd_no] = ''
    for nCounter = 1 to memvar->aPrn_stru[nOrd_no, 3]
      memvar->aValues[nOrd_no] += chr(aChar[nCounter])
      aadd(aChar, asc(substr(memvar->aValues[nOrd_no],nCounter,1)))
    next
    restsector(cSect)
  case memvar->aPrn_stru[nOrd_no, 2] = 'N'
    cSect = draw_box(10,5,15,75)
    @12,5 say trim(memvar->aTitles[nOrd_no]) get memvar->aValues[nOrd_no]
    read
    restsector(cSect)
endcase
return
*******************************************************************************
function prn_chr_disp
local cVar, cVal
cVar = readvar()
cVal = chr(&cVar)
@row(), col()+3 say cVal
return(.t.)
