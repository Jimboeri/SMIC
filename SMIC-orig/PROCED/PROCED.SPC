15/04/96                      E.T.'s UTILITIES                      page 1
 
                  ALPHABETIC LIST OF PROCEDURES AND FUNCTIONS
 
      Program/procedure name  ACCSHOW     
        Source in             ACCSHOW.PRG 
        Uses           ADDMONTH    
                       SIMHEAD     
       
       
       
      Program/procedure name  ADDMONTH    
        Source in                         
        Called from    ACCSHOW     
       
       
       
      Program/procedure name  ANYLOOK     
        Source in                         
        Called from    TO          
       
       
       
      Program/procedure name  ANYSEEK     
        Source in                         
        Called from    FINDSHR     
       
       
       
      Program/procedure name  ARR_WIDTH   
        Source in             SMICPROC.PRG
       
       
       
      Program/procedure name  BKSPACE     
        Source in                         
        Called from    FINDFUT     
                       FINDSTD     
       
       
       
      Program/procedure name  BROKER      
        Source in             SMICPROC.PRG
       
       
       
15/04/96                      E.T.'s UTILITIES                      page 2
 
                  ALPHABETIC LIST OF PROCEDURES AND FUNCTIONS
 
      Program/procedure name  DISP_MSG    
        Source in                         
        Called from    SECURITY    
       
       
       
      Program/procedure name  DNL_DT      
        Source in             SMICPROC.PRG
       
       
       
      Program/procedure name  DRAW_BOX    
        Source in                         
        Called from    FINDFUT     
                       FINDSTD     
                       PR          
                       PRERROR     
       
       
       
      Program/procedure name  ETSEEK      
        Source in                         
        Called from    FINDPORT    
       
       
       
      Program/procedure name  ET_SEEK     
        Source in                         
        Called from    FINDBEAR    
                       FINDFUT     
                       FINDPORT    
                       FINDSHR     
                       SEEKFIN     
                       SEEKSTD     
       
       
       
      Program/procedure name  FINDBEAR    
        Source in             SMICPROC.PRG
        Uses           ET_SEEK     
       
       
       
15/04/96                      E.T.'s UTILITIES                      page 3
 
                  ALPHABETIC LIST OF PROCEDURES AND FUNCTIONS
 
      Program/procedure name  FINDFUT     
        Source in             SMICPROC.PRG
        Uses           BKSPACE     
                       DRAW_BOX    
                       ET_SEEK     
       
       
       
      Program/procedure name  FINDPORT    
        Source in             SMICPROC.PRG
        Uses           ETSEEK      
                       ET_SEEK     
       
       
       
      Program/procedure name  FINDSHR     
        Source in             SMICPROC.PRG
        Uses           ANYSEEK     
                       ET_SEEK     
       
       
       
      Program/procedure name  FINDSTD     
        Source in             FINDSTD.PRG 
        Called from    TO          
        Uses           BKSPACE     
                       DRAW_BOX    
       
       
       
      Program/procedure name  FUTVAL      
        Source in             SMICPROC.PRG
       
       
       
      Program/procedure name  HANDLE      
        Source in             SMICPROC.PRG
       
       
       
      Program/procedure name  HELP        
        Source in                         
        Called from    TO          
       
       
       
15/04/96                      E.T.'s UTILITIES                      page 4
 
                  ALPHABETIC LIST OF PROCEDURES AND FUNCTIONS
 
      Program/procedure name  LAST_RUN    
        Source in             SMICPROC.PRG
       
       
       
      Program/procedure name  MOUSE       
        Source in                         
        Called from    TO          
       
       
       
      Program/procedure name  MST         
        Source in             SMICPROC.PRG
       
       
       
      Program/procedure name  NET_USE     
        Source in                         
        Called from    SECURITY    
                       SELFDEST    
       
       
       
      Program/procedure name  PERCENT     
        Source in             SMICPROC.PRG
       
       
       
      Program/procedure name  PGDNOFF     
        Source in             SMICPROC.PRG
       
       
       
      Program/procedure name  PGDNON      
        Source in             SMICPROC.PRG
       
       
       
      Program/procedure name  PR          
        Source in             PRINPROC.PRG
        Uses           DRAW_BOX    
                       PRERROR     
                       RESTSECTOR  
       
       
       
15/04/96                      E.T.'s UTILITIES                      page 5
 
                  ALPHABETIC LIST OF PROCEDURES AND FUNCTIONS
 
      Program/procedure name  PRERROR     
        Source in             PRINPROC.PRG
        Called from    PR          
        Uses           DRAW_BOX    
                       RESTSECTOR  
       
       
       
      Program/procedure name  PRINPROC    
        Source in             PRINPROC.PRG
       
       
       
      Program/procedure name  PROCED      
        Source in             PROCED.PRG  
       
       
       
      Program/procedure name  PROCS       
        Source in                         
        Called from    TO          
       
       
       
      Program/procedure name  RATIOS      
        Source in             SMICPROC.PRG
       
       
       
      Program/procedure name  RECLOCK     
        Source in                         
        Called from    SECURITY    
       
       
       
      Program/procedure name  RESTSECTOR  
        Source in                         
        Called from    PR          
                       PRERROR     
       
       
       
15/04/96                      E.T.'s UTILITIES                      page 6
 
                  ALPHABETIC LIST OF PROCEDURES AND FUNCTIONS
 
      Program/procedure name  REV_C_TO_N  
        Source in             SMICPROC.PRG
        Uses           REV_N_TO_C  
       
       
       
      Program/procedure name  REV_N_TO_C  
        Source in             SMICPROC.PRG
        Called from    REV_C_TO_N  
       
       
       
      Program/procedure name  SCRAM       
        Source in             SMICPROC.PRG
        Called from    SECURITY    
        Uses           _SCRAM      
       
       
       
      Program/procedure name  SECURITY    
        Source in             SECURITY.PRG
        Called from    TO          
        Uses           DISP_MSG    
                       NET_USE     
                       RECLOCK     
                       SCRAM       
                       SIMHEAD     
                       SMIC_N_TO_  
       
       
       
      Program/procedure name  SEEKFIN     
        Source in             SMICPROC.PRG
        Uses           ET_SEEK     
       
       
       
      Program/procedure name  SEEKSTD     
        Source in             SMICPROC.PRG
        Uses           ET_SEEK     
       
       
       
15/04/96                      E.T.'s UTILITIES                      page 7
 
                  ALPHABETIC LIST OF PROCEDURES AND FUNCTIONS
 
      Program/procedure name  SELFDEST    
        Source in             SELFDEST.PRG
        Called from    TO          
        Uses           NET_USE     
       
       
       
      Program/procedure name  SIMHEAD     
        Source in             SMICPROC.PRG
        Called from    ACCSHOW     
                       SECURITY    
       
       
       
      Program/procedure name  SMICPROC    
        Source in             SMICPROC.PRG
        Called from    TO          
       
       
       
      Program/procedure name  SMIC_C_TO_  
        Source in             SMICPROC.PRG
        Uses           SMIC_N_TO_  
       
       
       
      Program/procedure name  SMIC_N_TO_  
        Source in             SMICPROC.PRG
        Called from    SECURITY    
                       SMIC_C_TO_  
       
       
       
      Program/procedure name  STR_STAT    
        Source in             SMICPROC.PRG
       
       
       
      Program/procedure name  STR_TYPE    
        Source in             SMICPROC.PRG
       
       
       
15/04/96                      E.T.'s UTILITIES                      page 8
 
                  ALPHABETIC LIST OF PROCEDURES AND FUNCTIONS
 
      Program/procedure name  TO          
        Source in             PROCED.PRG  
        Uses           ANYLOOK     
                       FINDSTD     
                       HELP        
                       MOUSE       
                       PROCS       
                       SECURITY    
                       SELFDEST    
                       SMICPROC    
       
       
       
      Program/procedure name  _SCRAM      
        Source in                         
        Called from    SCRAM       
       
       
       




































                   ---   15/04/96   ---