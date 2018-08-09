// head1.h 02/13/68 09:31

GLOBAL     // input   output
$( Findinput:210; Findoutput:211; charv:212
   Createoutput:213
   C9TO12:214; C12TO9:215; IObase:216
   Readch:217; Writech:218
   Endread:219; Endwrite:220
   Endofstream:221; InitializeIO:222
   stdin:223; stdout:224
   INPUT:225; OUTPUT:226; CONSOLE:227;MONITOR:228  $)

MANIFEST $( Endofstreamch=255; ASCIIfiller=3  $)

GLOBAL    // BCPL compiler library
$( BCDword:237
   WriteO:238; Charcode:239; Formnumber:240; Formdigit:241
   Packstring:242; Unpackstring:243; WriteS:244; WriteN:245
   Report:246; Reportcount:247; Reportmessage:248; Plist:249
   Newvec:250; List1:251; List2:252; List3:253; List4:254; List5:255
   FreelistP:256; FreelistT:257    $)

MANIFEST $( H1 = 0; H2 = 1; H3 = 2; H4 = 3; H5 = 4 $)

MANIFEST  // AE operators
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

MANIFEST  // canonical symbols
$( get=87; word=88; be=89
   end=90; sectbra=91; sectket=92
   comment=93; spaces=94; space=95
   nl=96; semicolon=97
   into=98; to=99; then=100; do=101; or=102
   vec=103; star=104; rbra=105; rket=106
   sbra=107; sket=108; octal=109   $)

MANIFEST  // compiler machine specification 7094
$( Bytebits=9; Bytemax=511
   Bytesperword=4
   byte1shift=27; byte2shift=18; byte3shift=9; byte4shift=0   $)

MANIFEST  // Constants used by Nextsymb
$( Empty=0; Simple=1; Ignorable=2
   Digit=4; Capital=5; Small=6  $)

GLOBAL    // Nextsymb
$( LineV:280; LineP:281; LineT:282
   GetV:283; GetP:284; GetT:285
   WordV:286
   B:290; V:291; Vp:292; st:293; NLPending:294; Vmax:295
   Symb:296; Nsymb:297; Ch:298; Chkind:299
   Nextsymb:300; PPitem:301; Lookupword:302; Kind:303
   Rch:304
   opstr:305   $)

GLOBAL    // CAE
$( Readblockbody:306; Rblock:307
   Rnamelist:308; Rname:309
   Rexp:310; Rdef:311; Rcom:312; Eqvec:313
   namechain:316; errorname:317   $)

GLOBAL    // Trans main routine
$( CompileAE:368    $)

