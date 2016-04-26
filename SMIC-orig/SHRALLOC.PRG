*******************************************************************************
* SHRALLOCATES NEW SHARE TO EXISTING SHAREHOLDERS
* JIM WEST

local cType, nAlloc, cOrig_shr, cNew_shr, lDel, nCnt, nExtra, nRec, cStd
memvar getlist

simhead(memvar->pscr_title)

begin sequence
  
  select 1
  if !net_use('share', .f., , 'shrname')
    break
  endif
  
  select 4
  if !net_use('portfol', .f.,, 'portfol')
    break
  endif
  
  text
  
  
  The first share name that you enter must be the share that the student
  is holding in order to qualify to receive the other shares, the name
  of which must be entered second. The value to fill in must be the number
  of shares to be issued for every existing share held.
  
endtext
wait
@3,0 clear

nAlloc = 0
select Share
simhead(memvar->pscr_title)
@4,10 say 'Enter name of qualifying share'
findshr()
if !eof()
  cOrig_shr = share->share
  @4,10 SAY 'Enter name of share to be recieved'
  findshr()
  if !eof()
    cNew_shr = share->share
    if cNew_shr = cOrig_shr
      break
    endif
    @3,0 clear
    @5,0 say 'How many shares in ' + trim(cNew_shr) +;
        ' for each share held in ' + trim(cOrig_shr) + ' ?' get nAlloc;
        picture '9999.9999'
    read
    lDel = wmake_sure(10,,'Do you want to delete original share after the allocation (Y/N) ? ')
    @9,0 SAY 'Students will receive ' + LTRIM(STR(nAlloc)) + ' shares in ' + TRIM(cNew_shr) + ' for every ' + TRIM(cOrig_shr) + ' share held'
    if lDel
      @10,0 say 'The original shares will be deleted (lost).'
    else
      @10,0 say 'The original shares will be KEPT.'
    endif
    @11,0 clear
    if make_sure(13,27,'Is this correct (Y/N) ?')
      wopen(8,10,11,70)
      wbox(0)
      setcursor(0)
      select Portfol
      SET COLOR TO W*/N
      @14,33 SAY 'ALLOCATING SHARES'
      SET COLOR TO W/N
      @16,10 SAY 'Portfolio file'
      select Portfol
      dbgotop()
      nCnt = 0
      while !eof()
        nCnt++
        @1,0 say replicate('±', int(nCnt / lastrec() * 60))
        if portfol->share = cOrig_shr
          nExtra = portfol->qty * nAlloc
          nRec = recno()
          cStd = portfol->std_code
          cType = portfol->type
          if !dbseek(cStd + cType + cNew_shr)
            dbappend()
            reclock('Portfolio')
            Portfol->std_code := cStd
            Portfol->type     := cTYPE
            Portfol->share    := cNew_shr
            Portfol->qty      := nExtra
            dbunlock()
          else
            reclock('Portfolio')
            Portfol->qty := portfol->qty + nExtra
            dbunlock()
          endif
          dbgoto(nRec)
          if lDel
            select Portfol
            reclock('portfolio')
            dbdelete()
            dbunlock()
          endif
        endif
        dbskip()
      enddo
      wclose()
      ?? chr(7)
    endif
  endif
endif
end sequence
et_close('Share')
et_close('Portfol')
return

* EOF
