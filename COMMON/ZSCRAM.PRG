*- ZSCRAM SCRAMBLE/UNSCRAMBLE .DBF HEADER RECORD
* TO STOP ACCESS VIA DBASE
* XFILE=FILE NAME ( EXCLUDING .DBF )
* XTYPE=1 - SCRAMBLE
* XTYPE=2 - UNSCRAMBLE FILE WITHOUT MEMO FIELD
* XTYPE=3 - UNSCRAMBLE FILE WITH MEMO FIELD(S)
proc zscram
private xfile,xtype,xbyte
para xfile,xtype
xfile=xfile+'.dbf'
handle=fopen(xfile,2)
xbyte=' '
if ferror() # 0
  ? 'Cannot open '+xfile+' dos error ',ferror()
  return
endif
do case
  case xtype=1
    xbyte=chr(4)
  case xtype=2
    xbyte=chr(3)
  case xtype=3
    xbyte=chr(131)
endcase
fwrite(handle,xbyte,1)
return
