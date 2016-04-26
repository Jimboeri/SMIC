if not exist h:\jwest\exist.txt goto endproc
pkarc -a ut
copy ut.arc h:\jwest\db\dbu
del ut.arc
:endproc
