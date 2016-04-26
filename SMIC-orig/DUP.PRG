*******

#include "smic.ch"

simhead('duplicate checking')

select 1
if !net_use('newleads', .t., 'ld')
  return
endif
index on soundex(surname) to ldname

select 2
if !net_use('student', .f., 'std', 'names')
  return
endif

@5,5 to 20,75

while !eof()
  @6,30 say std->surname
  cSur = soundex(surname)
  select ld
  seek cSur
  while cSur = soundex(surname) .and. !eof()
    if std->archiv != ld->archiv
      if trim(ld->address1) $ std->address1;
	    .or. trim(ld->phone_h) $ std->phone_h;
	    .or. trim(ld->phone_w) $ std->phone_w
        @6,7 say trim(std->title) + ' ' + trim(std->name) + ' ' + std->surname
		@7,7 say std->address1
		@8,7 say std->address2
		@9,7 say std->p_code + std->address3
        @10,7 say 'Phone home ' + std->phone_h
        @11,7 say 'Phone work ' + std->phone_w
        @6,41 say trim(ld->title) + ' ' + trim(ld->initls) + ' ' + surname
		@7,41 say ld->address1
		@8,41 say ld->address2
		@9,41 say ld->p_code + ld->address3
        @10,41 say 'Phone home ' + ld->phone_h
        @11,41 say 'Phone work ' + ld->phone_w
        if make_sure(15,,'Mark as duplicate ?')
          reclock('newleads')
          ld->killed := 'Y'
        endif
        @6,7 clear to 20,74
      endif
    endif
    skip
  enddo
  select 2
  skip
enddo

close databases
