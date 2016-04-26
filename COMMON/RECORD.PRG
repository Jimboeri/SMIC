parameter param_1, param_2, param_3

LOCAL nCHOICE := 1, cSECTOR, nCnt, cParam, val_param
LOCAL aMENU[15]
local mpw_name := 'JIM            '

set date british
set scoreboard off
SET EPOCH TO 1960

errorblock({| obj_error| sys_error(obj_error)})

private force_bw := .f., force_prfile := .f., test_env := .f.
private cPw_name

for nCnt = 1 to 3
  cParam = 'param_' + ltrim(str(nCnt,2,0))
  val_param = &cParam
  if valtype(val_param) = 'C'
    do case
      case upper(val_param) = '/B'
        force_bw = .t.
      case upper(val_param) = '/P'
        force_prfile = .t.
      case upper(val_param) = '/T'
        test_env = .t.
    endcase
  endif
next

#include "colour.ch"
#include "mouse.ch"
#include "mouseini.ch"
#include "printer.ch"
#include 'inkey.ch'

clear
cFile = space(8)
cIndex = space(8)
@5,10 say 'File ' get cfile
@6,10 say 'Index ' get cIndex
read
if empty(cFile)
  return
endif

if empty(cIndex)
net_use(cFile, .f.)
else
net_use(cFile, .f.,, cIndex)
endif

while .t.
  for nCnt = 1 to 4
    @8+nCnt,10 say fieldname(nCnt)
    nVal = fieldget(nCnt)
    if valtype(nVal) = 'C'
      @8+nCnt,25 say nVal
    else    
      @8+nCnt,25 say str(nVal)
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

procedure pr_rec
begin sequence
  openprn()
  for nCnt = 1 to fcount()
    if pline > pr_lines - 2
      prntitle('RECORD VALUES FOR ' + cFile,,80)
    endif
    cLine = fieldname(nCnt) + '     '
    nVal = fieldget(nCnt)
    if valtype(nVal) = 'C'
      cLine += nVal
    else    
      cLine += str(nVal)      
    endif
    pr_line(cLine)
  next
  shutprn()
end sequence    
return
