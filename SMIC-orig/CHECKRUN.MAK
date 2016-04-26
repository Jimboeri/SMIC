checkrun.exe: checkrun.obj\
              CKR1.OBJ\
              proced.lib
              rtlink file checkrun, __wait_b, ckr1, ctus lib proced, ct

checkrun.obj: checkrun.prg\
              upgrade.prg\
              smic.ch\
              gm_upd.prg\
              hed_upd.prg\
              prcextr.prg\
              trnorder.prg\
              beardlv.prg\
              trnnplab.prg\
              futexp.prg\
              futauto.prg\
              futmarg.prg\
              stdrein2.prg
              clipper checkrun /w/b
              
CKR1.OBJ:     dividend.prg\
              ldunall.prg\
              reccheck.prg\
              interest.prg
              clipper @ckr1 /w/b
