*******************************************************************************
* FUTAUTO - UPDATES FUTURE PRICES AT NIGHT
*
*******************************************************************************

local nUpdates, dExp
memvar cMessage
nUpdates = 0

wopen(8,10,11,70)
wcenter()
wbox(0)
setcursor(0)
@0,0 say center('UPDATING FUTURES PRICES')

begin sequence
  
  select 2
  if !net_use('shrprice', .f.,, 'shrprice')
    break
  endif
  
  select 3
  if !net_use('futoptn', .f.,, 'futoptn')
    break
  endif
  
  while !eof()
    @1,0 say replicate('±', nUpdates / lastrec() * 60)
    tts_on()
    if futoptn->expired != 'E'
      select shrprice
      if dbseek(futoptn->dnl_name)
        nUpdates++
        select futoptn
        reclock('futoptn')
        do case
          case futoptn->calc_type = 1
            * INDICES
            futoptn->bid := val(shrprice->low)
            futoptn->offer := val(shrprice->high)
          case futoptn->calc_type = 2
            * E168
            futoptn->bid := val(shrprice->high) / 100
            futoptn->offer := val(shrprice->low) / 100
          case futoptn->calc_type = 3
            * BA RATE
            futoptn->bid := val(shrprice->high) / 100
            futoptn->offer := val(shrprice->low) / 100
          case futoptn->calc_type = 4
            * DOLLAR GOLD
            futoptn->bid := val(shrprice->low) / 100
            futoptn->offer := val(shrprice->high) / 100
        endcase
        dbunlock()
      endif
    else
      dExp = futoptn->exp_date
      dExp = et_addmonth(dExp)
      if dExp < date()
        select futoptn
        reclock('FUTOPTN')
        dbdelete()
        dbunlock()
      endif
    endif
    dbcommitall()
    tts_off()
    select futoptn
    dbskip()
  enddo
  
  if net_use('param', .f.)
    reclock('param')
    param->lst_f_updt := date()
    memvar->plst_f_upd := date()
    dbunlock()
  endif
  
end sequence
et_close('shrprice')
et_close('futoptn')
et_close('param')
wclose()

cMessage += 'Futures prices successfully updated = ' + ltrim(str(nUpdates));
    + chr(13) + chr(10)

return

* eof
