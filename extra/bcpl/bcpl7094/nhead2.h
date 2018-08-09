// NHEAD2.BCPL 06/19/68 11:02

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

GLOBAL    // bcpl COMPILER LIBRARY
$( BCDword:237
   WriteO:238; Charcode:239; Formnumber:240; Formdigit:241
   Packstring:242; Unpackstring:243; WriteS:244; WriteN:245
   Report:246; Reportcount:247; Reportmessage:248; Plist:249
   Newvec:250; List1:251; List2:252; List3:253; List4:254; List5:255
   FreelistP:256; FreelistT:257    $)

MANIFEST $( H1 = 0; H2 = 1; H3 = 2; H4 = 3; H5 = 4  $)

MANIFEST  // ae OPERATORS
$( number=1; name=2; stringconst=3; true=4; false=5
   valof=6; lv=7; rv=8; vecap=9; fnap=10
   mult=11; div=12; rem=13; plus=14; minus=15; pos=16; neg=17
   rel=19; eq=20; ne=21; ls=22; gr=23; le=24; ge=25
   not=30; lshift=31; rshift=32; logand=33; logor=34
   eqv=35; neqv=36
   cond=37; comma=38; table=39

   and=40; valdef=41; vecdef=42; constdef=43
   fndef=44; rtdef=45

   ass=50; rtap=51; goto=52; resultis=53
   colon=54
   test=55; for=56; if=57; unless=58
   while=59; until=60; repeat=61; repeatwhile=62
   repeatuntil=63; break=66; return=67; finish=68
   switchon=70; case=71; default=72
   seq=73; let=74; manifest=75; global=76
   local=77; label=78; static=79   $)

MANIFEST  // intoc OPERATOR
$( lp=40; lg=41; ln=42; lstr=43; ll=44
   llp=45; llg=46; lll=47

   sp=80; sg=81; sl=82; stind=83
   jump=85; jt=86; jf=87
   lab=90; stack=91; store=92; rstack=93
   save=95; fnrn=96; rtrn=97; res=98; reslab=99
   datalab=100; iteml=101; itemn=102; end=104  $) 

MANIFEST  // COMPILER MACHINE SPECIFICATION 7094
$( Bytebits=9; Bytemax=511
   Bytesperword=4
   Byte1SHIFT=27; Byte2SHIFT=18; Byte3SHIFT=9; Byte4SHIFT=0   $)

GLOBAL    // Trans
$( Trans:320; Declnames:321; Declvars:322; Declconst:323
   Checkdistinct:324; Addname:325; Cellwithname:326
   Transdef:327; Translabel:328; Decllabels:329
   Transreport:331
   Jumpcond:340; Relation:342
   Transswitch:345
   Assign:350; Load:351; LoadLV:352; Loadlist:353; Compdatalab:354
   Evalconst:357
   Complab:363; Compjump:364; Outputconsts:365
   Nextparam:366; Paramnumber:367; CompileAE:368

   DvecT:369
   Dvec:370; DvecS:371; DvecE:372; DvecB:373; DvecL:374; DvecP:375
   Labvec:379; LabvecS:380; LabvecT:381
   Casetable:382; CaseB:383; CaseP:384; CaseT:385
   Currentbranch:386
   Breaklabel:390; Resultlabel:391; Defaultlabel:392
   ssp:395; VecSSP:397; Savespacesize:398
   Globdecl:402; GlobdeclS:403;GlobdeclT:404
   Comcount:405; Ncount:406    $)

GLOBAL    // INTOC output routines
$( Out1:430; Out2:431; Out2P:432
   Out3:435; Out3P:436
   OutN:440; OutL:441; OutC:442
   Writeop:445  $)

