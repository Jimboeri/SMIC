*******************************************************************************
* FUTMARG - Calculates extra margin where necessary
* JIM WEST
* 03/89

local nTot_port, nVal, nOrig_val, nCurr_val, nCurr_marg, nExtra
memvar cMessage
nTot_port = 0
#define EOL     chr(13) + chr(10)

wopen(8,10,11,70)
wcenter()
wbox(0)
setcursor(0)
@0,0 say center('CHECKING FOR ANY EXTRA MARGIN THAT IS DUE')

begin sequence
  select 1
  if !net_use('futoptn', .f.,, 'futoptn')
    break
  endif
  
  select 2
  if !net_use('futport', .f.,, 'futport')
    break
  endif
  
  select 3
  if !net_use('futtrans', .f.,, 'futtrans')
    break
  endif
  
  select 4
  if !net_use('student', .f.,, 'stdcode')
    break
  endif
  
  select Futport
  while .not. eof()
    nTot_port++
    @1,0 say replicate('±', int(nTot_port / lastrec() * 60))
    select futoptn
    dbseek(Futport->fut_optn)
    if Futport->qty > 0
      nVal = Futoptn->bid
    else
      nVal = Futoptn->offer
    endif
    nOrig_val = 0
    select Futport
    nOrig_val = futval(nVal, futoptn->calc_type)
    nCurr_val = (Futport->int_value + (nOrig_val * futport->qty))
    nCurr_marg = abs(futoptn->margin * futport->qty)
    nExtra = 0
    if (futport->margin + nCurr_val) < (nCurr_marg / 2)
      tts_on()
      nExtra = nCurr_marg - (futport->margin + nCurr_val)
      select Futport
      reclock('Future portfolio')
      Futport->margin := Futport->margin + nExtra
      dbunlock()
      select Student
      dbseek(Futport->std_code)
      reclock('Student')
      Student->fut_cash := Student->fut_cash - nExtra
      dbunlock()
      select Futtrans
      dbappend()
      reclock('Future transactions')
      Futtrans->std_code := Futport->std_code
      Futtrans->fut_optn := Futport->fut_optn
      Futtrans->qty      := Futport->qty
      Futtrans->trn_type := 'FXM'
      Futtrans->margin   := Futport->margin
      Futtrans->trn_dt   := date()
      Futtrans->profit   := nExtra
      dbunlock()
      cMessage += 'Extra margin of ' + ltrim(str(nExtra,14,2)) + ' on ';
          + trim(Futport->fut_optn) + ' for Std ' + Futport->std_code + EOL
      tts_off()
    endif
    select Futport
    dbskip()
  enddo
end sequence
et_close('futoptn')
et_close('futport')
et_close('futtrans')
et_close('Student')
wclose()

cMessage += 'Future portfolio records = ' + ltrim(str(nTot_port,14,2)) + EOL

return

*eof
