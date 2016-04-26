*******************************************************************************
* WKSHRPRN - PRINTS LIST OF TRANSACTIONS FOR COURSE MANAGER
*

local aBuys[0], aNo_buy[0], nbuys_inx := 0
local aSells[0], aNo_sell[0], nSells_inx := 0
local aBears[0], aNo_bear[0], nBears_inx := 0
local aDlvs[0], aNo_dlv[0], nDlvs_inx := 0
local aNpls[0], aNo_npl[0], nNpls_inx := 0
local aHolds[0], aNo_hold[0], nHolds_inx := 0
local nGen_inx, nNo_funds, nNew_buys, Nnew_sells
local nTot_buys, nTot_sells, nTot_bears, nTot_dlvs, nTot_npls, nTot_holds
local cLine, nOPTION, nCnt
local cTitle

local aOption := {'TWIN comments',;
    'PORTFOLIO ADVISORY comments',;
    'BOTH set of comments'}

memvar pLine

#include 'inkey.ch'

simhead(memvar->pscr_title)

nNo_funds := nNew_buys := Nnew_sells := 0
nTOT_BUYS := nTOT_SELLS := nTOT_BEARS := nTOT_DLVS := nTOT_NPLS := nTOT_HOLDS := 0

nOption = get_arr(aOption,7)

if !wmake_sure(16,,'Print list of comments to write ?')
  return
endif

wopen(8,10,16,70)
setcolor(memvar->blue_cyan)
wbox(0)
setcursor(0)

begin sequence
  
  if empty(et_use_dbf('Transact'))
    break
  endif
  
  if empty(et_use_dbf('Portfol'))
    break
  endif
  
  if empty(et_use_dbf('Param'))
    break
  endif
  
  if empty(et_use_dbf('Shrdescr'))
    break
  endif
  
  if empty(et_use_dbf('Share'))
    break
  endif
  
  if openprn()
    break
  endif
  
  @0,0 say center('PRINTING LIST OF COMMENTS TO WRITE')
  @1,0 say center('SCANNING TRANSACTION FILE')
  if nOption = 1 .OR. nOption = 3
    select Transact
    nCnt = 0
    while !eof()
      nCnt++
      @2,0 say replicate('±', int(nCnt / lastrec() * maxcol() + 1))
      do case
        case transact->trn_type = 'BUY'
          if Transact->trn_dt > param->lst_portprt
            nGen_inx = ascan(aBuys, Transact->share)
            if nGen_inx = 0
              aadd(aBuys, nil)
              aadd(aNo_buy, nil)
              nBuys_inx++
              nGen_inx = seek_posn(aBuys, Transact->share, nBuys_inx)
              ains(aBuys, nGen_inx)
              ains(aNo_buy, nGen_inx)
              aBuys[nGen_inx] = Transact->share
              aNo_buy[nGen_inx] = 0
            endif
            aNo_buy[nGen_inx]++
          endif
        case Transact->trn_type = 'SEL'
          IF Transact->trn_dt > param->lst_portprt
            nGen_inx = ascan(aSells, Transact->share)
            if nGen_inx = 0
              aadd(aSells, nil)
              aadd(aNo_sell, nil)
              nSells_inx++
              nGen_inx = seek_posn(aSells, Transact->share, nSells_inx)
              ains(aSells, nGen_inx)
              ains(aNo_sell, nGen_inx)
              aSells[nGen_inx] = Transact->share
              aNo_sell[nGen_inx] = 0
            endif
            aNo_sell[nGen_inx]++
          endif
        case Transact->trn_type = 'SSL'
          if Transact->trn_dt > param->lst_portprt
            nGen_inx = ascan(aBears, Transact->share)
            if nGen_inx = 0
              aadd(aBears, nil)
              aadd(aNo_bear, nil)
              nBears_inx++
              nGen_inx = seek_posn(aBears, Transact->share, nBears_inx)
              ains(aBears, nGen_inx)
              ains(aNo_bear, nGen_inx)
              aBears[nGen_inx] = Transact->share
              aNo_bear[nGen_inx] = 0
            endif
            aNo_bear[nGen_inx]++
          endif
        case Transact->trn_type = 'SDV'
          if Transact->trn_dt > param->lst_portprt
            nGen_inx = ascan(aDlvs, Transact->share)
            if nGen_inx = 0
              aadd(aDlvs, nil)
              aadd(aNo_dlv, nil)
              nDlvs_inx++
              nGen_inx = seek_posn(aDlvs, Transact->share, nDlvs_inx)
              ains(aDlvs, nGen_inx)
              ains(aNo_dlv, nGen_inx)
              aDlvs[ngen_inx] = Transact->share
              aNo_dlv[nGen_inx] = 0
            endif
            aNo_dlv[nGen_inx]++
          endif
        case Transact->trn_type = 'NEX'
          if Transact->trn_dt > param->lst_portprt
            nGen_inx = ascan(aNpls, Transact->share)
            if nGen_inx = 0
              aadd(aNpls, nil)
              aadd(aNo_npl, nil)
              nNpls_inx++
              nGen_inx = seek_posn(aNpls, Transact->share, nNpls_inx)
              ains(aNpls, nGen_inx)
              ains(aNo_npl, nGen_inx)
              aNpls[nGen_inx] = Transact->share
              aNo_npl[nGen_inx] = 0
            endif
            aNo_npl[nGen_inx]++
          endif
      endcase
      dbskip()
      if inkey() = K_ESC .and. wmake_sure('Quit this print out ?')
        break
      endif
    enddo
    
    @1,0 say center('SCANNING COMMENTARY FILE',,,.t.)
    select shrdescr
    dbgotop()
    nCnt = 0
    while !eof()
      nCnt++
      @3,0 say replicate('±', int(nCnt / lastrec() * maxcol() + 1))
      if shrdescr->lst_f_chg > param->lst_portpr
        nNo_funds++
      endif
      dbskip()
      if inkey() = K_ESC .and. wmake_sure('Quit this print out ?')
        break
      endif
    enddo
  endif
  
  if nOption = 2 .or. nOption = 3
    @1,0 say center('SCANNING PORTFOLIO FILE',,,.t.)
    select Portfol
    dbgotop()
    nCnt = 0
    while !eof()
      nCnt++
      @4,0 say replicate('±', int(nCnt / lastrec() * maxcol() + 1))
      if portfol->type = 'P'
        nGen_inx = ascan(aHolds, Portfol->share)
        if nGen_inx = 0
          aadd(aHolds, nil)
          aadd(aNo_hold, nil)
          nHolds_inx++
          nGen_inx = seek_posn(aHolds, Portfol->share, nHolds_inx)
          ains(aHolds, nGen_inx)
          ains(aNo_hold, nGen_inx)
          aHolds[nGen_inx] = Portfol->share
          aNo_hold[nGen_inx] = 0
        endif
        aNo_hold[nGen_inx]++
      endif
      dbskip()
      if inkey() = K_ESC .and. wmake_sure('Quit this print out ?')
        break
      endif
    enddo
  endif
  
  @1,0 say center('GENERATING REPORTS',,,.t.)
  memvar->lPr_esc = .t.
  if nOption = 1 .or. nOption = 3
    if nBuys_inx != 0
      @5,0 say center('BUY REPORT')
      cTitle = 'ALL SHARES THAT HAVE BEEN BOUGHT SINCE LAST WEEK'
      for nGen_inx = 1 to nBuys_inx
        if pLine > 60
          prntitle(cTitle, 'N')
          pr_line('SHARE CODE              LAST TECHNICAL        LAST FUNDAMENTAL         NO TRANS')
          pr_line(' ')
        endif
        cLine = aBuys[nGen_inx]
        select Share
        dbseek(aBuys[nGen_inx])
        select shrdescr
        if dbseek(aBuys[nGen_inx])
          if shrdescr->lst_b_chg > param->lst_portpr
            nNew_buys++
          endif
          cLine += '                  ' + dtoc(shrdescr->lst_b_chg)
          if shrdescr->lst_b_chg + 4 > date()   // comment in last 3 days
            cLine += '    '
          else
            if shrdescr->lst_b_chg + 30 <= date() // but in last month
              cLine += '   *'
            else
              if abs(int((Share->price - shrdescr->lst_wk_pr) /;
                    shrdescr->lst_wk_pr * 100)) > 7     // wks move > 7%
                cLine += '   *'
              else
                cLine += '    '
              endif
            endif
          endif
          cLine += '            ' + dtoc(shrdescr->lst_f_chg)
          if shrdescr->lst_f_chg + 120 <= date()
            cLine += '   *'
          else
            cLine += '    '
          endif
        endif
        cLine += '    ' + str(aNo_buy[nGen_inx])
        pr_line(cLine)
        nTot_buys += aNo_buy[nGen_inx]
      next
      pr_line(' ')
      pr_line('Buy comments written = ' + ltrim(str(nNew_buys)))
      pr_line('Total buy transactions = ' + str(nTot_buys))
    endif
    
    if nSells_inx != 0
      @5,0 say center('SELL REPORT',,,.t.)
      cTitle = 'ALL SHARES THAT HAVE BEEN SOLD SINCE LAST WEEK'
      pLine = 90
      for nGen_inx = 1 to nSells_inx
        if pLine > 60
          prntitle(cTitle, 'N')
          pr_line('SHARE CODE                   LAST TECHNICAL         NO TRANS')
          pr_line(' ')
        endif
        cLine = aSells[nGen_inx]
        select Share
        dbseek(aSells[nGen_inx])
        select shrdescr
        if dbseek(aSells[nGen_inx])
          if shrdescr->lst_s_chg > param->lst_portpr
            nNew_sells++
          endif
          if shrdescr->lst_s_chg + 4 > date()   // comment in last 3 days
            cLine += '    '
          else
            if shrdescr->lst_s_chg + 30 <= date() // but in last month
              cLine += '   *'
            else
              if abs(int((Share->price - shrdescr->lst_wk_pr) /;
                    shrdescr->lst_wk_pr * 100)) > 7     // wks move > 7%
                cLine += '   *'
              else
                cLine += '    '
              endif
            endif
          endif
          cLine += '                    ' + dtoc(shrdescr->lst_s_chg)
        endif
        cLine += '      ' + str(aNo_sell[nGen_inx])
        pr_line(cLine)
        nTot_sells += aNo_sell[nGen_inx]
      next
      pr_line(' ')
      pr_line('Sell comments written = ' + ltrim(str(nNew_sells)))
      pr_line('Total sell transactions = ' + str(nTot_sells))
    endif
    
    IF nBEARS_INX != 0
      @5,0 say center('BEAR REPORT',,,.t.)
      cTitle = 'ALL SHARES THAT HAVE BEEN BEAR SOLD SINCE LAST WEEK'
      pLine = 90
      for nGen_inx = 1 to nBears_inx
        if pLine > 60
          prntitle(cTitle, 'N')
          pr_line('SHARE CODE                   LAST TECHNICAL         NO TRANS')
          pr_line(' ')
        endif
        cLine = aBears[nGen_inx]
        select shrdescr
        if dbseek(aBears[nGen_inx])
          cLine += '                    ' + dtoc(shrdescr->lst_s_chg) +;
              '                  ' + dtoc(shrdescr->lst_f_chg)
        endif
        pr_line(cLine)
        nTot_bears += aNo_bear[nGen_inx]
      next
      pr_line(' ')
      pr_line('Total bear transactions = ' + str(nTot_bears))
    endif
    
    if nDlvs_inx != 0
      @5,0 say center('BEAR DELIVERY REPORT',,,.t.)
      cTitle = 'ALL SHARES THAT HAVE BEEN BEAR SOLD SINCE LAST WEEK'
      pLine = 90
      for nGen_inx = 1 to nDlvs_inx
        if pLine > 60
          prntitle(cTitle, 'N')
          pr_line('SHARE CODE                   LAST TECHNICAL           LAST FUNDAMENTAL')
          pr_line(' ')
        endif
        cLine = aDlvs[nGen_inx]
        select shrdescr
        if dbseek(aDlvs[nGen_inx])
          cLine += '                    ' + dtoc(shrdescr->lst_b_chg) +;
              '                  ' + dtoc(shrdescr->lst_f_chg)
        endif
        pr_line(cLine)
        nTot_dlvs += aNo_dlv[nGen_inx]
      next
      pr_line(' ')
      pr_line('Total bear delivery transactions = ' + str(nTot_dlvs))
    endif
    
    pr_line(' ')
    pr_line('Fundamental comments written since last printout = ' +;
        ltrim(str(nNo_funds)))
  endif
  
  if nOption = 2 .or. nOption = 3
    if nHolds_inx != 0
      @5,0 say center('HOLDING REPORT',,,.t.)
      cTitle = 'PORTFOLIO ADVISORY SHARES'
      pLine = 90
      for nGen_inx = 1 to nHolds_inx
        if pLine > 60
          prntitle(cTitle, 'N')
          pr_line('SHARE CODE                   LAST HOLDING         CLIENT HOLDING')
          pr_line(' ')
        endif
        cLine = aHolds[nGen_inx]
        select shrdescr
        if dbseek(aHolds[nGen_inx])
          cLine += '                    ' + dtoc(shrdescr->lst_h_chg)
          if shrdescr->lst_h_chg + 30 < date()
            cLine += '    *'
          else
            cLine += '     '
          endif
          cLine += space(10) + str(aNo_hold[nGen_inx],5,0)
        endif
        nTot_holds += aNo_hold[Ngen_inx]
        pr_line(cLine)
      next
      pr_line(' ')
      pr_line("Total PORTFOLIO ADVISORY SHARES = " + str(nTot_holds))
    endif
  endif
end sequence
wclose()
shutprn()
et_close('Transact')
et_close('Portfol')
et_close('Share')
et_close('Shrdescr')
return

* EOF()

***********************************************************
static function seek_posn (aShare, cShare, nMax)
local nRet_inx := 1, lFound := .f.
while !lFound
  if nRet_inx = nMax
    lFound = .t.
  elseif aShare[nRet_inx] = nil
    lFound = .t.
  elseif aShare[nRet_inx] < cShare
    nRet_inx ++
  else
    lFound = .t.
  endif
enddo
return nRet_inx
*EOF()
