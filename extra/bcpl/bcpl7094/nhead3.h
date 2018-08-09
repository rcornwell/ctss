// nhead3.b 05/23/68 11:49

GLOBAL     // input   output
$( Findinput:210; Findoutput:211; charv:212
   Createoutput:213
   C9TO12:214; C12TO9:215; IObase:216
   Readch:217; Writech:218
   Endread:219; Endwrite:220
   Endofstream:221; InitializeIO:222
   stdin:223; stdout:224
   INPUT:225; OUTPUT:226; CONSOLE:227;MONITOR:228  $)

MANIFEST $( Endofstreamch=255  $)

GLOBAL    // BCPL compiler library
$( BCDword:237
   WriteO:238; Charcode:239; Formnumber:240; Formdigit:241
   Packstring:242; Unpackstring:243; WriteS:244; WriteN:245
   Report:246; Reportcount:247; Reportmessage:248; Plist:249
   Newvec:250; List1:251; List2:252; List3:253; List4:254; List5:255
   FreelistP:256; FreelistT:257    $)

MANIFEST $( H1 = 0; H2 = 1; H3 = 2; H4 = 3; H5 = 4  $)

MANIFEST  // INTOC operators and other constants
$( number=1; true=4; false=5
   rv=8; vecap=9; fnap=10
   mult=11; div=12; rem=13; plus=14; minus=15; pos=16; neg=17
   eq=20; ne=21; ls=22; gr=23; le=24; ge=25
   not=30; lshift=31; rshift=32; logand=33; logor=34
   eqv=35; neqv=36
   rtap=51; goto=52
   finish=68
   switchon=70; global=76
   local=77; label=78   $)

MANIFEST  // more operators
$( lp=40; lg=41; ln=42; lstr=43; ll=44
   llp=45; llg=46; lll=47
   sp=80; sg=81; sl=82; stind=83
   jump=85; jt=86; jf=87
   lab=90; stack=91; store=92; rstack=93
   save=95; fnrn=96; rtrn=97; res=98
   datalab=100; iteml=101; itemn=102; error=103; end=104  $) 

MANIFEST  // compiler machine specification 7094
$( Bytebits=9; Bytemax=511
   Bytesperword=4
   Byte1SHIFT=27; Byte2SHIFT=18; Byte3SHIFT=9; Byte4SHIFT=0   $)

GLOBAL    // global variables
$( Ch:500; Vp:501; WordV:502
   ssp:510; Arg1:511; Arg2:512
   TempV:514; TempT:515; ConstV:516
   ConstP:517; ConstL:518; ConstT:519
   CaseK:520; CaseL:521
   Svec:522; SvecP:523; SvecT:524
   //BSSing:550; Listing:551
   StatV:552; StatP:553; StatT:554
   stv:555; stp:556; stvq:557
   RefV:560; RefP:561; RefT:562; Parv:563
   Relbit:566; RelwordP:567; LastcardP:568
   Commonbreak:569
   Type:570; Op:571; stvl:574
   V1:575; V2:576; Nulladdr:578; Glob0:579
   //Filing:580
   Endlab:581  $)

GLOBAL    // CG routines
$( LoadT:600; CellN:601; Lose1:602; Iszero:603; Initstack:604
   Staticcell:605
   MovetoAC:610; MovetoLAC:611; MovetoMQ:612
   Storein:615; StoreI:616; StoreT:617; Storecode:618
   Stack:620; Store:621; FreeAC:622; FreeMQ:623
   Makeaddrble:624; Addr:625; Addrble:626; MovetoX:627
   NextX:628; IsXfree:629
   CGrv:630; CGapply:631; CGswitch:632; CGglobal:633
   CGplus:634; CGsubt:635; CGrel:636; CGshift:637
   CGlogop:638; CGstring:639
                    $)

GLOBAL    // CGtoFAP
$( Scan:651; Readop:652
   ReadN:654; ReadL:655
   Outconsts:662; Outnumbs:663; wrfapr:669
   wrlab:670; Compile:671; wrfaps:672; wrcom:673; wrchs:674
   wropcode:675; wrdata:678
   SetupBSS:680; Entryname:681; Nextcard:682; Strefbit:683
   wrbss:684
   Paramnumber:685; Nextparam:686; Wrocodeop:687
   acl:690; Addaddr:691  $)

MANIFEST
$( LACreg=2; MQreg=3; SIreg=4; ACreg=5; Xreg=6; rvplus=7
   Tempsize=5  $)

MANIFEST   // 7094 op codes
$( add=#o0400; als=#o0767; ana=#o4320; ars=#o0771
   axc=#o4774; cas=#o0340; cal=#o4500; cla=#o0500; cls=#o0502
   dvp=#o0221
   era=#o0322; hpr=#o0420; lac=#o0535; ldi=#o0441; ldq=#o0560
   lrs=#o0765; mpy=#o0200; ora=#o4501; pac=#o0737; pai=#o0044
   pca=#o0756; pia=#o4046; slw=#o0602; sta=#o0621; sti=#o0604
   sto=#o0601; stq=#o4600; stz=#o0600; sub=#o0402; tmi=#o4120
   tnz=#o4100; tpl=#o0120; tra=#o0020; tsx=#o0074
   txi=#o1000; tze=#o0100; xca=#o0131; xcl=#o4130   $)
