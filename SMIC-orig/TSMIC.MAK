smic.exe: smic.obj \
          enqmenu.obj\
          prntmenu.obj\
          etadmin.obj\
          etrxmenu.obj\
          repmenu.obj\
          datamenu.obj\
          replds.obj\
          accmenu.obj\
          accsubmn.obj\
          stdmenu.obj\
          ldmenu.obj\
          medmenu.obj\
          advmenu.obj\
          twin.obj\
          stdpmenu.obj\
          crs1.obj\
          crs3.obj\
          proced.lib
          rtlink @smic >> smic.aaa

smic.obj: smic.prg\
          smic.ch\
          upgrade.prg\
          ldcom.prg\
          ldarclb.prg\
          stdnamlb.prg\
          ldarealb.prg\
          notes.prg
          clipper smic /w >> smic.aaa

enqmenu.obj: enqmenu.prg\
             ldlook.prg\
             stdlook.prg\
             accdisp.prg\
             shrlook.prg\
             accchang.prg\
             trnlook.prg\
             trndisp.prg\
             smiclab.prg
             clipper enqmenu /w >> smic.aaa

prntmenu.obj: prntmenu.prg\
              rleads.prg\
              repratio.prg\
              pfolldt.prg\
              rsales.prg\
              ldlab.prg\
              repstat.prg\
              ldprlab.prg
              clipper prntmenu /w >> smic.aaa

etadmin.obj:  etadmin.prg\
              sysparam.prg\
              pr_ch.prg\
              secmenu.prg\
              secedit.prg\
              secdelet.prg\
              secdisp.prg\
              secprnt.prg\
              futmenu.prg\
              futadd.prg\
              futedit.prg\
              futdisp.prg
              clipper etadmin /w >> smic.aaa

etrxmenu.obj: etrxmenu.prg\
              ldpack.prg\
              advpack.prg\
              stdpack.prg\
              accpack.prg\
              shrpack.prg\
              portpack.prg\
              futpack.prg\
              secpack.prg
              clipper etrxmenu /w >> smic.aaa

repmenu.obj:  repmenu.prg\
              repadd.prg\
              repedit.prg
              clipper repmenu /w >> smic.aaa

datamenu.obj: datamenu.prg\
              ldold.prg\
              trnold.prg\
              finmove.prg
              clipper datamenu /w >> smic.aaa
                            
replds.obj:   replds.prg\
              ldcom.prg\
              ldedit1.prg\
              lddisp.prg
              clipper replds /w >> smic.aaa

accmenu.obj: accmenu.prg\
             accdisp.prg\
             accrepbk.prg\
             acccomm.prg\
             accstd.prg\
             accbank.prg\
             accunpd.prg\
             accstat.prg\
             vatrpt.prg\
             debitacc.prg
             clipper accmenu /w >> smic.aaa
              
accsubmn.obj: accsubmn.prg\
             accchang.prg\
             accupbnk.prg\
             accdepos.prg\
             acctodeb.prg\
             accdebit.prg\
             accdebpr.prg\
             accref.prg
             clipper accsubmn /b/w >> smic.aaa

stdmenu.obj: stdmenu.prg\
             stdadd.prg\
             stdedit.prg\
             stdexpl.prg\
             stdsusp.prg\
             stdunpd.prg\
             stdreins.prg\
             stdcomnt.prg
             clipper stdmenu /w >> smic.aaa

ldmenu.obj: ldmenu.prg\
            ldadd.prg\
            ldedit.prg\
            lddelete.prg\
            lddisp.prg\
            ldrep.prg\
            ldremove.prg\
            numedit.prg
            clipper ldmenu /w >> smic.aaa

medmenu.obj: medmenu.prg\
             medstat.prg\
             medstat1.prg\
             medareas.prg\
             medanal.prg\
             medsales.prg\
             medlab.prg
             clipper medmenu /w >> smic.aaa
          
advmenu.obj: advmenu.prg\
             advadd.prg\
             advedit.prg\
             advdelet.prg\
             advdisp.prg\
             advncost.prg\
             advlist.prg\
             advchang.prg
             clipper advmenu /w >> smic.aaa

twin.obj: twin.prg\
          trnbuy.prg\
          trnpas.prg\
          trnsell.prg\
          trndisp.prg\
          othtrnmn.prg\
          bearsl.prg\
          bearbuy.prg\
          trnnplex.prg\
          ordedit.prg\
          trnedit.prg\
          prebuy.prg\
          presell.prg\
          futuremn.prg\
          futlong.prg\
          futshort.prg\
          futdisp.prg\
          stdmenu2.prg\
          stdedit1.prg\
          stdsusp1.prg\
          stdrein1.prg\
          stdcomn1.prg\
          accdisp1.prg\
          stdlect.prg\
          shrmenu.prg\
          shrlook.prg\
          shrdiv.prg\
          prcextr.prg
          clipper twin /w >> smic.aaa
             
stdpmenu.obj: stdpmenu.prg\
          stdareal.prg\
          stdnamlb.prg\
          stdunact.prg\
          focuslb.prg\
          stdactiv.prg\
          stdfin.prg\
          stdstaff.prg\
          merge.prg
          clipper stdpmenu /w >> smic.aaa
          
crs1.obj:   crs1.prg\
            shredit.prg\
            wkshrprn.prg\
            shrchang.prg\
            shrdelet.prg\
            shrsplit.prg\
            shrcons.prg\
            trnnpl.prg\
            shralloc.prg\
            shrhold.prg\
            trnstop.prg\
            trnshrab.prg\
            msg_disp.prg
            clipper crs1 /w >> smic.aaa
            
crs3.obj:   crs3.prg\
            stdclass.prg\
            stdcash.prg\
            stdweek.prg\
            stdreset.prg\
            stdcount.prg\
            stdstart.prg
            clipper crs3 /w >> smic.aaa
            
proced.lib:     c:\db\common\procfl.prg\
                c:\db\common\help.prg\
                c:\db\common\to_do.prg\
                c:\db\common\mouse.prg\
                c:\db\common\anylook.prg\
                c:\db\smic\proced\proced.prg\
                c:\db\smic\proced\findstd.prg\
                c:\db\smic\proced\smicproc.prg\
                c:\db\smic\proced\selfdest.prg\
                c:\db\smic\proced\security.prg
                prcomp
                  