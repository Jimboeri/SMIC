****************************************
public force_bw := force_prfile := .t.

#include "colour.ch"
#include "mouseini.ch"
#include "printer.ch"
#include "smic.ch"
#include "inkey.ch"

use student index names
force_prfile := .t.
openprn()

while !eof()
  if status = 'C'
    if pLine > 55
      prntitle('Lectures to be sent out', 'Y', 132)
    endif
    lP = .f.
    cLine = trim(surname) + ' ' + trim(title) + ' ' + trim(name)
    cLine += space(50 - len(cLine))
    for nCnt = 1 to 20
      cFld = 'LEC' + ltrim(str(nCnt,2,0))
      if &cFld = 'P'
        cLine += ltrim(str(nCnt,2,0)) + ',  '
        lP = .t.
      endif
    next
    if lP
      pr_line(cLine)
    endif
  endif
  dbskip()
enddo
shutprn()
quit
