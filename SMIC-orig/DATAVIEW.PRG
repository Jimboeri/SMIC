****
*       This is a database seek utility used to select a record from a database
*
* Parameters    cDatabase - The name of the database
*               aDisp_fields - A numeric array consisting of the ordinal
*                              numbers of the fields in the database to be
*                              displayed.
*               lSearch - A boolean falue indicating whether a quick type
*                         search should be used. This works on the first record
*                         and must match the controlling index.
*               aEsc_keys - A numeric array of inkey code which will allow an
*                           escape from the procedure
*               cOrig_key - A character expression equal to the initial part
*                           of the index key. Used for selecting subrecords

local nCnt, bAction, lMore, cRet_val, cRet_var, cOrig_val, cSect1
local nCurssave, aStru, lClose_dd, cData, aDisp_stru, cColorsave
local nArea, cSectsave, oColumn, nKey, lSave_Visible, cSeek, cLook
local nRec

memvar oPick, lKey_search, cFilter, nTop, nBott, nLeft, nRight, cInd_key

public force_bw := force_prfile := .f.

#include "colour.ch"
#include "mouseini.ch"
#include "printer.ch"
SET DATE BRITISH
SET DELETED ON

#include "smic.ch"
private oPick, lKey_search, cFilter
private nTop, nLeft, nBott, nRight

#include "inkey.ch"
#include "setcurs.ch"

#define MY_HSEP         "ÄÂÄ"
#define MY_CSEP         " ³ "
#define MY_FSEP         "ÄÁÄ"

nTop = 5
nBott = 21
nRight = 75
nLeft = 4

cRet_var = readvar()
cOrig_val = if(!empty(cRet_var), &cRet_var, '')

select 1
use share exclusive
index on shr_cd to delete

select 2
use shr_data index shr_data
dbgotop()

if bof()
  cSect1 = disp_msg(14,memvar->white_red, 'Nothing found !')
  inkey(0)
  restsector(cSect1)
  if !empty(cRet_var)
    &cRet_var := space(len(&cRet_var))
  endif
  return('')
endif

dbselectarea("SHR_DATA")
nArea = select()
dbgotop()

cInd_key = indexkey()

/* make new browse object */
oPick := TBrowseDB(nTop, nLeft, nBott, nRight)
cColorSave := SetColor(memvar->black_white)
cSectSave = draw_box(nTop-1, nLeft-1, nBott, nRight+1)
@nTop+1, nLeft-1 say 'Ã'
@nTop+1, nRight+1 say '´'
nCursSave := SetCursor(0)

/* default heading and column separators */
oPick:headSep := MY_HSEP
oPick:colSep := MY_CSEP
oPick:footSep := MY_FSEP

/* add custom 'skipper' (to handle append mode) */
oPick:skipBlock := {|x| Skip_any(x)}

/* colors */
oPick:colorSpec := memvar->black_white

oColumn := TBColumnNew( 'SHARE', {|| dta_share()})
oPick:addColumn(oColumn)

oColumn := TBColumnNew( 'DATE', {|| dta_date()})
oPick:addColumn(oColumn)

oColumn := TBColumnNew( 'PRICE', {|| dta_price()})
oPick:addColumn(oColumn)

oColumn := TBColumnNew( 'HIGH', {|| dta_high()})
oPick:addColumn(oColumn)

oColumn := TBColumnNew( 'LOW', {|| dta_low()})
oPick:addColumn(oColumn)

oColumn := TBColumnNew( 'VOLUME', {|| dta_volume()})
oPick:addColumn(oColumn)


lMore := .t.
cSeek := ''
while (lMore)
  
  /* stabilize the display */
  nKey = 0
  while ( !oPick:stabilize() )
    nKey := InKey()
    if ( nKey != 0 )
      exit                    /* (abort if a key is waiting) */
    endif
  enddo
  
  if ( oPick:stable )
    /* display is stable */
    if ( oPick:hitTop .or. oPick:hitBottom )
      Tone(125, 0)
    end
    
    /* everything's done; just wait for a key */
    if nKey = 0
      nKey = inkey(0)
    endif
    
  endif
  
  /* process key */
  do case
    case ( nKey == K_F1 )
      help(procname(), procline(), "SHR_DATA")
      
    case (bAction := SETKEY(nKey)) != NIL
      EVAL(bAction, Procname(), Procline(), readvar())
      
    case ( nKey == K_DOWN )
      cSeek = ''
      oPick:down()
      
    case ( nKey == K_UP )
      cSeek = ''
      oPick:up()
      
    case ( nKey == K_PGDN )
      cSeek = ''
      oPick:pageDown()
      
    case ( nKey == K_PGUP )
      cSeek = ''
      oPick:pageUp()
      
    case ( nKey == K_CTRL_PGUP ) .or. ( nKey == K_HOME )
      cSeek = ''
      oPick:goTop()
      
    case ( nKey == K_CTRL_PGDN ) .or. ( nKey == K_END )
      cSeek = ''
      oPick:goBottom()
      
    case ( nKey == K_ESC )
      cRet_val = cOrig_val
      lMore := .f.
      
    case ( nKey == K_RETURN )
      cRet_val = fieldget(1)
      lMore := .f.
      
    otherwise
      
        do case
          case ( nKey == K_LEFT )
            oPick:left()
          case ( nKey == K_RIGHT )
            oPick:right()
          case ( nKey == K_CTRL_LEFT )
            oPick:panleft()
          case ( nKey == K_CTRL_RIGHT )
            oPick:panright()
        endcase
  endcase
enddo

if !empty(cRet_var)
  &cRet_var := cRet_val
endif

setcolor(cColorSave)
SetCursor(nCursSave)
restsector(cSectSave)

return(cRet_val)

****
*       skip_any()
*
static function skip_any(n)
local i
i := 0
if ( LastRec() != 0 )
  if ( n == 0 )
    dbskip(0)
    
  elseif ( n > 0 .and. Recno() != LastRec() + 1 )
    while ( i < n )
      dbskip(1)
      if Eof()
        dbskip(-1)
        exit
      endif
      i++
    enddo
    
  elseif ( n < 0 )
    while ( i > n )
      dbskip(-1)
      if ( Bof() )
        exit
      endif
      i--
    enddo
  end
endif
return (i)

*******************************************************************************
function dta_share
local nArea, cReturn
nArea = select()
select share
if dbseek(shr_data->shr_cd)
  cReturn = share->share
else
  cReturn = 'NOT FND'
endif
dbselectarea(nArea)
if cReturn = 'NOT FND'
  reclock()
  dbdelete()
  dbunlock()
endif
return(cReturn)

*******************************************************************************
function dta_date
local dRet, nDays
nDays = bin2i(shr_data->trade_dt)
dRet = ctod('01/01/80') + nDays
return dRet

*******************************************************************************
function dta_price
return(bin2i(shr_data->price))

*******************************************************************************
function dta_high
return(bin2i(shr_data->high))

*******************************************************************************
function dta_low
return(bin2i(shr_data->low))

*******************************************************************************
function dta_volume
return(bin2l(shr_data->volume))

