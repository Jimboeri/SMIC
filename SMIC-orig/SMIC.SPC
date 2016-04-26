08/05/95                      E.T.'s UTILITIES                      page 1
 
                  ALPHABETIC LIST OF PROCEDURES AND FUNCTIONS
 
      Program/procedure name  A10_VAL_PM  
        Source in             ACCCHANG.PRG
        Called from    ACCCHANG    
       
       
       
      Program/procedure name  A11_VAL_PM  
        Source in             ACCCHANG.PRG
        Called from    ACCCHANG    
       
       
       
      Program/procedure name  A12_PAY_HI  
        Source in             ACCCHANG.PRG
        Called from    ACCCHANG    
                       ACCDISP     
        Uses           INWAIT      
                       RESTSECTOR  
                       SAVESECTOR  
       
       
       
      Program/procedure name  A1_PMT_TYP  
        Source in             ACCDISP1.PRG
        Called from    A9_LOAD_AR  
                       P8_ARR_UDF  
       
       
       
      Program/procedure name  A2_PMT_DT   
        Source in             ACCDISP1.PRG
        Called from    P8_ARR_UDF  
       
       
       
      Program/procedure name  A3_AMOUNT   
        Source in             ACCDISP1.PRG
        Called from    A9_LOAD_AR  
       
       
       
08/05/95                      E.T.'s UTILITIES                      page 2
 
                  ALPHABETIC LIST OF PROCEDURES AND FUNCTIONS
 
      Program/procedure name  A4_COMMENT  
        Source in             ACCDISP1.PRG
        Called from    A9_LOAD_AR  
                       P8_ARR_UDF  
       
       
       
      Program/procedure name  A6_D_RECNO  
        Source in             ACCCHANG.PRG
        Called from    ACCCHANG    
       
       
       
      Program/procedure name  A7_C_RECNO  
        Source in             ACCDISP1.PRG
        Called from    A9_LOAD_AR  
                       ACCCHANG    
                       P8_ARR_UDF  
       
       
       
      Program/procedure name  A8_ARR_UDF  
        Source in             ACCDISP.PRG 
        Called from    ACCDISP     
                       ACCDISP1    
       
       
       
      Program/procedure name  A9_LOAD_AR  
        Source in             ACCCHANG.PRG
        Called from    ACCCHANG    
                       ACCDISP     
                       ACCDISP1    
        Uses           A1_PMT_TYP  
                       A3_AMOUNT   
                       A4_COMMENT  
                       A7_C_RECNO  
       
       
       
      Program/procedure name  ACCBANK     
        Source in             ACCBANK.PRG 
        Called from    ACCMENU     
        Uses           ET_CLOSE    
                       ET_USE_DBF  
                       OPENPRN     
                       PRNTITLE    
                       PR_LINE     
                       RECLOCK     
                       SHUTPRN     
                       WMAKE_SURE  
08/05/95                      E.T.'s UTILITIES                      page 3
 
                  ALPHABETIC LIST OF PROCEDURES AND FUNCTIONS
 
      Program/procedure name  ACCBANK     
       
       
       
      Program/procedure name  ACCCHANG    
        Source in             ACCCHANG.PRG
        Called from    ACCSUBMN    
        Uses           A10_VAL_PM  
                       A11_VAL_PM  
                       A12_PAY_HI  
                       A6_D_RECNO  
                       A7_C_RECNO  
                       A9_LOAD_AR  
                       DISP_MSG    
                       DRAW_BOX    
                       ET_ADDMONT  
                       GET_ARR     
                       GET_CHEQUE  
                       GET_CREDIT  
                       INWAIT      
                       MAKE_SURE   
                       NET_USE     
                       P8_ARR_UDF  
                       RECLOCK     
                       RESTSECTOR  
       
       
       
      Program/procedure name  ACCCOMM     
        Source in             ACCCOMM.PRG 
        Called from    ACCMENU     
        Uses           ET_ADDMONT  
                       ET_CLOSE    
                       ET_USE_DBF  
                       OPENPRN     
                       PRNTITLE    
                       PR_LINE     
                       RECLOCK     
                       SHUTPRN     
                       WMAKE_SURE  
       
       
       
08/05/95                      E.T.'s UTILITIES                      page 4
 
                  ALPHABETIC LIST OF PROCEDURES AND FUNCTIONS
 
      Program/procedure name  ACCDEBIT    
        Source in             ACCDEBIT.PRG
        Called from    ACCSUBMN    
        Uses           DISP_MSG    
                       DOS_WRITE   
                       MAKE_SURE   
                       NET_USE     
                       OPENPRN     
                       PRNTITLE    
                       PR_LINE     
                       RECLOCK     
                       RESTSECTOR  
                       SHUTPRN     
       
       
       
      Program/procedure name  ACCDEBPR    
        Source in             ACCDEBPR.PRG
        Called from    ACCSUBMN    
        Uses           MAKE_SURE   
                       NET_USE     
                       OPENPRN     
                       PRNTITLE    
                       SHUTPRN     
       
       
       
      Program/procedure name  ACCDEPOS    
        Source in             ACCDEPOS.PRG
        Called from    ACCSUBMN    
        Uses           NET_USE     
                       OPENPRN     
                       PRNTITLE    
                       RECLOCK     
                       SHUTPRN     
       
       
       
      Program/procedure name  ACCDISP     
        Description :                                       
        Source in             ACCDISP.PRG 
        Called from    ACCMENU     
                       ENQMENU     
        Uses           A12_PAY_HI  
                       A8_ARR_UDF  
                       A9_LOAD_AR  
                       GET_ARR     
                       NET_USE     
       
        This program is used to see how and when a student is paying. The    
        column of the left is how he agreed to pay and the column onthe right
08/05/95                      E.T.'s UTILITIES                      page 5
 
                  ALPHABETIC LIST OF PROCEDURES AND FUNCTIONS
 
      Program/procedure name  ACCDISP     
        is any payments we have received.                                    
        Payment types                                                        
          C - Credit card                                                    
          Q - cheQue                                                         
          D - Debit order                                                    
          O - Other (cash)                                                   
       
       
      Program/procedure name  ACCDISP1    
        Source in             ACCDISP1.PRG
        Called from    STDMENU2    
        Uses           A8_ARR_UDF  
                       A9_LOAD_AR  
                       ET_CLOSE    
                       NET_USE     
       
       
       
      Program/procedure name  ACCJIM      
        Source in             ACCJIM.PRG  
        Uses           ET_ADDMONT  
                       NET_USE     
                       OPENPRN     
                       PRNTITLE    
                       RECLOCK     
                       SHUTPRN     
       
       
       
      Program/procedure name  ACCMENU     
        Source in             ACCMENU.PRG 
        Called from    SMIC        
        Uses           ACCBANK     
                       ACCCOMM     
                       ACCDISP     
                       ACCREPBK    
                       ACCSTAT     
                       ACCSTD      
                       ACCUNPD     
                       DEBITACC    
                       GET_ARR     
                       VATRPT      
       
       
       
08/05/95                      E.T.'s UTILITIES                      page 6
 
                  ALPHABETIC LIST OF PROCEDURES AND FUNCTIONS
 
      Program/procedure name  ACCREF      
        Source in             ACCREF.PRG  
        Called from    ACCSUBMN    
        Uses           NET_USE     
       
       
       
      Program/procedure name  ACCREPBK    
        Source in             ACCREPBK.PRG
        Called from    ACCMENU     
        Uses           DISP_MSG    
                       ET_USE_DBF  
                       GET_ARR     
                       OPENPRN     
                       PRNTITLE    
                       PR_LINE     
                       SHUTPRN     
       
       
       
      Program/procedure name  ACCREPCM    
        Source in             ACCREPCM.PRG
        Uses           NET_USE     
                       OPENPRN     
                       PRNTITLE    
                       SHUTPRN     
       
       
       
      Program/procedure name  ACCSTAT     
        Source in             ACCSTAT.PRG 
        Called from    ACCMENU     
        Uses           ET_ADDMONT  
                       NET_USE     
                       WMAKE_SURE  
       
       
       
      Program/procedure name  ACCSTD      
        Source in             ACCSTD.PRG  
        Called from    ACCMENU     
        Uses           DISP_MSG    
                       NET_USE     
                       RESTSECTOR  
                       WMAKE_SURE  
       
       
       
08/05/95                      E.T.'s UTILITIES                      page 7
 
                  ALPHABETIC LIST OF PROCEDURES AND FUNCTIONS
 
      Program/procedure name  ACCSUBMN    
        Source in             ACCSUBMN.PRG
        Called from    SMIC        
        Uses           ACCCHANG    
                       ACCDEBIT    
                       ACCDEBPR    
                       ACCDEPOS    
                       ACCREF      
                       ACCTODEB    
                       ACCUPBNK    
                       DRAW_BOX    
                       GET_ARR     
       
       
       
      Program/procedure name  ACCTODEB    
        Source in             ACCTODEB.PRG
        Called from    ACCSUBMN    
       
       
       
      Program/procedure name  ACCUNPD     
        Source in             ACCUNPD.PRG 
        Called from    ACCMENU     
        Uses           GET_ARR     
                       NET_USE     
                       OPENPRN     
                       PRNTITLE    
                       PR_LINE     
                       SHUTPRN     
                       WMAKE_SURE  
       
       
       
      Program/procedure name  ACCUPBNK    
        Source in             ACCUPBNK.PRG
        Called from    ACCSUBMN    
        Uses           NET_USE     
                       RECLOCK     
                       WMAKE_SURE  
       
       
       
08/05/95                      E.T.'s UTILITIES                      page 8
 
                  ALPHABETIC LIST OF PROCEDURES AND FUNCTIONS
 
      Program/procedure name  ADVADD      
        Description :                                       
        Source in             ADVADD.PRG  
        Called from    ADVMENU     
        Uses           NET_USE     
                       RECLOCK     
       
        This program is used to enter new adverts.                           
        This is necessary as all leads are attached to an advert so we can   
        see what is working for us.                                          
                                                                             
        Please do not enter any adverts without first checking with the      
        National Sales Manager or the M.D.                                   
       
       
      Program/procedure name  ADVCHANG    
        Source in             ADVCHANG.PRG
        Called from    ADVMENU     
        Uses           NET_USE     
                       RECLOCK     
       
       
       
      Program/procedure name  ADVDELET    
        Source in             ADVDELET.PRG
        Called from    ADVMENU     
        Uses           DISP_MSG    
                       MAKE_SURE   
                       NET_USE     
                       RECLOCK     
       
       
       
      Program/procedure name  ADVDISP     
        Source in             ADVDISP.PRG 
        Called from    ADVMENU     
        Uses           DISP_MSG    
                       ET_CLOSE    
                       NET_USE     
       
       
       
08/05/95                      E.T.'s UTILITIES                      page 9
 
                  ALPHABETIC LIST OF PROCEDURES AND FUNCTIONS
 
      Program/procedure name  ADVEDIT     
        Description :                                       
        Source in             ADVEDIT.PRG 
        Called from    ADVMENU     
        Uses           ET_CLOSE    
                       NET_USE     
       
        This program is used to change details of an advert such as the cost 
        of it, what kind of an advert it is and a description of the advert. 
       
       
      Program/procedure name  ADVLIST     
        Source in             ADVLIST.PRG 
        Called from    ADVMENU     
        Uses           MAKE_SURE   
                       NET_USE     
                       OPENPRN     
                       PRNTITLE    
                       SHUTPRN     
       
       
       
      Program/procedure name  ADVMENU     
        Source in             ADVMENU.PRG 
        Called from    MIA         
                       SMIC        
        Uses           ADVADD      
                       ADVCHANG    
                       ADVDELET    
                       ADVDISP     
                       ADVEDIT     
                       ADVLIST     
                       ADVNCOST    
                       GET_ARR     
       
       
       
      Program/procedure name  ADVNCOST    
        Source in             ADVNCOST.PRG
        Called from    ADVMENU     
        Uses           MAKE_SURE   
                       NET_USE     
                       OPENPRN     
                       PRNTITLE    
                       PR_LINE     
                       SHUTPRN     
       
       
       
08/05/95                      E.T.'s UTILITIES                      page 10
 
                  ALPHABETIC LIST OF PROCEDURES AND FUNCTIONS
 
      Program/procedure name  ANYSEEK     
        Source in                         
        Called from    FINDCNT     
                       ORDEDIT     
                       PRE_SRC_CD  
                       PRE_SRC_DT  
       
       
       
      Program/procedure name  AREMOVE     
        Source in                         
        Called from    FUTADD      
                       PORTPRNT    
                       UPGRADE     
       
       
       
      Program/procedure name  BACKDISP    
        Source in             TWIN.PRG    
        Called from    TWIN        
       
       
       
      Program/procedure name  BEARBUY     
        Source in             BEARBUY.PRG 
        Called from    OTHTRNMN    
                       TRNSUBMN    
        Uses           DISP_MSG    
                       RECLOCK     
                       RESTSECTOR  
                       SAVESECTOR  
                       WAIT_MSG    
       
       
       
      Program/procedure name  BEARDLV     
        Source in             BEARDLV.PRG 
        Called from    CHECKRUN    
        Uses           ET_CLOSE    
                       NET_USE     
                       RECLOCK     
       
       
       
08/05/95                      E.T.'s UTILITIES                      page 11
 
                  ALPHABETIC LIST OF PROCEDURES AND FUNCTIONS
 
      Program/procedure name  BEARSL      
        Source in             BEARSL.PRG  
        Called from    OTHTRNMN    
                       TRNSUBMN    
        Uses           DISP_MSG    
                       RECLOCK     
                       RESTSECTOR  
                       SAVESECTOR  
                       WAIT_MSG    
       
       
       
      Program/procedure name  BELDIV      
        Source in             BELDIV.PRG  
        Uses           BELWRITE    
                       ENDDO       
                       NET_USE     
                       RECLOCK     
       
       
       
      Program/procedure name  BELWRITE    
        Source in                         
        Called from    BELDIV      
       
       
       
      Program/procedure name  BRADD       
        Source in             PORDERS.PRG 
        Called from    PORDERS     
       
       
       
      Program/procedure name  BRCOUNT     
        Source in             PLEADS.PRG  
        Called from    PLEADS      
       
       
       
      Program/procedure name  BUY_ORDER   
        Source in             TRNBUY.PRG  
        Called from    TRNBUY      
        Uses           RECLOCK     
       
       
       
08/05/95                      E.T.'s UTILITIES                      page 12
 
                  ALPHABETIC LIST OF PROCEDURES AND FUNCTIONS
 
      Program/procedure name  CHECKRUN    
        Source in             CHECKRUN.PRG
        Uses           BEARDLV     
                       DIVIDEND    
                       FILECOPY    
                       FUTAUTO     
                       FUTEXP      
                       FUTMARG     
                       GM_UPD      
                       HED_UPD     
                       INTEREST    
                       LDUNALL     
                       NET_USE     
                       PRCEXTR     
                       RECCHECK    
                       STDREIN2    
                       TRNNPLAB    
                       TRNORDER    
                       UPGRADE     
                       XFGEN       
       
       
       
      Program/procedure name  CHEQUE_OTH  
        Source in             STDADD.PRG  
        Called from    STDADD      
        Uses           DISP_MSG    
                       GET_CHEQUE  
                       RECLOCK     
                       WMAKE_SURE  
       
       
       
      Program/procedure name  CLIENT      
        Source in             CLIENT.PRG  
        Uses           CNTMENU     
                       MGET_ARR    
       
       
       
      Program/procedure name  CLOSEPRN    
        Source in                         
        Called from    STDACTIV    
                       STDAREAL    
                       STDLIST     
                       STDTEMP     
       
       
       
08/05/95                      E.T.'s UTILITIES                      page 13
 
                  ALPHABETIC LIST OF PROCEDURES AND FUNCTIONS
 
      Program/procedure name  CNTADD      
        Source in             CNTADD.PRG  
        Called from    CNTMENU     
        Uses           DISP_MSG    
                       ET_CLOSE    
                       JW_VAL_YN   
                       MAKE_SURE   
                       MGET_ARR    
                       NET_USE     
                       RECLOCK     
                       SAVESECTOR  
                       VAL_BIRTH_  
       
       
       
      Program/procedure name  CNTEDIT     
        Source in             CNTEDIT.PRG 
        Called from    CNTMENU     
        Uses           CNTEDIT1    
                       CNTEDIT2    
                       CNTEDIT3    
                       FINDCNT     
                       MGET_ARR    
                       NET_USE     
                       RECLOCK     
       
       
       
      Program/procedure name  CNTEDIT1    
        Source in             CNTEDIT.PRG 
        Called from    CNTEDIT     
       
       
       
      Program/procedure name  CNTEDIT2    
        Source in             CNTEDIT.PRG 
        Called from    CNTEDIT     
        Uses           JW_VAL_YN   
       
       
       
08/05/95                      E.T.'s UTILITIES                      page 14
 
                  ALPHABETIC LIST OF PROCEDURES AND FUNCTIONS
 
      Program/procedure name  CNTEDIT3    
        Source in             CNTEDIT.PRG 
        Called from    CNTEDIT     
       
       
       
      Program/procedure name  CNTLIST     
        Source in             CNTLIST.PRG 
        Called from    CNTMENU     
        Uses           NET_USE     
                       OPENPRN     
                       PRNTITLE    
                       SHUTPRN     
       
       
       
      Program/procedure name  CNTLIST1    
        Source in             CNTLIST1.PRG
        Called from    CNTMENU     
        Uses           NET_USE     
                       OPENPRN     
                       PRNTITLE    
                       SHUTPRN     
       
       
       
      Program/procedure name  CNTMENU     
        Source in             CNTMENU.PRG 
        Called from    CLIENT      
        Uses           CNTADD      
                       CNTEDIT     
                       CNTLIST     
                       CNTLIST1    
                       CNTPRNT     
                       GET_ARR     
       
       
       
      Program/procedure name  CNTPRNT     
        Source in             CNTPRNT.PRG 
        Called from    CNTMENU     
        Uses           NET_USE     
       
       
       
08/05/95                      E.T.'s UTILITIES                      page 15
 
                  ALPHABETIC LIST OF PROCEDURES AND FUNCTIONS
 
      Program/procedure name  CNT_MOVE    
        Source in             CNT_MOVE.PRG
        Uses           NET_USE     
       
       
       
      Program/procedure name  CRS1        
        Description :                                       
        Source in             CRS1.PRG    
        Called from    CRSMAN      
                       SMIC        
        Uses           GET_ARR     
                       MSG_DISP    
                       SHRALLOC    
                       SHRCONS     
                       SHRDELET    
                       SHREDIT     
                       SHRHOLD     
                       SHRMAN      
                       SHRSPLIT    
                       TRNNPL      
                       TRNSHRAB    
                       TRNSTOP     
                       WKSHRPRN    
       
        This menu is used to maintain the share database. If what you want is
        not on this menu it is probably on the 'Transaction' menu.           
                                                                             
       
       
      Program/procedure name  CRS2        
        Description :                                       
        Source in                         
        Called from    CRSMAN      
       
        This menu is used to maintain student portfolios and change some     
        student information.                                                 
                                                                             
        If what you want is not on this screen, it is probably on the 'Share'
        menu.                                                                
       
       
08/05/95                      E.T.'s UTILITIES                      page 16
 
                  ALPHABETIC LIST OF PROCEDURES AND FUNCTIONS
 
      Program/procedure name  CRS3        
        Source in             CRS3.PRG    
        Called from    CRSMAN      
                       SMIC        
        Uses           GET_ARR     
                       STDCASH     
                       STDCLASS    
                       STDCOUNT    
                       STDRESET    
                       STDSTART    
                       STDWEEK     
       
       
       
      Program/procedure name  CRSMAN      
        Description :                                       
        Source in             CRSMAN.PRG  
        Uses           CRS1        
                       CRS2        
                       CRS3        
                       INWAIT      
                       MOUSENEW    
                       M_GOTO      
                       M_INIT      
                       TO_DO       
       
        This program is for use by the course manager and assistants. With   
        this program the student, their portfolios and the shares databases  
        can be maintained. Just check all the options and you will probably  
        be able to do what you want to.                                      
                                                                             
       
       
      Program/procedure name  DATAMENU    
        Source in             DATAMENU.PRG
        Called from    ETADMIN     
        Uses           FINMOVE     
                       GET_ARR     
                       LDOLD       
                       TRNOLD      
       
       
       
08/05/95                      E.T.'s UTILITIES                      page 17
 
                  ALPHABETIC LIST OF PROCEDURES AND FUNCTIONS
 
      Program/procedure name  DATAVIEW    
        Source in             DATAVIEW.PRG
        Uses           DISP_MSG    
                       DRAW_BOX    
                       DTA_DATE    
                       DTA_HIGH    
                       DTA_LOW     
                       DTA_PRICE   
                       DTA_SHARE   
                       DTA_VOLUME  
                       HELP        
                       RESTSECTOR  
                       SKIP_ANY    
                       STABILIZE   
       
       
       
      Program/procedure name  DBCREATEIN  
        Source in                         
        Called from    RE_INDEX    
                       TO_DO       
       
       
       
      Program/procedure name  DB_ERROR    
        Source in             ERRORSYS.PRG
       
       
       
      Program/procedure name  DEBITACC    
        Source in             DEBITACC.PRG
        Called from    ACCMENU     
        Uses           ET_CLOSE    
                       MAKE_SURE   
                       NET_USE     
                       OPENPRN     
                       PRNTITLE    
                       PR_LINE     
                       SHUTPRN     
       
       
       
08/05/95                      E.T.'s UTILITIES                      page 18
 
                  ALPHABETIC LIST OF PROCEDURES AND FUNCTIONS
 
      Program/procedure name  DEBIT_ORDE  
        Source in             STDADD.PRG  
        Called from    STDADD      
        Uses           ENDDAY      
                       ET_ADDMONT  
                       GET_ARR     
                       MAKE_SURE   
                       RECLOCK     
                       WMAKE_SURE  
       
       
       
      Program/procedure name  DISP_MSG    
        Source in                         
        Called from    ACCCHANG    
                       ACCDEBIT    
                       ACCREPBK    
                       ACCSTD      
                       ADVDELET    
                       ADVDISP     
                       BEARBUY     
                       BEARSL      
                       CHEQUE_OTH  
                       CNTADD      
                       DATAVIEW    
                       DIVIDEND    
                       DOS_WRITE   
                       FUTSHORT    
                       LDADD       
                       LDAD_V04    
                       LDAD_V06    
                       LDAD_V07    
                       LDAD_V08    
                       LDAD_V10    
                       LDAD_V11    
                       LDEDIT      
                       LDEDITA     
                       LDEDITB     
                       LDOLD       
                       MEDANAL     
                       MEDRDIG     
                       NOTES       
                       NOT_EXCEP   
                       PR_CH       
                       RE_INDEX    
                       SECADD      
                       SECDELET    
                       SECEDIT     
                       STDADD      
                       STDCASH     
                       STDEDIT1    
08/05/95                      E.T.'s UTILITIES                      page 19
 
                  ALPHABETIC LIST OF PROCEDURES AND FUNCTIONS
 
      Program/procedure name  DISP_MSG    
                       STDEXPL     
                       STDREIN2    
                       STDREINS    
                       STDSTART    
                       STDSUSP     
                       STDUNPD     
                       TO_DO       
                       TRNBUY      
                       TRNNPLEX    
                       TWNDISP     
                       VAL_ARC_NO  
                       VAL_BIRTH_  
                       VAL_LD_DT_  
                       VAL_LD_P_C  
                       VAL_LD_RAC  
                       VAL_LD_SEL  
                       VAL_LD_SEX  
                       VAL_LD_SRC  
                       VAL_LD_SUR  
                       VAL_STDLEC  
                       VATADD      
       
       
       
      Program/procedure name  DIVIDEND    
        Source in             DIVIDEND.PRG
        Called from    CHECKRUN    
        Uses           DISP_MSG    
                       ET_CLOSE    
                       IND_PROG    
                       NET_USE     
                       RECLOCK     
       
       
       
      Program/procedure name  DIV_VAL_DT  
        Source in             SHRDIV.PRG  
        Called from    SHRDIV      
       
       
       
08/05/95                      E.T.'s UTILITIES                      page 20
 
                  ALPHABETIC LIST OF PROCEDURES AND FUNCTIONS
 
      Program/procedure name  DIV_VAL_TY  
        Source in             SHRDIV.PRG  
        Called from    SHRDIV      
       
       
       
      Program/procedure name  DOS_WRITE   
        Source in             ACCDEBIT.PRG
        Called from    ACCDEBIT    
        Uses           DISP_MSG    
                       RESTSECTOR  
       
       
       
      Program/procedure name  DRAW_BOX    
        Source in                         
        Called from    ACCCHANG    
                       ACCSUBMN    
                       DATAVIEW    
                       EDIT_TODO   
                       FINPRNT     
                       FOCUSLB     
                       FUTLONG     
                       FUTSHORT    
                       GET_CHEQUE  
                       GET_CREDIT  
                       MAIL_READ   
                       MAIL_SEND   
                       NOTES       
                       NOTPROG     
                       NOT_EXCEP   
                       ORDEDIT     
                       SET_BAR     
                       STDACTIV    
                       STDAREAL    
                       STDFIN      
                       STDLECT     
                       STDLIST     
                       STDNAMLB    
                       STDSUSP1    
                       STDUNACT    
                       TO_DO       
                       TO_DO_PRIN  
                       TRNSTOP     
                       TWIN        
       
       
       
08/05/95                      E.T.'s UTILITIES                      page 21
 
                  ALPHABETIC LIST OF PROCEDURES AND FUNCTIONS
 
      Program/procedure name  DTA_DATE    
        Source in             DATAVIEW.PRG
        Called from    DATAVIEW    
       
       
       
      Program/procedure name  DTA_HIGH    
        Source in             DATAVIEW.PRG
        Called from    DATAVIEW    
       
       
       
      Program/procedure name  DTA_LOW     
        Source in             DATAVIEW.PRG
        Called from    DATAVIEW    
       
       
       
      Program/procedure name  DTA_PRICE   
        Source in             DATAVIEW.PRG
        Called from    DATAVIEW    
       
       
       
      Program/procedure name  DTA_SHARE   
        Source in             DATAVIEW.PRG
        Called from    DATAVIEW    
        Uses           RECLOCK     
       
       
       
      Program/procedure name  DTA_VOLUME  
        Source in             DATAVIEW.PRG
        Called from    DATAVIEW    
       
       
       
      Program/procedure name  DUP         
        Source in             DUP.PRG     
        Uses           MAKE_SURE   
                       NET_USE     
                       RECLOCK     
       
       
       
08/05/95                      E.T.'s UTILITIES                      page 22
 
                  ALPHABETIC LIST OF PROCEDURES AND FUNCTIONS
 
      Program/procedure name  EDIT_TODO   
        Source in             TO_DO.PRG   
        Called from    TO_DO       
        Uses           DRAW_BOX    
                       RECLOCK     
                       RESTSECTOR  
       
       
       
      Program/procedure name  ENDDAY      
        Source in                         
        Called from    DEBIT_ORDE  
       
       
       
      Program/procedure name  ENDDO       
        Source in                         
        Called from    BELDIV      
       
       
       
      Program/procedure name  ENQMENU     
        Source in             ENQMENU.PRG 
        Called from    SMIC        
        Uses           ACCDISP     
                       ET_CLOSE    
                       GET_ARR     
                       LDDISP      
                       LDLOOK      
                       NET_USE     
                       SHRLOOK     
                       SMICLAB     
                       STDLOOK     
                       TRNLOOK     
       
       
       
      Program/procedure name  EOY         
        Source in                         
        Called from    PORTPRNT    
       
       
       
08/05/95                      E.T.'s UTILITIES                      page 23
 
                  ALPHABETIC LIST OF PROCEDURES AND FUNCTIONS
 
      Program/procedure name  ERRORSYS    
        Source in             ERRORSYS.PRG
       
       
       
      Program/procedure name  ETADMIN     
        Source in             ETADMIN.PRG 
        Called from    SMIC        
        Uses           DATAMENU    
                       FUTMENU     
                       GET_ARR     
                       MAKE_SURE   
                       NET_USE     
                       REPMENU     
                       RE_INDEX    
                       SECMENU     
                       SYSPARAM    
       
       
       
      Program/procedure name  ET_ADDMONT  
        Source in                         
        Called from    ACCCHANG    
                       ACCCOMM     
                       ACCJIM      
                       ACCSTAT     
                       DEBIT_ORDE  
                       FUTAUTO     
                       FUTMAN      
       
       
       
      Program/procedure name  ET_CLOSE    
        Source in                         
        Called from    ACCBANK     
                       ACCCOMM     
                       ACCDISP1    
                       ADVDISP     
                       ADVEDIT     
                       BEARDLV     
                       CNTADD      
                       DEBITACC    
                       DIVIDEND    
                       ENQMENU     
                       FUTAUTO     
                       FUTDISP     
                       FUTEXP      
                       FUTLONG     
                       FUTMARG     
                       FUTSHORT    
                       GM_UPD      
08/05/95                      E.T.'s UTILITIES                      page 24
 
                  ALPHABETIC LIST OF PROCEDURES AND FUNCTIONS
 
      Program/procedure name  ET_CLOSE    
                       HED_UPD     
                       INTEREST    
                       LDMENU      
                       LDUNALL     
                       MEDSALES    
                       PRCEXTR     
                       RECCHECK    
                       REPADD      
                       REPEDIT     
                       SHRALLOC    
                       SHRCHANG    
                       SMICLAB     
                       STDEDIT1    
                       STDREIN2    
                       STDUNACT    
                       TRNNPLAB    
                       TRNORDER    
                       TRNSTOP     
                       UPGRADE     
                       VATRPT      
                       WKSHRPRN    
       
       
       
      Program/procedure name  ET_SEEK     
        Source in                         
        Called from    PR_CH       
                       REPEDIT     
       
       
       
      Program/procedure name  ET_USE_DBF  
        Source in                         
        Called from    ACCBANK     
                       ACCCOMM     
                       ACCREPBK    
                       HED_UPD     
                       WKSHRPRN    
       
       
       
08/05/95                      E.T.'s UTILITIES                      page 25
 
                  ALPHABETIC LIST OF PROCEDURES AND FUNCTIONS
 
      Program/procedure name  EXPR_ERROR  
        Source in             ERRORSYS.PRG
       
       
       
      Program/procedure name  FIELDNAME   
        Source in                         
        Called from    LDOLD       
       
       
       
      Program/procedure name  FILECOPY    
        Source in                         
        Called from    CHECKRUN    
       
       
       
      Program/procedure name  FINDCNT     
        Source in             FINDCNT.PRG 
        Called from    CNTEDIT     
        Uses           ANYSEEK     
       
       
       
      Program/procedure name  FINMOVE     
        Source in             FINMOVE.PRG 
        Called from    DATAMENU    
        Uses           JW_EJECT    
                       NET_USE     
                       RECLOCK     
                       SHUTPRN     
                       WMAKE_SURE  
       
       
       
      Program/procedure name  FINPRNT     
        Source in             FINPRNT.PRG 
        Uses           DRAW_BOX    
                       MAKE_SURE   
                       NET_USE     
                       OPENPRN     
                       PRNTITLE    
                       SHUTPRN     
       
       
       
08/05/95                      E.T.'s UTILITIES                      page 26
 
                  ALPHABETIC LIST OF PROCEDURES AND FUNCTIONS
 
      Program/procedure name  FOCUSLB     
        Source in             FOCUSLB.PRG 
        Uses           DRAW_BOX    
                       MAKE_SURE   
       
       
       
      Program/procedure name  FUTADD      
        Source in             FUTADD.PRG  
        Called from    FUTMENU     
        Uses           AREMOVE     
                       GET_ARR     
                       NET_USE     
                       RECLOCK     
                       VAL_CALC_T  
                       VAL_FUT_DT  
                       VAL_FUT_NM  
                       VAL_MARGIN  
                       VAL_PERC_V  
       
       
       
      Program/procedure name  FUTAUTO     
        Source in             FUTAUTO.PRG 
        Called from    CHECKRUN    
        Uses           ET_ADDMONT  
                       ET_CLOSE    
                       NET_USE     
                       RECLOCK     
       
       
       
      Program/procedure name  FUTDELET    
        Source in             FUTDELET.PRG
        Called from    FUTMENU     
        Uses           NET_USE     
                       WMAKE_SURE  
       
       
       
      Program/procedure name  FUTDISP     
        Source in             FUTDISP.PRG 
        Called from    FUTUREMN    
                       TRNSUBMN    
        Uses           ET_CLOSE    
                       NET_USE     
                       WAIT_MSG    
       
       
       
08/05/95                      E.T.'s UTILITIES                      page 27
 
                  ALPHABETIC LIST OF PROCEDURES AND FUNCTIONS
 
      Program/procedure name  FUTEDIT     
        Source in             FUTEDIT.PRG 
        Called from    FUTMENU     
        Uses           NET_USE     
                       VAL_CALC_T  
                       VAL_MARGIN  
       
       
       
      Program/procedure name  FUTEXP      
        Source in             FUTEXP.PRG  
        Called from    CHECKRUN    
                       FUTMAN      
        Uses           ET_CLOSE    
                       NET_USE     
                       RECLOCK     
       
       
       
      Program/procedure name  FUTLONG     
        Source in             FUTLONG.PRG 
        Called from    FUTUREMN    
                       TRNSUBMN    
        Uses           DRAW_BOX    
                       ET_CLOSE    
                       MAKE_SURE   
                       NET_USE     
                       RECLOCK     
                       WAIT_MSG    
       
       
       
      Program/procedure name  FUTMAN      
        Source in             FUTMAN.PRG  
        Uses           ET_ADDMONT  
                       FUTEXP      
                       FUTMARG     
                       MAKE_SURE   
                       NET_USE     
                       RECLOCK     
       
       
       
08/05/95                      E.T.'s UTILITIES                      page 28
 
                  ALPHABETIC LIST OF PROCEDURES AND FUNCTIONS
 
      Program/procedure name  FUTMARG     
        Source in             FUTMARG.PRG 
        Called from    CHECKRUN    
                       FUTMAN      
        Uses           ET_CLOSE    
                       NET_USE     
                       RECLOCK     
       
       
       
      Program/procedure name  FUTMENU     
        Source in             FUTMENU.PRG 
        Called from    ETADMIN     
        Uses           FUTADD      
                       FUTDELET    
                       FUTEDIT     
                       GET_ARR     
       
       
       
      Program/procedure name  FUTPRNT     
        Source in             FUTPRNT.PRG 
        Called from    PORTPRNT    
                       WKLYMENU    
        Uses           JW_EJECT    
                       NET_USE     
                       PRNTITLE    
       
       
       
      Program/procedure name  FUTSHORT    
        Source in             FUTSHORT.PRG
        Called from    FUTUREMN    
                       TRNSUBMN    
        Uses           DISP_MSG    
                       DRAW_BOX    
                       ET_CLOSE    
                       MAKE_SURE   
                       NET_USE     
                       RECLOCK     
                       WAIT_MSG    
       
       
       
08/05/95                      E.T.'s UTILITIES                      page 29
 
                  ALPHABETIC LIST OF PROCEDURES AND FUNCTIONS
 
      Program/procedure name  FUTUREMN    
        Source in             FUTUREMN.PRG
        Called from    TWIN        
        Uses           FUTDISP     
                       FUTLONG     
                       FUTSHORT    
                       GET_ARR     
       
       
       
      Program/procedure name  GET_ARR     
        Source in                         
        Called from    ACCCHANG    
                       ACCDISP     
                       ACCMENU     
                       ACCREPBK    
                       ACCSUBMN    
                       ACCUNPD     
                       ADVMENU     
                       CNTMENU     
                       CRS1        
                       CRS3        
                       DATAMENU    
                       DEBIT_ORDE  
                       ENQMENU     
                       ETADMIN     
                       FUTADD      
                       FUTMENU     
                       FUTUREMN    
                       LDMENU      
                       MEDMENU     
                       OTHTRNMN    
                       PRM_DO_EDI  
                       PRNTMENU    
                       REPMENU     
                       SECMENU     
                       SHRMENU     
                       SMIC        
                       SMICLAB     
                       STDACTIV    
                       STDADD      
                       STDAREAL    
                       STDLIST     
                       STDMENU     
                       STDMENU2    
                       STDPMENU    
                       TO_DO_PRIN  
                       TRNBUY      
                       TRNPAS      
                       TRNSELL     
                       WKSHRPRN    
08/05/95                      E.T.'s UTILITIES                      page 30
 
                  ALPHABETIC LIST OF PROCEDURES AND FUNCTIONS
 
      Program/procedure name  GET_ARR     
       
       
       
      Program/procedure name  GET_CHEQUE  
        Source in             ACCCHANG.PRG
        Called from    ACCCHANG    
                       CHEQUE_OTH  
        Uses           DRAW_BOX    
                       RECLOCK     
                       RESTSECTOR  
       
       
       
      Program/procedure name  GET_CREDIT  
        Source in             ACCCHANG.PRG
        Called from    ACCCHANG    
                       STDADD      
        Uses           DRAW_BOX    
                       RECLOCK     
                       RESTSECTOR  
       
       
       
      Program/procedure name  GM_UPD      
        Source in             GM_UPD.PRG  
        Called from    CHECKRUN    
        Uses           ET_CLOSE    
                       IND_PROG    
                       NET_USE     
                       RECLOCK     
       
       
       
      Program/procedure name  HED_TEST    
        Source in             HED_TEST.PRG
        Uses           HED_UPD     
                       UPGRADE     
       
       
       
08/05/95                      E.T.'s UTILITIES                      page 31
 
                  ALPHABETIC LIST OF PROCEDURES AND FUNCTIONS
 
      Program/procedure name  HED_UPD     
        Source in             HED_UPD.PRG 
        Called from    CHECKRUN    
                       HED_TEST    
        Uses           ET_CLOSE    
                       ET_USE_DBF  
                       RECLOCK     
                       STR_COM     
       
       
       
      Program/procedure name  HELP        
        Source in                         
        Called from    DATAVIEW    
                       LDLOOK      
                       TO_DO       
       
       
       
      Program/procedure name  HITBOTTOM   
        Source in                         
        Called from    TO_DO       
       
       
       
      Program/procedure name  IND_PROG    
        Source in             PRCEXTR.PRG 
        Called from    DIVIDEND    
                       GM_UPD      
                       PRCEXTR     
       
       
       
      Program/procedure name  INTEREST    
        Source in             INTEREST.PRG
        Called from    CHECKRUN    
        Uses           ET_CLOSE    
                       NET_USE     
                       RECLOCK     
       
       
       
08/05/95                      E.T.'s UTILITIES                      page 32
 
                  ALPHABETIC LIST OF PROCEDURES AND FUNCTIONS
 
      Program/procedure name  INWAIT      
        Source in                         
        Called from    A12_PAY_HI  
                       ACCCHANG    
                       CRSMAN      
                       MENU        
                       MIA         
                       STDMENU1    
                       TWIN        
       
       
       
      Program/procedure name  JIM         
        Source in             JIM.PRG     
        Uses           STDTEMP     
       
       
       
      Program/procedure name  JIMP        
        Source in             JIMP.PRG    
        Uses           MEDSTAT1    
       
       
       
      Program/procedure name  JIMPRN      
        Source in             JIMPRN.PRG  
       
       
       
      Program/procedure name  JW_EJECT    
        Source in                         
        Called from    FINMOVE     
                       FUTPRNT     
                       PORTPRNT    
       
       
       
      Program/procedure name  JW_HEAD     
        Source in                         
        Called from    MAIL        
       
       
       
08/05/95                      E.T.'s UTILITIES                      page 33
 
                  ALPHABETIC LIST OF PROCEDURES AND FUNCTIONS
 
      Program/procedure name  JW_PRI_SW   
        Source in                         
        Called from    MAIL        
                       SMIC        
       
       
       
      Program/procedure name  JW_VAL_YN   
        Source in                         
        Called from    CNTADD      
                       CNTEDIT2    
                       SECEDIT     
       
       
       
      Program/procedure name  LABELLINE   
        Source in             MEDLAB.PRG  
        Called from    MEDLAB      
        Uses           PRNTITLE    
       
       
       
      Program/procedure name  LDADD       
        Description :         Lead entry program            
        Source in             LDADD.PRG   
        Called from    LDMENU      
        Uses           DISP_MSG    
                       LDAD_V04    
                       LDAD_V06    
                       LDAD_V07    
                       LDAD_V08    
                       LDAD_V09    
                       MAKE_SURE   
                       PRE_SRC_CD  
                       PRE_SRC_DT  
                       RECLOCK     
                       RESTSECTOR  
                       SAVESECTOR  
                       VAL_ARC_NO  
                       VAL_LD_DT_  
                       VAL_LD_P_C  
                       VAL_LD_RAC  
                       VAL_LD_SEL  
                       VAL_LD_SEX  
                       VAL_LD_SRC  
                       VAL_LD_SUR  
       
        This screen is used for the initial data capture of a lead. As our   
        company depends on leads it is important to fill in as much          
        information as possible as accurately as possible. Some important    
        fields will only allow certain characters. Press F1 again when you   
08/05/95                      E.T.'s UTILITIES                      page 34
 
                  ALPHABETIC LIST OF PROCEDURES AND FUNCTIONS
 
      Program/procedure name  LDADD       
        are there for more help.                                             
       
       
      Program/procedure name  LDADV       
        Source in             LDADV.PRG   
       
       
       
      Program/procedure name  LDAD_V04    
        Source in             LDADD.PRG   
        Called from    LDADD       
                       LDEDITB     
        Uses           DISP_MSG    
                       RESTSECTOR  
       
       
       
      Program/procedure name  LDAD_V06    
        Source in             LDADD.PRG   
        Called from    LDADD       
                       LDEDITB     
                       LDREP       
        Uses           DISP_MSG    
                       RESTSECTOR  
       
       
       
      Program/procedure name  LDAD_V07    
        Source in             LDADD.PRG   
        Called from    LDADD       
                       LDEDITB     
                       LDREP       
        Uses           DISP_MSG    
                       RESTSECTOR  
       
       
       
      Program/procedure name  LDAD_V08    
        Source in             LDADD.PRG   
        Called from    LDADD       
        Uses           DISP_MSG    
                       RESTSECTOR  
       
       
       
08/05/95                      E.T.'s UTILITIES                      page 35
 
                  ALPHABETIC LIST OF PROCEDURES AND FUNCTIONS
 
      Program/procedure name  LDAD_V09    
        Source in             LDADD.PRG   
        Called from    LDADD       
                       LDEDITA     
                       LDREP       
        Uses           RESTSECTOR  
       
       
       
      Program/procedure name  LDAD_V10    
        Source in             LDADD.PRG   
        Called from    LDEDITA     
        Uses           DISP_MSG    
                       RESTSECTOR  
       
       
       
      Program/procedure name  LDAD_V11    
        Source in             LDADD.PRG   
        Called from    LDEDITA     
        Uses           DISP_MSG    
                       RESTSECTOR  
       
       
       
      Program/procedure name  LDARCLB     
        Description :                                       
        Source in             LDARCLB.PRG 
        Uses           NET_USE     
                       OPENPRN     
       
        This program will print out labels for any lead that you might have. 
                                                                             
        Some points to remember -                                            
           * The computer must have a printer.                               
           * There must be labels in the printer.                            
           * You must know the archive no's.                                 
        To leave the program, simply enter a blank archive number.           
       
       
      Program/procedure name  LDAREALB    
        Source in             LDAREALB.PRG
        Uses           MAREALINE   
                       NET_USE     
                       SHUTPRN     
       
       
       
08/05/95                      E.T.'s UTILITIES                      page 36
 
                  ALPHABETIC LIST OF PROCEDURES AND FUNCTIONS
 
      Program/procedure name  LDDELETE    
        Source in             LDDELETE.PRG
        Uses           MAKE_SURE   
                       NET_USE     
       
       
       
      Program/procedure name  LDDISP      
        Description :         Lead display screen           
        Source in             LDDISP.PRG  
        Called from    ENQMENU     
                       LDMENU      
       
        This program is used to find out archive numbers of leads. Enter in  
        the surname, or if you think it is misspelled just the first part of 
        the surname. This will bring up a list of all leads with this        
        surname, and the assosiated rep.                                     
       
       
      Program/procedure name  LDEDIT      
        Description :                                       
        Source in             LDEDIT.PRG  
        Called from    LDMENU      
        Uses           DISP_MSG    
                       LDEDITA     
                       LDEDITB     
                       MAKE_SURE   
                       RECLOCK     
                       RESTSECTOR  
       
        The lead edit screen is broken into 2 portions so that you do not    
        need to go through many fields when you only want to edit one.       
                                                                             
        The first option edits sales information while the second one edits  
        details about the customer himself.                                  
       
       
      Program/procedure name  LDEDITA     
        Source in             LDEDIT.PRG  
        Called from    LDEDIT      
        Uses           DISP_MSG    
                       LDAD_V09    
                       LDAD_V10    
                       LDAD_V11    
                       RECLOCK     
                       RESTSECTOR  
                       SAVESECTOR  
       
       
       
08/05/95                      E.T.'s UTILITIES                      page 37
 
                  ALPHABETIC LIST OF PROCEDURES AND FUNCTIONS
 
      Program/procedure name  LDEDITB     
        Source in             LDEDIT.PRG  
        Called from    LDEDIT      
        Uses           DISP_MSG    
                       LDAD_V04    
                       LDAD_V06    
                       LDAD_V07    
                       PRE_SRC_CD  
                       PRE_SRC_DT  
                       RESTSECTOR  
                       SAVESECTOR  
                       VAL_LD_DT_  
                       VAL_LD_P_C  
                       VAL_LD_RAC  
                       VAL_LD_SEL  
                       VAL_LD_SEX  
                       VAL_LD_SRC  
       
       
       
      Program/procedure name  LDFARMER    
        Source in             LDFARMER.PRG
        Uses           MAREALINE   
                       NET_USE     
                       SIMHEAD     
       
       
       
      Program/procedure name  LDLAB       
        Source in             LDLAB.PRG   
        Called from    PRNTMENU    
        Uses           NET_USE     
                       OPENPRN     
                       SHUTPRN     
                       WMAKE_SURE  
       
       
       
      Program/procedure name  LDLOOK      
        Description :         Lead display screen           
        Source in             LDLOOK.PRG  
        Called from    ENQMENU     
        Uses           HELP        
                       NET_USE     
       
        This screen is used to display details of a particular lead. To look 
        up the information you will need the archive number of the lead from 
        your lead card.                                                      
       
       
08/05/95                      E.T.'s UTILITIES                      page 38
 
                  ALPHABETIC LIST OF PROCEDURES AND FUNCTIONS
 
      Program/procedure name  LDMENU      
        Source in             LDMENU.PRG  
        Called from    MIA         
                       SMIC        
        Uses           ET_CLOSE    
                       GET_ARR     
                       LDADD       
                       LDDISP      
                       LDEDIT      
                       LDREMOVE    
                       LDREP       
                       NET_USE     
       
       
       
      Program/procedure name  LDOLD       
        Source in             LDOLD.PRG   
        Called from    DATAMENU    
        Uses           DISP_MSG    
                       FIELDNAME   
                       NET_USE     
                       RECLOCK     
                       SHUTPRN     
                       WMAKE_SURE  
       
       
       
      Program/procedure name  LDPRLAB     
        Source in             LDPRLAB.PRG 
        Called from    PRNTMENU    
        Uses           NET_USE     
                       OPENPRN     
                       SHUTPRN     
                       WMAKE_SURE  
       
       
       
      Program/procedure name  LDREMOVE    
        Source in             LDREMOVE.PRG
        Called from    LDMENU      
        Uses           MAKE_SURE   
                       RECLOCK     
       
       
       
08/05/95                      E.T.'s UTILITIES                      page 39
 
                  ALPHABETIC LIST OF PROCEDURES AND FUNCTIONS
 
      Program/procedure name  LDREP       
        Source in             LDREP.PRG   
        Called from    LDMENU      
        Uses           LDAD_V06    
                       LDAD_V07    
                       LDAD_V09    
                       MAKE_SURE   
                       RECLOCK     
                       SAVESECTOR  
       
       
       
      Program/procedure name  LDSPCLB     
        Source in             LDSPCLB.PRG 
        Uses           NET_USE     
                       OPENPRN     
                       RECLOCK     
       
       
       
      Program/procedure name  LDUNALL     
        Source in             LDUNALL.PRG 
        Called from    CHECKRUN    
        Uses           ET_CLOSE    
                       NET_USE     
                       RECLOCK     
       
       
       
      Program/procedure name  LD_KILL_EN  
        Source in             LDADD.PRG   
        Called from    PRE_SRC_CD  
       
       
       
      Program/procedure name  LOAD_ARR    
        Source in             STDAREAL.PRG
        Called from    STDAREAL    
       
       
       
08/05/95                      E.T.'s UTILITIES                      page 40
 
                  ALPHABETIC LIST OF PROCEDURES AND FUNCTIONS
 
      Program/procedure name  MAIL        
        Source in             MAIL.PRG    
        Uses           JW_HEAD     
                       JW_PRI_SW   
                       MAIL_READ   
                       MAIL_SEND   
                       MEM_DISP    
                       MGET_ARR    
                       MOUSENEW    
                       M_GOTO      
                       M_INIT      
                       NET_USE     
                       SYS_ERROR   
                       TO_DO       
       
       
       
      Program/procedure name  MAIL_READ   
        Source in             MAIL.PRG    
        Called from    MAIL        
        Uses           DRAW_BOX    
                       MGET_ARR    
                       RECLOCK     
                       RESTSECTOR  
       
       
       
      Program/procedure name  MAIL_SEND   
        Source in             MAIL.PRG    
        Called from    MAIL        
        Uses           DRAW_BOX    
                       MGET_ARR    
                       RECLOCK     
                       RESTSECTOR  
       
       
       
      Program/procedure name  MAKE_SURE   
        Source in                         
        Called from    ACCCHANG    
                       ACCDEBIT    
                       ACCDEBPR    
                       ADVDELET    
                       ADVLIST     
                       ADVNCOST    
                       CNTADD      
                       DEBITACC    
                       DEBIT_ORDE  
                       DUP         
                       ETADMIN     
                       FINPRNT     
08/05/95                      E.T.'s UTILITIES                      page 41
 
                  ALPHABETIC LIST OF PROCEDURES AND FUNCTIONS
 
      Program/procedure name  MAKE_SURE   
                       FOCUSLB     
                       FUTLONG     
                       FUTMAN      
                       FUTSHORT    
                       LDADD       
                       LDDELETE    
                       LDEDIT      
                       LDREMOVE    
                       LDREP       
                       MEDAREAS    
                       MEDLAB      
                       MEDRDIG     
                       MEDSALES    
                       MEDSTAT     
                       MEDSTAT1    
                       NOT_DEL_IT  
                       NOT_INS_IT  
                       NOT_SUB_ME  
                       PASPRNT     
                       PORTPRNT    
                       PRCEXTR     
                       PREBUY      
                       QUESSIE     
                       SHRALLOC    
                       SHRCHANG    
                       STDACTIV    
                       STDADDR     
                       STDCLASS    
                       STDCOUNT    
                       STDGRADD    
                       STDLIST     
                       STDREIN1    
                       STDREINS    
                       STDRESET    
                       STDSTAFF    
                       STDSTART    
                       STDSUSP1    
                       STDUNPD     
                       TO_DO       
                       TRNBUY      
                       TRNEDIT     
                       TRNNPLEX    
                       TRNPAS      
                       TWIN        
                       VATADD      
                       VATRPT      
       
       
       
08/05/95                      E.T.'s UTILITIES                      page 42
 
                  ALPHABETIC LIST OF PROCEDURES AND FUNCTIONS
 
      Program/procedure name  MAREALINE   
        Source in             LDFARMER.PRG
        Called from    LDAREALB    
                       LDFARMER    
       
       
       
      Program/procedure name  MEDANAL     
        Source in             MEDANAL.PRG 
        Called from    MEDMENU     
        Uses           DISP_MSG    
                       NET_USE     
                       SHUTPRN     
                       WMAKE_SURE  
       
       
       
      Program/procedure name  MEDAREAS    
        Source in             MEDAREAS.PRG
        Called from    MEDMENU     
        Uses           MAKE_SURE   
                       MED_1_COUN  
                       MED_2_PRIN  
                       NET_USE     
                       OPENPRN     
                       PRNTITLE    
                       SHUTPRN     
       
       
       
      Program/procedure name  MEDLAB      
        Source in             MEDLAB.PRG  
        Called from    MEDMENU     
        Uses           LABELLINE   
                       MAKE_SURE   
                       NET_USE     
                       OPENPRN     
                       PRNTITLE    
                       SHUTPRN     
       
       
       
08/05/95                      E.T.'s UTILITIES                      page 43
 
                  ALPHABETIC LIST OF PROCEDURES AND FUNCTIONS
 
      Program/procedure name  MEDMENU     
        Source in             MEDMENU.PRG 
        Called from    MIA         
                       SMIC        
        Uses           GET_ARR     
                       MEDANAL     
                       MEDAREAS    
                       MEDLAB      
                       MEDRDIG     
                       MEDSALES    
                       MEDSTAT     
                       MEDSTAT1    
       
       
       
      Program/procedure name  MEDPROC1    
        Source in             MEDSTAT.PRG 
        Called from    MEDSTAT     
                       MEDSTAT1    
       
       
       
      Program/procedure name  MEDRDIG     
        Source in             MEDRDIG.PRG 
        Called from    MEDMENU     
        Uses           DISP_MSG    
                       MAKE_SURE   
                       NET_USE     
                       OPENPRN     
                       PRNTITLE    
                       PR_LINE1    
                       PR_LINE2    
                       PR_LINE3    
                       PSTAT1      
                       PSTAT2      
                       SHUTPRN     
       
       
       
      Program/procedure name  MEDSALES    
        Source in             MEDSALES.PRG
        Called from    MEDMENU     
        Uses           ET_CLOSE    
                       MAKE_SURE   
                       NET_USE     
                       OPENPRN     
                       PRNTITLE    
                       SHUTPRN     
       
       
       
08/05/95                      E.T.'s UTILITIES                      page 44
 
                  ALPHABETIC LIST OF PROCEDURES AND FUNCTIONS
 
      Program/procedure name  MEDSTAT     
        Source in             MEDSTAT.PRG 
        Called from    MEDMENU     
        Uses           MAKE_SURE   
                       MEDPROC1    
                       NET_USE     
                       OPENPRN     
                       PRNTITLE    
                       PR_LINE     
                       RECLOCK     
                       SHUTPRN     
       
       
       
      Program/procedure name  MEDSTAT1    
        Source in             MEDSTAT1.PRG
        Called from    JIMP        
                       MEDMENU     
        Uses           MAKE_SURE   
                       MEDPROC1    
                       NET_USE     
                       OPENPRN     
                       PRNTITLE    
                       PR_LINE     
                       SHUTPRN     
       
       
       
      Program/procedure name  MED_1_COUN  
        Source in             MEDAREAS.PRG
        Called from    MEDAREAS    
       
       
       
      Program/procedure name  MED_2_PRIN  
        Source in             MEDAREAS.PRG
        Called from    MEDAREAS    
       
       
       
      Program/procedure name  MEM_DISP    
        Source in                         
        Called from    MAIL        
       
       
       
08/05/95                      E.T.'s UTILITIES                      page 45
 
                  ALPHABETIC LIST OF PROCEDURES AND FUNCTIONS
 
      Program/procedure name  MENU        
        Source in             MENU.PRG    
        Uses           INWAIT      
                       STDMENU     
                       TO_DO       
       
       
       
      Program/procedure name  MERGE       
        Source in             MERGE.PRG   
        Called from    STDPMENU    
        Uses           MERGE_STD   
                       MGET_ARR    
                       NET_USE     
       
       
       
      Program/procedure name  MERGE_STD   
        Source in             MERGE.PRG   
        Called from    MERGE       
        Uses           PROP_NOUN   
       
       
       
      Program/procedure name  MGET_ARR    
        Source in                         
        Called from    CLIENT      
                       CNTADD      
                       CNTEDIT     
                       MAIL        
                       MAIL_READ   
                       MAIL_SEND   
                       MERGE       
                       NOTES       
                       SYSPARAM    
       
       
       
      Program/procedure name  MIA         
        Description :         Data capture program          
        Source in             MIA.PRG     
        Uses           ADVMENU     
                       INWAIT      
                       LDMENU      
                       MEDMENU     
                       PRNTMENU    
                       STDMENU1    
                       TO_DO       
       
        Data capture program                                                 
       
08/05/95                      E.T.'s UTILITIES                      page 46
 
                  ALPHABETIC LIST OF PROCEDURES AND FUNCTIONS
 
      Program/procedure name  MIA         
       
      Program/procedure name  MISC_ERROR  
        Source in             ERRORSYS.PRG
       
       
       
      Program/procedure name  MOUSENEW    
        Source in                         
        Called from    CRSMAN      
                       MAIL        
       
       
       
      Program/procedure name  MOVE_BAR    
        Source in             RE_INDEX.PRG
        Called from    RE_INDEX    
       
       
       
      Program/procedure name  MSG_DISP    
        Source in             MSG_DISP.PRG
        Called from    CRS1        
       
       
       
      Program/procedure name  M_GOTO      
        Source in                         
        Called from    CRSMAN      
                       MAIL        
       
       
       
      Program/procedure name  M_INIT      
        Source in                         
        Called from    CRSMAN      
                       MAIL        
       
       
       
      Program/procedure name  NET_USE     
        Source in                         
        Called from    ACCCHANG    
                       ACCDEBIT    
                       ACCDEBPR    
                       ACCDEPOS    
                       ACCDISP     
                       ACCDISP1    
                       ACCJIM      
                       ACCREF      
                       ACCREPCM    
08/05/95                      E.T.'s UTILITIES                      page 47
 
                  ALPHABETIC LIST OF PROCEDURES AND FUNCTIONS
 
      Program/procedure name  NET_USE     
                       ACCSTAT     
                       ACCSTD      
                       ACCUNPD     
                       ACCUPBNK    
                       ADVADD      
                       ADVCHANG    
                       ADVDELET    
                       ADVDISP     
                       ADVEDIT     
                       ADVLIST     
                       ADVNCOST    
                       BEARDLV     
                       BELDIV      
                       CHECKRUN    
                       CNTADD      
                       CNTEDIT     
                       CNTLIST     
                       CNTLIST1    
                       CNTPRNT     
                       CNT_MOVE    
                       DEBITACC    
                       DIVIDEND    
                       DUP         
                       ENQMENU     
                       ETADMIN     
                       FINMOVE     
                       FINPRNT     
                       FUTADD      
                       FUTAUTO     
                       FUTDELET    
                       FUTDISP     
                       FUTEDIT     
                       FUTEXP      
                       FUTLONG     
                       FUTMAN      
                       FUTMARG     
                       FUTPRNT     
                       FUTSHORT    
                       GM_UPD      
                       INTEREST    
                       LDARCLB     
                       LDAREALB    
                       LDDELETE    
                       LDFARMER    
                       LDLAB       
                       LDLOOK      
                       LDMENU      
                       LDOLD       
                       LDPRLAB     
                       LDSPCLB     
08/05/95                      E.T.'s UTILITIES                      page 48
 
                  ALPHABETIC LIST OF PROCEDURES AND FUNCTIONS
 
      Program/procedure name  NET_USE     
                       LDUNALL     
                       MAIL        
                       MEDANAL     
                       MEDAREAS    
                       MEDLAB      
                       MEDRDIG     
                       MEDSALES    
                       MEDSTAT     
                       MEDSTAT1    
                       MERGE       
                       NOTES       
                       OUTST       
                       PARAMS      
                       PASPRNT     
                       PFOLLDT     
                       PLEADS      
                       PORDERS     
                       PORTPRNT    
                       PRCEXTR     
                       PRDADD      
                       PR_CH       
                       QUESSIE     
                       RECCHECK    
                       REPADD      
                       REPEDIT     
                       REPRATIO    
                       REPSTAT     
                       RE_INDEX    
                       RLEADS      
                       RSALES      
                       SECADD      
                       SECDELET    
                       SECDISP     
                       SECEDIT     
                       SECPRNT     
                       SHRALLOC    
                       SHRCHANG    
                       SHRCONS     
                       SHRDELET    
                       SHRDIVEX    
                       SHREDIT     
                       SHRHOLD     
                       SHRJIM      
                       SHRMAN      
                       SHRSPLIT    
                       SMICLAB     
                       STDACTIV    
                       STDADD      
                       STDADDR     
                       STDAREAL    
08/05/95                      E.T.'s UTILITIES                      page 49
 
                  ALPHABETIC LIST OF PROCEDURES AND FUNCTIONS
 
      Program/procedure name  NET_USE     
                       STDCASH     
                       STDCLASS    
                       STDCODE     
                       STDCOMNT    
                       STDCOUNT    
                       STDDISP     
                       STDEDIT     
                       STDEDIT1    
                       STDEXPL     
                       STDFIN      
                       STDGRADD    
                       STDJIM      
                       STDLIST     
                       STDLOOK     
                       STDREIN2    
                       STDREINS    
                       STDRESET    
                       STDSPECL    
                       STDSTART    
                       STDSUSP     
                       STDTEMP     
                       STDTVLLB    
                       STDUNACT    
                       STDUNPD     
                       STDWEEK     
                       SYSPARAM    
                       TO_DO       
                       TRNLOOK     
                       TRNNPL      
                       TRNNPLAB    
                       TRNOLD      
                       TRNORDER    
                       TRNPAS      
                       TRNSHRAB    
                       TRNSTOP     
                       TWIN        
                       UPGRADE     
                       VATADD      
                       VATLIST     
                       VATRPT      
       
       
       
08/05/95                      E.T.'s UTILITIES                      page 50
 
                  ALPHABETIC LIST OF PROCEDURES AND FUNCTIONS
 
      Program/procedure name  NOTES       
        Source in             NOTES.PRG   
        Called from    SMIC        
        Uses           DISP_MSG    
                       DRAW_BOX    
                       MGET_ARR    
                       NET_USE     
                       NOT_PRINT   
                       OPENPRN     
                       PRNTITLE    
                       PR_LINE     
                       RESTSECTOR  
                       SHUTPRN     
       
       
       
      Program/procedure name  NOTES_UDF   
        Source in             NOTES.PRG   
       
       
       
      Program/procedure name  NOTPROG     
        Source in             NOTPROG.PRG 
        Uses           DRAW_BOX    
       
       
       
      Program/procedure name  NOT_DEL_IT  
        Source in             NOTES.PRG   
        Called from    NOT_EXCEP   
        Uses           MAKE_SURE   
                       RECLOCK     
       
       
       
      Program/procedure name  NOT_EDIT_I  
        Source in             NOTES.PRG   
        Called from    NOT_EXCEP   
                       NOT_INS_IT  
                       NOT_SUB_ME  
        Uses           RECLOCK     
                       RESTSECTOR  
                       SAVESECTOR  
       
       
       
08/05/95                      E.T.'s UTILITIES                      page 51
 
                  ALPHABETIC LIST OF PROCEDURES AND FUNCTIONS
 
      Program/procedure name  NOT_EXCEP   
        Source in             NOTES.PRG   
        Uses           DISP_MSG    
                       DRAW_BOX    
                       NOT_DEL_IT  
                       NOT_EDIT_I  
                       NOT_INS_IT  
                       NOT_PRINT   
                       NOT_SUB_ME  
                       OPENPRN     
                       RESTSECTOR  
                       SHUTPRN     
       
       
       
      Program/procedure name  NOT_INS_IT  
        Source in             NOTES.PRG   
        Called from    NOT_EXCEP   
        Uses           MAKE_SURE   
                       NOT_EDIT_I  
                       NOT_NM_NUM  
                       NOT_NUM_NM  
                       RECLOCK     
       
       
       
      Program/procedure name  NOT_NM_NUM  
        Source in             NOTES.PRG   
        Called from    NOT_INS_IT  
       
       
       
      Program/procedure name  NOT_NUM_NM  
        Source in             NOTES.PRG   
        Called from    NOT_INS_IT  
                       NOT_SUB_ME  
       
       
       
      Program/procedure name  NOT_PRINT   
        Source in             NOTES.PRG   
        Called from    NOTES       
                       NOT_EXCEP   
                       NOT_PRINT   
        Uses           NOT_PRINT   
                       PRNTITLE    
                       PR_LINE     
       
       
       
08/05/95                      E.T.'s UTILITIES                      page 52
 
                  ALPHABETIC LIST OF PROCEDURES AND FUNCTIONS
 
      Program/procedure name  NOT_SUB_ME  
        Source in             NOTES.PRG   
        Called from    NOT_EXCEP   
        Uses           MAKE_SURE   
                       NOT_EDIT_I  
                       NOT_NUM_NM  
                       RECLOCK     
       
       
       
      Program/procedure name  OPENPRN     
        Source in                         
        Called from    ACCBANK     
                       ACCCOMM     
                       ACCDEBIT    
                       ACCDEBPR    
                       ACCDEPOS    
                       ACCJIM      
                       ACCREPBK    
                       ACCREPCM    
                       ACCUNPD     
                       ADVLIST     
                       ADVNCOST    
                       CNTLIST     
                       CNTLIST1    
                       DEBITACC    
                       FINPRNT     
                       LDARCLB     
                       LDLAB       
                       LDPRLAB     
                       LDSPCLB     
                       MEDAREAS    
                       MEDLAB      
                       MEDRDIG     
                       MEDSALES    
                       MEDSTAT     
                       MEDSTAT1    
                       NOTES       
                       NOT_EXCEP   
                       PASPRNT     
                       PFOLLDT     
                       PRNPORT     
                       PRN_MEDANA  
                       REPSTAT     
                       RSALES      
                       SECPRNT     
                       STDACTIV    
                       STDCLASS    
                       STDFIN      
                       STDLEC      
                       STDLIST     
08/05/95                      E.T.'s UTILITIES                      page 53
 
                  ALPHABETIC LIST OF PROCEDURES AND FUNCTIONS
 
      Program/procedure name  OPENPRN     
                       STDSTAFF    
                       STDSTART    
                       STDTEMP     
                       STDUNACT    
                       TESTPRN     
                       TO_DO_PRIN  
                       TRNOLD      
                       VATLIST     
                       VATRPT      
                       WKSHRPRN    
       
       
       
      Program/procedure name  OPEN_ERROR  
        Source in             ERRORSYS.PRG
       
       
       
      Program/procedure name  ORDEDIT     
        Source in             ORDEDIT.PRG 
        Called from    OTHTRNMN    
        Uses           ANYSEEK     
                       DRAW_BOX    
                       RECLOCK     
                       SAVESECTOR  
       
       
       
      Program/procedure name  OTHTRNMN    
        Source in             OTHTRNMN.PRG
        Called from    TWIN        
        Uses           BEARBUY     
                       BEARSL      
                       GET_ARR     
                       ORDEDIT     
                       PREBUY      
                       PRESELL     
                       TRNEDIT     
                       TRNNPLEX    
       
       
       
08/05/95                      E.T.'s UTILITIES                      page 54
 
                  ALPHABETIC LIST OF PROCEDURES AND FUNCTIONS
 
      Program/procedure name  OUTST       
        Source in             OUTST.PRG   
        Uses           NET_USE     
                       SHUTPRN     
                       SIMHEAD     
                       SIMTITLE    
       
       
       
      Program/procedure name  P8_ARR_UDF  
        Source in             ACCCHANG.PRG
        Called from    ACCCHANG    
        Uses           A1_PMT_TYP  
                       A2_PMT_DT   
                       A4_COMMENT  
                       A7_C_RECNO  
       
       
       
      Program/procedure name  PARAMS      
        Source in             PARAMS.PRG  
        Uses           NET_USE     
                       SIMHEAD     
       
       
       
      Program/procedure name  PASPRNT     
        Source in             PASPRNT.PRG 
        Uses           MAKE_SURE   
                       NET_USE     
                       OPENPRN     
                       PRNTITLE    
                       SHUTPRN     
       
       
       
      Program/procedure name  PCT         
        Source in             PCT.PRG     
       
       
       
08/05/95                      E.T.'s UTILITIES                      page 55
 
                  ALPHABETIC LIST OF PROCEDURES AND FUNCTIONS
 
      Program/procedure name  PFOLLDT     
        Source in             PFOLLDT.PRG 
        Called from    PRNTMENU    
        Uses           NET_USE     
                       OPENPRN     
                       PRNTITLE    
                       SHUTPRN     
                       WMAKE_SURE  
       
       
       
      Program/procedure name  PLEADS      
        Source in             PLEADS.PRG  
        Uses           BRCOUNT     
                       NET_USE     
                       SHUTPRN     
                       SIMTITLE    
       
       
       
      Program/procedure name  PORDERS     
        Source in             PORDERS.PRG 
        Uses           BRADD       
                       NET_USE     
                       SHUTPRN     
                       SIMHEAD     
                       SIMTITLE    
       
       
       
      Program/procedure name  PORTPRNT    
        Source in             PORTPRNT.PRG
        Called from    WKLYMENU    
        Uses           AREMOVE     
                       EOY         
                       FUTPRNT     
                       JW_EJECT    
                       MAKE_SURE   
                       NET_USE     
                       PORT_SUM_L  
                       PRNTITLE    
                       PR_LINE     
                       RECLOCK     
                       WEEK        
       
       
       
08/05/95                      E.T.'s UTILITIES                      page 56
 
                  ALPHABETIC LIST OF PROCEDURES AND FUNCTIONS
 
      Program/procedure name  PORT_SUM_L  
        Source in             PORTPRNT.PRG
        Called from    PORTPRNT    
       
       
       
      Program/procedure name  PRCEXTR     
        Source in             PRCEXTR.PRG 
        Called from    CHECKRUN    
                       SHRMENU     
        Uses           ET_CLOSE    
                       IND_PROG    
                       MAKE_SURE   
                       NET_USE     
                       RECLOCK     
                       SHR_DATE    
       
       
       
      Program/procedure name  PRDADD      
        Source in             PRDADD.PRG  
        Uses           NET_USE     
       
       
       
      Program/procedure name  PREBUY      
        Source in             PREBUY.PRG  
        Called from    OTHTRNMN    
        Uses           MAKE_SURE   
                       RECLOCK     
                       WAIT_MSG    
       
       
       
      Program/procedure name  PRESELL     
        Source in             PRESELL.PRG 
        Called from    OTHTRNMN    
        Uses           RECLOCK     
                       WAIT_MSG    
       
       
       
08/05/95                      E.T.'s UTILITIES                      page 57
 
                  ALPHABETIC LIST OF PROCEDURES AND FUNCTIONS
 
      Program/procedure name  PRE_SRC_CD  
        Source in             LDADD.PRG   
        Called from    LDADD       
                       LDEDITB     
        Uses           ANYSEEK     
                       LD_KILL_EN  
       
       
       
      Program/procedure name  PRE_SRC_DT  
        Source in             LDADD.PRG   
        Called from    LDADD       
                       LDEDITB     
        Uses           ANYSEEK     
       
       
       
      Program/procedure name  PRINT_ERRO  
        Source in             ERRORSYS.PRG
       
       
       
      Program/procedure name  PRM_DO_EDI  
        Source in             SYSPARAM.PRG
        Called from    SYSPARAM    
        Uses           GET_ARR     
                       RECLOCK     
       
       
       
      Program/procedure name  PRNPORT     
        Source in             TRNDISP.PRG 
        Called from    TRNDISP     
        Uses           OPENPRN     
                       PRNTITLE    
                       PR_LINE     
                       SHUTPRN     
       
       
       
      Program/procedure name  PRNTITLE    
        Source in                         
        Called from    ACCBANK     
                       ACCCOMM     
                       ACCDEBIT    
                       ACCDEBPR    
                       ACCDEPOS    
                       ACCJIM      
                       ACCREPBK    
                       ACCREPCM    
                       ACCUNPD     
08/05/95                      E.T.'s UTILITIES                      page 58
 
                  ALPHABETIC LIST OF PROCEDURES AND FUNCTIONS
 
      Program/procedure name  PRNTITLE    
                       ADVLIST     
                       ADVNCOST    
                       CNTLIST     
                       CNTLIST1    
                       DEBITACC    
                       FINPRNT     
                       FUTPRNT     
                       LABELLINE   
                       MEDAREAS    
                       MEDLAB      
                       MEDRDIG     
                       MEDSALES    
                       MEDSTAT     
                       MEDSTAT1    
                       NOTES       
                       NOT_PRINT   
                       PASPRNT     
                       PFOLLDT     
                       PORTPRNT    
                       PRNPORT     
                       PRN_MEDANA  
                       PR_PROC     
                       PR_TO_DO    
                       PSTAT2      
                       REPRATIO    
                       REPSTAT     
                       RLEADS      
                       RLEADSBR    
                       RSALES      
                       SECPRNT     
                       STDACTIV    
                       STDCLASS    
                       STDFIN      
                       STDLEC      
                       STDLIST     
                       STDSTAFF    
                       STDSTART    
                       STDUNACT    
                       TESTPRN     
                       TRNOLD      
                       VATLIST     
                       VATRPT      
                       WKSHRPRN    
       
       
       
08/05/95                      E.T.'s UTILITIES                      page 59
 
                  ALPHABETIC LIST OF PROCEDURES AND FUNCTIONS
 
      Program/procedure name  PRNTMENU    
        Source in             PRNTMENU.PRG
        Called from    MIA         
                       SMIC        
        Uses           GET_ARR     
                       LDLAB       
                       LDPRLAB     
                       PFOLLDT     
                       REPRATIO    
                       REPSTAT     
                       RLEADS      
                       RSALES      
       
       
       
      Program/procedure name  PRN_LAB     
        Source in             STDAREAL.PRG
        Called from    STDAREAL    
        Uses           PR_LINE     
       
       
       
      Program/procedure name  PRN_MEDANA  
        Source in             MEDANAL.PRG 
        Uses           OPENPRN     
                       PRNTITLE    
                       PR_LINE1    
                       PR_LINE2    
                       PR_LINE3    
                       PSTAT1      
                       PSTAT2      
       
       
       
      Program/procedure name  PROP_NOUN   
        Source in                         
        Called from    MERGE_STD   
       
       
       
      Program/procedure name  PRT_LINE    
        Source in             REPSTAT.PRG 
        Called from    REPSTAT     
       
       
       
08/05/95                      E.T.'s UTILITIES                      page 60
 
                  ALPHABETIC LIST OF PROCEDURES AND FUNCTIONS
 
      Program/procedure name  PR_CH       
        Source in             PR_CH.PRG   
        Called from    SYSPARAM    
        Uses           DISP_MSG    
                       ET_SEEK     
                       NET_USE     
                       RECLOCK     
                       RESTSECTOR  
                       WMAKE_SURE  
       
       
       
      Program/procedure name  PR_LINE     
        Source in                         
        Called from    ACCBANK     
                       ACCCOMM     
                       ACCDEBIT    
                       ACCREPBK    
                       ACCUNPD     
                       ADVNCOST    
                       DEBITACC    
                       MEDSTAT     
                       MEDSTAT1    
                       NOTES       
                       NOT_PRINT   
                       PORTPRNT    
                       PRNPORT     
                       PRN_LAB     
                       STDCLASS    
                       STDFIN      
                       STDLEC      
                       STDSTART    
                       STDUNACT    
                       TRNOLD      
                       VATRPT      
                       WKSHRPRN    
       
       
       
      Program/procedure name  PR_LINE1    
        Source in             MEDRDIG.PRG 
        Called from    MEDRDIG     
                       PRN_MEDANA  
       
       
       
08/05/95                      E.T.'s UTILITIES                      page 61
 
                  ALPHABETIC LIST OF PROCEDURES AND FUNCTIONS
 
      Program/procedure name  PR_LINE2    
        Source in             MEDRDIG.PRG 
        Called from    MEDRDIG     
                       PRN_MEDANA  
       
       
       
      Program/procedure name  PR_LINE3    
        Source in             MEDRDIG.PRG 
        Called from    MEDRDIG     
                       PRN_MEDANA  
       
       
       
      Program/procedure name  PR_PROC     
        Source in             STDTEMP.PRG 
        Called from    STDTEMP     
        Uses           PRNTITLE    
       
       
       
      Program/procedure name  PR_TO_DO    
        Source in             TO_DO.PRG   
        Called from    TO_DO_PRIN  
        Uses           PRNTITLE    
       
       
       
      Program/procedure name  PSTAT1      
        Source in             MEDRDIG.PRG 
        Called from    MEDRDIG     
                       PRN_MEDANA  
        Uses           STAT_ADD    
       
       
       
      Program/procedure name  PSTAT2      
        Source in             MEDRDIG.PRG 
        Called from    MEDRDIG     
                       PRN_MEDANA  
        Uses           PRNTITLE    
       
       
       
08/05/95                      E.T.'s UTILITIES                      page 62
 
                  ALPHABETIC LIST OF PROCEDURES AND FUNCTIONS
 
      Program/procedure name  QUESSIE     
        Source in             QUESSIE.PRG 
        Uses           MAKE_SURE   
                       NET_USE     
       
       
       
      Program/procedure name  RATIODISP   
        Source in             REPRATIO.PRG
        Called from    REPRATIO    
       
       
       
      Program/procedure name  RECCHECK    
        Source in             RECCHECK.PRG
        Called from    CHECKRUN    
        Uses           ET_CLOSE    
                       NET_USE     
                       RECLOCK     
       
       
       
      Program/procedure name  RECLOCK     
        Source in                         
        Called from    ACCBANK     
                       ACCCHANG    
                       ACCCOMM     
                       ACCDEBIT    
                       ACCDEPOS    
                       ACCJIM      
                       ACCUPBNK    
                       ADVADD      
                       ADVCHANG    
                       ADVDELET    
                       BEARBUY     
                       BEARDLV     
                       BEARSL      
                       BELDIV      
                       BUY_ORDER   
                       CHEQUE_OTH  
                       CNTADD      
                       CNTEDIT     
                       DEBIT_ORDE  
                       DIVIDEND    
                       DTA_SHARE   
                       DUP         
                       EDIT_TODO   
                       FINMOVE     
                       FUTADD      
                       FUTAUTO     
                       FUTEXP      
08/05/95                      E.T.'s UTILITIES                      page 63
 
                  ALPHABETIC LIST OF PROCEDURES AND FUNCTIONS
 
      Program/procedure name  RECLOCK     
                       FUTLONG     
                       FUTMAN      
                       FUTMARG     
                       FUTSHORT    
                       GET_CHEQUE  
                       GET_CREDIT  
                       GM_UPD      
                       HED_UPD     
                       INTEREST    
                       LDADD       
                       LDEDIT      
                       LDEDITA     
                       LDOLD       
                       LDREMOVE    
                       LDREP       
                       LDSPCLB     
                       LDUNALL     
                       MAIL_READ   
                       MAIL_SEND   
                       MEDSTAT     
                       NOT_DEL_IT  
                       NOT_EDIT_I  
                       NOT_INS_IT  
                       NOT_SUB_ME  
                       ORDEDIT     
                       PORTPRNT    
                       PRCEXTR     
                       PREBUY      
                       PRESELL     
                       PRM_DO_EDI  
                       PR_CH       
                       RECCHECK    
                       REIN_STD    
                       REPADD      
                       RLEADS      
                       SECADD      
                       SECEDIT     
                       SELL_ORDER  
                       SHRALLOC    
                       SHRCHANG    
                       SHRCONS     
                       SHRDELET    
                       SHRDIV      
                       SHREDIT     
                       SHRHOLD     
                       SHRSPLIT    
                       STDADD      
                       STDADDR     
                       STDCOMN1    
                       STDCOMNT    
08/05/95                      E.T.'s UTILITIES                      page 64
 
                  ALPHABETIC LIST OF PROCEDURES AND FUNCTIONS
 
      Program/procedure name  RECLOCK     
                       STDEDIT     
                       STDEDIT1    
                       STDEXPL     
                       STDGRADD    
                       STDREIN1    
                       STDREIN2    
                       STDREINS    
                       STDRESET    
                       STDSTART    
                       STDSUSP     
                       STDSUSP1    
                       STDUNPD     
                       SYSPARAM    
                       TO_DO       
                       TRNBUY      
                       TRNEDIT     
                       TRNNPL      
                       TRNNPLAB    
                       TRNNPLEX    
                       TRNORDER    
                       TRNPAS      
                       TRNSELL     
                       TRNSHRAB    
                       TRNSTOP     
                       TWIN        
                       VATADD      
       
       
       
      Program/procedure name  REIN_STD    
        Source in             STDREIN2.PRG
        Called from    STDREIN2    
        Uses           RECLOCK     
       
       
       
      Program/procedure name  REPADD      
        Source in             REPADD.PRG  
        Called from    REPMENU     
        Uses           ET_CLOSE    
                       NET_USE     
                       RECLOCK     
                       WAIT_MSG    
       
       
       
08/05/95                      E.T.'s UTILITIES                      page 65
 
                  ALPHABETIC LIST OF PROCEDURES AND FUNCTIONS
 
      Program/procedure name  REPEDIT     
        Source in             REPEDIT.PRG 
        Called from    REPMENU     
        Uses           ET_CLOSE    
                       ET_SEEK     
                       NET_USE     
                       VAL_REP_LE  
                       VAL_REP_ST  
                       WAIT_MSG    
       
       
       
      Program/procedure name  REPMENU     
        Source in             REPMENU.PRG 
        Called from    ETADMIN     
        Uses           GET_ARR     
                       REPADD      
                       REPEDIT     
       
       
       
      Program/procedure name  REPRATIO    
        Source in             REPRATIO.PRG
        Called from    PRNTMENU    
        Uses           NET_USE     
                       PRNTITLE    
                       RATIODISP   
                       SHUTPRN     
       
       
       
      Program/procedure name  REPSTAT     
        Source in             REPSTAT.PRG 
        Called from    PRNTMENU    
        Uses           NET_USE     
                       OPENPRN     
                       PRNTITLE    
                       PRT_LINE    
                       SHUTPRN     
                       WMAKE_SURE  
       
       
       
08/05/95                      E.T.'s UTILITIES                      page 66
 
                  ALPHABETIC LIST OF PROCEDURES AND FUNCTIONS
 
      Program/procedure name  RESTSECTOR  
        Source in                         
        Called from    A12_PAY_HI  
                       ACCCHANG    
                       ACCDEBIT    
                       ACCSTD      
                       BEARBUY     
                       BEARSL      
                       DATAVIEW    
                       DOS_WRITE   
                       EDIT_TODO   
                       GET_CHEQUE  
                       GET_CREDIT  
                       LDADD       
                       LDAD_V04    
                       LDAD_V06    
                       LDAD_V07    
                       LDAD_V08    
                       LDAD_V09    
                       LDAD_V10    
                       LDAD_V11    
                       LDEDIT      
                       LDEDITA     
                       LDEDITB     
                       MAIL_READ   
                       MAIL_SEND   
                       NOTES       
                       NOT_EDIT_I  
                       NOT_EXCEP   
                       PR_CH       
                       RE_INDEX    
                       STDEDIT1    
                       STDLECT     
                       TO_DO       
                       TRNNPLEX    
                       TWIN        
                       VAL_ARC_NO  
                       VAL_BIRTH_  
                       VAL_LD_DT_  
                       VAL_LD_P_C  
                       VAL_LD_RAC  
                       VAL_LD_SEL  
                       VAL_LD_SEX  
                       VAL_LD_SRC  
                       VAL_LD_SUR  
                       VAL_STDLEC  
       
       
       
08/05/95                      E.T.'s UTILITIES                      page 67
 
                  ALPHABETIC LIST OF PROCEDURES AND FUNCTIONS
 
      Program/procedure name  RE_INDEX    
        Source in             RE_INDEX.PRG
        Called from    ETADMIN     
        Uses           DBCREATEIN  
                       DISP_MSG    
                       MOVE_BAR    
                       NET_USE     
                       RESTSECTOR  
                       SET_BAR     
       
       
       
      Program/procedure name  RLEADS      
        Source in             RLEADS.PRG  
        Called from    PRNTMENU    
        Uses           NET_USE     
                       PRNTITLE    
                       RECLOCK     
                       RLEADSBR    
                       WMAKE_SURE  
       
       
       
      Program/procedure name  RLEADSBR    
        Source in             RLEADS.PRG  
        Called from    RLEADS      
        Uses           PRNTITLE    
       
       
       
      Program/procedure name  RSALES      
        Source in             RSALES.PRG  
        Called from    PRNTMENU    
        Uses           NET_USE     
                       OPENPRN     
                       PRNTITLE    
                       SHUTPRN     
                       WMAKE_SURE  
       
       
       
08/05/95                      E.T.'s UTILITIES                      page 68
 
                  ALPHABETIC LIST OF PROCEDURES AND FUNCTIONS
 
      Program/procedure name  SAVESECTOR  
        Source in                         
        Called from    A12_PAY_HI  
                       BEARBUY     
                       BEARSL      
                       CNTADD      
                       LDADD       
                       LDEDITA     
                       LDEDITB     
                       LDREP       
                       NOT_EDIT_I  
                       ORDEDIT     
                       STDADD      
                       STDLECT     
                       TRNNPLEX    
                       TWIN        
       
       
       
      Program/procedure name  SECADD      
        Source in             SECADD.PRG  
        Uses           DISP_MSG    
                       NET_USE     
                       RECLOCK     
       
       
       
      Program/procedure name  SECDELET    
        Source in             SECDELET.PRG
        Called from    SECMENU     
        Uses           DISP_MSG    
                       NET_USE     
                       WMAKE_SURE  
       
       
       
      Program/procedure name  SECDISP     
        Source in             SECDISP.PRG 
        Called from    SECMENU     
        Uses           NET_USE     
       
       
       
08/05/95                      E.T.'s UTILITIES                      page 69
 
                  ALPHABETIC LIST OF PROCEDURES AND FUNCTIONS
 
      Program/procedure name  SECEDIT     
        Source in             SECEDIT.PRG 
        Called from    SECMENU     
        Uses           DISP_MSG    
                       JW_VAL_YN   
                       NET_USE     
                       RECLOCK     
                       WMAKE_SURE  
       
       
       
      Program/procedure name  SECMENU     
        Source in             SECMENU.PRG 
        Called from    ETADMIN     
        Uses           GET_ARR     
                       SECDELET    
                       SECDISP     
                       SECEDIT     
                       SECPRNT     
       
       
       
      Program/procedure name  SECPRNT     
        Source in             SECPRNT.PRG 
        Called from    SECMENU     
        Uses           NET_USE     
                       OPENPRN     
                       PRNTITLE    
                       SEC_PR_LIN  
                       SHUTPRN     
                       WMAKE_SURE  
       
       
       
      Program/procedure name  SEC_PR_LIN  
        Source in             SECPRNT.PRG 
        Called from    SECPRNT     
       
       
       
      Program/procedure name  SEEK_POSN   
        Source in             WKSHRPRN.PRG
        Called from    WKSHRPRN    
       
       
       
08/05/95                      E.T.'s UTILITIES                      page 70
 
                  ALPHABETIC LIST OF PROCEDURES AND FUNCTIONS
 
      Program/procedure name  SELL_ORDER  
        Source in             TRNSELL.PRG 
        Called from    TRNSELL     
        Uses           RECLOCK     
       
       
       
      Program/procedure name  SET_BAR     
        Source in             RE_INDEX.PRG
        Called from    RE_INDEX    
        Uses           DRAW_BOX    
       
       
       
      Program/procedure name  SHRALLOC    
        Source in             SHRALLOC.PRG
        Called from    CRS1        
        Uses           ET_CLOSE    
                       MAKE_SURE   
                       NET_USE     
                       RECLOCK     
       
       
       
      Program/procedure name  SHRCHANG    
        Description :                                       
        Source in             SHRCHANG.PRG
        Uses           ET_CLOSE    
                       MAKE_SURE   
                       NET_USE     
                       RECLOCK     
       
        This program will change the name of a share on all students         
        portfolios but will not delete the old share from the database as it 
        will still be used in the printout.It will however appear on the list
        of shares to be deleted and can be deleted after a week or so if the 
        system does not automatically do so.                                 
       
       
      Program/procedure name  SHRCONS     
        Description :                                       
        Source in             SHRCONS.PRG 
        Called from    CRS1        
        Uses           NET_USE     
                       RECLOCK     
                       WMAKE_SURE  
       
        This program will calculate a share consolidation and adjust all     
        student portfolios accordingly.                                      
                                                                             
        The value you enter is the number of shares that will be consolidated
08/05/95                      E.T.'s UTILITIES                      page 71
 
                  ALPHABETIC LIST OF PROCEDURES AND FUNCTIONS
 
      Program/procedure name  SHRCONS     
        into one new share.                                                  
                                                                             
       
       
      Program/procedure name  SHRDELET    
        Description :                                       
        Source in             SHRDELET.PRG
        Called from    CRS1        
        Uses           NET_USE     
                       RECLOCK     
                       WMAKE_SURE  
       
        This program is used to delete a share from the database. It first   
        checks to see if any students still hold the share. If any do you    
        will be told their names and will not be permitted to delete the     
        share. First find out what has happened to it. This program has      
        basically become redundant as the system automatically deletes       
        deleteable shares.                                                   
       
       
      Program/procedure name  SHRDIV      
        Source in             SHRDIV.PRG  
        Called from    SHRMENU     
        Uses           DIV_VAL_DT  
                       DIV_VAL_TY  
                       RECLOCK     
       
       
       
      Program/procedure name  SHRDIVEX    
        Source in             SHRDIVEX.PRG
        Uses           NET_USE     
                       SIMHEAD     
       
       
       
      Program/procedure name  SHREDIT     
        Description :                                       
        Source in             SHREDIT.PRG 
        Called from    CRS1        
        Uses           NET_USE     
                       RECLOCK     
       
        This program is used to write comments on shares and to enter any    
        forth coming dividends and dates. An LDR (Last Date to Register) must
        be in the future as we will pay students dividends on that day.      
                                                                             
                                                                             
       
       
08/05/95                      E.T.'s UTILITIES                      page 72
 
                  ALPHABETIC LIST OF PROCEDURES AND FUNCTIONS
 
      Program/procedure name  SHREXPL     
        Source in             SHREXPL.PRG 
       
       
       
      Program/procedure name  SHRHOLD     
        Source in             SHRHOLD.PRG 
        Called from    CRS1        
        Uses           NET_USE     
                       RECLOCK     
       
       
       
      Program/procedure name  SHRJIM      
        Source in             SHRJIM.PRG  
        Uses           NET_USE     
                       SIMHEAD     
       
       
       
      Program/procedure name  SHRLOOK     
        Description :                                       
        Source in             SHRLOOK.PRG 
        Called from    ENQMENU     
                       SHRMENU     
       
        This program will display information about any share such as any    
        dividends due in the near future, and Derek's comments.The date      
        associated with the comment is the date the comment was last updated.
                                                                             
                                                                             
       
       
      Program/procedure name  SHRMAN      
        Source in             SHRMAN.PRG  
        Called from    CRS1        
        Uses           NET_USE     
       
       
       
      Program/procedure name  SHRMENU     
        Source in             SHRMENU.PRG 
        Called from    TWIN        
        Uses           GET_ARR     
                       PRCEXTR     
                       SHRDIV      
                       SHRLOOK     
       
       
       
08/05/95                      E.T.'s UTILITIES                      page 73
 
                  ALPHABETIC LIST OF PROCEDURES AND FUNCTIONS
 
      Program/procedure name  SHRSPLIT    
        Description :                                       
        Source in             SHRSPLIT.PRG
        Called from    CRS1        
        Uses           NET_USE     
                       RECLOCK     
                       WMAKE_SURE  
       
        This program is used to calculate a share split and adjust the       
        student portfolios accordingly.                                      
                                                                             
        The value that you enter is the number of new shares created from 1  
        old share.                                                           
       
       
      Program/procedure name  SHR_DATE    
        Source in             PRCEXTR.PRG 
        Called from    PRCEXTR     
       
       
       
      Program/procedure name  SHUTPRN     
        Source in                         
        Called from    ACCBANK     
                       ACCCOMM     
                       ACCDEBIT    
                       ACCDEBPR    
                       ACCDEPOS    
                       ACCJIM      
                       ACCREPBK    
                       ACCREPCM    
                       ACCUNPD     
                       ADVLIST     
                       ADVNCOST    
                       CNTLIST     
                       CNTLIST1    
                       DEBITACC    
                       FINMOVE     
                       FINPRNT     
                       LDAREALB    
                       LDLAB       
                       LDOLD       
                       LDPRLAB     
                       MEDANAL     
                       MEDAREAS    
                       MEDLAB      
                       MEDRDIG     
                       MEDSALES    
                       MEDSTAT     
                       MEDSTAT1    
                       NOTES       
08/05/95                      E.T.'s UTILITIES                      page 74
 
                  ALPHABETIC LIST OF PROCEDURES AND FUNCTIONS
 
      Program/procedure name  SHUTPRN     
                       NOT_EXCEP   
                       OUTST       
                       PASPRNT     
                       PFOLLDT     
                       PLEADS      
                       PORDERS     
                       PRNPORT     
                       REPRATIO    
                       REPSTAT     
                       RSALES      
                       SECPRNT     
                       SMICLAB     
                       STDCLASS    
                       STDFIN      
                       STDLEC      
                       STDSTAFF    
                       STDSTART    
                       STDUNACT    
                       TO_DO_PRIN  
                       TRNOLD      
                       VATLIST     
                       VATRPT      
                       WKSHRPRN    
       
       
       
      Program/procedure name  SIMHEAD     
        Source in                         
        Called from    LDFARMER    
                       OUTST       
                       PARAMS      
                       PORDERS     
                       SHRDIVEX    
                       SHRJIM      
                       STDSPECL    
                       STDTVLLB    
                       TRNSUBMN    
                       WKLYMENU    
       
       
       
08/05/95                      E.T.'s UTILITIES                      page 75
 
                  ALPHABETIC LIST OF PROCEDURES AND FUNCTIONS
 
      Program/procedure name  SIMTITLE    
        Source in                         
        Called from    OUTST       
                       PLEADS      
                       PORDERS     
       
       
       
      Program/procedure name  SKIP_ANY    
        Source in             DATAVIEW.PRG
        Called from    DATAVIEW    
       
       
       
      Program/procedure name  SKIP_TO_DO  
        Source in             TO_DO.PRG   
        Called from    TO_DO       
       
       
       
      Program/procedure name  SMIC        
        Description :         SMIC program                  
        Source in             SMIC.PRG    
        Uses           ACCMENU     
                       ACCSUBMN    
                       ADVMENU     
                       CRS1        
                       CRS3        
                       ENQMENU     
                       ETADMIN     
                       GET_ARR     
                       JW_PRI_SW   
                       LDMENU      
                       MEDMENU     
                       NOTES       
                       PRNTMENU    
                       STDMENU     
                       STDPMENU    
                       TWIN        
                       UPGRADE     
       
        This is a simple program for use by anyone in the company to view    
        information on our computer. Don't be scared of this program as it   
        has been designed change or damage anything important. When you have 
        finished please press 'Esc' to leave the computer free.              
       
       
08/05/95                      E.T.'s UTILITIES                      page 76
 
                  ALPHABETIC LIST OF PROCEDURES AND FUNCTIONS
 
      Program/procedure name  SMICLAB     
        Source in             SMICLAB.PRG 
        Called from    ENQMENU     
        Uses           ET_CLOSE    
                       GET_ARR     
                       NET_USE     
                       SHUTPRN     
       
       
       
      Program/procedure name  STABILIZE   
        Source in                         
        Called from    DATAVIEW    
                       TO_DO       
       
       
       
      Program/procedure name  STAT_ADD    
        Source in             MEDRDIG.PRG 
        Called from    PSTAT1      
       
       
       
      Program/procedure name  STDACTIV    
        Source in             STDACTIV.PRG
        Called from    STDPMENU    
        Uses           CLOSEPRN    
                       DRAW_BOX    
                       GET_ARR     
                       MAKE_SURE   
                       NET_USE     
                       OPENPRN     
                       PRNTITLE    
       
       
       
      Program/procedure name  STDADD      
        Source in             STDADD.PRG  
        Called from    STDMENU     
                       STDMENU1    
        Uses           CHEQUE_OTH  
                       DEBIT_ORDE  
                       DISP_MSG    
                       GET_ARR     
                       GET_CREDIT  
                       NET_USE     
                       RECLOCK     
                       SAVESECTOR  
                       STD_V01     
                       STD_V02     
                       STD_V03     
08/05/95                      E.T.'s UTILITIES                      page 77
 
                  ALPHABETIC LIST OF PROCEDURES AND FUNCTIONS
 
      Program/procedure name  STDADD      
                       STD_V04     
                       STD_V05     
                       STD_V06     
                       WMAKE_SURE  
       
       
       
      Program/procedure name  STDADDR     
        Source in             STDADDR.PRG 
        Uses           MAKE_SURE   
                       NET_USE     
                       RECLOCK     
       
       
       
      Program/procedure name  STDAREAL    
        Source in             STDAREAL.PRG
        Called from    STDPMENU    
        Uses           CLOSEPRN    
                       DRAW_BOX    
                       GET_ARR     
                       LOAD_ARR    
                       NET_USE     
                       PRN_LAB     
                       WMAKE_SURE  
       
       
       
      Program/procedure name  STDCASH     
        Description :                                       
        Source in             STDCASH.PRG 
        Called from    CRS3        
        Uses           DISP_MSG    
                       NET_USE     
       
        This program will alter the starting capital and any related fields  
        for a student. Just enter the amount it must change (negative for    
        less money) and it shall be so.                                      
                                                                             
        N.B. This is not the same as giving the student more cash for profit 
        he may have lost.                                                    
       
       
08/05/95                      E.T.'s UTILITIES                      page 78
 
                  ALPHABETIC LIST OF PROCEDURES AND FUNCTIONS
 
      Program/procedure name  STDCLASS    
        Description :                                       
        Source in             STDCLASS.PRG
        Called from    CRS3        
        Uses           MAKE_SURE   
                       NET_USE     
                       OPENPRN     
                       PRNTITLE    
                       PR_LINE     
                       SHUTPRN     
       
        This program prints out the top ten students for the previous week   
        based on their last months performance.                              
       
       
      Program/procedure name  STDCODE     
        Source in             STDCODE.PRG 
        Uses           NET_USE     
       
       
       
      Program/procedure name  STDCOMN1    
        Source in             STDCOMN1.PRG
        Called from    STDMENU2    
        Uses           RECLOCK     
       
       
       
      Program/procedure name  STDCOMNT    
        Source in             STDCOMNT.PRG
        Called from    STDMENU     
        Uses           NET_USE     
                       RECLOCK     
       
       
       
      Program/procedure name  STDCOUNT    
        Source in             STDCOUNT.PRG
        Called from    CRS3        
        Uses           MAKE_SURE   
                       NET_USE     
       
       
       
08/05/95                      E.T.'s UTILITIES                      page 79
 
                  ALPHABETIC LIST OF PROCEDURES AND FUNCTIONS
 
      Program/procedure name  STDDISP     
        Source in             STDDISP.PRG 
        Uses           NET_USE     
       
       
       
      Program/procedure name  STDEDIT     
        Source in             STDEDIT.PRG 
        Called from    STDMENU     
                       STDMENU1    
        Uses           NET_USE     
                       RECLOCK     
                       STD_V01     
                       STD_V02     
                       STD_V03     
                       STD_V04     
                       STD_V05     
                       STD_V06     
       
       
       
      Program/procedure name  STDEDIT1    
        Source in             STDEDIT1.PRG
        Called from    STDMENU2    
        Uses           DISP_MSG    
                       ET_CLOSE    
                       NET_USE     
                       RECLOCK     
                       RESTSECTOR  
                       WAIT_MSG    
       
       
       
      Program/procedure name  STDEXPL     
        Source in             STDEXPL.PRG 
        Called from    STDMENU     
        Uses           DISP_MSG    
                       NET_USE     
                       RECLOCK     
                       WMAKE_SURE  
       
       
       
08/05/95                      E.T.'s UTILITIES                      page 80
 
                  ALPHABETIC LIST OF PROCEDURES AND FUNCTIONS
 
      Program/procedure name  STDFIN      
        Source in             STDFIN.PRG  
        Called from    STDPMENU    
        Uses           DRAW_BOX    
                       NET_USE     
                       OPENPRN     
                       PRNTITLE    
                       PR_LINE     
                       SHUTPRN     
                       WMAKE_SURE  
       
       
       
      Program/procedure name  STDGRADD    
        Source in             STDGRADD.PRG
        Called from    STDMENU1    
        Uses           MAKE_SURE   
                       NET_USE     
                       RECLOCK     
       
       
       
      Program/procedure name  STDJIM      
        Source in             STDJIM.PRG  
        Uses           NET_USE     
       
       
       
      Program/procedure name  STDLEC      
        Source in             STDLEC.PRG  
        Uses           OPENPRN     
                       PRNTITLE    
                       PR_LINE     
                       SHUTPRN     
       
       
       
      Program/procedure name  STDLECT     
        Source in             STDLECT.PRG 
        Called from    STDMENU2    
        Uses           DRAW_BOX    
                       RESTSECTOR  
                       SAVESECTOR  
                       VAL_STDLEC  
                       WAIT_MSG    
       
       
       
08/05/95                      E.T.'s UTILITIES                      page 81
 
                  ALPHABETIC LIST OF PROCEDURES AND FUNCTIONS
 
      Program/procedure name  STDLIST     
        Source in             STDLIST.PRG 
        Called from    STDPMENU    
        Uses           CLOSEPRN    
                       DRAW_BOX    
                       GET_ARR     
                       MAKE_SURE   
                       NET_USE     
                       OPENPRN     
                       PRNTITLE    
       
       
       
      Program/procedure name  STDLOOK     
        Description :                                       
        Source in             STDLOOK.PRG 
        Called from    ENQMENU     
                       STDMENU1    
        Uses           NET_USE     
       
        This program is used to look up information on any student. Any      
        changes to student information must be done by the admin girls.      
                                                                             
                                                                             
                                                                             
       
       
      Program/procedure name  STDMENU     
        Source in             STDMENU.PRG 
        Called from    MENU        
                       SMIC        
        Uses           GET_ARR     
                       STDADD      
                       STDCOMNT    
                       STDEDIT     
                       STDEXPL     
                       STDREINS    
                       STDSUSP     
                       STDUNPD     
       
       
       
08/05/95                      E.T.'s UTILITIES                      page 82
 
                  ALPHABETIC LIST OF PROCEDURES AND FUNCTIONS
 
      Program/procedure name  STDMENU1    
        Source in             STDMENU1.PRG
        Called from    MIA         
        Uses           INWAIT      
                       STDADD      
                       STDEDIT     
                       STDGRADD    
                       STDLOOK     
                       STDREINS    
                       STDSUSP     
       
       
       
      Program/procedure name  STDMENU2    
        Source in             STDMENU2.PRG
        Called from    TWIN        
        Uses           ACCDISP1    
                       GET_ARR     
                       STDCOMN1    
                       STDEDIT1    
                       STDLECT     
                       STDREIN1    
                       STDSUSP1    
       
       
       
      Program/procedure name  STDNAMLB    
        Source in             STDNAMLB.PRG
        Uses           DRAW_BOX    
       
       
       
      Program/procedure name  STDPMENU    
        Source in             STDPMENU.PRG
        Called from    SMIC        
        Uses           GET_ARR     
                       MERGE       
                       STDACTIV    
                       STDAREAL    
                       STDFIN      
                       STDLIST     
                       STDUNACT    
       
       
       
08/05/95                      E.T.'s UTILITIES                      page 83
 
                  ALPHABETIC LIST OF PROCEDURES AND FUNCTIONS
 
      Program/procedure name  STDREIN1    
        Source in             STDREIN1.PRG
        Called from    STDMENU2    
        Uses           MAKE_SURE   
                       RECLOCK     
                       STD_PORT_V  
       
       
       
      Program/procedure name  STDREIN2    
        Source in             STDREIN2.PRG
        Called from    CHECKRUN    
        Uses           DISP_MSG    
                       ET_CLOSE    
                       NET_USE     
                       RECLOCK     
                       REIN_STD    
       
       
       
      Program/procedure name  STDREINS    
        Source in             STDREINS.PRG
        Called from    STDMENU     
                       STDMENU1    
        Uses           DISP_MSG    
                       MAKE_SURE   
                       NET_USE     
                       RECLOCK     
       
       
       
      Program/procedure name  STDRESET    
        Source in             STDRESET.PRG
        Called from    CRS3        
        Uses           MAKE_SURE   
                       NET_USE     
                       RECLOCK     
       
       
       
      Program/procedure name  STDSPECL    
        Source in             STDSPECL.PRG
        Uses           NET_USE     
                       SIMHEAD     
       
       
       
08/05/95                      E.T.'s UTILITIES                      page 84
 
                  ALPHABETIC LIST OF PROCEDURES AND FUNCTIONS
 
      Program/procedure name  STDSTAFF    
        Source in             STDSTAFF.PRG
        Uses           MAKE_SURE   
                       OPENPRN     
                       PRNTITLE    
                       SHUTPRN     
       
       
       
      Program/procedure name  STDSTART    
        Source in             STDSTART.PRG
        Called from    CRS3        
        Uses           DISP_MSG    
                       MAKE_SURE   
                       NET_USE     
                       OPENPRN     
                       PRNTITLE    
                       PR_LINE     
                       RECLOCK     
                       SHUTPRN     
       
       
       
      Program/procedure name  STDSUSP     
        Source in             STDSUSP.PRG 
        Called from    STDMENU     
                       STDMENU1    
        Uses           DISP_MSG    
                       NET_USE     
                       RECLOCK     
                       WMAKE_SURE  
       
       
       
      Program/procedure name  STDSUSP1    
        Source in             STDSUSP1.PRG
        Called from    STDMENU2    
        Uses           DRAW_BOX    
                       MAKE_SURE   
                       RECLOCK     
                       WAIT_MSG    
       
       
       
08/05/95                      E.T.'s UTILITIES                      page 85
 
                  ALPHABETIC LIST OF PROCEDURES AND FUNCTIONS
 
      Program/procedure name  STDTEMP     
        Source in             STDTEMP.PRG 
        Called from    JIM         
        Uses           CLOSEPRN    
                       NET_USE     
                       OPENPRN     
                       PR_PROC     
       
       
       
      Program/procedure name  STDTVLLB    
        Source in             STDTVLLB.PRG
        Uses           NET_USE     
                       SIMHEAD     
       
       
       
      Program/procedure name  STDUNACT    
        Source in             STDUNACT.PRG
        Called from    STDPMENU    
        Uses           DRAW_BOX    
                       ET_CLOSE    
                       NET_USE     
                       OPENPRN     
                       PRNTITLE    
                       PR_LINE     
                       SHUTPRN     
                       WMAKE_SURE  
       
       
       
      Program/procedure name  STDUNPD     
        Source in             STDUNPD.PRG 
        Called from    STDMENU     
        Uses           DISP_MSG    
                       MAKE_SURE   
                       NET_USE     
                       RECLOCK     
       
       
       
08/05/95                      E.T.'s UTILITIES                      page 86
 
                  ALPHABETIC LIST OF PROCEDURES AND FUNCTIONS
 
      Program/procedure name  STDWEEK     
        Description :                                       
        Source in             STDWEEK.PRG 
        Called from    CRS3        
        Uses           NET_USE     
       
        With this program you can increase the time a student will be on TWIN
        for whatever reason.                                                 
       
       
      Program/procedure name  STD_PORT_V  
        Source in             STDREIN1.PRG
        Called from    STDREIN1    
       
       
       
      Program/procedure name  STD_V01     
        Source in             STDADD.PRG  
        Called from    STDADD      
                       STDEDIT     
       
       
       
      Program/procedure name  STD_V02     
        Source in             STDADD.PRG  
        Called from    STDADD      
                       STDEDIT     
       
       
       
      Program/procedure name  STD_V03     
        Source in             STDADD.PRG  
        Called from    STDADD      
                       STDEDIT     
       
       
       
      Program/procedure name  STD_V04     
        Source in             STDADD.PRG  
        Called from    STDADD      
                       STDEDIT     
       
       
       
08/05/95                      E.T.'s UTILITIES                      page 87
 
                  ALPHABETIC LIST OF PROCEDURES AND FUNCTIONS
 
      Program/procedure name  STD_V05     
        Source in             STDADD.PRG  
        Called from    STDADD      
                       STDEDIT     
       
       
       
      Program/procedure name  STD_V06     
        Source in             STDADD.PRG  
        Called from    STDADD      
                       STDEDIT     
       
       
       
      Program/procedure name  STR_COM     
        Source in             HED_UPD.PRG 
        Called from    HED_UPD     
       
       
       
      Program/procedure name  SYSMENU     
        Source in             SYSMENU.PRG 
       
       
       
      Program/procedure name  SYSPARAM    
        Source in             SYSPARAM.PRG
        Called from    ETADMIN     
        Uses           MGET_ARR    
                       NET_USE     
                       PRM_DO_EDI  
                       PR_CH       
                       RECLOCK     
       
       
       
      Program/procedure name  SYS_ERROR   
        Source in                         
        Called from    MAIL        
       
       
       
08/05/95                      E.T.'s UTILITIES                      page 88
 
                  ALPHABETIC LIST OF PROCEDURES AND FUNCTIONS
 
      Program/procedure name  TEST        
        Source in             TEST.PRG    
        Uses           XFGEN       
       
       
       
      Program/procedure name  TESTPRN     
        Source in             TESTPRN.PRG 
        Uses           OPENPRN     
                       PRNTITLE    
       
       
       
      Program/procedure name  TO_DO       
        Source in             TO_DO.PRG   
        Called from    CRSMAN      
                       MAIL        
                       MENU        
                       MIA         
        Uses           DBCREATEIN  
                       DISP_MSG    
                       DRAW_BOX    
                       EDIT_TODO   
                       HELP        
                       HITBOTTOM   
                       MAKE_SURE   
                       NET_USE     
                       RECLOCK     
                       RESTSECTOR  
                       SKIP_TO_DO  
                       STABILIZE   
                       TO_DO_PRIN  
       
       
       
      Program/procedure name  TO_DO_PRIN  
        Source in             TO_DO.PRG   
        Called from    TO_DO       
        Uses           DRAW_BOX    
                       GET_ARR     
                       OPENPRN     
                       PR_TO_DO    
                       SHUTPRN     
       
       
       
08/05/95                      E.T.'s UTILITIES                      page 89
 
                  ALPHABETIC LIST OF PROCEDURES AND FUNCTIONS
 
      Program/procedure name  TRNBUY      
        Source in             TRNBUY.PRG  
        Called from    TWIN        
        Uses           BUY_ORDER   
                       DISP_MSG    
                       GET_ARR     
                       MAKE_SURE   
                       RECLOCK     
       
       
       
      Program/procedure name  TRNDISP     
        Source in             TRNDISP.PRG 
        Called from    TRNLOOK     
                       TWIN        
        Uses           PRNPORT     
       
       
       
      Program/procedure name  TRNEDIT     
        Source in             TRNEDIT.PRG 
        Called from    OTHTRNMN    
        Uses           MAKE_SURE   
                       RECLOCK     
                       WAIT_MSG    
       
       
       
      Program/procedure name  TRNLOOK     
        Description :                                       
        Source in             TRNLOOK.PRG 
        Called from    ENQMENU     
        Uses           NET_USE     
                       TRNDISP     
       
        This program will display the current portfolio of a student so that 
        you can see how they are doing.                                      
                                                                             
                                                                             
                                                                             
       
       
08/05/95                      E.T.'s UTILITIES                      page 90
 
                  ALPHABETIC LIST OF PROCEDURES AND FUNCTIONS
 
      Program/procedure name  TRNNPL      
        Source in             TRNNPL.PRG  
        Called from    CRS1        
        Uses           NET_USE     
                       RECLOCK     
                       WMAKE_SURE  
       
       
       
      Program/procedure name  TRNNPLAB    
        Description :                                       
        Source in             TRNNPLAB.PRG
        Called from    CHECKRUN    
        Uses           ET_CLOSE    
                       NET_USE     
                       RECLOCK     
       
        This program will delete the specified NPL from the students         
        portfolios, i.e. they will lose any value the NPL's might have had.  
                                                                             
                                                                             
                                                                             
       
       
      Program/procedure name  TRNNPLEX    
        Source in             TRNNPLEX.PRG
        Called from    OTHTRNMN    
                       TRNSUBMN    
        Uses           DISP_MSG    
                       MAKE_SURE   
                       RECLOCK     
                       RESTSECTOR  
                       SAVESECTOR  
                       WAIT_MSG    
       
       
       
      Program/procedure name  TRNOLD      
        Source in             TRNOLD.PRG  
        Called from    DATAMENU    
        Uses           NET_USE     
                       OPENPRN     
                       PRNTITLE    
                       PR_LINE     
                       SHUTPRN     
                       WMAKE_SURE  
       
       
       
08/05/95                      E.T.'s UTILITIES                      page 91
 
                  ALPHABETIC LIST OF PROCEDURES AND FUNCTIONS
 
      Program/procedure name  TRNORDER    
        Source in             TRNORDER.PRG
        Called from    CHECKRUN    
        Uses           ET_CLOSE    
                       NET_USE     
                       RECLOCK     
       
       
       
      Program/procedure name  TRNPAS      
        Source in             TRNPAS.PRG  
        Called from    TWIN        
        Uses           GET_ARR     
                       MAKE_SURE   
                       NET_USE     
                       RECLOCK     
       
       
       
      Program/procedure name  TRNSELL     
        Source in             TRNSELL.PRG 
        Called from    TWIN        
        Uses           GET_ARR     
                       RECLOCK     
                       SELL_ORDER  
                       WAIT_MSG    
       
       
       
      Program/procedure name  TRNSHRAB    
        Description :                                       
        Source in             TRNSHRAB.PRG
        Called from    CRS1        
        Uses           NET_USE     
                       RECLOCK     
                       WMAKE_SURE  
       
        This program will return the cost of holding a share to all students 
        that hold the share e.g. if the share was delisted.                  
       
       
08/05/95                      E.T.'s UTILITIES                      page 92
 
                  ALPHABETIC LIST OF PROCEDURES AND FUNCTIONS
 
      Program/procedure name  TRNSTOP     
        Description :                                       
        Source in             TRNSTOP.PRG 
        Called from    CRS1        
        Uses           DRAW_BOX    
                       ET_CLOSE    
                       NET_USE     
                       RECLOCK     
       
        This program will stop or re-start the ability to do portfolio       
        transactions. This would only be done just before the weekly print   
        run so that the course manager can finish writing the comments. At   
        the end of the print run trading will automatically be restarted.    
       
       
      Program/procedure name  TRNSUBMN    
        Source in             TRNSUBMN.PRG
        Uses           BEARBUY     
                       BEARSL      
                       FUTDISP     
                       FUTLONG     
                       FUTSHORT    
                       SIMHEAD     
                       TRNNPLEX    
       
       
       
      Program/procedure name  TWIN        
        Source in             TWIN.PRG    
        Called from    SMIC        
        Uses           BACKDISP    
                       DRAW_BOX    
                       FUTUREMN    
                       INWAIT      
                       MAKE_SURE   
                       NET_USE     
                       OTHTRNMN    
                       RECLOCK     
                       RESTSECTOR  
                       SAVESECTOR  
                       SHRMENU     
                       STDMENU2    
                       TRNBUY      
                       TRNDISP     
                       TRNPAS      
                       TRNSELL     
                       TWNDISP     
       
       
       
08/05/95                      E.T.'s UTILITIES                      page 93
 
                  ALPHABETIC LIST OF PROCEDURES AND FUNCTIONS
 
      Program/procedure name  TWNDISP     
        Source in             TWIN.PRG    
        Called from    TWIN        
        Uses           DISP_MSG    
       
       
       
      Program/procedure name  UDF_EDIT    
        Source in             QUESSIE.PRG 
       
       
       
      Program/procedure name  UNDEF_ERRO  
        Source in             ERRORSYS.PRG
       
       
       
      Program/procedure name  UPGRADE     
        Source in             UPGRADE.PRG 
        Called from    CHECKRUN    
                       HED_TEST    
                       SMIC        
        Uses           AREMOVE     
                       ET_CLOSE    
                       NET_USE     
       
       
       
      Program/procedure name  VAL_ARC_NO  
        Source in             LDADD.PRG   
        Called from    LDADD       
        Uses           DISP_MSG    
                       RESTSECTOR  
       
       
       
      Program/procedure name  VAL_BIRTH_  
        Source in             CNTADD.PRG  
        Called from    CNTADD      
        Uses           DISP_MSG    
                       RESTSECTOR  
       
       
       
08/05/95                      E.T.'s UTILITIES                      page 94
 
                  ALPHABETIC LIST OF PROCEDURES AND FUNCTIONS
 
      Program/procedure name  VAL_CALC_T  
        Source in             FUTADD.PRG  
        Called from    FUTADD      
                       FUTEDIT     
       
       
       
      Program/procedure name  VAL_FUT_DT  
        Source in             FUTADD.PRG  
        Called from    FUTADD      
       
       
       
      Program/procedure name  VAL_FUT_NM  
        Source in             FUTADD.PRG  
        Called from    FUTADD      
       
       
       
      Program/procedure name  VAL_LD_DT_  
        Source in             LDADD.PRG   
        Called from    LDADD       
                       LDEDITB     
        Uses           DISP_MSG    
                       RESTSECTOR  
       
       
       
      Program/procedure name  VAL_LD_P_C  
        Source in             LDADD.PRG   
        Called from    LDADD       
                       LDEDITB     
        Uses           DISP_MSG    
                       RESTSECTOR  
       
       
       
      Program/procedure name  VAL_LD_RAC  
        Source in             LDADD.PRG   
        Called from    LDADD       
                       LDEDITB     
        Uses           DISP_MSG    
                       RESTSECTOR  
       
       
       
08/05/95                      E.T.'s UTILITIES                      page 95
 
                  ALPHABETIC LIST OF PROCEDURES AND FUNCTIONS
 
      Program/procedure name  VAL_LD_SEL  
        Source in             LDADD.PRG   
        Called from    LDADD       
                       LDEDITB     
        Uses           DISP_MSG    
                       RESTSECTOR  
       
       
       
      Program/procedure name  VAL_LD_SEX  
        Source in             LDADD.PRG   
        Called from    LDADD       
                       LDEDITB     
        Uses           DISP_MSG    
                       RESTSECTOR  
       
       
       
      Program/procedure name  VAL_LD_SRC  
        Source in             LDADD.PRG   
        Called from    LDADD       
                       LDEDITB     
        Uses           DISP_MSG    
                       RESTSECTOR  
       
       
       
      Program/procedure name  VAL_LD_SUR  
        Source in             LDADD.PRG   
        Called from    LDADD       
        Uses           DISP_MSG    
                       RESTSECTOR  
       
       
       
      Program/procedure name  VAL_MARGIN  
        Source in             FUTADD.PRG  
        Called from    FUTADD      
                       FUTEDIT     
       
       
       
08/05/95                      E.T.'s UTILITIES                      page 96
 
                  ALPHABETIC LIST OF PROCEDURES AND FUNCTIONS
 
      Program/procedure name  VAL_PERC_V  
        Source in             FUTADD.PRG  
        Called from    FUTADD      
       
       
       
      Program/procedure name  VAL_REP_LE  
        Source in             REPEDIT.PRG 
        Called from    REPEDIT     
       
       
       
      Program/procedure name  VAL_REP_ST  
        Source in             REPEDIT.PRG 
        Called from    REPEDIT     
       
       
       
      Program/procedure name  VAL_STDLEC  
        Source in             STDLECT.PRG 
        Called from    STDLECT     
        Uses           DISP_MSG    
                       RESTSECTOR  
       
       
       
      Program/procedure name  VATADD      
        Source in             VATADD.PRG  
        Uses           DISP_MSG    
                       MAKE_SURE   
                       NET_USE     
                       RECLOCK     
       
       
       
      Program/procedure name  VATLIST     
        Source in             VATLIST.PRG 
        Uses           NET_USE     
                       OPENPRN     
                       PRNTITLE    
                       SHUTPRN     
       
       
       
08/05/95                      E.T.'s UTILITIES                      page 97
 
                  ALPHABETIC LIST OF PROCEDURES AND FUNCTIONS
 
      Program/procedure name  VATRPT      
        Source in             VATRPT.PRG  
        Called from    ACCMENU     
        Uses           ET_CLOSE    
                       MAKE_SURE   
                       NET_USE     
                       OPENPRN     
                       PRNTITLE    
                       PR_LINE     
                       SHUTPRN     
       
       
       
      Program/procedure name  WAIT_MSG    
        Source in                         
        Called from    BEARBUY     
                       BEARSL      
                       FUTDISP     
                       FUTLONG     
                       FUTSHORT    
                       PREBUY      
                       PRESELL     
                       REPADD      
                       REPEDIT     
                       STDEDIT1    
                       STDLECT     
                       STDSUSP1    
                       TRNEDIT     
                       TRNNPLEX    
                       TRNSELL     
       
       
       
      Program/procedure name  WEEK        
        Source in                         
        Called from    PORTPRNT    
       
       
       
      Program/procedure name  WKLYMENU    
        Source in             WKLYMENU.PRG
        Uses           FUTPRNT     
                       PORTPRNT    
                       SIMHEAD     
       
       
       
08/05/95                      E.T.'s UTILITIES                      page 98
 
                  ALPHABETIC LIST OF PROCEDURES AND FUNCTIONS
 
      Program/procedure name  WKSHRPRN    
        Description :                                       
        Source in             WKSHRPRN.PRG
        Called from    CRS1        
        Uses           ET_CLOSE    
                       ET_USE_DBF  
                       GET_ARR     
                       OPENPRN     
                       PRNTITLE    
                       PR_LINE     
                       SEEK_POSN   
                       SHUTPRN     
                       WMAKE_SURE  
       
        This will print out all shares that have transactions assosiated     
        with them. Buy and sell transaction are flagged with an asterisk if  
        they are out of date (4 weeks for technical and 4 months for         
        fundamental comments) or if the price has changed by more than 8% in 
        the previous week (technical comments only).                         
       
       
      Program/procedure name  WMAKE_SURE  
        Source in                         
        Called from    ACCBANK     
                       ACCCOMM     
                       ACCSTAT     
                       ACCSTD      
                       ACCUNPD     
                       ACCUPBNK    
                       CHEQUE_OTH  
                       DEBIT_ORDE  
                       FINMOVE     
                       FUTDELET    
                       LDLAB       
                       LDOLD       
                       LDPRLAB     
                       MEDANAL     
                       PFOLLDT     
                       PR_CH       
                       REPSTAT     
                       RLEADS      
                       RSALES      
                       SECDELET    
                       SECEDIT     
                       SECPRNT     
                       SHRCONS     
                       SHRDELET    
                       SHRSPLIT    
                       STDADD      
                       STDAREAL    
                       STDEXPL     
08/05/95                      E.T.'s UTILITIES                      page 99
 
                  ALPHABETIC LIST OF PROCEDURES AND FUNCTIONS
 
      Program/procedure name  WMAKE_SURE  
                       STDFIN      
                       STDSUSP     
                       STDUNACT    
                       TRNNPL      
                       TRNOLD      
                       TRNSHRAB    
                       WKSHRPRN    
       
       
       
      Program/procedure name  XFGEN       
        Source in                         
        Called from    CHECKRUN    
                       TEST        
       
       
       





































                   ---   08/05/95   ---