*******************************************************************************
*
*  LDREMOVE - REMOVES LEADS WITH INCORRECT ADDRESSES FROM MAILING LISTS
*  APRIL 90
*
*******************************************************************************

local cArchiv
memvar getlist

simhead(memvar->pscr_title)

cArchiv = 'XXXXXXX'
while !empty(cArchiv)
  @3,0 CLEAR
  cArchiv = SPACE(7)
  @5,10 say 'Enter archive number ' get cArchiv
  read
  if !empty(cArchiv)
    select student
    if dbseek(cArchiv)
      @23,10 say 'Student attached to this lead'
      inkey(10)
    endif
    select newleads
    if dbseek(cArchiv)
      @8,10 say trim(newleads->title) + ' ' + trim(newleads->initls);
          + ' ' + newleads->surname
      @9,10 say newleads->address1
      @10,10 say newleads->address2
      @11,10 say newleads->p_code + ' ' + newleads->address3
      if make_sure(14,22,'Remove this lead from the database ')
        reclock('newleads')
        newleads->killed := 'Y'
        dbunlock()
        select oldleads
        if dbseek(cArchiv)
          reclock('old leads')
          dbdelete()
          dbunlock()
        endif
      endif
    else
      select oldleads
      if dbseek(cArchiv)
        @8,10 say trim(oldleads->title) + ' ' + trim(oldleads->initls);
            + ' ' + oldleads->surname
        @9,10 say oldleads->address1
        @10,10 say oldleads->address2
        @11,10 say oldleads->p_code + ' ' + oldleads->address3
        if make_sure(14,22,'Remove this lead from the database ')
          reclock('old leads')
          dbdelete()
          dbunlock()
        endif
      else
        @22,10 say 'Archive number does not exist'
      endif
    endif
  endif
enddo

return

* EOF
