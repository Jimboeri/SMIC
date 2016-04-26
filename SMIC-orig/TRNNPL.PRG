*******************************************************************************
* PROGRAM TRNNPL - ALLOCATES NIL PAID LETTERS
* 9/3/88
* JIM WEST

local cShare, cNpl, nSplit, nOption, dOption, lValid, nCnt
local nRecno, nQty, cStd_code
memvar getlist

select 1
if !net_use('portfol', .f.,, 'portfol')
  return
endif

select 4
if !net_use('shrdescr', .f.,, 'shrdescr')
  close database
  return
endif

select 2
if !net_use('share', .f.,, 'shrname')
  close database
  return
endif

select 3
if !net_use('transact', .f.,, 'trancode')
  close database
  return
endif

simhead(memvar->pscr_title)
select Share
@5,0 say 'Enter name of share having the rights issue'
findshr()
if !eof()
  cShare = share->share
  @5,0 clear
  @5,0 say 'Enter name of the NPL'
  findshr()
  if !eof()
    cNpl = share->share
    @5,0 clear
    @5,5 say cShare + ' has issued Nil Paid Letters called ' + cNpl
    nSplit = 1
    @8,0 clear
    @8,10 say 'Enter NPLs per share ' GET nSplit PICTURE '999.9999'
    read
    nSplit = abs(nSplit)
    @8,32 say str(nSplit,8,4)
    nOption = 0
    dOption = ctod('  /  /  ')
    @10,0 clear
    @10,10 say 'Enter Option price of NPLs' get nOption picture '9999999.99'
    @12,10 say 'Enter Option date of NPLs ' get dOption picture '@d'
    @14,10 say 'Option price must be in cents'
    read
    lValid = .F.
    while !lValid
      lValid = .T.
      if dOption = ctod('  /  /  ')
        lValid = .f.
        @23,10 say 'Option date must be entered'
        @12,10 say 'Enter Option date of NPLs ' get dOption picture '@d'
        read
        @23,0 clear
      ENDIF
      IF dOption <= date()
        lValid = .f.
        @23,10 say 'Option date cannot be prior to today'
        @12,10 say 'Enter Option date of NPLs ' get dOption picture '@d'
        read
        @23,0 clear
      endif
    enddo (validation)
    nOption = abs(nOption)
    @10,37 say str(nOption,10,2)
    if wmake_sure(17,,'Is this correct ? (Y/N)')
      select Share
      seek cNpl
      reclock('Share')
      Share->suspend := 'N'
      dbunlock()
      select Shrdescr
      seek cNpl
      if !found()
        dbappend()
        reclock('Share comment')
        Shrdescr->share := cNpl
        dbunlock()
      endif
      reclock('Share comment')
      Shrdescr->dividend := nOption
      Shrdescr->div_dt   := dOption
      Shrdescr->sec_shr  := cShare
      dbunlock()
      select Portfol
      dbgotop()
      nCnt = 0
      @17,10 say 'Changing the portfolio file'
      while !eof()
        if portfol->share = cShare
          nCnt++
          @17,40 say 'Changes = ' + ltrim(str(nCnt))
          nRecno = recno()
          cStd_code = portfol->std_code
          nQty = portfol->qty
          if !dbseek(cStd_code + 'T' + cNpl)
            dbappend()
            reclock('Portfolio')
            Portfol->std_code  := cStd_code
            Portfol->type      := 'T'
            Portfol->share     := cNpl
            Portfol->cost_hold := 0
            Portfol->qty       := 0
            dbunlock()
          endif
          reclock('Portfolio')
          Portfol->qty := Portfol->qty + int(nSplit * nQty)
          dbunlock()
          select Transact
          dbappend()
          reclock('Transaction')
          Transact->std_code := cStd_code
          Transact->type     := Portfol->type
          Transact->share    := cNpl
          Transact->trn_type := 'NRC'
          Transact->qty      := int(nSplit * nQty)
          Transact->trn_dt   := date()
          Transact->price    := nOption
          dbunlock()
          select Portfol
          dbgoto(nRecno)
        endif
        dbskip()
      enddo (end of portfol file)
      ?? chr(7)
    endif (yesno)
  endif (founf npl)
endif (found share)
close databases

*eof