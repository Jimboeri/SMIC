*******************************************************************************
* PROGRAM 'TRNNPLEX' - RIGHTS OPTION EXCERCISED
* AUTHOR JIM WEST
* 9/2/88

local cOrig_col, nQty, cShare, cShareop, nValue, nTotal, cPort, nCost
local nOpper, nShrpos, cType, lBuy_ok, cSect, lAdd_rec
memvar getlist

cType = 'T'

select Student
if !rlock()
  wait_msg(20,'Student already in use - Please try later',,,20)
  return
endif

@4,1 clear to 22,78
@4,1 to 22,78
cOrig_col = setcolor(memvar->yell_black)
@5,20 say "EXERCISE NPL's"
@6,10 say 'STUDENT : ' + trim(Student->title) + ' ' + trim(Student->name);
 + ' ' + trim(Student->surname)
setcolor(cOrig_col)
cShare = findport(Student->std_code + cType)
if !empty(cShare)
  select Share
  dbseek(cShare)
  if share->suspend = 'N' .or. !found()
    select shrdescr
    dbseek(cShare)
    nOpper = share->dividend
    cPort = Student->std_code + cType + cShare
    cShareop = shrdescr->sec_shr
    select Student
    @8,5 say 'Option : ' + cShare
    select Share
    nQty = 0
    @8,5 say 'SHARE   : ' + share->share + '  ' + share->full_name
    @10,40 SAY 'Option price = ' + ltrim(str(nOpper)) + 'c'
    @12,40 SAY 'Cash available        ' + str(Student->cash)
    @13,40 SAY 'Options available     ' + str(portfol->qty)
    if nOpper != 0
      nShrpos = Student->cash / (nOpper/100) / 100
      nShrpos = int(nShrpos) * 100
      if nShrpos < 0
        nShrpos = 0
      endif
      if nShrpos > portfol->qty
        nShrpoS = portfol->qty
      endif
      nValue = (nShrpos * share->price) / 100
      nTotal = nValue
      if nTotal > Student->cash
        nShrpos = nShrpos - 100
      endif
      @14,40 say 'Approx shares available ' + str(nShrpos,10,0)
    endif
    @16,5 say 'QUANTITY OF OPTIONS TO BE EXERCISED' get nQty picture '999999999'
    read
    lBuy_ok = .F.
    while !lBuy_ok
      lBuy_ok = .T.
      nQty = abs(nQty)
      if (nQty > portfol->qty)
        lBuy_ok = .F.
        cSect = savesector(19,10,24,70)
        disp_msg(20,, "CANNOT EXERCISE MORE OPTIONS THAN ARE HELD")
        nQty = 0
        @16,5 say 'ENTER QUANTITY OF OPTIONS TO BE EXERCISED' get nQty;
         picture '999999999'
        read
        restsector(cSect)
      endif
    enddo
    lAdd_rec = .T.
    if nQty > 0
      nValue = (nQty * nOpper) / 100
      nTotal = nValue
      select Student
      if nTotal > student->cash
        if nTotal < student->cash + memvar->povrdrft_lm
          if !make_sure(19,25, 'DO YOU WANT TO GO INTO OVERDRAFT ? ')
            lAdd_rec = .F.
          endif
        else
          lAdd_rec = .F.
          wait_msg(20, 'TRANSACTION VALUE TOTAL EXCEDES CASH AVAILABLE',,,20)
        endif
      endif
      if lAdd_rec
        Student->cash       := student->cash - nTotal
        Student->last_tran  := date()
        Student->wk_unact   := 0
        if student->lec_stat = 'A'
          Student->lec_stat := ' '
        endif
        select transact
        dbappend()
        reclock('Transaction')
        transact->std_code  := Student->std_code
        transact->type      := cType
        transact->share     := cShareop
        transact->trn_type  := 'NEX'
        transact->qty       := nQty
        transact->price     := nOpper / 100
        transact->value     := nTotal * -1
        transact->trn_dt    := date()
        transact->cost_hold := 0
        dbunlock()
        select portfol
        cPort = Student->std_code + cType + cShare
        dbseek(cPort)
        reclock('Portfolio')
        if portfol->qty = nQty
          nCost = portfol->cost_hold
        else
          nCost = portfol->cost_hold * nQty / portfol->qty
          portfol->cost_hold := portfol->cost_hold - nCost
        endif
        portfol->qty := portfol->qty - nQty
        if portfol->qty = 0
          select portfol
          dbdelete()
        endif
        dbunlock()
        cPort = Student->std_code + cType + cShareop
        if !dbseek(cPort)
          dbappend()
          reclock('Portfolio')
          portfol->std_code  := Student->std_code
          portfol->type      := cType
          portfol->share     := cShareop
          portfol->qty       := nQty
          portfol->cost_hold := nTotal + nCost
          dbunlock()
        else
          reclock('Portfolio')
          portfol->qty       := portfol->qty + nQty
          portfol->cost_hold := portfol->cost_hold + nTotal
          dbunlock()
        endif (rec found)
      endif (lAdd_rec)
    endif
  else
    wait_msg(20,, 'THIS IS NOT A NPL - CONTACT THE COURSE MANAGER',,,20)
  endif
endif
select Student
dbunlock()
return
* EOF
