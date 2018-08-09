// head1a.b 07/26/67 1532.9     Header file for lb1a.b

GLOBAL     // input   output
$( Findinput:210; Findoutput:211; charv:212
   Createoutput:213
   C9TO12:214; C12TO9:215; IObase:216
   Readch:217; Writech:218
   Endread:219; Endwrite:220
   Endofstream:221; InitializeIO:222
   stdin:223; stdout:224
   INPUT:225; OUTPUT:226; CONSOLE:227;MONITOR:228  $)

MANIFEST $( Endofstreamch = 255  $)

GLOBAL    // BCPL compiler library
$( BCDword:237
   WriteO:238; Charcode:239; Formnumber:240; Formdigit:241
   Packstring:242; Unpackstring:243; WriteS:244; WriteN:245
   Report:246; Reportcount:247; Reportmessage:248; Plist:249
   Newvec:250; List1:251; List2:252; List3:253; List4:254; List5:255
   FreelistP:256; FreelistT:257    $)

MANIFEST $( H1 = 0; H2 = 1; H3 = 2; H4 = 3; H5 = 4   $)

MANIFEST  // compiler machine specification 7094
$( Bytebits=9; Bytemax=511; Bytesperword=4
   byte1shift=27; byte2shift=18; byte3shift=9; byte4shift=0   $)

