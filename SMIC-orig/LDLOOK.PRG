*******************************************************************************
* LDLOOK - LEAD VIEW PROGRAM
* Author - Jim West
* 04/10/87

local cArchiv
memvar getlist

#include 'inkey.ch'

begin sequence
  
  select 1
  if !net_use('newleads', .f.,, 'archives')
    break
  endif
  
  select 2
  if !net_use('student', .f.,, 'stdarc')
    break
  endif
  
  select newleads
  cArchiv = 'XXXXXXX'
  while !empty(cArchiv)
    simhead(memvar->pscr_title)
    cArchiv = space(7)
    @5,1 say 'ENTER ARCHIVE NUMBER :' get cArchiv picture '!!!!!!!'
    @10,10 say 'INPUT ARCHIVE NUMBER OR ENTER TO RETURN TO LEADS MENU'
    read
    IF cArchiv != SPACE(7)
      if !dbseek(cArchiv)
        @22,0 say 'Lead does not exist or archive no wrong'
        inkey(10)
      else
        @2,0 clear
        @2,25 say 'Display of lead information'
        setcolor(memvar->scr_title)
        @3,10 say 'ARCHIVE NUMBER'
        @4,10 say 'Title Intls Surname'
        @6,10 say 'Address'
        @9,10 say 'Post code '
        @6,50 say 'Telephone Numbers'
        @7,50 say 'Home '
        @8,50 say 'Work '
        @10,10 say 'Race '
        @10,30 say 'Sex '
        @10,55 say 'Occupation '
        @12,10 say 'Source code '
        @12,30 say 'Source date '
        @12,55 say 'Self emp   '
        @14,10 say 'Date received      '
        @15,10 say 'Allocation Date    '
        @14,40 say 'Sales Person       '
        @15,40 say 'Miscellaneous code '
        @16,10 say 'Follow up date     '
        @17,40 say 'Brochure/Letter    '
        @16,40 say 'Interview          '
        @22,20 say 'Comment '
        setcolor(memvar->disp_text)
        @3,25 say newleads->archiv
        @5,10 say newleads->title
        @5,16 say newleads->initls
        @5,22 say newleads->surname
        @6,20 say newleads->address1
        @7,20 say newleads->address2
        @8,20 say newleads->address3
        @9,20 say newleads->p_code
        @7,56 say newleads->phone_h
        @8,56 say newleads->phone_w
        @10,15 say newleads->race
        @10,34 say newleads->sex
        @10,66 say newleads->occupation
        @12,22 say newleads->source_cd
        @12,42 say dtoc(newleads->source_dt)
        @12,66 say newleads->self_emp
        @14,29 say dtoc(newleads->date_rcvd)
        @14,59 say newleads->salespsn
        @15,29 say dtoc(newleads->alloc_dt)
        @15,59 say newleads->misc_cd
        @16,29 say dtoc(newleads->follow_dt)
        @16,59 say newleads->intview
        @17,59 say newleads->bro_let
        @22,28 say memoline(newleads->mem_comnt,50,1)
        select Student
        if dbseek(newleads->archiv)
          setcolor(memvar->scr_title)
          @19,10 say 'Sold course 1 '
          @19,40 say 'Sold course 2 '
          @20,10 say 'Sold Share Std'
          @20,40 say 'Sold Lectures '
          setcolor(memvar->disp_text)
          @19,25 say dtoc(student->sold_crs_1)
          @19,54 say dtoc(student->sold_crs_2)
          @20,25 say dtoc(student->sold_ss)
          @20,54 say dtoc(student->sold_lectr)
        endif
        if inkey(300) = K_F1
          help(procname(), procline(),'')
        endif
      endif (rec found)
      select newleads
    endif (cArchiv = space)
  enddo
end sequence
dbcloseall()
return
* eof
