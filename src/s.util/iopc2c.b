* R. DALEY ..... PACKAGE TO ALLOW RUNNING OF FILE SYSTEM OUTSIDE OF CTSS
       LINK    ON                                                       
       REM                                                              
       ENTRY   SETIO         TO INITIALIZE IOPAC AND FILE SYSTEM        
       ENTRY   DKEY          TO SUPER FUDGE                             
       ENTRY   GETIME        TO GET DATE AND TIME OF DAY                
       ENTRY   GETELT        TO GET ELAPSE TIME SINCE LAST CALL         
       ENTRY   TPWAIT        TO WAIT AND CHECK CHANNEL FLAGS            
       ENTRY   FERRTN        TO SET RETURN FOR UNDEFINED ERRORS         
       ENTRY   TILOCK        TO SET RETURN ON INTERLOCKED FILES         
       ENTRY   EXIT          TO UPDATE FILE SYSTEM AND TERMINATE        
       ENTRY   PRINT         TO PRINT ON ON-LINE PRINTER                
       ENTRY   PUNCH         TO PUNCH A CARD ON LINE                    
       ENTRY   EPRINT        TO PRINT A LINE DURING A TRAP              
       ENTRY   WRFLX         SYNONOMOUS WITH 'PRINT'                    
       ENTRY   WRTOPR        SYNONYMOUS WITH 'EPRINT'                   
       ENTRY   CMEXIT        TO RETURN TO INTERRUPTED PROGRAM           
       ENTRY   STZ.A)        SPECIAL REFERENCE FROM TAPE ADAPTER        
       ENTRY   FILXIT        TO RETURN TO CALLER OF FILE SYSTEM         
       ENTRY   ALLSAV        TO SAVE MACHINE CONDITIONS ON TRAP         
       ENTRY   ALLRST        TO RESTORE MACHINE CONDITIONS              
       ENTRY   ENABLE        POINTER ENTRY TO COMMON ENABLE WORD        
       REM                                                              
       EXTERN  BTOC,CTIME,PRNTER                                        
DEMKEY BOOL    75045         DAEMON KEY SETTING ***** COMMON SENSITIVE *
       REM                                                              
HITRAP BOOL    61            HIGHEST CHANNEL INTERRUPT LOCATION         
Z      TAPENO  A7            CHRONOLOG CLOCK SET AS TAPE A7             
DELAY  EQU     4500          9 MILLESECOND DELAY AFTER READING CHRONOLOG
CLOCK  EQU     5             INTERVAL TIMER AND INTERRUPT CLOCK         
CLKLOC EQU     6             ILC SVAED HERE ON CLOCK TRAP               
CLKTRP EQU     7             TRANSFER FROM HERE ON CLOCK TRAP           
ATRLOC EQU     10            ILC SAVED HERE ON CHANNEL 'A' TRAP         
ADCTRP EQU     11            TRANSFER FROM HERE ON CHANNEL 'A' TRAP     
BTRLOC EQU     12            ILC SAVED HERE ON CHANNEL 'B' TRAP         
BDCTRP EQU     13            TRANSFER FROM HERE ON CHANNEL 'B' TRAP     
B      EQU     0             MEMORY B SWITCH, ('0' FOR A, '1' FOR B)    
STBL   EQU     21+10*22      A.F.S.T. LENGTH, SPACE FOR 10 FILES        
1QL    EQU     1+9*10        DISK/DRUM QUEUE LENGTH                     
2QL    EQU     0             NULL QUEUE (DISK USES DRUM QUEUE)          
3QL    EQU     25            TAPE QUEUE LENGTH                          
       REM                                                              
OVLBGN MACRO                 MACRO USED AT BEGINNING OF SECTION         
       UNLIST                .. TO BE OVER WRITTEN                      
OVLORG SET     *             SAVE CURRENT LOCATION COUNTER              
OVLBGN END                                                              
       REM                                                              
OVLEND MACRO                 MACRO USED AT END OF SECTION               
       ORG     OVLORG        .. TO BE OVER WRITTEN                      
       LIST                  ..                                         
OVLEND END                                                              
       REM                                                              
WHEN   MACRO   A,TFIND,LOC,OP,ADDR,TAG,DECR    WHENEVER MACRO           
       IFF     1,TFIND,T                                                
       GENIF   A,0,0,LOC,OP,ADDR,TAG,DECR,                              
       IFF     1,TFIND,F                                                
       GENIF   A,0,1,LOC,OP,ADDR,TAG,DECR,                              
WHEN   END                                                              
       REM                                                              
GENIF  MACRO   IF1,IF2,IF3,LOC,OP,ADDR,TAG,DECR                         
       IFF     IF1,IF2,IF3                                              
       GENOP   LOC,OP,ADDR,TAG,DECR,                                    
GENIF  END                                                              
       REM                                                              
GENOP  MACRO   LOC,OP,ADDR,TAG,DECR    GENERATE OPERATION               
       PMC     ON                                                       
LOC    OP      ADDR,TAG,DECR                                            
       PMC     OFF                                                      
GENOP  END                                                              
       REM                                                              
       EJECT                                                            
       REM                                                              
       REM     SETIO ..... INITIALIZE FILE SYSTEM AND I/O PACKAGE       
       REM                                                              
SETIO  ENB     =0            ENTRY TO INITIALIZE IOPAC AND FILE SYSTEM  
       STL     ENBSW         INDICATE TO ALLSAV THAT TRAPS ARE LEGAL    
       LMTM                  INSURE 7-TAG (7094) MODE                   
       SXA     SETX1,1                                                  
       SXA     SETX2,2                                                  
       SXA     SETX4,4                                                  
       CAL*    1,4           PICK UP AUTHOR FROM CALLER                 
       SLW     AUTHOR        ..                                         
       CLA     1,4           CHECK IF TAPE STRATEGY NEEDED              
       TMI     FIRST         SKIP IF TAPE STRATEGY NOT NEEDED           
       CAL     =O3000003     OTHERWISE SET UP TRAPS FOR TAPE STRATEGY   
       ORS     ENABLE        ..                                         
       CAL     ENABLE        SET UP ENABLE FOR CHANNEL 'A' ONLY         
       ANA     =O1000001     ..                                         
       SLW     ENBIFA        .. ONLY IF CHANNEL 'A' ENABLED ALREADY     
       REM                                                              
FIRST  TRA     *+1           FIRST PASS SWITCH                          
       TSX     RDCLOC,4      READ CHRONOLOG CLOCK FIRST TIME ONLY       
       STL     FIRST         AND CLOSE THIS PATH                        
       RDCA                  RESET DATA CHANNEL 'A'                     
       RDCB                  RESET DATA CHANNEL 'B'                     
       REM                                                              
       WHEN    B,T,,OVLBGN,,,,,                                         
       REM                                                              
       AXT     HITRAP+1,4    SAVE FMS CONTROL LOCATIONS AND FMS CLOCK   
       CAL     HITRAP+1,4    ..                                         
       SLW     SAVFMS,4      ..                                         
       TIX     *-2,4,1       ..                                         
       REM                                                              
       WHEN    B,T,,OVLEND,,,,,                                         
       REM                                                              
       AXT     HITRAP+1,4    CLEAR OUT TRAP AND INTERRUPT LOCATIONS     
       WHEN    B,T,,SEA,,,,,                                            
       STZ     HITRAP+1,4    ..                                         
       TIX     *-1,4,1       ..                                         
       WHEN    B,T,,SEB,,,,,                                            
       CAL     CLKINT        SET FOR FOR INTERVAL TIMER CLOCK TRAP      
       LDQ     ATRAP         .. CHANNEL 'A' TRAP                        
       LDI     BTRAP         .. AND CHANNEL 'B' TRAP                    
       WHEN    B,T,,SEA,,,,,                                            
       SLW     CLKTRP        .. CLOCK TRAP                              
       STQ     ADCTRP        .. CHANNEL 'A' TRAP                        
       STI     BDCTRP        .. CHANNEL 'B' TRAP                        
       WHEN    B,T,,SEB,,,,,                                            
       REM                                                              
       REM     ..... INITIALIZE FILE I/O SYSTEM ........................
       REM                                                              
       TSX     $IOINIT,4     FILE SYSTEM INITIALIZATION ENTRY           
       PTH     IOERTN        .. ERROR RETURN                            
       PTH     DATEYR        .. TODAY'S DATE IN BCD                     
       PTH     TIMNOW        .. TIME OF DAY IN 60THS OF A SECOND        
       PTH     ENABLE        .. COMMON ENABLE WORD                      
       TSX     $CHNGUS,4     SET USER NO. 1 AS USER OF FILE SYSTEM      
       PTH     =1            ..                                         
       TSX     $USTAT,4      SET UP STORAGE FOR FILE SYSTEM             
       PTH     STATBL,,STBL  ..                                         
       PTH     QUEUE1,,1QL   ..                                         
       PTH     QUEUE2,,2QL   ..                                         
       PTH     QUEUE3,,3QL   ..                                         
       TSX     $SETRAP,4     SET UP SUPERVISOR INTERRUPT LOCATION       
       PTH     SSTRAP        ..                                         
       TSX     $SETUSR,4     SET UP USER OPTIONS                        
       PTH     =1            .. FOR USER NO. 1                          
       PTH     =O007010777777 .. UNRESTRICTED USER (DAEMON)             
       PTH     AUTHOR        .. AUTHOR FROM CALL TO SETIO               
       PTH     =O77777000000 .. PROTECTION LIMITS IF NEEDED             
       PTH     =0            .. ZERO RELOCATION                         
       PTH     =1            .. GIVE USER HIGHEST PRIORITY              
       TSX     $SETAB,4      SET ALL ENTRIES TO COME FROM 'HOME' MEMORY 
       PTH     HOME          ..                                         
       PTH     HOME          ..                                         
       PTH     HOME          ..                                         
       REM                                                              
       CAL     TIMNOW        COMPUTE ANY TIME WASTED IN INITIALIZATION  
       WHEN    B,T,,SEA,,,,,                                            
       ADM     CLOCK         ..                                         
       WHEN    B,T,,SEB,,,,,                                            
       SLW     TIMNOW        ..                                         
       REM                                                              
       TSX     STCLOC,4      START UP INTERVAL TIMER CLOCK NOW          
SETX1  AXT     **,1                                                     
SETX2  AXT     **,2                                                     
SETX4  AXT     **,4                                                     
       ENB     ENABLE        INSURE ALL TRAPS ENABLED                   
       TRA     2,4           AND RETURN                                 
       REM                                                              
       EJECT                                                            
       REM                                                              
       REM     STCLOC/CLKINT ....... BASIC CLOCK SECTION ...............
       REM                                                              
STCLOC CAL     CLKTIM        RESTART CLOCK TO RUN FOR CLKTIM            
       COM                   ..                                         
       ADD     =1            ..                                         
       WHEN    B,T,,SEA,,,,,                                            
       STO     CLOCK         .. NOTE 'P' BIT NOT STORED                 
       WHEN    B,T,,SEB,,,,,                                            
       TRA     1,4           ..                                         
       REM                                                              
       WHEN    B,F,CLKINT,TTR,*+1,,,,                                   
       WHEN    B,T,CLKINT,TIB,*+1,,,,                                   
       REM                                                              
       WHEN    B,T,,SEB,,,,,                                            
       REM                                                              
       ENB     =0            HERE ON ALL INTERVAL TIMER 'CLOCK' TRAPS   
       SXA     TRPIR4,4      SAVE IR4                                   
       TSX     ALLSAV,4      AND REST OF MACHINE CONDITIONS             
       WHEN    B,T,,SEA,,,,, PICK UP TRAP FLAGS                         
       CAL     CLKLOC        ..                                         
       WHEN    B,T,,SEB,,,,, ..                                         
       SLW     RTNLOC        ..                                         
       ENK                   PICK UP CONSOLE KEYS                       
       STQ     CLKEYS        SAVE KEYS                                  
       LDI     CLKEYS        KEYS TO SI                                 
       RNT     40000         IS KEY '21' DOWN                           
       TRA     KEYSUP        NO, SKIP                                   
       ZET     KEYSW         YES, IS THIS A PREVIOUS REQUEST            
       TRA     SKPKEY        YES, IGNORE REDUNDANT REQUEST              
       STL     KEYSW         NO, SERVICE NEW KEY REQUEST                
       TSX     BTOC,4        CONVERT LEFT-HALF MQ TO BCD                
       SLW     KREAD+2       ..                                         
       TSX     BTOC,4        RIGHT-HALF                                 
       SLW     KREAD+3       ..                                         
       TSX     EPRINT,4      PRINT MESSAGE                              
       PON     KREAD,,4      (DOUBLE SPACE)                             
       CAL     CLKEYS        KEYS TO AC                                 
       ANA     =O7777        IGNORE ALL BUT KEYS 24-35                  
       PAX     0,4           23-35 TO IR4                               
       TNX     BADKEY,4,6    IGNORE FMS KEY SETTINGS (0-6)              
       TNX     KEYSOK,4,4    SKIP IF KEYS SET FOR TAPE STRATEGY MODULE  
       TNX     BADKEY,4,5    TEST FOR ILLEGAL KEY SETTING               
       TNX     DKEY,4,8       TEST FOR DAEMON KEY                       
BADKEY TSX     EPRINT,4      PRINT 'ILLEGAL KEY SETTING, TRY AGAIN.'    
               KEYSNG,,8     ..                                         
       TRA     SKPKEY                                                   
       REM                                                              
KEYSOK SXA     CLKEYS,4      SAVE KEY SETTING FOR TAPE STRATEGY MODULE  
       TSX     EPRINT,4      PRINT '****** PLEASE PUT KEY 21 UP ******' 
               PP21UP,,6     ..                                         
       TSX     $TAPKEY,4     CALL TAPE STRATEGY MODULE                  
       PTH     CLKEYS        .. WITH KEY SETTING                        
       TRA     SKPKEY                                                   
       REM                                                              
DKEY   SXA     DEMKEY,4       SAVE DAEMON KEY SETTING                   
       TSX     EPRINT,4       SAVE KEY '21' BACK UP                     
               PP21UP,,6      ..                                        
       TRA     SKPKEY         EXIT                                      
       REM                                                              
KEYSUP STZ     KEYSW         HERE IF KEY 21 UP, RESET SWITCH            
       REM                                                              
SKPKEY TSX     ADDTIM,4      UPDATE TIME COUNTERS                       
       CAL     TOTTIM        UPDATE TOTAL TIME SYSTEM HAS RUN           
       ADD     CLKTIM        ..                                         
       WHEN    B,T,,SEA,,,,,                                            
       ADM     CLOCK         ..                                         
       WHEN    B,T,,SEB,,,,,                                            
       SLW     TOTTIM        ..                                         
       TSX     STCLOC,4      RESTART INTERVAL TIMER FOR 'CLKTIM'        
       TSX     ALLRST,4      RESTORE USER'S MACHINE CONDITIONS          
       TSX     CMEXIT,4      AND RETURN TO INTERRUPTED PROGRAM          
       LXA     TRPIR4,4      ..                                         
               RTNLOC        ..                                         
       REM                                                              
*  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  
       REM                                                              
       REM     ... ATRAP/BTRAP ... RECORD TRAPS FROM CHANNELS A AND B ..
       REM                                                              
       WHEN    B,F,ATRAP,TTR,*+1,,,,                                    
       WHEN    B,T,ATRAP,TIB,*+1,,,,                                    
       REM                                                              
       WHEN    B,T,,SEB,,,,,                                            
       REM                                                              
       ENB     =0            HERE FOR TRAP FROM CHANNEL 'A'             
       SXA     TRPIR4,4      SAVE IR4                                   
       TSX     ALLSAV,4      AND REST OF MACHINE CONDITIONS             
       WHEN    B,T,,SEA,,,,, PICK UP TRAP FLAGS                         
       CAL     ATRLOC        ..                                         
       WHEN    B,T,,SEB,,,,, ..                                         
       SLW     RTNLOC        ..                                         
ATRAP1 TSX     $TRAPA,4      GIVE TRAP TO TAPE I/O ADAPTER              
       PTH     RTNLOC        ..                                         
       TRA     IGNTRP        SKIP IF TRAP TAKEN BY ADAPTER              
       AXC     1,1           POINTER TO TRAP FLAGS FOR CHANNEL A        
       TRA     RECTRP        AND RECORD THIS TRAP                       
       REM                                                              
       WHEN    B,F,BTRAP,TTR,*+1,,,,                                    
       WHEN    B,T,BTRAP,TIB,*+1,,,,                                    
       REM                                                              
       WHEN    B,T,,SEB,,,,,                                            
       REM                                                              
       ENB     =0            HERE FOR TRAP FROM CHANNEL 'B'             
       SXA     TRPIR4,4      SAVE IR4                                   
       TSX     ALLSAV,4      AND REST OF MACHINE CONDITIONS             
       WHEN    B,T,,SEA,,,,, PICK UP TRAP FLAGS                         
       CAL     BTRLOC        ..                                         
       WHEN    B,T,,SEB,,,,, ..                                         
       SLW     RTNLOC        ..                                         
       TSX     $TRAPB,4      GIVE TRAP TO TAPE I/O ADAPTER              
       PTH     RTNLOC        ..                                         
       TRA     IGNTRP        SKIP IF TRAP TAKEN BY ADAPTER              
       AXC     2,1           POINTER TO TRAP FLAGS FOR CHANNEL B        
       REM                                                              
RECTRP CAL     RTNLOC        RECORD TRAP FLAGS FOR 'TPWAIT'             
       ORS     TPFLAG,1      ..                                         
IGNTRP TSX     ALLRST,4      RESTORE USER'S MACHINE CONDITIONS          
       TSX     CMEXIT,4      RETURN TO INTERRUPTED PROGRAM              
       LXA     TRPIR4,4      ..                                         
               RTNLOC        ..                                         
       REM                                                              
       EJECT                                                            
       REM                                                              
       REM     ... GETIME ... RETURN TIME OF DAY IN LAC AND DATE IN MQ .
       REM                                                              
GETIME SXA     *+2,4                                                    
       TSX     ADDTIM,4      COMPUTE TIME TO NEAREST 60TH OF A SECOND   
       AXT     **,4                                                     
       CAL     TIMNOW        RETURN TIME OF DAY IN LOGICAL AC           
       LDQ     DATEYR        AND DATE IN MQ                             
       ENB     ENABLE        REENABLE                                   
       TRA     1,4           AND RETURN                                 
       REM                                                              
*  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  
       REM                                                              
       REM     ... GETELT ... RETURN ELAPSE TIME IN LOGICAL AC ........ 
       REM                                                              
GETELT SXA     *+2,4                                                    
       TSX     ADDTIM,4      COMPUTE TIME TO NEAREST 60TH OF A SECOND   
       AXT     **,4                                                     
       CAL     ELAPSE        RETURN ELAPSE TIME IN LOGICAL AC           
       STZ     ELAPSE        AND RESET ELAPSE TIME                      
       ENB     ENABLE        REENABLE                                   
       TRA     1,4           AND RETURN                                 
       REM                                                              
*  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  
       REM                                                              
       REM     ... TPWAIT ... WAIT ON CHANNEL AND CHECK FLAGS ..........
       REM                                                              
TPWAIT SXA     TWATX4,4                                                 
       CAL     1,4           PZE CHANNO                                 
       PAC     0,4           -CHANNEL NO. TO IR4                        
       ENB     ENABLE        INSURE ALL CHANNELS ENABLED                
       STL     TCOAB,4       WAIT ON CHANNEL                            
       XEC     TCOAB,4       ..                                         
       NOP                   INSURE ALL TRAPS TAKEN                     
       LDI     TPFLAG,4      PICK UP CHANNEL STATUS FLAGS               
       STZ     TPFLAG,4      .. AND RESET THEM                          
TWATX4 AXT     **,4          RESTORE CALLER'S IR4                       
       LFT     2             WAS REDUNDANCY CHECK FLAG ON               
       TRA     2,4           YES, TAKE TAPE CHECK EXIT (2,4)            
       LFT     4             NO, WAS EOF FLAG ON                        
       TRA     3,4           YES, TAKE EOF EXIT (3,4)                   
       TRA     4,4           NO, TAKE NORMAL EXIT (4,4)                 
       REM                                                              
       EJECT                                                            
       REM                                                              
       REM     ... FERRTN ... SET RETURN FOR UNDEFINED ERRORS           
       REM                                                              
FERRTN CAL     1,4           ERROR RETURN LOCATION (PZE RTNLOC)         
       STA     FERTN         SAVE IT                                    
       TRA     2,4           AND RETURN                                 
       REM                                                              
IOERTN ZET     FERTN         HERE FOR ERROR RETURN FROM FILE SYSTEM     
       TRA*    FERTN         TAKE USER EXIT IF SPECIFIED                
       TSX     PRNTER,4      OTHERWISE, PRINT FILE SYSTEM ERROR MESSAGE 
       TSX     PRINT,4       PRINT 'NO ERROR RETURN SPECIFIED'          
               NOERTN,,5     ..                                         
       TRA     EXIT          AND EXIT                                   
       REM                                                              
*  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  
       REM                                                              
       REM     ... TILOCK ... SET RETURN ON INTERLOCKED FILES           
       REM                                                              
TILOCK CAL     1,4           INTERLOCK RETURN LOCATION (PZE RTNLOC)     
       STA     UILOCK        SAVE IT                                    
       TRA     2,4           AND RETURN                                 
       REM                                                              
SSTRAP ENB     =0            HERE ON INTERRUPT FROM FILE SYSTEM         
       CAL*    3,4           PICK UP USER'S IR4 FROM CALL               
       STA     SSTIR4        SAVE USER'S IR4                            
       CAL*    2,4           PICK UP INTERRUPT CODE (1-6)               
       PAX     0,5           INTO IR5                                   
       TXL     IGNINT,5,3    IGNORE CODES 1-3                           
       TXL     FILOCK,5,4    SKIP ON FILE INTERLOCKED (CODE 4)          
       TRA     IGNINT        IGNORE ALL OTHER INTERRUPT CODES           
       REM                                                              
FILOCK NZT     UILOCK        HAS USER SPECIFIED INTERLOCKED RETURN      
       TRA     IGNINT        NO, IGNORE INTERRUPT                       
SSTIR4 AXT     **,4          YES, RESTORE USER'S IR4                    
       ENB     ENABLE        RE-ENABLE ALL TRAPS                        
       TRA*    UILOCK        AND TAKE USER INTERLOCKED RETURN           
       REM                                                              
IGNINT TRA     6,4           HERE TO IGNORE INTERRUPT FROM FILE SYS.    
       REM                                                              
       EJECT                                                            
       REM                                                              
       REM     ... EXIT ... TERMINATION ROUTINE, EXIT TO FMS OR STOP ...
       REM                                                              
EXIT   TSX     $IOFINI,4     INSURE FILE SYSTEM UPDATED                 
       PTH     *+1           .. IGNORE ERROR RETURN                     
       TSX     PRINT,4       PRINT MESSAGE                              
       PON     EXITMS,,2     ..                                         
       ENB     =0            DISABLE ALL TRAPS                          
       TCOA    *             WAIT UNTIL ALL CHANNEL ACTIVITY CEASES     
       TCOB    *             ..                                         
       RDCA                  AND RESET CHANNELS A,                      
       RDCB                  .. AND B                                   
       REM                                                              
       WHEN    B,T,,OVLBGN,,,,,                                         
       REM                                                              
       AXT     HITRAP+1,4    RESTORE FMS LOWER CORE                     
       CAL     SAVFMS,4      ..                                         
       SLW     HITRAP+1,4    ..                                         
       TIX     *-2,4,1       ..                                         
       REM                                                              
       AXT     10,4          RELOAD FMS FROM A1                         
EXIT1  REWA    1             ..                                         
       RTBA    1             ..                                         
       RCHA    LDFIOP        ..                                         
       TCOA    *             ..                                         
       TRCA    A1BAD         ..                                         
       TEFA    A1BAD         ..                                         
       RTBA    1             .. SKIP CARD TO TAPE RECORD                
       RTBA    1             .. SKIP DUMP RECORD                        
       TRA     1             EXIT TO FIOP TO LOAD SIGN-ON RECORD        
       REM                                                              
A1BAD  TIX     EXIT1,4,1     COUNT ERRORS                               
       HTR     EXIT1         STOP ON TOO MANY ERRORS                    
       REM                                                              
       WHEN    B,T,,OVLEND,,,,,                                         
       REM                                                              
       WHEN    B,T,,HTR,*,,,,                                           
       REM                                                              
       EJECT                                                            
       REM                                                              
       REM     .. PRINT/PUNCH/EPRINT .. ON LINE PRINT AND PUNCH ROUTINES
       REM                                                              
WRFLX  SYN     *             SIMULATED TYPEWRITER                       
PRINT  ENB     =0            DISABLE ALL TRAPS                          
       STL     PRSW          ROUTINE TO PRINT ON LINE                   
       TRA     PUNCH+2       ..                                         
       REM                                                              
PUNCH  ENB     =0            DISABLE ALL TRAPS                          
       STZ     PRSW          ROUTINE TO PUNCH CARD ON LINE              
       SXA     PRPUX4,4      SAVE IR4 FROM CALL TO 'PRINT' OR 'PUNCH'   
       LDQ     1,4           PICK UP USER CALLING SEQUENCE              
       STQ     *+2           SET IN CALL                                
       TSX     WPRPU,4       CALL PRINT/PUNCH ROUTINE                   
               **,,**        ..                                         
       TSX     CHKCHA,4      CHECK FOR LOST TRAP ON CHANNEL 'A'         
       ENB     ENABLE        RE-ENABLE                                  
PRPUX4 AXT     **,4          RESTORE USER'S IR4                         
       TRA     2,4           AND RETURN                                 
       REM                                                              
WRTOPR SYN     *             USED BY DDIOA IN LIEU OF EPRINT            
EPRINT ENB     =0            DISABLE ALL TRAPS                          
       STL     PRSW          ROUTINE TO PRINT DURING ANY TRAP           
       REM                                                              
WPRPU  SXA     PRX1,1        SAVE XRS.                                  
       SXA     PRX2,2        ..                                         
       SXA     PRX4,4        ..                                         
       TSX     SAVCHA,4      DISABLE AND SAVE CHANNEL 'A'               
       LXA     PRX4,4        RELOAD CALLER'S XR4.                       
       CAL     1,4           PZE FIRST,,N                               
       PDX     ,2            GET WORD COUNT                             
       PXA     ,2            ..                                         
       ACL     1,4           BES LOCATION OF USER DATA                  
       STA     PRPU.2        FOR WORD PICKUP.                           
       NZT     PRSW          IF CALL IS FOR PUNCH,                      
       TRA     PRPU.1        SKIP SENSE INSTRUCTION SETUP               
       ARS     15            ELSE, PREFIX TO X7                         
       PDC     ,7            ..                                         
       CAL     SPRTBL,7      PICK UP USER REQUESTED SPRA                
       SLW     SPRA          SAVE                                       
       SLW     SPRX          THERE ALSO IN CASE BLANK LINE              
       REM                                                              
PRPU.1 AXT     48,7          CLEAR CARD IMAGE BUFFER                    
       STZ     CBUF2+48,7    ..                                         
       TIX     *-1,7,1       ..                                         
       CAL     =-0           INITIALIZE COLUMN MARKER TO FIRST COLUMN   
       SLW     PRCOL         ..                                         
       AXT     1,4           INITIALIZE CHARACTER COUNT                 
       AXT     1,5           START ON RIGHT HALF                        
       AXT     1,6           OF FIRST BUFFER                            
       TXL     DONE,2,0      SKIP FOR ZERO WORD COUNT.                  
       STZ     DONESW        INDICATE THERE IS MORE PRINTING TO DO      
       REM                                                              
PRPU.2 LDQ     -,2           LOAD FIRST OR NEXT USER DATA WORD          
       AXT     6,1           SIX CHARACTERS PER WORD                    
PRPU.3 ZAC                                                              
       LGL     6             CHARACTER TO AC                            
       STQ     MQ.T          SAVE PARTIAL MQ CONTENTS                   
       LGR     1             DIVIDE BY 2, SAVE REMAINDER                
       PAC     ,7            TABLE POSITION FOR CHARACTER               
       CAL     CHRTB,7       GET PUNCH CONFIGURATION FOR THIS           
       TQP     *+2           CHARACTER                                  
       ARS     18            TO ADDRESS                                 
       PAI                   ..                                         
       PAC     ,7            TRANSFER ADDRESS IF CONTROL CHAR.          
       RFT     100000        TEST FOR SPECIAL CHARACTER                 
       TRA     0,7           YES, GO PROCESS SPECIAL CHARACTER          
       LGR     12            ORDINARY CHARACTER, PUNCHES TO MQ          
       CAL     PRCOL         PICKUP COLUMN MARKER                       
       AXT     24,7          24 WORD CARD IMAGE BUFFER, EVERY           
       TQP     *+2           IF BIT IS OFF, IGNORE.                     
       XEC     ORINBT,5      ELSE, ADD PUNCH TO PROPER BUFFER.          
       RQL     1             ONWARD TO NEXT ROW OF CARD THIS COLUMN     
       TIX     *-3,7,2       ..                                         
       ARS     1             MOVE COLUMN MARKER TO NEXT COLUMN          
       TXI     *+1,4,1       INCREMENT WORD COUNT                       
       TXH     DONE,4,120    SEE IF OUT OF BOUNDS                       
       TNZ     PRPU.4        IF DONE WITH HALF OF CARD,                 
       CAL     =-0           REINITIALIZE COLUMN MARKER                 
       TXI     *+1,5,1       INDICATE ON NEXT HALF OF CARD              
       TIX     PRPU.5,5,2    IF TWO HALVES DONE, GO PRINT BUFFER OUT    
PRPU.4 SLW     PRCOL         SAVE COLUMN MARKER FOR NEXT CHARACTER      
SKP    LDQ     MQ.T          RESTORE PARTIAL MQ. ENTER HERE TO IGNORE   
       TIX     PRPU.3,1,1    GO GET NEXT CHARACTER                      
       TIX     PRPU.2,2,1    WORD EXHAUSTED, GO GET NEXT WORD           
DONE   STL     DONESW        FINISHED, INDICATE LAST BUFFER TO PRINT.   
PRPU.5 ZET     PRSW          ARE WE PRINTING OR PUNCHING. Q             
       TRA     PRNT.1        WE ARE PRINTING, GO TO PRINT ROUTINE       
       WPUA                  HERE TO PUNCH CARD.                        
       RCHA    PUCOM         START CHANNEL                              
       TRA     PEND          AND SKIP TO EXIT AFTER ONE CARD.           
PRNT.1 AXT     24,7          HERE TO PRINT PARTIAL LINE.                
       ZET*    CARD,6        SEE IF BUFFER ALL BLANK                    
       TRA     PNOW          NON-ZERO WORD FOUND, GO PRINT.             
       TIX     *-2,7,1       ..                                         
       TXH     PEND,6,1      HAVE WE PRINTED ANYTHING ON THIS LINE      
       WPRA                  NO, SELECT PRINTER                         
SPRX   SPRA    **            USER REQUESTED SPRA                        
       RCHA    IOCD          AND DISCONNECT CHANNEL                     
       TRA     PRT2.2        SKIP                                       
PNOW   WPRA                  SELECT PRINTER ON CHANNEL 'A'              
SPRA   SPRA    **            USER REQUESTED SPRA OR SPRA 9.             
       RCHA*   PRCOM,6       START UP CHANNEL ON RIGHT BUFFER           
PRT2.2 ZET     DONESW        IS THERE MORE TO DO. Q                     
       TRA     PEND          NO, SKIP TO END                            
       CAL     SPRA9         YES, SET UP TO PRINT RIGHT HALF LINE       
       SLW     SPRA          ..                                         
       CAL     =-0           RESET COLUMN MARKER                        
       TXI     PRPU.4,6,1    AND RE-ENTER ROUTINE                       
       REM                                                              
PEND   TSX     RSTCHA,4      HERE WHEN DONE, RESTORE CHANNEL 'A'        
PRX1   AXT     -,1           RESTORE XRS                                
PRX2   AXT     -,2           ..                                         
PRX4   AXT     -,4           ..                                         
       TRA     2,4           RETURN TO CALLER.                          
       REM                                                              
       REM                                                              
       PZE     PRCM2         CHANNEL COMMANDS FOR SECOND BUFFER         
       PZE     PRCM1         .. FOR FIRST BUFFER                        
PRCOM  SYN     *             ..                                         
       REM                                                              
PRCM1  IOSP    CBUF1,B,24    WHEN PRINTING, THIS SEQUENCE DISCONNECTS   
IOCD   IOCD    0,,0          13 MS. FASTER THAN IOCD                    
PRCM2  IOSP    CBUF2,B,24    ..                                         
       IOCD    0,,0          ..                                         
       REM                                                              
PUCOM  SYN     PRCM1         DISCONNECTS 25 MS FASTER THAN IOCD         
       REM                                                              
       ORS*    CARD+2,6      TO ADD PUNCH INTO RIGHT HALF CARD          
       ORS*    CARD,6        .. LEFT HALF CARD                          
ORINBT SYN     *             ' XEC ORINBT,5 '                           
       REM                                                              
       PZE     CBUF2+24,7    RIGHT HALF LINE                            
       PZE     CBUF1+24,7    LEFT HALF LINE                             
CARD   SYN     *             .. 'ORS* CARD,6'                           
       PZE     CBUF2+25,7    FOR RIGHT HALF CARD COL 37-72              
       PZE     CBUF1+25,7    ..                                         
       REM                                                              
CBUF2  BSS     24            PRINT BUFFER 2                             
CBUF1  BSS     24            PRINT BUFFER 1, PUNCH BUFFER               
       REM                                                              
PRSW   PZE     -1            PRINT/PUNCH SWITCH                         
DONESW PZE                   NON-ZERO IF CONTENTS OF BUFFER IS LAST     
MQ.T   PZE                   STORAGE FOR PARTIAL MQ DURING CONVERSION   
       REM                                                              
SPRTBL SYN     *             TABLE OF VALID SPR'S                       
NOP    NOP                   (PZE)  SINGLE SPACE                        
       SPRA    1             (PON)  NEW PAGE                            
       SPRA    2             (PTW)  HALF-PAGE SKIP                      
SPRA9  SPRA    9             (PTH)  PRINT RIGHT-HALF LINE               
       NOP                   (MZE)  SINGLE SPACE                        
       NOP                   (MON)  SINGLE SPACE                        
       SPRA    4             (MTW)  DOUBLE SPACE                        
       NOP                   (MTH)  SINGLE SPACE                        
       REM                                                              
P12    BOOL    1             BIT FOR 12-PUNCH                           
P11    BOOL    2                     11-PUNCH                           
P0     BOOL    4                      0-PUNCH                           
P1     BOOL    10                     1-PUNCH                           
P2     BOOL    20                     2-PUNCH                           
P3     BOOL    40                     3-PUNCH                           
P4     BOOL    100                    4-PUNCH                           
P5     BOOL    200                    5-PUNCH                           
P6     BOOL    400                    6-PUNCH                           
P7     BOOL    1000                   7-PUNCH                           
P8     BOOL    2000                   8-PUNCH                           
P9     BOOL    4000                   9-PUNCH                           
       REM                                                              
CHRTB  SYN     *             CONVERSION TABLE FOR CHARACTERS            
       PZE     P0,,P1        DIGITS 0, 1                                
       PZE     P2,,P3        2, 3                                       
       PZE     P4,,P5        4, 5                                       
       PZE     P6,,P7        6, 7                                       
       PZE     P8,,P9        8, 9                                       
       PZE     SKP,1,P8+P3   ILL., =                                    
       PON     P8+P4,,SKP    ', ILL.                                    
       PON     SKP,1,SKP     ILL, ILL.                                  
       PZE     P12,,P12+P1   +, A                                       
       PZE     P12+P2,,P12+P3 B, C                                      
       PZE     P12+P4,,P12+P5 D, E                                      
       PZE     P12+P6,,P12+P7 F, G                                      
       PZE     P12+P8,,P12+P9 H, I                                      
       PZE     SKP,1,P12+P8+P3 ILL., '.'                                
       PZE     P12+P8+P4,,P12+P8+P3 ), COLON (USE .)                    
       PON     SKP,1,SKP     ILL., ILL.                                 
       PZE     P11,,P11+P1   -, J                                       
       PZE     P11+P2,,P11+P3 K, L                                      
       PZE     P11+P4,,P11+P5 M, N                                      
       PZE     P11+P6,,P11+P7 O, P                                      
       PZE     P11+P8,,P11+P9 Q, R                                      
       PZE     SKP,1,P11+P8+P3 ILL., $                                  
       PON     P11+P8+P4,,SKP *, ILL.                                   
       PON     SKP,1,SKP     ILL., NULL                                 
       PZE     0,,P0+P1      BLANK, /                                   
       PZE     P0+P2,,P0+P3  S, T                                       
       PZE     P0+P4,,P0+P5  U, V                                       
       PZE     P0+P6,,P0+P7  W, X                                       
       PZE     P0+P8,,P0+P9  Y, Z                                       
       PZE     SKP,1,P0+P8+P3 TAB, ','                                  
       PON     P0+P8+P4,,SKP (, ILL.                                    
       PON     SKP,1,SKP     ILL., ILL.                                 
       REM                                                              
       EJECT                                                            
       REM                                                              
       REM     ... CMEXIT ... COMMON EXIT ROUTINE FROM ALL TRAPS .......
       REM                                                              
CMEXIT ENB     =0            INSURE ALL TRAPS DISABLED                  
       STI     CMXSI         SAVE INDICATORS                            
       LDI*    2,4           PICK UP RETURN FLAGS                       
       RIR     700000        INSURE TAG ZERO                            
       STI     CMXRTN        SAVE RETURN LOCATION                       
       XEC     1,4           RESTORE USER'S IR4 FROM 1,4                
       ZET     ATLOST        WAS A TRAP ON CHANNEL 'A' LOST             
       TRA     SIMTRP        YES, GO TO SIMULATE LOST TRAP              
       LFT     20000         NO, WAS ECC SET FOR MEMORY 'A'             
       TRA     CMRTNB        NO, SET ECC TO MEMORY 'B'                  
       LDI     CMXSI         YES, RELOAD INDICATORS                     
       ENB     ENABLE        AND RETURN TO INTERRUPTED PROGRAM          
       WHEN    B,T,,LRI,=0,,,,  ..                                      
       WHEN    B,T,,SEA,,,,, ..                                         
       TRA*    CMXRTN        ..                                         
       REM                                                              
CMRTNB LDI     CMXSI         HERE TO RETURN WITH ECC SET FOR MEMORY 'B' 
       ENB     ENABLE        RETURN TO INTERRUPTED PROGRAM              
       WHEN    B,F,,LRI,=0,,,,  ..                                      
       WHEN    B,F,,SEB,,,,, ..                                         
       TRA*    CMXRTN        ..                                         
       REM                                                              
SIMTRP RIL     717777        HERE TO SIMULATE LOST TRAP ON CHANNEL 'A'  
       STI     RTNLOC        SET UP RETURN LOC. WITH ECC AND ICC FLAGS  
       LDI     CMXSI         RELOAD USER'S SENSE INDICATORS             
       SXA     TRPIR4,4      AND INSURE USER'S MACHINE CONDITIONS SAVED 
       TSX     ALLSAV,4      ..                                         
       CAL     ATLOST        PICK UP FLAGS FROM LOST TRAP               
       ANA     =O7000000     SAVE BITS 15-17                            
       ORS     RTNLOC        COMPLETE TRAP FLAGS IN 'RTNLOC'            
STZ.A) STZ     ATLOST        RESET LOST TRAP CONDITION                  
       TRA     ATRAP1        AND SIMULATE TRAP ON CHANNEL 'A'           
       REM                                                              
*  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  
       REM                                                              
       REM     ... FILXIT ... EXIT TO USER FROM FILE SYSTEM .....       
       REM                                                              
FILXIT CAL*    2,4           PICK UP RETURN ADDRESS                     
       PAC     0,5           .. -RETURN ADDRESS TO IR5                  
       XEC     1,4           RELOAD USER'S IR4                          
       ENB     ENABLE        RE-ENABLE ALL TRAPS                        
       TRA     0,5           AND RETURN TO USER                         
       REM                                                              
       EJECT                                                            
       REM                                                              
       REM     ... ALLSAV ... SAVE BASIC MACHINE CONDITIONS ............
       REM                                                              
ALLSAV ENB     =0            INSURE NO TRAPS COME NOW.                  
       NZT     ENBSW         HAVE WE TAKEN A PREVIOUS TRAP.             
       HTR     *             YES, STOP AND TAKE A DUMP.                 
       STZ     ENBSW         NO, INDICATE WE ARE IN TRAP TIME.          
       SXA     ALLXR4,4      SAVE NAME OF THIS CALLER                   
       SXA     TRPIR1,1      SAVE BASIC MACHINE CONDITIONS.             
       SXA     TRPIR2,2      ..                                         
       SXA     TRPIR3,3      ..                                         
       AXT     0,3           .. SAVE TAG MODE                           
       AXT     1,1           ..                                         
       STZ     TRPMTM        ..                                         
       TXL     7TAG,3,0      .. SKIP IF IN 7-TAG (7094) MODE            
       STL     TRPMTM        .. OTHERWISE SET 3-TAG (7090) MODE         
       LMTM                  ..                                         
       SXA     TRPIR3,3      .. RESAVE IR3                              
7TAG   SXA     TRPIR5,5      ..                                         
       SXA     TRPIR6,6      ..                                         
       SXA     TRPIR7,7      ..                                         
       STI     TRPSI         .. SAVE SENSE INDICATORS                   
       STQ     TRPMQ         .. MQ                                      
       SLW     TRPLAC        .. LOGICAL AC                              
       ARS     2             ..                                         
       STO     TRPSQ         .. S AND Q BITS                            
       STZ     TRPOV         .. AC OVERFLOW CONDITION                   
       TNO     *+2           ..                                         
       STL     TRPOV         ..                                         
       TRA     1,4           AND RETURN                                 
       REM                                                              
*  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  
       REM                                                              
ALLXR4 PZE     **,,**        X4(ALLSAV,,ALLRST)                         
       REM                                                              
*  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  
       REM                                                              
       REM     ... ALLRST ... RESTORE BASIC MACHINE CONDITIONS .........
       REM                                                              
ALLRST ENB     =0            INSURE NO TRAPS ON TOP OF STOP.            
       ZET     ENBSW         ARE WE CALLED AT TRAP TIME.                
       HTR     *             NO, STOP AND TAKE DUMP.                    
       STL     ENBSW         YES, INDICATE WE ARE LEAVING TRAP TIME.    
       LMTM                  INSURE 7-TAG (7094) MODE                   
       SXD     ALLXR4,4      SAVE X4 OF CALLER FOR DEBUGGING            
TRPIR1 AXT     **,1          ..                                         
TRPIR2 AXT     **,2          ..                                         
TRPIR3 AXT     **,3          ..                                         
TRPIR5 AXT     **,5          ..                                         
TRPIR6 AXT     **,6          ..                                         
TRPIR7 AXT     **,7          ..                                         
       ZET     TRPMTM        .. RESTORE TAG MODE                        
       EMTM                  ..                                         
       LDQ     TRPSQ         .. RESTORE S AND Q BITS                    
       CLA     *             .. AND INSURE OVERFLOW LIGHT IS ON         
       LLS     1             ..                                         
       ALS     36            ..                                         
       ORA     TRPLAC        .. RESTORE LOGICAL AC                      
       LDQ     TRPMQ         .. RESTORE MQ                              
       LDI     TRPSI         .. RESTORE SI                              
       NZT     TRPOV         .. RESTORE CORRECT OVERFLOW STATUS         
       TOV     *+1           ..                                         
       TRA     1,4           AND RETURN                                 
       REM                                                              
ENBSW  PZE     **            SWITCH ON DURING ENABLE TIME.              
       EJECT                                                            
       REM     ... SAVCHA/RSTCHA/CHKCHA ... SAVE RESTORE AND CHECK 'A'  
       REM                                                              
SAVCHA ENB     =0            SAVE STATUS OF CHANNEL 'A'                 
       ZET     ATLOST        HAVE WE LOST A TRAP ALREADY                
       TRA     SVCHA2        YES, SKIP                                  
       CAL     TSTRAP        NO, SET UP TO CHECK FOR TRAP ON CHANNEL 'A'
       WHEN    B,T,,SEA,,,,, SAVE CHANNEL 'A' TRAP INSTRUCTION          
       LDI     ADCTRP        ..                                         
       SLW     ADCTRP        .. AND SUBSTITUTE NEW TRAP INSTRUCTION     
       WHEN    B,T,,SEB,,,,, ..                                         
       ENB     ENBIFA        ENABLE IF ENABLE CONTAINS CHANNEL 'A' BITS 
       TCOA    *             AND WAIT                                   
       TRA     SVCHA1        GO RESTORE TRAP INSTRUCTION IF NO TRAP     
       REM                                                              
       WHEN    B,F,TSTRAP,TTR,*+1,,,,                                   
       WHEN    B,T,TSTRAP,TIB,*+1,,,,                                   
       REM                                                              
       CAL     ATRLOC        PICK UP FLAGS FROM TRAP ON CHANNEL 'A'     
       WHEN    B,T,,SEB,,,,, ..                                         
       SLW     ATLOST        SET FLAGS FOR LOST TRAP                    
SVCHA1 ENB     =0            DISABLE ALL TRAPS                          
       WHEN    B,T,,SEA,,,,, RESTORE PREVIOUS TRAP INSTRUCTION          
       STI     ADCTRP        ..                                         
       WHEN    B,T,,SEB,,,,, ..                                         
       REM                                                              
SVCHA2 SCHA    SVCHAN        SAVE CHANNEL 'A' REGISTERS                 
       STZ     SVIOCK        AND I/O CHECK CONDITION                    
       IOT                   ..                                         
       STL     SVIOCK        ..                                         
       TRA     1,4           AND RETURN                                 
       REM                                                              
RSTCHA SXA     RSTCX4,4      RESTORE CHANNEL STATUS                     
       TCOA    *             WAIT UNTIL CHANNEL IS FREE                 
       CAL     SVCHAN        PICK UP PREVIOUS CHANNEL STATUS            
       PDC     0,4           -LOCATION COUNTER TO IR4                   
       ANA     =O700000377777  RESTORE CHANNEL 'A' REGISTERS            
       LDQ     -1,4          ..                                         
       SLW     -1,4          ..                                         
       RCHA    -1,4          ..                                         
       STQ     -1,4          ..                                         
       NZT     SVIOCK        RESTORE PREVIOUS CONDITIONS OF I/O CHECK   
       IOT                   ..                                         
       NOP                   .. FOR SAFETY ONLY (IOT SHOULD BE ON)      
       CAL     FORGET        SET UP TO LOOSE ANY TRAP ON CHANNEL 'A'    
       WHEN    B,T,,SEA,,,,, SAVE CHANNEL 'A' TRAP INSTRUCTION          
       LDI     ADCTRP        ..                                         
       SLW     ADCTRP        .. SUBSTITUTE NEW TRAP INSTRUCTION         
       WHEN    B,T,,SEB,,,,, ..                                         
       ENB     ENBIFA        ENABLE IF ENABLE CONTAINS CHAN. 'A' BITS   
       TCOA    *             AND WAIT                                   
       TRA     RSCHA1        GO RESTORE TRAP INSTRUCTION IF NO TRAP     
       REM                                                              
       WHEN    B,F,FORGET,TTR,*+1,,,,                                   
       WHEN    B,T,FORGET,TIB,*+1,,,,                                   
       REM                                                              
       WHEN    B,T,,SEB,,,,,                                            
       REM                                                              
RSCHA1 ENB     =0            DISABLE ALL TRAPS                          
       WHEN    B,T,,SEA,,,,, RESTORE PREVIOUS TRAP INSTRUCTION          
       STI     ADCTRP        ..                                         
       WHEN    B,T,,SEB,,,,, ..                                         
RSTCX4 AXT     **,4          RESTORE IR4                                
       TRA     1,4           AND RETURN                                 
       REM                                                              
CHKCHA ENB     =0            SIMULATE LOST TRAP ON CHANNEL 'A'          
       NZT     ATLOST        DID WE LOOSE A TRAP ON CHANNEL 'A'         
       TRA     1,4           NO, RETURN                                 
       SXA     CKXIR4,4      YES, SIMULATE TRAP SEQUENCE                
       TSX     ALLSAV,4      SAVE REGISTERS, SET 7-TAG MODE             
       TSX     $TRAPA,4      GIVE TRAP TO TAPE STRATEGY MODULE          
       PTH     ATLOST        ..                                         
       TRA     *+3           TRAP ACCEPTED, DON'T SAVE FLAGS            
       CAL     ATLOST        RECORD THIS TRAP FOR FUTURE REFERENCE      
       ORS     TPFLAG+1      ..                                         
       STZ     ATLOST        RESET LOST TRAP CONDITION                  
       TSX     ALLRST,4      RESTORE REGISTERS, TAG MODE                
CKXIR4 AXT     **,4          AND RETURN                                 
       TRA     1,4           ..                                         
       REM                                                              
*  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  
       REM                                                              
ENABLE OCT     400000        COMMON ENABLE WORD                         
       REM                                                              
*  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  
       REM                                                              
       REM     ... ADDTIM ... COMPUTE TIME TO NEAREST 60TH OF A SECOND  
       REM                                                              
ADDTIM ENB     =0            INSURE ALL TRAPS DISABLED (USED BY CLKINT) 
       WHEN    B,T,,SEA,,,,,                                            
       CAL     CLOCK         COMPUTE TOTAL TIME SYSTEM HAS RUN          
       WHEN    B,T,,SEB,,,,, ..                                         
       ACL     CLKTIM        .. CLOCK TRAP INTERVAL                     
       ANA     =O777777      ..                                         
       ACL     TOTTIM        ..                                         
       SUB     SAVTOT        SUBTRACT TIME OF LAST CALL TO 'ADDTIM'     
       TZE     1,4           IGNORE IF NO TIME HAS ELAPSED SINCE        
       SLW     DELTA         OTHERWISE, SAVE TIME INCREMENT             
       ADD     SAVTOT        SAVE CURRENT TIME                          
       SLW     SAVTOT        .. FOR NEXT CALL TO 'ADDTIM'               
       CAL     TIMNOW        UPDATE TIME OF DAY                         
       ADD     DELTA         ..                                         
       SLW     TIMNOW        ..                                         
       CAL     ELAPSE        UPDATE ELAPSE TIME SINCE LAST CALL         
       ADD     DELTA         .. TO 'GETELT'                             
       SLW     ELAPSE        ..                                         
       TRA     1,4           AND RETURN                                 
       REM                                                              
       EJECT                                                            
       REM                                                              
       REM     ..... CONSTANT AND VARIABLE STORAGE FOR 'IOPAC' ........ 
       REM                                                              
       TITLE                                                            
       REM                                                              
DATEYR PZE     0             TODAY'S DATE  BCI 1,MMDDYY                 
TIMNOW PZE     0             TIME OF DAY IN 60THS OF A SECOND           
ELAPSE PZE     0             TIME SINCE LAST CALL TO 'GETELT'           
TOTTIM PZE     0             TOTAL TIME SYSTEM HAS RUN                  
SAVTOT PZE     0             TOTTIM AT TIME OF LAST CALL TO 'ADDTIM'    
DELTA  PZE     0             TEMP FOR 'ADDTIM'                          
ATLOST PZE     0             LOST TRAP ON CHANNEL 'A' SAVED HERE        
CMXRTN PZE     0             TEMP FOR RETURN FROM 'CMEXIT'              
CMXSI  PZE     0             SENSE INDICATORS SAVED BY 'CMEXIT'         
       REM                                                              
TRPIR4 PZE     0             MACHINE CONDITIONS SAVED ON TRAP           
TRPMTM PZE     **            ..                                         
TRPSI  PZE     0             ..                                         
TRPMQ  PZE     0             ..                                         
TRPLAC PZE     0             ..                                         
TRPSQ  PZE     0             ..                                         
TRPOV  PZE     0             ..                                         
       REM                                                              
PRCOL  PZE     0             TEMPS FOR WPRPU                            
AUTHOR PZE     0             TEMP FOR 'SETIO'                           
RTNLOC PZE     0             TRAP FLAGS SAVED HERE ON ALL TRAPS         
CLKEYS PZE     0             CONSOLE KEYS, SAVED BY 'CLKINT'            
KEYSW  PZE     0             SWITCH USED BY 'CLKINT'                    
FERTN  PZE     **            RETURN LOCATION SET BY 'FERRTN'            
UILOCK PZE     **            RETURN LOCATION SET BY 'TILOCK'            
SVCHAN PZE     0             TEMP USED BY SAVCHA/RSTCHA                 
SVIOCK PZE     0             TEMP USED BY SAVCHA/RSTCHA                 
ENBIFA PZE     -             ENABLE BITS IF CHANNEL A ENABLED           
       REM                                                              
TPFLAG SYN     *-1           CHANNEL FLAGS SAVED HERE                   
       PZE     0             .. FOR CHANNEL 'A'                         
       PZE     0             .. AND CHANNEL 'B'                         
       REM                                                              
CLKTIM DEC     60            CLOCK TRAP INTERVAL                        
       REM                                                              
HOME   PZE     B+1           FLAG FOR 'HOME' MEMORY                     
       REM                                                              
NOERTN BCI     5, NO ERROR RETURN SPECIFIED.                            
PP21UP BCI     6,****** PLEASE PUT KEY 21 UP. ******                    
KEYSNG BCI     8,****** ILLEGAL KEY SETTING, TRY AGAIN. ******          
KREAD  BCI     4, KEYS READ. ************                               
EXITMS BCI     2, EXIT CALLED                                           
       REM                                                              
SAVFMS BES     HITRAP+1      FMS LOWER CORE SAVED HERE                  
       REM                                                              
LDFIOP IOCP    0,,3          LOAD FIOP INTO MEMORY 'A'                  
       TCH     0             ..                                         
       REM                                                              
TCOAB  SYN     *-1           CHANNEL WAIT INSTRUCTIONS                  
       TCOA    **            .. FOR CHANNEL 'A'                         
       TCOB    **            .. AND CHANNEL 'B'                         
       EJECT                                                            
       REM                                                              
       REM     ... RCLOCK ... READ CHRONOLOG, SET TIMNOW AND DATEYR ... 
       REM                                                              
RDCLOC SXA     RCLKX4,4      SAVE XRS                                   
       SXA     RCLKX2,2      ..                                         
       SXA     RCLKX1,1      ..                                         
       REM                                                              
       AXT     2,1           TRY TWICE IN CASE OF BAD DATE              
RCLOC1 STZ     MMDDHH        RESET                                      
       STZ     MMSS66        ..                                         
       RTDZ                  SELECT CHRONOLOG AS TAPE 'A7'              
       RCHZ    RCLOCK        START UP CHANNEL TO READ CLOCK             
       AXT     2,2           COUNT TRIES                                
RCLOC2 AXT     DELAY,4       9 MS DELAY WITH TIX *                      
       TIX     *,4,1         ..                                         
       ZET     MMDDHH        HAS FIRST WORD BEEN READ                   
       TRA     RCLOC3        YES, SKIP TO WAIT ON CHANNEL               
       TIX     RCLOC2,2,1    NO, COUNT TRIES                            
       RDCZ                  AFTER 18 MS GIVE UP, RESET CHANNEL         
       TRA     BADCLK        SKIP TO INFORM OPERATOR                    
RCLOC3 TCOZ    *             WAIT UNTIL BOTH WORDS ARE READ             
       TRCZ    *+1           INSURE RTT TRIGGER RESET                   
       REM                                                              
RCLOC4 AXT     2,2           INSURE ALL CHARACTERS READ ARE LEGAL       
RCLK4A LDQ     MMDDHH+2,2    PICK UP WORD READ                          
       AXT     6,4           6 DIGITS PER WORD                          
RCLOC5 ZAC                   ..                                         
       LGL     6             SHIFT CHAR                                 
       PAX     ,7            TO X7                                      
       TXH     RCLOC8,7,9    ERROR IF .G. 9                             
       TIX     RCLOC5,4,1    DO FOR ALL CHARS                           
       TIX     RCLK4A,2,1    .. OF EACH WORD                            
       REM                                                              
       LDQ     MMDDHH        PICK UP HOUR                               
       RQL     24            ..                                         
       TSX     DTB,7         CONVERT TO BINARY                          
       PAX     ,7            ..                                         
       TXH     RCLOC8,7,23   INSURE LEGAL VALUE                         
       LDQ     MMSS66        NOW GET REST OF TIME                       
       AXT     3,4           MINUTES, SECONDS, 60THS                    
RCLOC6 ALS     2             MULTIPLY PREVIOUS VALUE BY 60              
       SLW     TMP           .. N * 4                                   
       AXT     3,7           ..                                         
       ALS     1             .. 8, 16, 32                               
       ADD     TMP           ..                                         
       TIX     *-2,7,1       ..                                         
       SLW     60THS         .. = 60                                    
       TSX     DTB,7         NOW CONVERT NEXT FIELD FROM MQ             
       PAX     ,7            ..                                         
       TXH     RCLOC8,7,59   MUST BE LESS THAN 60                       
       ADD     60THS         ADD PREVIOUS RESULT                        
       TIX     RCLOC6,4,1    GO BACK TO MULTIPLY AGAIN                  
       SLW     TIMNOW        ..                                         
       CAL     MMDDHH        ..                                         
       ANA     =O777777770000 MASK OUT HOUR                             
       ORA     YEAR          ADD IN YEAR TO FORM                        
       SLW     DATEYR        .. MMDDYY                                  
RCLKX1 AXT     -,1           RESTORE XRS                                
RCLKX2 AXT     -,2           ..                                         
RCLKX4 AXT     -,4           ..                                         
       TRA     1,4           RETURN                                     
       REM                                                              
RCLOC8 TIX     RCLOC1,1,1    HERE FOR BAD DATE FROM CHRONOLOG, RETRY    
       REM                                                              
BADCLK LDQ     TIMNOW        HERE IF CHRONOLOG WILL NOT READ PROPERLY   
       TSX     CTIME,4       CONVERT TIME FOR PRINTING                  
       SLW     MMSS66+2      ..                                         
       TSX     EPRINT,4      TELL OPERATOR ABOUT IT                     
       PZE     CLKBAD,,12    .. THOUGH IT PROBABLY IS A WASTED EFFORT   
       TSX     EPRINT,4      YES, MUST HAVE A DATE AND TIME             
       PZE     SETMDH,,12    PRETEND OPERATOR IS CHRONOLOG              
       HTR     *+1           WAIT FOR OPERATOR                          
       ENK                   GET KEYS (MMDDHH)                          
       STQ     MMDDHH        PRETEND THE CHRONOLOG DID IT               
       TSX     EPRINT,4      NOW ASK FOR THE REST OF IT                 
       PZE     SETMS6,,11    ..                                         
       HTR     *+1           .. WAIT AGAIN                              
       ENK                   MMSS66                                     
       STQ     MMSS66        ..                                         
       TRA     RCLOC4        PROCESS NORMALLY                           
       REM                                                              
DTB    ZAC                   ROUTINE TO CONVERT TWO BCD DIGITS TO BINARY
       LGL     6             ..                                         
       STO     TMP           ..                                         
       ZAC                   ..                                         
       LGL     3             ..                                         
       ADD     TMP           ..                                         
       LGL     2             ..                                         
       ADD     TMP           ..                                         
       LGL     1             ..                                         
       TRA     1,7           ..                                         
       REM                                                              
       REM                                                              
RCLOCK IORT    MMDDHH,B,2    CHANNEL COMMAND TO READ CHRONOLOG CLOCK    
YEAR   BCI     1,000071      MUST BE CHANGED EVERY YEAR **************  
60THS  PZE                                                              
TMP    PZE                                                              
       REM                                                              
SETMDH BCI     9,OPERATOR ENTER BCD MONTH, DAY, HOUR IN KEYS, FORMAT MM 
       BCI     3,DDHH. PRESS START.                                     
SETMS6 BCI     9,ENTER BCD MINUTE, SECOND, 60TH IN KEYS, FORMAT MMSS66. 
       BCI     2, PRESS START.                                          
CLKBAD BCI     /CHRONOLOG CLOCK MALFUNCTIONING. CLOCK READ '/           
MMDDHH BCI     1,MMDDHH                                                 
MMSS66 BCI     1,MMSS66                                                 
       BCI     /' AT /                                                  
       BCI     1,HHMM.M                                                 
       REM                                                              
       ORG     RDCLOC        CLOCK READ ROUTINE IS OVERLAPPED           
       REM                                                              
STATBL BSS     STBL          STORAGE FOR ACTIVE FILE STATUS TABLE       
QUEUE1 BSS     1QL           STORAGE FOR DRUM STRATEGY MODULE           
QUEUE2 BSS     2QL           STORAGE FOR DISK STRATEGY MODULE           
QUEUE3 BSS     3QL           STORAGE FOR TAPE STRATEGY MODULE           
       REM                                                              
       DETAIL                                                           
       END                                                              
               
