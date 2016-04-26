*******************************************************************************
* DBF MENU
local aCh := {'Select database',;
    'Control indices',;
    'Print file structure ',;
    'View/print record',;
    'Create / change structure',;
    'Edit / browse',;
    'Pack database',;
    'Reindex all',;
    'Return'}
local nLen, nCh := 1, nCnt
public cDbf := '', aNtx := {}, aStru := {}, cAlias, aNtx_descr := {}
public aVisible := {}, aOther := {}

#include "dbstruct.ch"

while nCh != 0 .and. nCh != len(aCh)
  jw_screen('DATABASE MENU')
  if !empty(cDbf)
    nLen = if(len(aStru) > 17, 17, len(aStru))
    draw_box(4,1,6+nLen,30)
    @5,4 say 'Structure of ' + cDbf
    for nCnt = 1 to nLen
      @5+nCnt,4 say aStru[nCnt, DBS_NAME]
      do case
        case aStru[nCnt, DBS_TYPE] = 'C'
          @5+nCnt,16 say 'Char  ' + str(aStru[nCnt, DBS_LEN],3,0)
        case aStru[nCnt, DBS_TYPE] = 'N'
          @5+nCnt,16 say 'Num   ' + str(aStru[nCnt, DBS_LEN],3,0) + '  ' + str(aStru[nCnt, DBS_DEC],2,0)
        case aStru[nCnt, DBS_TYPE] = 'M'
          @5+nCnt,16 say 'Memo  ' + str(aStru[nCnt, DBS_LEN],3,0)
        case aStru[nCnt, DBS_TYPE] = 'D'
          @5+nCnt,16 say 'Date  ' + str(aStru[nCnt, DBS_LEN],3,0)
        case aStru[nCnt, DBS_TYPE] = 'L'
          @5+nCnt,16 say 'Logic ' + str(aStru[nCnt, DBS_LEN],3,0)
      endcase
    next
  endif
  if len(aNtx) > 0
    draw_box(16,38,18+len(aNtx), 75)
    @17,40 say 'Open indices'
    for nCnt = 1 to len(aNtx)
      @17+nCnt, 40 say aNtx[nCnt]
      @17+nCnt, 50 say substr(aNtx_descr[nCnt],1,25)
      if nCnt = indexord()
        @17+nCnt, 74 say '*'
      endif
    next
  endif
  nCh = mget_arr(aCh,6,52,,.t.)
  do case
    case nCh = 1
      do dbfsel
    case nCh = 2 .and. !empty(cDbf)
      do dbfntx
    case nCh = 3
      do dbfprnt
    case nCh = 4
      if !empty(cDbf)
        do dbfview
      endif
    case nCh = 5
      do dbfstru
    case nCh = 6
      if !empty(cDbf)
        do dbfedit
      endif
    case nCh = 7
      if !empty(cDbf)
        do dbfpack
      endif
    case nCh = 8
      do re_index
  endcase
enddo

if select(cAlias) != 0
  select &cAlias
  dbclosearea()
endif

return

*eof
