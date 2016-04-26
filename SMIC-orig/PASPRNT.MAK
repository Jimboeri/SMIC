PASprnt.exe: PASPRNT.OBJ\
             proced.lib
             rtlink @pASprnt

pASprnt.obj: pASprnt.prg\
             smic.ch
             clipper pASprnt
