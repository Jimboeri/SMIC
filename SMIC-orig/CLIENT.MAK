client.exe:     client.obj\
                prdmenu.obj\
                clntmenu.obj\
                cl_ac_mn.obj\
                proced.lib
                rtlink fi client, clntmenu, cl_ac_mn, prdmenu, ctus lib proced, ct
                                
client.obj:     client.prg\
                smic.ch\
                cntmenu.prg\
                cntadd.prg\
                cntedit.prg\
                cnt_move.prg\
                cntlist.prg\
                cntlist1.prg\
                cntdel.prg\
                findcnt.prg
                clipper client /b/w

clntmenu.obj:   clntmenu.prg\
                clntadd.prg
                clipper clntmenu /b/w

cl_ac_mn.obj:   cl_ac_mn.prg\
                clgendeb.prg
                clipper cl_ac_mn /b/w

prdmenu.obj:    prdmenu.prg\
                prdedit.prg
                clipper prdmenu /w/b
                                                
proced.lib: c:\db\common\procfl.prg\
                  c:\db\common\help.prg\
                  c:\db\common\to_do.prg\
                  c:\db\common\mouse.prg\
                  c:\db\smic\proced\proced.prg\
                  c:\db\smic\proced\findstd.prg\
                  c:\db\smic\proced\smicproc.prg\
                  c:\db\smic\proced\selfdest.prg\
                  c:\db\smic\proced\security.prg
                  prcomp

