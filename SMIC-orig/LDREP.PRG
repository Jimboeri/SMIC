*******************************************************************************
* PROGRAM LDREP
* Jim West
*
*******************************************************************************

local cOrig_col, lMore_reps, lValid, cBr_code, cArchiv, lStudent
local cSp1, cSp2, lChange
memvar cErr_Sect, getlist, cSalespsn, dAlloc, cMisc_1, cMisc_2

cErr_Sect = savesector(20,1,24,79)

simhead(memvar->pscr_title)
cOrig_col = setcolor(memvar->scr_heading)
@4,20 SAY 'Entry screen for sales rep allocations'
setcolor(cOrig_col)
lMore_reps = .T.
while lMore_reps
  @8,0 clear
  cSalespsn = '  '
  dAlloc = date()
  @8,10 say 'Rep ' get cSalespsn picture '!!' valid ldad_v09()
  @8,40 say 'Allocation date ' get dAlloc picture '@d'
  read
  lValid = .F.
  while !lValid
    lValid = .t.
    if cSalespsn = '  '
      @8,10 say 'Rep ' get cSalespsn picture '!!' valid ldad_v09()
      read
      lValid = .F.
    endif
  enddo (validation)
  select reps
  dbseek(cSalespsn)
  cBr_code = substr(cSalespsn,1,1)
  cArchiv = 'XX     '
  while !empty(cArchiv)
    @12,0 clear
    cArchiv = space(7)
    @13,10 say 'Enter archive number ' get cArchiv
    read
    if !empty(cArchiv)
      select newleads
      if !dbseek(cArchiv)
        @23,10 SAY 'Archive number not on file'
        inkey(10)
      else
        select student
        if dbseek(cArchiv)
          lStudent = .T.
        else
          lStudent = .F.
        endif
        select newleads
        if lStudent
          @23,10 say 'LEAD HAS ALREADY BEEN SOLD - CANNOT RE-ALLOCATE'
          inkey(10)
        else
          setcolor(memvar->scr_title)
          @14,0 clear
          @13,40 say trim(newleads->title) + ' ' + newleads->initls
          @14,40 say newleads->surname
          @16,40 say newleads->address1
          @17,40 say newleads->address2
          @18,40 say newleads->address3
          @19,40 say newleads->p_code
          setcolor(cOrig_col)
          cMisc_1 = substr(newleads->misc_cd,1,1)
          cMisc_2 = substr(newleads->misc_cd,2,1)
          cSp1 = substr(newleads->salespsn,1,1)
          cSp2 = substr(newleads->salespsn,2,1)
          lChange = .F.
          if cSp1 = cBr_code .and. cSp2 = ' '
            lChange = .t.
          else
            if cSp2 = ' '
              lChange = make_sure(22,3,;
                  'Lead is already allocated to branch ';
                  + cSp1 + ', do you want to change it ')
            else
              lChange = make_sure(22,3,'Lead is already allocated to ';
                  + newleads->salespsn + ', do you want to change it ')
            endif
          endif
          if lChange
            @17,10 say 'Miscellaneous code: ' get cMisc_1 picture '!';
                valid ldad_v06()
            @17,32 get cMisc_2 picture '!' valid ldad_v07()
            read
            RECLOCK('Leads')
            newleads->misc_cd := cMisc_1 + cMisc_2
            newleads->salespsn := cSalespsn
            newleads->alloc_dt := dAlloc
            dbunlock()
            select reps
            if dAlloc > reps->last_lead
              reclock('reps')
              reps->last_lead := dAlloc
              dbunlock()
            endif
            select newleads
          endif (change allocation)
        endif (lead sold)
      endif (found lead)
    endif (archiv = space)
  enddo (end of leads for that rep)
  lMore_reps = make_sure(22,10,;
      'Do you wish to enter leads allocations for anyone else ?')
enddo (end of reps)
return

*eof
