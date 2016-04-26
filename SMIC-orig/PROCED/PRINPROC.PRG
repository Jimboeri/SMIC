*******************************************************************************
* PRINPROC

FUNCTION pr(cIn_line)
LOCAL bLst_error, bError, cOrig_col, cSector, lPr_ready, nKey := 0, cChar

#include "error.ch"

bError = { | oError | prError(oError) }
bLst_error = errorblock(bError)
BEGIN SEQUENCE
  lPr_ready = .f.
  do while !lPr_ready
    if isprinter()
      lPr_ready = .t.
    else
      cOrig_col = setcolor('W+/R')
      cSector = draw_box(10,20,12,60)
      @11,23 say 'Printer not ready, Retry or Abort'
      do while nKey != 27 .or. nKey != 65 .or. nKey != 79 .or. nKey != 82 .or. nKey != 114
        nKey = inkey(0)
      enddo
      setcolor(cOrig_col)
      restsector(cSector)
      cChar = upper(chr(nKey))
      if nKey = 27 .or. cChar = 'A'
        errorblock(bLst_error)
        return(.f.)
      endif
    endif
  enddo
  ? cIn_line
  RECOVER
    errorblock(bLst_error)
    RETURN (.f.)
END SEQUENCE
errorblock(bLst_error)
return(.t.)

* eop()

*******************************************************************************
*
* FUNCTION PRERROR - handles printer errors
FUNCTION prError ( objError )
LOCAL cOrig_col, cSector, nKey, cChar

if objError:genCode == EG_PRINT .and. objError:canRetry
  cOrig_col = setcolor('W+/R')
  cSector = draw_box(10,20,12,60)
  @11,23 say 'Printer not ready, Retry or Abort'
  do while nKey != 27 .or. nKey != 65 .or. nKey != 79 .or. nKey != 82 .or. nKey != 114
    nKey = inkey(0)
  enddo
  setcolor(cOrig_col)
  restsector(cSector)
  cChar = upper(chr(nKey))
  if nKey = 27 .or. cChar = 'A'
    break
  else
    return(.t.)
  endif
endif
return nil

* eof()