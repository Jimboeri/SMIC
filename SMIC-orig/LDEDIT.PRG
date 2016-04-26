*******************************************************************************
* EDIT MENU (LDEDIT)
* Author - Jim West
* 04/10/87
* ----     SET UP SYSTEM DEFAULTS

local pOrig_col, cArchiv := space(7), cSect, nKey, cOrig_arc
memvar getlist, lSold

#include 'inkey.ch'

select newleads
@5,10 say 'ENTER ARCHIVE NUMBER :' get cArchiv picture '@!'
@10,10 say 'INPUT ARCHIVE NUMBER OR ENTER TO RETURN TO LEADS MENU'
read

if !dbseek(cArchiv)
  cSect = disp_msg(15,,'Archive number not found')
  inkey(30)
  restsector(cSect)
  return
endif

while .t.
  simhead(memvar->pScr_title)
  @3,0 to 24,79
  @5,5 say 'ARCHIVE NUMBER'
  @5,20 say newleads->archiv
  @6,16 say newleads->title + ' ' + newleads->initls + ' ' +;
      newleads->surname
  @7,5 say 'Address    ' + newleads->address1
  @8,16 say newleads->address2
  @9,16 say newleads->p_code + ' ' + newleads->address3
  @7,45 say 'Home phone no ' + newleads->phone_h
  @8,45 say 'Work phone no ' + newleads->phone_w
  @10,5 say 'Race ' + newleads->Race
  @10,25 say 'Sex ' + newleads->Sex
  @10,55 say 'Self employed ' + newleads->Self_emp
  @11,5 say 'Occupation  ' + newleads->Occupation
  @11,25 say 'Miscellaneous code ' + newleads->Misc_cd
  @13,5 say 'Source code ' + newleads->source_cd
  @14,5 say 'Source_date ' + dtoc(newleads->source_dt)
  @13,55 say 'Post/Telephone/Fax ' + newleads->Lead_gen_c
  @14,55 say 'Date received ' + dtoc(newleads->date_rcvd)
  @16,5 say 'Sales rep      ' + newleads->salespsn
  @17,5 say 'Date allocated ' + dtoc(newleads->alloc_dt)
  @18,5 say 'Follow up date ' + dtoc(newleads->follow_dt)
  @16,55 say 'Presented     ' + newleads->intview
  @17,55 say 'Sent Brochure ' + newleads->bro_let
  
  lSold = .f.
  select student
  if dbseek(newleads->archiv)
    @20,20 say 'This person has bought a course from us'
    lSold = .t.
  endif
  
  @23,3 say 'F4 - Sales'
  @23,16 SAY 'F5 - Customer'
  @23,32 SAY 'F6 - Another lead'
  @23,52 SAY 'Del - Delete'
  @23,67 SAY 'Esc - Exit'
  nKey = inkey(0)
  do case
    case nKey = K_F4
      ldedita()
    case nKey = K_F5
      ldeditb()
    case nKey = K_F6
      cOrig_arc = cArchiv
      @5,20 get cArchiv picture '@!'
      read
      if !dbseek(cArchiv)
        cSect = disp_msg(18,,'Lead not found')
        inkey(30)
        restsector(cSect)
        cArchiv = cOrig_arc
        dbseek(cArchiv)
      endif
    case nKey = K_DEL
      if !lSold
        if make_sure(18,,'Are you sure you want to delete this lead ?')
          select newleads
          reclock()
          dbdelete()
          dbunlock()
          exit
        endif
      else
        cSect = disp_msg(18,,'Lead has been sold', 'Cannot be deleted')
        inkey(30)
        restsector(cSect)
      endif
    case nKey = K_ESC
      exit
  endcase
enddo
return
* eof

*******************************************************************************
* Program 'ldedita' SALES PERSON EDIT

procedure ldedita
local cSect
memvar cErr_sect, cSales_psn, getlist
select newleads
if !rlock()
  cSect = disp_msg(18,,'Lead in use elsewhere, Please try later')
  inkey(30)
  restsector(cSect)
  return
endif
cSales_psn = newleads->salespsn
if !memvar->lSold
  @16,20 get cSales_psn picture '!!' valid ldad_v09()
endif
@17,20 get newleads->alloc_dt picture '@d'
@18,20 get newleads->follow_dt picture '@d'
@16,71 get newleads->intview picture '!' valid ldad_v10()
@17,71 get newleads->bro_let picture '!' valid ldad_v11()

cErr_sect = savesector(20,5,24,75)
read
if newleads->salespsn != cSales_psn
  select reps
  if dbseek(cSales_psn)
    if newleads->alloc_dt > reps->last_lead
      reclock('Reps')
      reps->last_lead := newleads->alloc_dt
      dbunlock()
    endif
  endif
endif
select newleads
newleads->salespsn := cSales_psn
dbcommit()
return

* EOF

*******************************************************************************
* Program 'ldeditb' CUSTOMER EDIT

procedure ldeditb
local cSect
memvar getlist, cErr_sect, cMisc1, cMisc2, cSales_psn

select newleads
if !rlock()
  cSect = disp_msg(18,,'Lead in use elsewhere, Please try later')
  inkey(30)
  restsector(cSect)
  return
endif
cMisc1 = substr(newleads->misc_cd,1,1)
cMisc2 = substr(newleads->misc_cd,2,1)
cSales_psn = newleads->salespsn
@6,16 clear to 6,60
@6,16 get newleads->title picture '@!'
@6,21 get newleads->initls picture '@!'
@6,26 get newleads->surname picture '@!'
@7,16 get newleads->address1 picture '@!'
@8,16 get newleads->address2 picture '@!'
@9,16 get newleads->p_code picture '9999' valid val_ld_p_code()
@9,21 get newleads->address3 picture '@!'
@7,59 get newleads->phone_h
@8,59 get newleads->phone_w
@10,10 get newleads->Race picture '!' valid val_ld_race()
@10,29 get newleads->Sex picture '!' valid val_ld_sex()
@10,69 get newleads->Self_emp picture '!' valid val_ld_self_emp()
@11,17 get newleads->Occupation picture '!!' valid ldad_v04()
@11,44 get cMisc1 picture '!' valid ldad_v06()
@11,45 get cMisc2 picture '!' valid ldad_v07()
@13,17 get newleads->source_cd picture '@!';
    when pre_src_cd() valid val_ld_src_cd()
@14,17 get newleads->source_dt picture '@d';
    when pre_src_dt(newleads->Source_cd);
    valid val_ld_dt_src(newleads->Source_cd)
@13,74 get newleads->Lead_gen_c
cErr_sect = savesector(21,10,24,70)
read
newleads->misc_cd := cMisc1 + cMisc2
dbcommit()

return
* eof
