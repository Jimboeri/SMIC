*******************************************************************************

parameter param_1, param_2
local nCnt := 0, cParam, val_param, aType
memvar force_prfile, force_bw, aDdict, cCo_name
memvar pScr_title, lDecode, aBook
#include 'defcolor.ch'
#include 'defprint.ch'

#include 'mouse.ch'
#include 'mouseini.ch'

public cCo_name := "E.T.'s Utility program"
public aBook

errorblock({| obj_error| sys_error(obj_error)})

private force_bw := .f., force_prfile := lDecode := .f.
for nCnt = 1 to 2
  cParam = 'param_' + ltrim(str(nCnt,2,0))
  val_param = &cParam
  if valtype(val_param) = 'C'
    do case
      case upper(val_param) = '/B'
        force_bw = .t.
      case upper(val_param) = '/P'
        force_prfile = .t.
    endcase
  endif
next

#include 'colour.ch'
#include 'Printer.ch'
#include 'ut.ch'
#include 'inkey.ch'

setkey(K_ALT_F6, {||jw_pri_sw()})                    // Alt F6 - printer switch
setkey(K_ALT_T, {||decode()})                        // Alt T - decoder

wsetshadow("N+")

if !file('DD.DBF')
  declare aDDict[0]
  aadd(aDDict, {'FILE      ', 'C', 15, 0})
  aadd(aDDict, {'NAME      ', 'C', 15, 0})
  aadd(aDDict, {'DESCRIPTN ', 'C', 30, 0})
  aadd(aDDict, {'TYPE      ', 'C', 1, 0})
  aadd(aDDict, {'LENGTH    ', 'N', 7, 2})
  aadd(aDDict, {'REC_CODE  ', 'N', 5, 0})
  aadd(aDDict, {'LINK1     ', 'N', 5, 0})
  aadd(aDDict, {'LINK2     ', 'N', 5, 0})
  aadd(aDDict, {'LINK3     ', 'N', 5, 0})
  aadd(aDDict, {'KEY       ', 'C', 1, 0})
  aadd(aDDict, {'HELP      ', 'M', 10, 0})
  dbcreate('DD', aDDict)
  release aDDict
endif
select 10
use dd

IF !FILE('DD_FILE.NTX')
  INDEX ON dd->file+dd->name TO dd_file
ENDIF

if !file('DD_RECS.NTX')
  index on str(dd->rec_code,5,0) TO dd_recs
endif

if !file('DD_NAME.NTX')
  dbCreateIndex( "dd_name", "name + file", {|| dd->name + dd->file} )
endif

dbcloseall()

if !file('DDSPEC.DBF')
  declare aDDict[0]
  AADD(aDDict, {'FILE      ', 'C', 15, 0})
  AADD(aDDict, {'SPEC      ', 'M', 10, 0})
  AADD(aDDict, {'SOURCE    ', 'M', 10, 0})
  AADD(aDDict, {'SOURCE_DT ', 'D', 8, 0})
  DBCREATE('DDspec', aDDict)
  release aDDict
ENDIF

select 10
use ddspec

if !file('ddspec.ntx')
  index on ddspec->file to ddspec
endif

dbcloseall()

select 199
if !net_use('dd', .f., , 'dd_file', 'dd_recs', 'dd_name')
  return
endif

select 200
if !net_use('ddspec', .f., , 'ddspec')
  return
endif

aType := {'PROGRAMS', 'DATABASES', 'PRINTERS', 'NETWORK', 'QUIT'}
nCnt = 0
while nCnt != len(aType)
  begin sequence
    jw_screen("E.T.'s utility program")
    ncnt = mget_arr(aType,10)
    do case
      case nCnt = 1
        prgmenu()
      case nCnt = 2
        dbfmenu1()
      case nCnt = 3
        do prnmenu
      case nCnt = 4
        do net_test
    endcase
  end sequence
enddo
setcolor(white_black)
@3,0 clear to 24,79
return

*eof

*******************************************************************************
procedure decode
if (Inkey(0) != K_ALT_E)
  return
endif
if memvar->lDecode
  memvar->lDecode := .f.
else
  memvar->lDecode := .t.
endif
return
