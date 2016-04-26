*******************************************************************************
*
* HED_UPD - Auto update from header file
*

Parameter cInput

local aStru, cData, cShare, cSector, nAt, cCommand, aCommand, cNew_sec
local nCnt, cNew_share
local cDate, dDate, nPrice, nHigh, nLow, nVol
local cSeek
memvar cInput, cFile

wopen(8,10,14,70)
@0,0 say center('Checking HED fle')

aStru := {}
aadd(aStru, {'STAR   ', 'C', 1, 0})
aadd(aStru, {'COMMAND', 'C', 3, 0})
aadd(aStru, {'DATA   ', 'C', 80, 0})

if !file(cInput + '.HED') .and. !file(memvar->cHED_dir + cInput + '.HED')
  return
endif

if !file('HED.DBF')
  dbcreate('HED', aStru)
endif

aStru := {}
aadd(aStru, {'COMMAND', 'C', 3, 0})
aadd(aStru, {'DATE   ', 'D', 8, 0})
aadd(aStru, {'DATA   ', 'C', 80, 0})

if !file('HED_UNKN.DBF')
  dbcreate('HED_UNKN', aStru)
endif

if empty(et_use_dbf('HED', .t.))
  return
endif

if empty(et_use_dbf('HED_UNKN'))
  return
endif

if empty(et_use_dbf('SHARE'))
  return
endif

if empty(et_use_dbf('SHRDESCR'))
  return
endif

if empty(et_use_dbf('SECTORS'))
  return
endif

if empty(et_use_dbf('ORDER'))
  return
endif

if empty(et_use_dbf('TRANSACT'))
  return
endif

if empty(et_use_dbf('PORTFOL'))
  return
endif

if empty(et_use_dbf('SHR_DATA'))
  return
endif

cFile = cInput + '.HED'
if !file(cfile)
  cFile = memvar->cHED_dir + cInput + '.HED'
endif

select hed
zap
append from &cFile sdf

dbgotop()
while !eof()
  if hed->star != '*' .or. hed->command = 'SHD'  .or. hed->command = 'EHD'
    reclock()
    dbdelete()
    dbunlock()
  endif
  dbskip()
enddo

*altd()

dbgotop()
while !eof()
  do case
    case hed->command = 'NSH'                   // new share
      cCommand = ltrim(hed->data)
      aCommand = str_com(cCommand)
      cShare = aCommand[1]
      cShare += space(9-len(cShare))
      cSector = aCommand[2]
      cSector = str(val(cSector),3)
      select sectors
      if !dbseek(cSector)
        dbappend()
        reclock()
        sectors->sector_cd  := cSector
*        sectors->Full_name  := 'Unknown sector'
*        sectors->short_name := 'UNKNOWN'
        dbunlock()
        dbcommit()
      endif
      
      select share
      if !dbseek(cShare)
        dbappend()
        reclock()
        share->share := cShare
        dbunlock()
      endif
      reclock()
      share->sec_cd := cSector
      share->full_name := cShare
      dbunlock()
      
      select shrdescr
      if !dbseek(cShare)
        dbappend()
        reclock()
        shrdescr->share := cShare
        dbunlock()
      endif
      reclock()
      shrdescr->sec_cd := cSector
      shrdescr->sector := sectors->Full_name
      dbunlock()
      
    case hed->command = 'DSH'                   // Delete share
      cCommand = ltrim(hed->data)
      aCommand = str_com(cCommand)
      cShare = aCommand[1]
      cShare += space(9-len(cShare))
      
      select shrdescr
      if !dbseek(cShare)
        dbappend()
        reclock()
        shrdescr->share := cShare
        dbunlock()
      endif
      reclock()
      shrdescr->kill_dt := date()
      dbunlock()
      
    case hed->command = 'MSH'   // Change sector
      cCommand = ltrim(hed->data)
      aCommand = str_com(cCommand)
      cShare = aCommand[1]
      cShare += space(9-len(cShare))
      cSector = aCommand[2]
      if len(cSector) = 2
        cSector = ' ' + cSector
      endif
      cNew_sec = aCommand[3]
      if len(cNew_sec) = 2
        cNew_sec = ' ' + cNew_sec
      endif
      
      select sectors
      dbseek(cNew_sec)
      
      select share
      if dbseek(cShare)
        reclock()
        share->sec_cd := cNew_sec
        dbunlock()
      endif
      
      select shrdescr
      if dbseek(cShare)
        reclock()
        shrdescr->sec_cd := cSector
        shrdescr->sector := sectors->Full_name
        dbunlock()
      endif
      
    case hed->command = 'RSH'                   // Rename share
      cCommand = ltrim(hed->data)
      aCommand = str_com(cCommand)
      cShare = aCommand[1]
      cShare += space(9-len(cShare))
      cNew_Share = aCommand[3]
      cNew_Share += space(9-len(cNew_Share))
      
      cSector = aCommand[2]
      if len(cSector) = 2
        cSector = ' ' + cSector
      endif
      select sectors
      dbseek(cSector)
      
      select share
      dbappend()
      reclock()
      share->share := cNew_share
      share->sec_cd := cSector
      share->full_name := cShare
      dbunlock()
      
      select Shrdescr
      if dbseek(cNew_share)
        if empty(Shrdescr->buy_1) .and. empty(Shrdescr->sell_1) .and.;
              empty(Shrdescr->fundamnt_1)
          select share
          reclock('Share')
          dbdelete()
          dbunlock()
        endif
      endif
      
      select shrdescr
      if !dbseek(cNew_share)
        if dbseek(cShare)
          reclock('Share comment')
          Shrdescr->share := cNew_share
          shrdescr->sec_cd := cSector
          shrdescr->sector := sectors->Full_name
          dbunlock()
        endif
      endif
      
      @1,0 say center('Transaction File')
      select Transact
      dbgotop()
      nCnt = 0
      while !eof()
        nCnt++
        @2,0 say replicate('±', int(nCnt / lastrec() * 60))
        if transact->share = cShare
          reclock('Transaction')
          Transact->share := cNew_share
          dbunlock()
          dbseek(transact->std_code)
          dbskip(-1)
        endif
        dbskip()
      enddo
      
      @1,0 say center('Portfolio file', .t.)
      select Portfol
      dbgotop()
      nCnt = 0
      while !eof()
        nCnt++
        @2,0 say replicate('±', int(nCnt / lastrec() * 60))
        if portfol->share = cShare
          reclock('Portfolio')
          Portfol->share := cNew_share
          dbunlock()
          dbseek(portfol->std_code)
          dbskip(-1)
        endif
        dbskip()
      enddo
      
      @1,0 say center('Order file', .t.)
      select Order
      dbgotop()
      nCnt = 0
      while !eof()
        nCnt++
        @2,0 say replicate('±', int(nCnt / lastrec() * 60))
        if order->share = cShare
          reclock()
          Order->share := cNew_share
          dbunlock()
          dbseek(order->std_code)
          dbskip(-1)
        endif
        dbskip()
      enddo
      
    case hed->command = 'ERR'   // Change values
      cCommand = ltrim(hed->data)
      aCommand = str_com(cCommand)
      cShare = aCommand[1]
      cDate = trim(aCommand[3])
      cDate = substr(cDate,1,2) + '/' + substr(cDate,3,2) + '/' + substr(cDate,5,2)
      dDate = ctod(cDate)
      nPrice = val(aCommand[4])
      nHigh = val(aCommand[5])
      nLow = val(aCommand[6])
      nVol = val(aCommand[7])
      ? cDate
      ? nPrice
      ? nHigh
      ? nLow
      ? nVol
      
      select share
      if dbseek(cShare)
        select shr_data
        cSeek = share->shr_cd + i2bin(shr_date(dDate))
        if !dbseek(cSeek)
          dbappend()
          reclock()
          shr_data->shr_cd := share->shr_cd
          shr_data->trade_dt := i2bin(shr_date(dDate))
          dbunlock()
        endif
        reclock()
        shr_data->price  := i2bin(nPrice)
        shr_data->high   := i2bin(nHigh)
        shr_data->low    := i2bin(nLow)
        shr_data->volume := l2bin(nVol)
        dbunlock()
      endif
      
    case hed->command = 'NSE'                   // new sector
      new_sector()

    otherwise
      select hed_unkn
      dbappend()
      reclock()
      hed_unkn->command := hed->command
      hed_unkn->data    := hed->data
      hed_unkn->date    := ctod(cInput)
  endcase
  select hed
  dbskip()
enddo

et_close('HED')
et_close('HED_UNKN')
et_close('SHARE')
et_close('SHRDESCR')
et_close('SECTORS')
et_close('ORDER')
et_close('TRANSACT')
et_close('PORTFOL')
wclose()

*deletefile('HED.DBF')

return

*******************************************************************************
function str_com(cString)
local aReturn := {}, nAt, cLine
while !empty(cString)
  nAt = at(' ', cString)
  cLine = substr(cString,1,nAt-1)
  aadd(aReturn, cLine)
  cString = stuff(cString, 1, nAt, '')
enddo
return(aReturn)

*******************************************************************************
procedure new_sector()
local cCommand, aCommand, cSec_cd, cSec_name
cCommand = ltrim(hed->data)
aCommand = str_com(cCommand)
cSec_cd = aCommand[1]
cSec_cd = str(val(cSec_cd),3)
cSec_name = aCommand[2]
select sectors
if !dbseek(cSec_cd)
  dbappend()
  reclock()
  sectors->sector_cd  := cSec_cd
  dbunlock()
endif
reclock()
sectors->Full_name  := cSec_name
dbunlock()
dbcommit()
return
