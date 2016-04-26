portprnt.exe: PORTPRNT.OBJ\
               proced.lib
               rtlink fi portprnt, __wait_b, ctus lib proced, ct

portprnt.obj: portprnt.prg\
              smic.ch\
              futprnt.prg
              clipper portprnt /b/w

