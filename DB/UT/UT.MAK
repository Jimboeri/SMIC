ut.exe:         ut.obj\
                prgmenu.obj\
                dbfmenu1.obj\
                procfl.obj\
                mouse.obj\
                help.obj\
                procs.obj
                rtlink fi ut, __wait_b, prgmenu, dbfmenu1, procs, procfl, mouse, \clipper\db\bin\mousea, help, \clipper\db\bin\cproc, ctus lib ct
                
ut.obj:         ut.prg\
                prnmenu.prg\
                pr_ch.prg\
                prnupd.prg\
                net_test.prg
                clipper ut /b/w
                
prgmenu.obj:    prgmenu.prg\
                prgchk.prg\
                prgspec.prg\
                prgproc.prg
                clipper prgmenu /w/b

dbfmenu1.obj:   dbfmenu1.prg\
                ntx_proc.prg\
                dbfsel.prg\
                dbfedit.prg\
                dbfstru.prg\
                dbfprnt.prg\
                dbf_util.prg
                clipper dbfmenu1 /w/b

procfl.obj:     d:\clipper\db\common\procfl.prg
                clipper d:\clipper\db\common\procfl /n

mouse.obj:     d:\clipper\db\common\mouse.prg
                clipper d:\clipper\db\common\mouse /m

help.obj:       d:\clipper\db\common\help.prg
                clipper d:\clipper\db\common\help

procs.obj:      d:\clipper\db\common\procs.prg
                clipper d:\clipper\db\common\procs /n/w
                