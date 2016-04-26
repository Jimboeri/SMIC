*******************************************************************************
* PROGRAM 'TRNPAS'
* AUTHOR JIM WEST
* 9/2/88

local cShr, nQty, nBrok, nHand, nMst, nValue, nTotal, lCont, nCost_hold
local cScr, nNtx, nInx, nPrice, cOrog_col, aOptions, aType, cOrig_col
local dPurch_dt
memvar getlist

aOptions := {'Buy shares',;
    'Sell shares',;
    'Sell all shares (delete)',;
    'Adjust values'}
aType := {'Price', 'Value'}

cOrig_col = setcolor()

select 4
if !net_use('portfol', .f.,, 'portfol')
  return
endif

select 3
if !net_use('share', .f., , 'shrname')
  return
endif

save screen to cScr
findshr()
restore screen from cScr

if !eof()
  cShr = Share->share
  nQty := nCost_hold := 0
  lCont := .f.
  select Student
  reclock('student')
  @7,1 clear to 23,78
  @7,1 to 23,78
  @8,19 say 'PORTFOLIO ADVISORY SERVICE - SHARE PURCHASE SCREEN'
  @10,10 say trim(cSHR) + ' - ' + Share->full_name
  @11,10 say ' Current price ' + ltrim(str(Share->price))
  select portfol
  if !dbseek(student->std_code + 'P' + cShr)
    if make_sure(14,,'Add share to Portfolio ? ')
      dPurch_dt = ctod('  /  /  ')
      @13,10 say 'Date purchased ' get dPurch_dt
      read
      select portfol
      dbappend()
      reclock('Portfolio')
      portfol->std_code = student->std_code
      portfol->type := 'P'
      portfol->share := cShr
      if empty(dPurch_dt)
        portfol->purch_dt := date()
      else
        portfol->purch_dt := dPurch_dt
      endif
      lCont := .t.
    endif
  else
    lCont = .t.
  endif
  if lCont
    if portfol->qty > 0
      @13,10 say 'SHARES CURRENTLY HELD = ' + ltrim(str(portfol->qty))
    endif
    nNtx = get_arr(aOptions,15,10)
    do case
      case nNtx = 1
        @14,2 clear to 22,77
        @15,10 say 'No of shares bought ' get nQty
        read
        if nQty > 0
          reclock('Portfolio')
          portfol->qty := portfol->qty + nQty
          nInx = get_arr(aType, 15,60)
          do case
            case nInx = 1
              nPrice = 0
              @17,20 say 'Price paid for shares ' get nPrice
              read
              if nPrice != 0
                nValue = (nQty * nPrice) / 100
                nBrok = broker(nValue)
                nHand = handle(nQty)
                nMst = mst(nValue)
                nTotal = nValue + nBrok + nMst + nHand
                reclock('Portfolio')
                portfol->cost_hold := portfol->cost_hold + nTotal
              endif
            case nInx = 2
              @17,20 say 'Original cost of shares ' get nCost_hold picture '999999999.99'
              read
              if nCost_hold > 0
                reclock('Portfolio')
                portfol->cost_hold := portfol->cost_hold + nCost_hold
              endif
          endcase
        endif
      case nNtx = 2
        @14,2 clear to 22,77
        @15,10 say 'No of shares sold ' get nQty
        read
        if nQty > 0
          reclock('Portfolio')
          portfol->qty := portfol->qty - nQty
          nInx = get_arr(aType, 15,60)
          do case
            case nInx = 1
              nPrice = 0
              @17,20 say 'Price received for shares ' get nPrice
              read
              if nPrice != 0
                nValue = (nQty * nPrice) / 100
                nBrok = broker(nValue)
                nHand = handle(nQty)
                nTotal = nValue + nBrok + nHand
                reclock('Portfolio')
                portfol->cost_hold := portfol->cost_hold - nTotal
              endif
            case nInx = 2
              @17,20 say 'Money received from shares ' get nCost_hold
              read
              if nCost_hold > 0
                reclock('Portfolio')
                portfol->cost_hold := portfol->cost_hold - nCost_hold
              endif
          endcase
        endif
      case nNtx = 3
        if make_sure(15,,'Are you SURE you want to delete this share ?')
          if make_sure(17,,'Are you 100 % SURE ?')
            select portfol
            reclock('Portfolio')
            dbdelete()
          endif
        endif
      case nNtx = 4
        nQty = portfol->qty
        nCost_hold = portfol->cost_hold
        dPurch_dt = portfol->purch_dt
        @13,10 say 'Date purchased ' get dPurch_dt
        @15,10 SAY 'Shares held ' get nQty picture '@9'
        @17,10 SAY 'Cost of holding ' get nCost_hold picture '@9'
        read
        reclock('Portfolio')
        portfol->qty := nQty
        portfol->cost_hold := nCost_hold
        portfol->purch_dt := dPurch_dt
    endcase
  endif (lCont)
endif
select Student
dbunlock()
return

* EOF
