*******************************************************************************
* PROGRAM 'LDADD'
* AUTHOR JIM WEST (E.T.)
* 1/10/87

memvar dSource_dt, cSource_cd, cArchiv, getlist, cErr_sect, cSEct, lAdd_rec
memvar cP_code, cInitls, cTitle, cSurname, cAddr1, cAddr2, cAddr3
memvar cPhone_w, cPhone_h, cMisc_cd1, cSelf_emp, cLead_gen_c, cSex
memvar cRace, cMisc_cd2, cMisc_code, cSales_psn, cOccupation, dAlloc_dt
memvar lDuplicate, cSur1

local lCnt, cTmp_add1, cTmp_add2

private cSect, getlist := {}, cErr_sect

#include 'inkey.ch'

dSource_dt = ctod('  /  /  ')
cSource_cd = '   '
cArchiv = 'xxxxxxx'
while !empty(cArchiv)
  simhead(memvar->pscr_title)
  @3,1 say space(12) + 'Initial data capture of a new lead '
  cArchiv = space(7)
  @5,1 say 'Archive No: ' get cArchiv picture '@!' valid val_arc_no()
  @10,5 say 'Enter archive number or hit enter to return to menu'
  cErr_sect = savesector(20,10,24,70)
  read
  if !empty(cArchiv)
    lAdd_rec = .t.
    select newleads
    if dbseek(cArchiv)
      cSect = disp_msg(21,, 'Lead already exists')
      inkey(20)
      restsector(cSect)
    else
      @5,14 clear
      @6,1 clear
      @5,14 say cArchiv
      cTitle := cInitls := cP_code := space(4)
      cSurname := space(30)
      cAddr1 := cAddr2 := cAddr3 := space(25)
      cPhone_H := cPhone_W := space(15)
      cRace := cSex := cLead_gen_c := cSelf_emp := cMisc_cd1 := ' '
      cMisc_cd2 := ' '
      cMisc_code := space(3)
      cOccupation := cSales_psn := space(2)
      dAlloc_dt := date()
      @7,1 say 'Title:   ' get cTitle picture '@!'
      @7,15 say 'Initials: ' get cInitls picture '@!'
      @8,1 say 'Surname: ' get cSurname picture '@!' valid val_ld_surname()
      @7,50 say 'Source code: ' get cSource_cd picture '@!';
          when pre_src_cd() valid val_ld_src_cd()
      @8,50 say 'Source Date: ' get dSource_dt picture '@d';
          when pre_src_dt(cSource_cd) valid val_ld_dt_src(cSource_cd)
      cErr_sect = savesector(20,10,24,70)
      read
      if lAdd_rec
        select newleads
        dbsetorder(2)
        save screen
        lDuplicate = .F.
        cSur1 = substr(cSurname,1,5)
        dbseek(cSource_cd + dtos(dSource_dt) + cSur1)
        while cSource_cd = newleads->source_cd .and.;
              dSource_dt = newleads->source_dt;
              .and. newleads->surname = cSur1 .and. !eof()
          @2,0 clear to 23,80
          @3,0 to 23,79
          @4,25 say 'Displaying possible duplicates'
          lCnt = 5
          while cSource_cd = newleads->source_cd .and.;
                dSource_dt = newleads->source_dt;
                .and. newleads->surname = cSur1 .and. lCnt < 20 .and. !eof()
            if !empty(newleads->address3)
              cTmp_add1 = newleads->address2
              cTmp_add2 = newleads->address3
            else
              cTmp_add1 = newleads->address1
              cTmp_add2 = newleads->address2
            endif
            if !lDuplicate
              lDuplicate = .t.
            endif
            @lCnt,2 say newleads->archiv + ' ' + newleads->title + ' ';
                + newleads->initls + ' ' + newleads->surname + ' ' +;
                newleads->p_code + ' ' + trim(cTmp_add1)
            @lCnt+1,2 SAY 'Phone H ' + newleads->Phone_h + ' Phone W ' +;
                newleads->Phone_w + '       ' + trim(cTmp_add2)
            lCnt += 3
            dbskip()
          enddo
          inkey(0)
        enddo
        if lDuplicate
          lAdd_rec = make_sure(22,20,;
              'Are you sure you want to add this lead ?')
        endif
        dbsetorder(1)
        restore screen
      endif
      if lAdd_rec
        @10,0 clear
        @10,1 say 'Address :    ' get cAddr1 picture  '@!'
        @11,15 get cAddr2 picture '@!'
        @12,15 get cAddr3 picture '@!'
        @13,1 say 'Postal Code: ' get cP_code picture '9999';
            valid val_ld_p_code()
        @14,1 say 'Phone-Home: ' get cPhone_H picture '@!'
        @14,30 say 'Phone-Work: ' get cPhone_W picture '@!'
        @16,1 say 'Race: ' get cRace picture '!' valid val_ld_race()
        @16,20 say 'Sex: ' get cSex picture '!' valid val_ld_sex()
        @16,45 say 'Self employed: ' get cSelf_emp picture '!';
            valid val_ld_self_emp()
        @18,1 say 'Occupation:  ' get cOccupation picture '!!' valid ldad_v04()
        @18,30 say 'Miscellaneous code: ' get cMisc_cd1 picture '!';
            valid ldad_v06()
        @18,52 get cMisc_cd2 picture '!' valid ldad_v07()
        @18,58 say 'Post/Telephone/Fax ' get cLead_gen_c picture '!';
            valid ldad_v08()
        @20,20 say 'Salesperson: ' get cSales_psn picture '!!';
            valid ldad_v09()
        @20,44 say 'Date allocated: ' get dAlloc_dt picture '@d'
        cErr_sect = savesector(21,10,24,70)
        *
        read
        cMisc_code = cMisc_cd1 + cMisc_cd2
        dbappend()
        reclock('Leads')
        newleads->archiv     := cArchiv
        newleads->title      := cTitle
        newleads->initls     := cInitls
        newleads->surname    := cSurname
        newleads->address1   := cAddr1
        newleads->address2   := cAddr2
        newleads->address3   := cAddr3
        newleads->p_code     := cP_code
        newleads->phone_h    := cPhone_h
        newleads->phone_w    := cPhone_w
        newleads->race       := cRace
        newleads->sex        := cSex
        newleads->occupation := cOccupation
        newleads->misc_cd    := cMisc_code
        newleads->source_cd  := cSource_cd
        newleads->source_dt  := dSource_dt
        newleads->date_rcvd  := date()
        newleads->lead_gen_c := cLead_gen_c
        newleads->salespsn   := cSales_psn
        newleads->alloc_dt   := dAlloc_dt
        newleads->self_emp   := cSelf_emp
        dbunlock()
        select adverts
        reclock('adverts')
        adverts->total_ld := adverts->total_ld + 1
        if substr(cMisc_code,2,1) = 'G'
          adverts->good_ld := adverts->good_ld + 1
        endif
        if adverts->lst_lead < date()
          adverts->lst_lead := date()
        endif
        dbunlock()
        select reps
        if dbseek(cSales_psn) .and. reps->last_lead < date()
          reclock('reps')
          reps->last_lead := date()
          dbunlock()
        endif
        select newleads
      endif // surname not empty
    endif // rec not found
    dbcommit()
  endif // archiv != space
enddo // archiv != space
return

***********************************************************
function val_ld_race
local cField, cVal
cField = readvar()
cVal = &cField
restsector(memvar->cErr_sect)
if lastkey() = K_UP
  return(.t.)
endif
if cVal $ 'WBA'
  return(.t.)
endif
disp_msg(21,, "Race must be 'W', 'B' or 'A'")
return(.f.)

***********************************************************
function val_ld_sex()
local cField, cVal
cField = readvar()
cVal = &cField
restsector(memvar->cErr_sect)
if lastkey() = K_UP
  return(.t.)
endif
if cVal $  'MF'
  return(.t.)
endif
disp_msg(21,, "Sex must be 'M' or 'F'")
return(.f.)

***********************************************************
function val_ld_self_emp()
local cField, cVal
cField = readvar()
cVal = &cField
restsector(memvar->cErr_sect)
if lastkey() = K_UP
  return(.t.)
endif
if cVal $ 'NY'
  return(.t.)
endif
disp_msg(21,, "Self employed must be 'Y' or 'N'")
return(.f.)

***********************************************************
FUNCTION LDAD_V04
LOCAL cFIELD, CVAL
cFIELD = READVAR()
cVAL = &cFIELD
restsector(memvar->cErr_sect)
IF cVAL != '02' .AND. cVAL != '04' .AND. cVAL != '06' .AND. cVAL != '08' .AND. cVAL != '10';
      .AND. cVAL != '12' .AND. cVAL != '14' .AND. cVAL != '16' .AND. cVAL != '18' .AND. cVAL != '20';
      .AND. cVAL != '22' .AND. cVAL != '24' .AND. cVAL != '26' .AND. cVAL != '28' .AND. cVAL != '32';
      .AND. cVAL != '34' .AND. cVAL != '36' .AND. cVAL != '38' .AND. cVAL != '40' .AND. cVAL != '42';
      .AND. cVAL != '44' .AND. cVAL != '46' .AND. cVAL != '48' .AND. cVAL != '50' .AND. cVAL != '52';
      .AND. cVAL != '54' .AND. cVAL != '56' .AND. cVAL != '58' .AND. cVAL != '59' .AND. cVAL != '60';
      .AND. cVAL != '62' .AND. cVAL != '64' .AND. cVAL != '66' .AND. cVAL != '68' .AND. cVAL != '70';
      .AND. cVAL != '72' .AND. cVAL != '74' .AND. cVAL != '76' .AND. cVAL != '78' .AND. cVAL != '80';
      .AND. cVAL != '82' .AND. cVAL != '84' .AND. cVAL != '86' .AND. cVAL != '88'
  disp_msg(21, , "Invalid occupation - Press F1")
  return(.f.)
endif
return(.t.)

***********************************************************
function Val_ld_p_code()
local cField, cVal, nVal, nLenpcd, lNumeric, nCnt, cChar
cField = readvar()
cVal = &cField
nVal = val(cVal)
restsector(memvar->cErr_sect)
if memvar->cSales_psn != 'N'
  do case
    case nVal > 0 .and. nVal < 1400 .and. substr(memvar->cSales_psn,1,1) != 'P'
      memvar->cSales_psn = 'P '
    case nVal > 2799 .and. nVal < 2900 .and. substr(memvar->cSales_psn,1,1) != 'P'
      memvar->cSales_psn = 'P '
    case nVal > 8299 .and. nVal < 9000 .and. substr(memvar->cSales_psn,1,1) != 'P'
      memvar->cSales_psn = 'P '
    case nVal > 9299 .and. nVal < 10000 .and. substr(memvar->cSales_psn,1,1) != 'P'
      memvar->cSales_psn = 'P '
    case nVal > 1399 .and. nVal < 2800 .and. substr(memvar->cSales_psn,1,1) != 'J'
      memvar->cSales_psn = 'J '
    case nVal > 4899 .and. nVal < 8300 .and. substr(memvar->cSales_psn,1,1) != 'C'
      memvar->cSales_psn = 'C '
    case nVal > 2899 .and. nVal < 4900 .and. substr(memvar->cSales_psn,1,1) != 'D'
      memvar->cSales_psn = 'D '
  endcase
endif
nLenpcd = trim(cVal)
if len(nLenpcd) != 4
  disp_msg(21, , 'Postal code must be fully entered')
  return(.f.)
endif
return(.t.)

***********************************************************
function ldad_v06
local Cfield, cval
cField = readvar()
cVal = &cField
restsector(memvar->cErr_sect)
if !(cVal $ 'YFSBDR')
  disp_msg(21, , '1st char of Miscellaneous code must be Y/F/S/R/B/D')
  return(.f.)
endif
return(.t.)

***********************************************************
FUNCTION LDAD_V07
LOCAL cFIELD, CVAL
cFIELD = READVAR()
cVAL = &cFIELD
restsector(memvar->cErr_sect)
IF !(cVAL = 'G' .OR. cVAL = 'P')
  disp_msg(21, , '2nd char of Miscellaneous code must be G / P')
  return(.f.)
endif
return(.t.)

***********************************************************
FUNCTION LDAD_V08
LOCAL cFIELD, CVAL
cFIELD = READVAR()
cVAL = &cFIELD
restsector(memvar->cErr_sect)
IF cVAL != 'P' .AND. cVAL != 'T' .AND. cVAL != 'F'
  disp_msg(21, ,;
      "Please tell me how you recieved the lead - Post/Telephone/Fax")
  return(.f.)
endif
return(.t.)

***********************************************************
function ldad_v09
local cField, cVal, lReturn
cField = readvar()
cVal = &cField
restsector(memvar->cErr_sect)
lReturn = .t.
select reps
if !dbseek(Cval)
  lReturn = .f.
  @23,10 say 'Sales person does not exist'
else
  if reps->status != 'C'.and. (reps->end_dt + 30) < date()
    lReturn = .f.
    @23,10 SAY 'Sales person is not current'
  endif
endif
select newleads
return(lReturn)

***********************************************************
FUNCTION LDAD_V10
LOCAL cFIELD, CVAL
cFIELD = READVAR()
cVAL = &cFIELD
restsector(memvar->cErr_sect)
IF cVAL != 'N' .AND. cVAL != 'Y' .AND. cVAL != ' '
  disp_msg(21, , "Must be space or 'Y' or 'N'")
  return(.f.)
endif
return(.t.)


***********************************************************
function ldad_v11
local cField, cVal
cField = readvar()
cVal = &cField
restsector(memvar->cErr_sect)
IF cVAL != 'N' .AND. cVAL != 'Y' .AND. cVAL != ' '
  disp_msg(21, , "Must be space or 'Y' or 'N'")
  return(.f.)
else
  return(.t.)
endif
return nil

*******************************************************************************
function val_arc_no()
local cField, cVal, lNumeric, nCnt, cChar
cField = readvar()
cVal = &cField
restsector(memvar->cErr_sect)
if empty(cVal)
  return(.t.)
endif
cVal = trim(cVal)
if len(cVal) != 5
  disp_msg(21,,'Archive number must be 5 characters long')
  return(.f.)
endif
lNumeric = .t.
for nCnt = 1 to 5
  cChar = substr(cVal,nCnt,1)
  if !isdigit(cChar)
    lNumeric = .f.
  endif
next
if !lNumeric
  disp_msg(21,,'Archive number must be Numeric')
  return(.f.)
endif
return(.t.)

*******************************************************************************
function val_ld_surname()
local cField, cVal
cField = readvar()
cVal = &cField
restsector(memvar->cErr_sect)
if lastkey() = K_UP
  return(.t.)
endif
if empty(cVal)
  disp_msg(21,,'Surname must be entered')
  return(.f.)
endif
return(.t.)

*******************************************************************************
function pre_src_cd()
setkey(K_F2, {|| et_seek('adverts', {1,2,5}, .t.)})
setkey(K_F3, {|| ld_kill_entry()})
return(.t.)

*******************************************************************************
function val_ld_src_cd()
local cField, cVal
cField = readvar()
cVal = &cField
restsector(memvar->cErr_sect)
if lastkey() = K_UP
  return(.t.)
endif
if empty(cVal)
  disp_msg(21,,'Source code must be entered','(F2 for list or F3 to quit)')
  return(.f.)
endif
select adverts
if !dbseek(cVal)
  disp_msg(21,,'Source code not on file', '(F2 for list or F3 to quit)')
  return(.f.)
endif
setkey(K_F2, nil)
return(.t.)

*******************************************************************************
function pre_src_dt(cSrc_cd)
select adverts
setkey(K_F2, {|| et_seek('adverts', {2,5}, .f.,, cSrc_cd)})
return(.t.)

*******************************************************************************
function val_ld_dt_src(cSrc_cd)
local cField, dVal
cField = readvar()
dVal = &cField
restsector(memvar->cErr_sect)
if lastkey() = K_UP
  return(.t.)
endif
select adverts
if !dbseek(cSrc_cd + dtos(dVal))
  disp_msg(21,,'Source date not on file', '(F2 for list or F3 to quit)')
  return(.f.)
endif
set filter to
setkey(K_F2, nil)
setkey(K_F3, nil)
return(.t.)

*******************************************************************************
procedure ld_kill_entry()
memvar getlist
memvar->lAdd_rec = .f.
clear gets
return
