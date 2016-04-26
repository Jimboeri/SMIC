*******************************************************************************
*
*  msg_disp - display message files
*

local nCnt, dDown, cDown, nDow, cMsg_file, nKey, cDir

#include 'inkey.ch'

clear screen

begin sequence
  select 1
  if empty(et_use_dbf('param'))
    break
  endif
  
  cDir = trim(param->msg_dir)
  
  nCnt = 1
  dDown = date()
  nDow = dow(dDown)
  if nDow = 2
    dDown = date() - 3
  else
    dDown = date() - 1
  endif
  cDown = dtoc(dDown)
  cMsg_file = substr(cDown,1,2) + '-' + substr(cDown,4,2) + '-' +;
      substr(cDown,7,2) + '.MSG'
  cMsg_file = cDir + cMsg_file
  @0,0 clear
  if file(cMsg_file)
    type &cMsg_file
  else
    @10,10 say 'MESSAGE FILE DOES NOT EXIST'
    @15,10 say cMsg_file
  endif
  for nCnt = 1 to 23
    @nCnt,40 say chr(186)
  next
  setcolor('+W/N')
  @23,1 say 'F2'
  @23,20 say 'F3'
  @23,40 say 'F4'
  @23,60 say 'F5'
  setcolor('W/N')
  @23,4 say 'Previous'
  @23,23 say 'Next'
  @23,43 say 'Yesterday'
  @23,63 say 'Problem shares'
  nKey = 0
  while nKey != K_ESC .and. nKey != K_ENTER
    nKey = inkey(0)
    do case
      case nKey = K_F2
        dDown--
        nDow = dow(dDown)
        while nDow < 2 .or. nDow > 6
          dDown--
          nDow = dow(dDown)
        enddo
        cDown = dtoc(dDown)
        cMsg_file = substr(cDown,1,2) + '-' + substr(cDown,4,2) + '-' +;
            substr(cDown,7,2) + '.MSG'
        cMsg_file = cDir + cMsg_file
        @0,0 clear
        if file(cMsg_file)
          type &cMsg_file
        else
          @10,10 say 'MESSAGE FILE DOES NOT EXIST'
          @15,10 say cMsg_file
        endif
        for nCnt = 1 to 23
          @nCnt,40 say chr(186)
        next
      case nKey = K_F3
        dDown++
        nDow = dow(dDown)
        while nDow < 2 .or. nDow > 6
          dDown++
          nDow = dow(dDown)
        enddo
        cDown = dtoc(dDown)
        cMsg_file = substr(cDown,1,2) + '-' + substr(cDown,4,2) + '-' +;
            substr(cDown,7,2) + '.MSG'
        cMsg_file = cDir + cMsg_file
        @0,0 clear
        if file(cMsg_file)
          type &cMsg_file
        else
          @10,10 say 'MESSAGE FILE DOES NOT EXIST'
          @15,10 say cMsg_file
        endif
        for nCnt = 1 to 23
          @nCnt,40 say chr(186)
        next
      case nKey = K_F4
        @0,0 clear
        if file(cMsg_file)
          type &cMsg_file
        else
          @15,10 say cMsg_file
          @10,10 say 'MESSAGE FILE DOES NOT EXIST'
        endif
        for nCnt = 1 to 23
          @nCnt,40 say chr(186)
        next
      case nKey = K_F5
        @0,0 clear
        if file('PROBSHR.TXT')
          type PROBSHR.TXT
        endif
    endcase
    setcolor('+W/N')
    @23,1 say 'F2'
    @23,20 say 'F3'
    @23,40 say 'F4'
    @23,60 say 'F5'
    setcolor('W/N')
    @23,4 say 'Previous'
    @23,23 say 'Next'
    @23,43 say 'Yesterday'
    @23,63 say 'Problem shares'
  enddo
  
end sequence
et_close('param')
return

* eof
