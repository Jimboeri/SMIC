*******************************************************************************
* DBFSEL - select a database

local aFile[aDir("*.DBF")]              // array of database names
local nCh
local nAt
local aOpt := {'Update data dictionary',;
    'Leave data dictionary'}
local nOpt
local nCnt
local lAsk                      // set if structure is incompatable with DD
local nRec                      // record code for DD
local lUpdate                   // set if DD to be updated
local nAlias
local cDescr
local nLen

memvar cDbf                     // public vvariable containing name 
                                // of currecnt database (inc .DBF)
memvar aStru                    // Array of current databases structure
memvar cAlias                   // Same as cDbf without .DBF
memvar aVisible                 // array of fields visible in browse

#include "dbstruct.ch"
#include "inkey.ch"

while .t.
  
  aDir("*.DBF", aFile)                  // load array of database names
  asort(aFile)
  aadd(aFile, 'Return')                 // add and exit out
  
  setkey(K_INS, {|| memvar->lMore := .f.})      // cludge to get out
  nCh = get_arr(aFile,,50,,.t.,'Select database file')
  setkey(K_INS, nil)
  
  cDbf := ''
  aStru := {}
  
  if lastkey() = K_INS
    dbfstru()
  else
    
    if nCh = 0 .or. nCh = len(aFile)    // no selection or return
      exit
    endif
    
    select 1
    cDbf := aFile[nCh]
    if aFile[nCh] = 'DD.DBF'
      select dd
      aStru := dbstruct()                       // fill structure array
      cAlias = 'DD'                             // crate alias
    elseif net_use(aFile[nCh])
      aStru := dbstruct()
      nAt := at('.', cDbf)
      cAlias := substr(cDbf,1,nAt-1)
    endif
    memvar->aNtx := {}                          // clear index array
    memvar->aNtx_descr := {}                    // clear index description array
    
    if cDbf != 'DD.DBF'
      lUpdate = .f.
      lAsk = .f.
      select dd
      dbsetorder(1)
      for nCnt = 1 to len(aStru)
        if !dbseek(cDbf + space(15-len(cDbf)) + aStru[nCnt, DBS_NAME])
          // field not in DD
          if !lAsk
            nOpt = Get_arr(aOpt,17,,,.t.)       // ask if DD to be updated
            lUpdate = if(nOpt = 1, .t., .f.)    // interpret request
            lAsk = .t.                          // set flag
          endif
          if lUpdate
            dbsetorder(2)
            dbgobottom()                           // get next rec_code
            nRec = dd->rec_code
            nRec++
            dbsetorder(1)
            dbappend()
            reclock('Data dictionary')
            dd->file := cDbf
            dd->name := aStru[nCnt, DBS_NAME]
            dd->rec_code := nRec
            dbunlock()
          endif
        endif
      next
      dbcommit()
    endif
    
    nAlias = select(cAlias)                     // get work area of alias
    
    aVisible := {}                              // clear array
    for nCnt = 1 to len(aStru)
      select dd
      cDescr = trim(aStru[nCnt, DBS_NAME])      // init descr with name
      if dbseek(cDbf + space(15-len(cDbf)) + aStru[nCnt, DBS_NAME])
        if !empty(dd->descriptn)
          cDescr = trim(dd->descriptn)          // replace with descr if found
        endif
      endif
      dbselectarea(cAlias)
      if cAlias != 'DD' .and.;
       (valtype(dd->key) = 'C' .and. dd->key != ' ')    // encrypted field
        aadd(aVisible, {aStru[nCnt, 1], aStru[nCnt, 2],;
            aStru[nCnt, 3], aStru[nCnt, 4], trim(cDescr),;
            fieldwblock(aStru[nCnt, 1], nAlias),;
            et_block(aStru[nCnt, 1], nAlias, asc(dd->key))})
      else
        aadd(aVisible, {aStru[nCnt, 1], aStru[nCnt, 2],;
            aStru[nCnt, 3], aStru[nCnt, 4], trim(cDescr),;
            fieldwblock(aStru[nCnt, 1], nAlias),;
            fieldwblock(aStru[nCnt, 1], nAlias)})
      endif
    next
    
    memvar->aOther := {}
    exit
  endif
enddo
return

* eof()

*******************************************************************************
function et_block(cField, nAlias, nKey)
local bRet
bRet = { | In_val | et_get_set ( In_val, cField, nAlias, nKey) }
return(bRet)

*******************************************************************************
function et_get_set ( New_val , cField, nAlias, nKey)
local Ret_val, nOrig_area, cAlias, cName
nOrig_area = select()
dbselectar(nAlias)
cAlias = alias(nAlias)
cName = cAlias + '->' + cField
if !empty(new_val)
  &cName := jw_scram(New_val, nKey)
endif
ret_val = &cName
ret_val = jw_scram(ret_val, nKey)
dbselectarea(nOrig_area)
return(ret_val)
