:start
checkrun /auto
if exist exist.txt goto start
cd\comms\snet
snetp
fastdn
cd\db\smic
goto start
