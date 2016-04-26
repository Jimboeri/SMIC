d:
cd\clipper\db\smic\proced
COPY \clipper\DB\COMMON\PROCFL.PRG
COPY \clipper\DB\COMMON\help.PRG
COPY \clipper\DB\COMMON\mouse.PRG
COPY \clipper\DB\COMMON\to_do.PRG
COPY \clipper\DB\COMMON\procs.PRG
CLIPPER PROCED /w > proced.aaa
DEL PROCFL.PRG
del mouse.prg
del help.prg
del to_do.prg
del procs.prg
CD\clipper\DB\BIN
COPY d:\clipper\DB\smic\PROCED\PROCED.OBJ
rem lib proced.lib proced.obj+cproc.obj+oldcproc.obj+mousea.obj+getsys.obj ;
lib proced.lib proced.obj+cproc.obj+oldcproc.obj+getsys.obj ;
COPY PROCED.LIB d:\clipper\DB\smic
DEL PROCED.*
CD\clipper\DB\smic
