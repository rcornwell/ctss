/*
THIS IS CURRENTLY UNDER DEVELOPMENT.

It will compile programs in the version of BCPL as it was at Project
MAC in June 1968. The target code is either 7094 FAP assembly language
or BSS.

Since the 7094 is a 36-bit machine, this compiler uses the 64-bit
version of Cintcode BCPL.

This file has been systematically edited to make it work under the
current Cintcode BCPL system.

*/

GET "libhdr"
GET "lbhead"
GET "head1"
GET "nhead3"

// iopack.b  This file is missing and was probably written
//              in FAP assembly language


LET Setmem() BE $( RETURN  $)

AND Writech(stream, ch) BE wrch(ch)

AND Readch(stream, lvch) BE
{ !lvch := rdch()
}

AND BCDword(s) = VALOF
{ // Pack the 8-bit ASCII bytes of s into the 6-bit bytes of the
  // 36-bit result, right justified and converted from ASCII
  // to CTSS 6-but code.

  LET len = s%0
  LET res = #o606060606060  // Six blanks
  LET p = len >= 6 -> len - 5, 1  // Position of first character to pack
  LET k = len - p                 // The number-1 of characters to pack
  FOR i = 0 TO k DO
  { LET c = capitalch(s%(p+i))
    //writef("Converting ASCII %i3 %c to CTSS %o2*n", c, c, ASCII2CTSS!c)
    res := res<<6 | ASCII2CTSS!(c)
  }
  //sawritef("BCDword:p=%n k=%i2  S=*"%s*" => %12o*n", p, k, s, res)
  //abort(6667)
  RESULTIS res
}

AND initchartabs() BE
{ CTSS2ASCII := TABLE // 128 entries, empty entries are marked by -1
    '0', '1', '2', '3', '4', '5', '6', '7',
    '8', '9',  -1, '=','*'',  -1,  -1,  -1,
    '+', 'A', 'B', 'C', 'D', 'E', 'F', 'G',
    'H', 'I',  -1, '.', ')', ':',  -1,  -1,
    '-', 'J', 'K', 'L', 'M', 'N', 'O', 'P',
    'Q', 'R','*p', '$','**','*c',  -1,   0,
   '*s', '/', 'S', 'T', 'U', 'V', 'W', 'X',
    'Y', 'Z','*t', ',', '(',  -1,  -1,  -1,

    '|', ']', '\', ';', '#', '%', '@','*n',
     -1,  -1, '^',   7, '!',  -1,  -1,  -1,
    '&', 'a', 'b', 'c', 'd', 'e', 'f', 'g',
    '_', 'j', 'k', 'l', 'm', 'n', 'o', 'p',
    'q', 'r', '<', '[',  27, '>', '?',  -1,
   '*'',  -1, 's', 't', 'u', 'v', 'w', 'x',
    'y', 'z','*p', '{', '}',  -1,  -1,  -1

  ASCII2CTSS := TABLE // Table to convert ASCII to CTSS code
     127, 127, 127, 127, 127, 127, 127, 127, 
     127, 127, 127, 127, 127, 127, 127, 127, 
     127, 127, 127, 127, 127, 127, 127, 127, 
     127, 127, 127, 127, 127, 127, 127, 127, 
     127, 127, 127, 127, 127, 127, 127, 127, 
     127, 127, 127, 127, 127, 127, 127, 127, 
     127, 127, 127, 127, 127, 127, 127, 127, 
     127, 127, 127, 127, 127, 127, 127, 127, 

     127, 127, 127, 127, 127, 127, 127, 127, 
     127, 127, 127, 127, 127, 127, 127, 127, 
     127, 127, 127, 127, 127, 127, 127, 127, 
     127, 127, 127, 127, 127, 127, 127, 127, 
     127, 127, 127, 127, 127, 127, 127, 127, 
     127, 127, 127, 127, 127, 127, 127, 127, 
     127, 127, 127, 127, 127, 127, 127, 127, 
     127, 127, 127, 127, 127, 127, 127, 127

  FOR i = 0 TO 127 IF CTSS2ASCII!i>=0 DO ASCII2CTSS!(CTSS2ASCII!i) := i
  RETURN
/*
writef("*nCTSS2ASCII Table*n")
FOR i = 0 TO 127 DO
{ IF i MOD 16 = 0 DO writef("*n%i3: ", i)
  writef(" %i3", CTSS2ASCII!i)
}
newline()
writef("*nASCII2CTSS Table*n")
FOR i = 0 TO 127 DO
{ IF i MOD 16 = 0 DO writef("*n%i3: ", i)
  writef(" %i3", ASCII2CTSS!i)
}
newline()
abort(6666)
*/
}

AND Findinput(N1, N2) = VALOF
{ // N1 and N2 are BCD words giving the CTSS file name
  RESULTIS findinput(CTSS2LINUX(N1, N2, charv))
}

AND Findoutput(N1, N2) = VALOF
{ // N1 and N2 are BCD words giving the CTSS file name
  RESULTIS findinput(CTSS2LINUX(N1, N2, charv))
}

AND CTSS2LINUX(N1, N2, v) = VALOF
{ LET len = 0
  FOR i = 0 TO 10 DO v!0 := 0
  FOR sh = 30 TO 0 BY -6 DO
  { LET ctssch = N1>>sh & 63
    LET ch = CTSS2ASCII!ctssch
    UNLESS ch='*s' DO { len := len+1; v%len := ch }
  }
  len := len+1
  v%len := '.'
  FOR sh = 30 TO 0 BY -6 DO
  { LET ctssch = N2>>sh & 63
    LET ch = CTSS2ASCII!ctssch
    UNLESS ch='*s' DO { len := len+1; v%len := ch }
  }
  v%0 := len
  RESULTIS v
}

AND BCD2ASCII(N, s) = VALOF
{ LET len = 0
  FOR i = 0 TO 2 DO s!i := 0

  FOR sh = 30 TO 0 BY -6 DO
  { LET ch = CTSS2ASCII!(N>>sh & 63)
    UNLESS ch='*s' DO { len := len+1; s%len := ch }
  }
  s%0 := len
  RESULTIS s
}

// lb1a.b 07/26/67 1530.2       Demo library file

GET "libhdr"
GET "head1a"

LET Formdigit(x) = x+48   // The result is an ASCII digit

AND Formnumber(x) = x-48

AND Unpackstring(S, V) BE
      $(1 LET n = S!(0) RSHIFT byte1shift
          LET i,j = 0,0
          UNTIL j GR n DO
               $( LET W = S!(i)
                  V!(j) := W RSHIFT byte1shift
                  V!(j+1) := W RSHIFT byte2shift & Bytemax
                  V!(j+2) := W RSHIFT byte3shift & Bytemax
                  V!(j+3) := W & Bytemax
                  i,j := i+1,j+4  $)1

AND Packstring(V, S) BE
      $(1 LET n = V!(0)
          AND i,j = 0,0
          V!(n+1), V!(n+2), V!(n+3) := 0, 0, 0
          UNTIL j GR n DO
                 $( S!(i) := V!(j) LSHIFT byte1shift LOGOR
                             V!(j+1) LSHIFT byte2shift LOGOR
                             V!(j+2) LSHIFT byte3shift LOGOR V!(j+3)
                    i,j := i+1,j+4  $)1

AND WriteS(S) BE
       $( LET V = VEC 512
          Unpackstring(S, V)
          FOR i = 1 TO V!(0) DO Writech(OUTPUT, V!(i))  $)

AND WriteN(n) BE
       $( LET v = VEC 20
          AND Neg = n LS 0
          LET j = VALOF
                 $( IF Neg DO n := -n
                    FOR i = 0 TO 20 DO
                           $( v!(i) := n REM 10
                              n := n/10
                              IF n=0 RESULTIS i  $)
                    RESULTIS 20  $)
          IF Neg DO Writech(OUTPUT, '-')
          FOR i = 0 TO j DO Writech(OUTPUT, Formdigit(v!(j-i)))
          RETURN  $)

AND WriteO(n) BE
      $(1 LET i = 36
          UNTIL i=0 DO $( i := i-3
                          Writech(OUTPUT, Formdigit(n RSHIFT i & 7))  $)1

AND Report(n) BE
       $( LET Out = output()
          selectoutput(stdout)
          sawritef("Report %n*n", n)
          //WriteN(n)
          //Writech(OUTPUT,'*n')
          selectoutput(Out) $)
          //OUTPUT := Out  $) 

.


// inpp1.b 02/13/68 09:10

GET "libhdr"
GET "lbhead"
GET "head1.h"

LET Nextsymb() BE
$(1 IF B DO $( Symb, B := Nsymb, FALSE
               RETURN  $)
    UNLESS Chkind = Empty GOTO M
//sawritef("Nextsymb: entered*n")
Next: Rch()
//sawritef("Nextsymb: Ch=%i3", Ch)
//IF Ch >= 32 DO sawritef("  %c",Ch)
//sawrch('*n')

L: Chkind := Kind(Ch)
//sawritef("Chkind=%n*n", Chkind)
M: SWITCHON Chkind INTO
   $( CASE Ignorable: Rch() REPEATWHILE Ch='*s'
                      GOTO L

      CASE Digit: Vp := 0
                  $( Vp := Vp + 1
                     V!(Vp) := Ch
               Numb: Rch()
                     Chkind := Kind(Ch)  $) REPEATWHILE Chkind=Digit
                  PPitem(number, 01)
                  RETURN

      CASE Capital:Vp := 0
                   $( Vp := Vp + 1
                      V!Vp := Ch
                      Rch()
                      Chkind := Kind(Ch)  $) REPEATWHILE Chkind GE 4
                   PPitem(name, 11)
                   RETURN

      CASE Small: Vp := 0
                   $( Vp := Vp + 1
                      V!(Vp) := Ch
                      Rch()
                      Chkind := Kind(Ch)  $) REPEATWHILE Chkind=Small
                   TEST Vp=1 THEN PPitem(name, 11)
                               OR Lookupword()
                   RETURN

                                 $)

      Chkind := Empty
      SWITCHON Ch INTO
      $(     CASE '$': Rch()
                       IF Ch = '8' DO
                             $(  V!(1), Vp := octal, 1
                                 GOTO Numb  $)
                       IF Ch = '(' DO
                             $(  Vp := 0
                                 $( Rch()
                                    Chkind := Kind(Ch)
                                    UNLESS Chkind GE 4 BREAK
                                    Vp := Vp + 1
                                    V!(Vp) := Ch  $) REPEAT
                                 PPitem(sectbra, 10)
                                 RETURN  $)
                       IF Ch = ')' DO
                             $(  Vp := 0
                                 $( Rch()
                                    Chkind := Kind(Ch)
                                    UNLESS Chkind GE 4 BREAK
                                    Vp := Vp + 1
                                    V!(Vp) := Ch  $) REPEAT
                                 PPitem(sectket, 01)
                                 RETURN  $)
                       Report(91)
                       GOTO Next

             CASE '%': Rch()
                       IF Ch = '(' DO $( PPitem(rbra, 10); RETURN  $)
                       IF Ch = ')' DO $( PPitem(rket, 01); RETURN  $)
                       Report(92)
                       GOTO Next

             CASE '(': PPitem(sbra, 00); RETURN
             CASE ')': PPitem(sket, 01); RETURN
             CASE '**':PPitem(star, 00); RETURN
             CASE '+': PPitem(plus, 00); RETURN
             CASE ',': PPitem(comma, 00); RETURN
             CASE ';': PPitem(semicolon, 00); RETURN
             CASE '&': PPitem(logand, 00); RETURN
             CASE '=': PPitem(eq, 00); RETURN

             CASE '/': Rch()
                       UNLESS Ch = '/' DO $(  PPitem(div, 00)
                                              Chkind := Kind(Ch)
                                              RETURN  $)
                       Rch() REPEATUNTIL Ch='*n'
             CASE '*n':NLPending := TRUE
                       GOTO Next

             CASE '-': Rch()
                       IF Ch = '**' DO $(  PPitem(cond, 00); RETURN  $)
                       PPitem(minus, 00)
                       Chkind := Kind(Ch)
                       RETURN

             CASE ':': Rch()
                       IF Ch = '=' DO $(  PPitem(ass, 00); RETURN  $)
                       PPitem(colon, 00)
                       Chkind := Kind(Ch)
                       RETURN

             CASE '*'': Vp := 0
               NSCh: $( Rch()
                        IF Ch = '**' DO
                               $( Rch()
                                  Vp := Vp + 1
                                  V!(Vp) := Ch = 't' -> '*t',
                                            Ch = 's' -> '*s',
                                            Ch = 'n' -> '*n',
                                            Ch = 'b' -> '*b',
                                            Ch
                                  GOTO NSCh  $)

                        IF Ch = '*'' DO
                             $( PPitem(stringconst, 01); RETURN  $)
                        IF Vp=Vmax DO $( Report(95); GOTO Next  $)
                        Vp := Vp + 1
                        V!(Vp) := Ch
                        GOTO NSCh  $)

            CASE '.': $(  LET a = output()
                          selectoutput(stdout)
                          writes( "Input terminated by *'.*'*n" )
                          selectoutput(a)  $)

            DEFAULT:   IF Ch = endstreamch LOGOR Ch=ASCIIfiller LOGOR Ch='.' DO
                                           $( IF GetP=0 DO
                                                        $( PPitem(end,00) 
                                                           RETURN  $)
                                              endread()
                                              GetP := GetP - 1
                                              fromstream := GetV!GetP
                                              selectinput(fromstream)
                                              NLPending := TRUE
                                              LineP := 0
                                              Chkind := Empty
                                              GOTO Next  $)
                   $( //LET a = OUTPUT
                      LET a = output()
                      //OUTPUT := MONITOR
                      selectoutput(stdout)
                      Report(94); WriteN(Ch); Writech(OUTPUT,'/')
                      Writech(OUTPUT, Ch); Writech(OUTPUT, '*n')
                      //OUTPUT := a
                      selectoutput(a)
                      GOTO Next     $)1

.

// INPP2.BCPL 02/13/68 09:20

GET "libhdr"
GET "lbhead"
GET "head1.h"

LET Lookupword() BE
$(1 LET Error() BE
           $( sawritef("Error: entered*n")
              Report(93)
              FOR j = 1 TO Vp DO wrch(V!j)
              newline()
              PPitem(name, 11)  $)
    LET Is(S) = VALOF
       $(2 FOR i = 0 TO S%0 / bytesperword DO
           $( //sawritef("Is: %s  %s*n", WordV, S) 
              //sawritef("Is: i=%n %16x %16x*n", i, WordV!i, S!i) 
              UNLESS WordV!i=S!i RESULTIS FALSE
           $)
           RESULTIS TRUE   $)2

    V!0 := Vp
    // Pack into 64-bit words
    packstring(V, WordV)
    //WordV!(Vp / bytesperword) := 0
    //FOR i = 0 TO Vp DO WordV%i := V!i

    SWITCHON V!1 INTO
    $( DEFAULT:   Error(); RETURN

       CASE 'a':
          TEST Is("and") THEN PPitem(and,00)
                           OR Error()
          RETURN

       CASE 'b':
          TEST Is("be") THEN PPitem(be,00) OR
          TEST Is("break") THEN PPitem(break,22)
                           OR Error()
          RETURN

       CASE 'c':
          TEST Is("case") THEN PPitem(case,20)
                           OR Error()
          RETURN

       CASE 'd':
          TEST Is("do") THEN PPitem(do,00) OR
          TEST Is("default") THEN PPitem(default,20)
                           OR Error()
          RETURN

       CASE 'e':
          TEST Is("eq") THEN PPitem(eq,00) OR
          TEST Is("eqv") THEN PPitem(eqv,00)
                           OR Error()
          RETURN

       CASE 'f':
          TEST Is("false") THEN PPitem(false,01) OR
          TEST Is("for") THEN PPitem(for,20) OR
          TEST Is("finish") THEN PPitem(finish,22)
                           OR Error()
          RETURN

       CASE 'g':
          TEST Is("goto") THEN PPitem(goto,20) OR
          TEST Is("ge") THEN PPitem(ge,00) OR
          TEST Is("gr") THEN PPitem(gr,00) OR
          TEST Is("global") THEN PPitem(global,00) OR
          TEST Is("get")
                    THEN $( st := 0
                            Nextsymb()
                            UNLESS Symb=stringconst DO
                                        $( Report(97)
                                           RETURN  $)
                         $( LET N1, N2 = 0, BCDword("BCPL")
                            LET S = VEC 256
                            // Pack the string into 64-bit words
                            V!0 := Vp
                            packstring(V, S)
                            N1 := BCDword(S)
                            fromstream := Findinput(N1, N2)
                            UNLESS fromstream DO
                            { LET s1 = VEC 2
                              LET s2 = VEC 2
                              writef("Trouble with GET stream: %s %s*n",
                                      BCD2ASCII(N1,s1),BCD2ASCII(N2,s2))
                              Nextsymb()
                              RETURN
                            }
                            GetV!GetP := input()
                            selectinput(fromstream)  
                            GetP := GetP + 1
                            NLPending := TRUE
                            Chkind := Empty
                            Nextsymb()
                            RETURN  $)  $)
                    OR { abort(1006); Error() }
          RETURN

       CASE 'i':
          TEST Is("if") THEN PPitem(if,20) OR
          TEST Is("into") THEN PPitem(into,00)
                           OR Error()
          RETURN

       CASE 'l':
          TEST Is("let") THEN PPitem(let,00) OR
          TEST Is("lv") THEN PPitem(lv,00) OR
          TEST Is("le") THEN PPitem(le,00) OR
          TEST Is("ls") THEN PPitem(ls,00) OR
          TEST Is("logor") THEN PPitem(logor,00) OR
          TEST Is("logand") THEN PPitem(logand,00) OR
          TEST Is("lshift") THEN PPitem(lshift,00)
                           OR Error()
          RETURN

       CASE 'm':
          TEST Is("manifest") THEN PPitem(manifest,00)
                           OR Error()
          RETURN

       CASE 'n':
          TEST Is("ne") THEN PPitem(ne,00) OR
          TEST Is("neqv") THEN PPitem(neqv,00) OR
          TEST Is("not") THEN PPitem(not,00) OR
                              Error()
          RETURN

       CASE 'o':
          TEST Is("or") THEN PPitem(or,00)
                           OR Error()
          RETURN

       CASE 'r':
          TEST Is("resultis") THEN PPitem(resultis,20) OR
          TEST Is("return") THEN PPitem(return,22) OR
          TEST Is("rem") THEN PPitem(rem,00) OR
          TEST Is("rshift") THEN PPitem(rshift,00) OR
          TEST Is("rv") THEN PPitem(rv,10) OR
          TEST Is("repeat") THEN PPitem(repeat,02) OR
          TEST Is("repeatwhile") THEN PPitem(repeatwhile,00) OR
          TEST Is("repeatuntil") THEN PPitem(repeatuntil,00)
                           OR Error()
          RETURN

       CASE 's':
          TEST Is("switchon") THEN PPitem(switchon,20) OR
          TEST Is("static") THEN PPitem(static,00)
                           OR Error()
          RETURN

       CASE 't':
          TEST Is("to") THEN PPitem(to,00) OR
          TEST Is("test") THEN PPitem(test,20) OR
          TEST Is("true") THEN PPitem(true,01) OR
          TEST Is("then") THEN PPitem(do,00) OR
          TEST Is("table") THEN PPitem(table,00)
                           OR Error()
          RETURN

       CASE 'u':
          TEST Is("until") THEN PPitem(until,20) OR
          TEST Is("unless") THEN PPitem(unless,20)
                              OR Error()
          RETURN

       CASE 'v':
          TEST Is("vec") THEN PPitem(vec,00) OR
          TEST Is("valof") THEN PPitem(valof,10)
                             OR Error()
          RETURN

       CASE 'w':
          TEST Is("while") THEN PPitem(while,20)
                             OR Error()
          RETURN   $)1
.

// prepro.h 02/13/68 09:28

GET "libhdr"
GET "head1.h"

LET Rch() BE
       $( IF Ch='*n' DO LineP := 0
          Ch := rdch()
          LineP := LineP + 1
          IF LineP GR LineT DO LineP := LineT
          LineV!(LineP) := Ch  $)

AND PPitem(Item, Class) BE
       $( Symb := Item
          IF st NE 0 DO
                    TEST NLPending
                        THEN IF Class GE 10 DO
                                     $( Nsymb, B := Symb, TRUE
                                        Symb := semicolon  $)
                          OR IF st=1 & Class GE 20 DO
                                     $( Nsymb, B := Symb, TRUE
                                        Symb := do  $)
          NLPending, st := FALSE, Class REM 10
  $)

AND Kind(Ch) = VALOF
    $( SWITCHON Ch INTO
       $( CASE 'a':CASE 'b':CASE 'c':CASE 'd':CASE 'e':
          CASE 'f':CASE 'g':CASE 'h':CASE 'i':CASE 'j':
          CASE 'k':CASE 'l':CASE 'm':CASE 'n':CASE 'o':
          CASE 'p':CASE 'q':CASE 'r':CASE 's':CASE 't':
          CASE 'u':CASE 'v':CASE 'w':CASE 'x':CASE 'y':
          CASE 'z':
                    RESULTIS Small

          CASE 'A':CASE 'B':CASE 'C':CASE 'D':CASE 'E':
          CASE 'F':CASE 'G':CASE 'H':CASE 'I':CASE 'J':
          CASE 'K':CASE 'L':CASE 'M':CASE 'N':CASE 'O':
          CASE 'P':CASE 'Q':CASE 'R':CASE 'S':CASE 'T':
          CASE 'U':CASE 'V':CASE 'W':CASE 'X':CASE 'Y':
          CASE 'Z':
                    RESULTIS Capital

          CASE '0':CASE '1':CASE '2':CASE '3':CASE '4':
          CASE '5':CASE '6':CASE '7':CASE '8':CASE '9':
                    RESULTIS Digit

          CASE '*s':CASE '*t':CASE 0:
                    RESULTIS Ignorable

          DEFAULT:  RESULTIS Simple  $)  $)

.


// cae0.b 02/13/68 09:41

GET "libhdr"
GET "lbhead.h"
GET "head1.h"

LET start() = VALOF
$(1      LET msecs0 = 0
         LET argv = VEC 50
         LET v = VEC 50
         charv := v          // To hold filenames
         stdin := input()
         stdout := output()
         
         initchartabs()

          //LET vv = VEC 1778
          //InitializeIO(vv, 1778)
          //MONITOR := Createoutput(0, 0, 0)
          //OUTPUT := MONITOR
          //Setmem(#o77377)
          //writes( "Syntax analyser entered*n" )

       $( LET N1, N2 = 0, BCDword("  BCPL")
/*
          LET bb = VEC 10
          FOR i = 0 TO 10 DO bb!(i) := FALSE
          FOR i = 0 TO 20 DO
                 $( LET W, M = Getcom(i), FALSE
                    IF W = #o777777777777 BREAK
                    IF W=BCDword("  tree") DO M, bb!(1) := TRUE, TRUE
                    IF W=BCDword(" ocode") DO M, bb!(2) := TRUE, TRUE
                    IF W=BCDword("  list") DO M, bb!(3) := TRUE, TRUE
                    IF W=BCDword(" pprep") DO M, bb!(4) := TRUE, TRUE
                    IF W=BCDword("synrep") DO M, bb!(5) := TRUE, TRUE
                    IF W=BCDword("tcgfap") DO M, bb!(6) := TRUE, TRUE
                    IF W=BCDword("  file") DO M, bb!(7) := TRUE, TRUE
                    IF W=BCDword(" nobss") DO M, bb!(8) := TRUE, TRUE
                    UNLESS M DO
                           $( IF i=1 DO N1 := W
                              IF i=2 DO N2 := W  $)  $)
*/
          fromname    := "t1.bcpl"
          N1 := BCDword("T1")
          N2 := BCDword("BCPL")
          fapname     := 0
          bssname     := "**"
          ocodename   := "OCODE"

          BSSing := TRUE

          fromstream  := 0
          fapstream   := 0
          bssstream   := 0
          ocodestream := 0

          UNLESS rdargs("N1,N2,fap/K,bss/K,ocode/S,lextrace/S,tree/S,list/S",
                         argv, 50) DO
          { writes("Bad arguments for bcpl7094*n")
            RESULTIS 0
          }

          IF argv!0 DO N1 := BCDword(argv!0)   // N1
          IF argv!1 DO N2 := BCDword(argv!1)   // N2
          IF argv!2 DO fapname   := argv!2     // fap/K
          IF argv!3 DO bssname   := argv!3     // bss/K
          ocode := argv!4                      // ocode/S
          lextracing := argv!5                 // lextrace/S
          tree := argv!6                       // tree/S
          listing := argv!7                    // list/S

//sawritef("fromname=%s tracing=%n*n", fromname, lextracing)

    L: $( LET A = 0
          //LET Wrtime() BE
          //       $( LET T = 0
          //          Stopcl(LV T)
          //          Rsclck()
          //          T := T*100
          //          WriteN(T/60)
          //          WriteS( " centisecs" )  $)
          LET Listvec = VEC 5700  
          FreelistP, FreelistT := Listvec, Listvec+5700

      $( LET R = Report
         LET CAEreport(n) BE
                $( Reportcount := Reportcount + 1
                   sawritef("Syntax error: %n", n)
                   sawritef("   The line so far is:*n")
                   FOR i = 1 TO LineP DO sawrch(LineV!(i))
                   sawrch('*n')  $)

         LET v = VEC 200
         LineV, LineP, LineT := v, 0, 200
      $( LET v = VEC 10
         GetV, GetP, GetT := v, 0, 10
      $( LET v = VEC 50
         WordV := v
         Reportcount := 0

         fromstream := Findinput(N1, N2)
         UNLESS fromstream DO
         { LET s1 = VEC 2
           AND s2 = VEC 2
           writef("Trouble with input file: %s %s*n", BCD2ASCII(N1,s1), BCD2ASCII(N2,s2))
           GOTO fin }
         selectinput(fromstream)

         Report, namechain := CAEreport, 0
         errorname := TABLE name, 0, 0, 0
         errorname!(3) := RV "$$"
      $( LET v = VEC 512
         V, Vp, Symb, Nsymb, st, NLPending, Vmax := v, 0, 0, 0, 0, TRUE, 512
         Ch, Chkind, B := 0, Empty, FALSE
         //Rsclck()
         msecs0 := sys(Sys_cputime)
      M: Nextsymb()
         IF lextracing DO $( writef("Symb=%i3  ",Symb)
                             IF Symb=end DO
                             { newline()
                               GOTO fin
                             }

                             FOR i = 1 TO Vp DO wrch(V!i)
                             newline()
                             GOTO M  $)
         A := Readblockbody()
         UNLESS Symb=end DO Report(99)
         endstream(fromstream)
         fromstream := 0
         Report := R  $)

         writef("*nCAE time %5.3d secs", sys(Sys_cputime) - msecs0)
         writef("    AE tree size = %n*n",FreelistP-Listvec)

         IF tree DO $( Plist(A, 0, 20); newline()  $)
         UNLESS Reportcount=0 DO $( writes("Compilation aborted*n")
                                    GOTO fin  $)
         //IF bb!(1) & N1=0 GOTO L
         //OUTPUT := Createoutput(N1, BCDword(" OCODE"), bb!(2) -> 0, 1)

         ocodestream := findoutput(ocodename)
         UNLESS ocodestream DO
         { writef("Unable to open file: %s for writing*n", ocodename)
           GOTO fin
         }

         selectoutput(ocodestream)
         msecs0 := sys(Sys_cputime)

         CompileAE(A)

         endwrite(ocodestream)
         selectoutput(stdout)
         //OUTPUT := MONITOR

         writef( "Trans time %8.3d*n", sys(Sys_cputime) - msecs0)
         UNLESS Reportcount=0 DO $( writes("Compilation aborted*n")
                                    GOTO fin  $)
/*
       $( LET Comv = VEC 20
          LET i = 3
          Comv!(2) := N1
          IF bb!(3) DO Comv!(i), i := BCDword("  LIST"), i+1
          IF bb!(7) DO Comv!(i), i := BCDword("  FILE"), i+1
          IF bb!(8) DO Comv!(i), i := BCDword(" NOBSS"), i+1
          Comv!(i) := #o777777777777
          Setcls(Comv, 0)
          Nexcom(BCDword("     R"), BCDword(bb!(6) -> "TCGFAP", " CGFAP"))
*/

          fapstream := stdout

          IF fapname DO
          { fapstream := findoutput(fapname)
            UNLESS fapstream DO
            { writef("Unable to open file %s for output*n", fapname)
              GOTO fin
            }
          }

          IF bssname DO
          { bssstream := findoutput(bssname)
            UNLESS bssstream DO
            { writef("Unable to open file %s for output*n", bssname)
              GOTO fin
            }
          }

          ocodestream := findinput(ocodename)
          UNLESS ocodestream DO
          { writef("Unable to open file %s for input*n", ocodename)
            GOTO fin
          }
          selectinput(ocodestream)
//selectoutput(stdout)
//sawritef("start: calling Cgfap, reading from file %s*n", ocodename)

          Cgfap(N1)

fin:
          IF fromstream DO endstream(fromstream)
          IF fapstream & fapstream ~= stdout DO endstream(fapstream)
          IF bssstream & bssstream ~= stdout DO endstream(bssstream)
          IF ocodestream & ocodestream ~= stdout DO endstream(ocodestream)
          RESULTIS 0
                    $)1

AND Newvec(upb) = VALOF
{ LET p = FreelistP
  FreelistP := FreelistP + upb + 1
  IF FreelistP > FreelistT DO
  { writef("Newvec: more store needed*n")
    abort(999)
  }
  RESULTIS p
}

AND List1(a) = VALOF
{ LET p = Newvec(0)
  H1!p := a
//sawritef("List1: %n -> [%n,%n]*n",p,a)
  RESULTIS p
}

AND List2(a, b) = VALOF
{ LET p = Newvec(1)
  H1!p, H2!p := a, b
//sawritef("List2: %n -> [%n,%n]*n",p,a,b)
  RESULTIS p
}

AND List3(a, b, c) = VALOF
{ LET p = Newvec(2)
  H1!p, H2!p, H3!p := a, b, c
//sawritef("List3: %n -> [%n,%n,%n]*n",p,a,b,c)
  RESULTIS p
}

AND List4(a, b, c, d) = VALOF
{ LET p = Newvec(3)
  H1!p, H2!p, H3!p, H4!p := a, b, c, d
//sawritef("List4: %n -> [%n,%n,%n,%n]*n",p,a,b,c,d)
  RESULTIS p
}

AND List5(a, b, c, d, e) = VALOF
{ LET p = Newvec(4)
  H1!p, H2!p, H3!p, H4!p, H5!p := a, b, c, d, e
//sawritef("List5: %n -> [%n,%n,%n,%n,%n]*n",p,a,b,c,d,e)
  RESULTIS p
}
.

// cae1.b 02/13/68 09:46
// including hand written corrections

GET "libhdr"
GET "head1"

LET Readblockbody() = VALOF
   $(1 LET A, B, Cdefs, Op = 0, 0, 0, 0
//sawritef("Readblockbody: Symb=%n*n", Symb)
       SWITCHON Symb INTO
       $( CASE manifest:
          CASE global:
          CASE static:
                $(2 LET n = 0
                    LET V1 = VEC 20
                    Op := Symb
                    Nextsymb()
                    UNLESS Symb=sectbra DO
                                        $( Report(2)
                                           RESULTIS 0  $)
                    n, V1!(0) := Vp, Vp
                    FOR i = 1 TO n DO V1!(i) := V!(i)
                    Nextsymb()

                 L: TEST Symb=name THEN A := Rname()
                                     OR $( Report(1)
                                           A := errorname
                                           Nextsymb()  $)
                    UNLESS Symb=eq LOGOR Symb=colon DO Report(3)

                    Nextsymb()
                    B := Rexp(0)
                    Cdefs := List4(constdef, Cdefs, A, B)
                    IF Symb=semicolon DO
                                        $( Nextsymb()
                                           GOTO L  $)
                    UNLESS Symb=sectket DO
                                        $( Report(4)
                                           RESULTIS 0  $)
                    V!(0) := Vp
                    IF Eqvec(V1, V, n) DO Nextsymb()   $)2

                    A := Readblockbody()
                    RESULTIS List3(Op, Cdefs, A)

          CASE let: Nextsymb()
                    A := Rdef()
                    B := Readblockbody()
                    RESULTIS List3(let, A, B)

          CASE sectket:
          CASE end: RESULTIS A

          CASE semicolon: Nextsymb()

          DEFAULT:  A := Rcom()
                    WHILE Symb=semicolon DO $( Nextsymb()
                                               B := Rcom()
                                               A := List3(seq, A, B)  $)
                     RESULTIS A  $)1

AND Rblock() = VALOF
       $( LET A, n = 0, 0
          LET V1 = VEC 20
          UNLESS Symb=sectbra DO
                    $( Report(6)
                       RESULTIS 0  $)
          n, V1!(0) := Vp, Vp
          FOR i = 1 TO n DO V1!(i) := V!(i)
          Nextsymb()
          A := Readblockbody()

          UNLESS Symb=sectket DO
                    $( Report(7)
                       Nextsymb()
                       RESULTIS A  $)
          V!(0) := Vp

          IF Eqvec(V1, V, n) DO Nextsymb()
          RESULTIS A  $)

AND Rnamelist() = VALOF
       $( LET A, B, C = 0, 0, 0
          UNLESS Symb=name DO $( Report(8)
                                 Nextsymb()
                                 RESULTIS errorname  $)
          A := Rname()
          UNLESS Symb=comma RESULTIS A
          Nextsymb()
          B := Rnamelist()
          RESULTIS List3(comma, A, B)  $)

AND Rname() = VALOF
       $( LET A, n = 0, 0
          LET S = VEC 50
          IF Vp GR 19 DO Report(9)
          n, V!(0) := Vp, Vp
          // Pack into 64-bit words
          packstring(V, S)

          Nextsymb()
        $( LET L = namechain
           LET N = n/bytesperword + 1 // The length of the string in words
           UNTIL L=0 DO
             $(1 IF S!0=L!2
                 DO $(2 IF N=1 RESULTIS L
                        IF S!1=L!3
                        DO $( IF N=2 RESULTIS L
                              IF S!2=L!4
                              DO $( IF N=3 RESULTIS L
                                    IF S!3=L!5
                                    DO $( IF N=4 RESULTIS L
                                          IF S!4=L!6
                                          DO $( IF N=5 RESULTIS L
                                                Report(9)
                                                RESULTIS L  $)2
                  L := H2!L  $)1
            A := Newvec(N+1)
            H1!A, H2!A := name, namechain
            namechain := A
            FOR i = 0 TO N-1 DO namechain!(i+2) := S!i

            RESULTIS namechain  $)  $)

AND Eqvec(V1,V2, n) = VALOF
                    $( FOR i = 0 TO n IF V1!(i) NE V2!(i) RESULTIS FALSE
                       RESULTIS TRUE  $)

.

// cae2.b 02/13/68 09:52
// with the hand written corrections

GET "libhdr"
GET "head1"

LET opstr(sym) = VALOF SWITCHON sym INTO
{ DEFAULT:  RESULTIS "Unknown"

  CASE number:        RESULTIS "number"
  CASE name:          RESULTIS "name"
  CASE stringconst:   RESULTIS "stringconst"
  CASE true:          RESULTIS "true"
  CASE false:         RESULTIS "false"
  CASE valof:         RESULTIS "valof"
  CASE lv:            RESULTIS "lv"
  CASE rv:            RESULTIS "rv"
  CASE vecap:         RESULTIS "vecap"
  CASE fnap:          RESULTIS "fnap"
  CASE mult:          RESULTIS "mult"
  CASE div:           RESULTIS "div"
  CASE rem:           RESULTIS "rem"
  CASE plus:          RESULTIS "plus"
  CASE minus:         RESULTIS "minus"
  CASE pos:           RESULTIS "pos"
  CASE neg:           RESULTIS "neg"
  CASE rel:           RESULTIS "rel"
  CASE eq:            RESULTIS "eq"
  CASE ne:            RESULTIS "ne"
  CASE ls:            RESULTIS "ls"
  CASE gr:            RESULTIS "gr"
  CASE le:            RESULTIS "le"
  CASE ge:            RESULTIS "ge"
  CASE not:           RESULTIS "not"
  CASE lshift:        RESULTIS "lshift"
  CASE rshift:        RESULTIS "rshift"
  CASE logand:        RESULTIS "logand"

  CASE cond:          RESULTIS "cond"
  CASE comma:         RESULTIS "comma"
  CASE table:         RESULTIS "table"

  CASE and:           RESULTIS "and"
  CASE valdef:        RESULTIS "valdef"
  CASE vecdef:        RESULTIS "vecdef"
  CASE constdef:      RESULTIS "constdef"
  CASE fndef:         RESULTIS "fndef"
  CASE rtdef:         RESULTIS "rtdef"

  CASE ass:           RESULTIS "ass"
  CASE rtap:          RESULTIS "rtap"
  CASE goto:          RESULTIS "goto"
  CASE resultis:      RESULTIS "resultis"
  CASE colon:         RESULTIS "colon"
  CASE test:          RESULTIS "test"
  CASE for:           RESULTIS "for"
  CASE if:            RESULTIS "if"
  CASE unless:        RESULTIS "unless"
  CASE while:         RESULTIS "while"
  CASE until:         RESULTIS "until"
  CASE repeat:        RESULTIS "repeat"
  CASE repeatwhile:   RESULTIS "repeatwhile"
  CASE repeatuntil:   RESULTIS "repeatuntil"
  CASE break:         RESULTIS "break"
  CASE return:        RESULTIS "return"
  CASE finish:        RESULTIS "finish"
  CASE switchon:      RESULTIS "switchon"
  CASE case:          RESULTIS "case"
  CASE seq:           RESULTIS "seq"
  CASE let:           RESULTIS "let"
  CASE manifest:      RESULTIS "manifest"
  CASE global:        RESULTIS "global"
  CASE local:         RESULTIS "local"
  CASE label:         RESULTIS "label"
  CASE static:        RESULTIS "static"
  CASE be:            RESULTIS "be"
  CASE end:           RESULTIS "end"
  CASE sectbra:       RESULTIS "sectbra"
  CASE sectket:       RESULTIS "sectket"
  CASE comment:       RESULTIS "comment"
  CASE spaces:        RESULTIS "spaces"
  CASE space:         RESULTIS "space"
  CASE nl:            RESULTIS "nl"
  CASE semicolon:     RESULTIS "semicolon"
  CASE into:          RESULTIS "into"
  CASE to:            RESULTIS "to"
  CASE then:          RESULTIS "then"
  CASE do:            RESULTIS "do"
  CASE star:          RESULTIS "star"
  CASE rbra:          RESULTIS "rbra"
  CASE rket:          RESULTIS "rket"
  CASE sbra:          RESULTIS "sbra"
  CASE sket:          RESULTIS "sket"
  CASE octal:         RESULTIS "octal"

}

LET Rexp(n) = VALOF
   $(1 LET A, B, C, Op = 0, 0, 0, 0

       SWITCHON Symb INTO
       $(A DEFAULT:   Report(32)
                      Nextsymb()
                      A := List2(number, 0)

           CASE name: A := Rname()
                      GOTO L

           CASE stringconst:
                  $( LET S = VEC 200
                     IF Vp=1 DO $( A := List2(number, V!(1))
                                   Nextsymb()
                                   GOTO L  $)
                     V!(0) := Vp
                     // Pack as a string on this 64-bit version of BCPL
                     packstring(V, S)
                  $( LET N = Vp/bytesperword + 1
                     A := Newvec(N)
                     A!0 := stringconst
                     FOR i = 0 TO N-1 DO A!(i+1) := S!(i)
                     Nextsymb()
                     GOTO L  $)  $)

            CASE number: A := 0
                         TEST V!(1)=octal
                           THEN FOR i=2 TO Vp DO A := A LSHIFT 3 LOGOR
                                                         V!i-'0'
                             OR FOR i=1 TO Vp DO A := A*10 + V!i-'0'
                         Nextsymb()
                         A := List2(number, A)
                         GOTO L

           CASE true:
           CASE false:   A := List1(Symb)
                         Nextsymb()
                         GOTO L

           CASE rbra:    Nextsymb()
                         A := Rexp(0)
                         UNLESS Symb=rket DO Report(15)
                         Nextsymb()
                         GOTO L

           CASE valof:   Nextsymb()
                         A := Rblock()
                         A := List2(valof, A)
                         GOTO L

           CASE lv:
           CASE rv:      Op := Symb
                         Nextsymb()
                         A := Rexp(35)
                         A := List2(Op, A)
                         GOTO L

           CASE plus:
           CASE minus:   Op := Symb
                         Nextsymb()
                         A := Rexp(34)
                         IF Op=minus DO TEST H1!(A)=number
                                            THEN H2!(A) := -H2!(A)
                                              OR A := List2(neg, A)
                         GOTO L

           CASE not:   Nextsymb()
                       A := Rexp(25)
                       A := List2(not, A)
                       GOTO L

           CASE table: Nextsymb()
                       A := Rexp(0)
                       A := List2(table, A)
                       GOTO L                  $)A

    L: // A is non zero

       SWITCHON Symb INTO
       $(B DEFAULT:   RESULTIS A // Symb is not an infixed operator

           CASE sbra: Nextsymb()
                      B := 0
                      UNLESS Symb=sket DO
                                      $( B := Rexp(0)
                                         UNLESS Symb=sket DO Report(19)  $)
                      Nextsymb()
                      A := List3(fnap, A, B)
                      GOTO L

           CASE star: Nextsymb()
                      IF Symb=sbra DO  // Vector application
                             $( Nextsymb()
                                B := Rexp(0)
                                UNLESS Symb=sket DO Report(21)
                                Nextsymb()
                                A := List3(vecap, A, B)
                                GOTO L  $)
                      IF n GE 35 RESULTIS A
                      B := Rexp(34)
                      A := List3(mult, A, B)
                      GOTO L

           CASE rem:
           CASE div:  IF n GE 35 RESULTIS A
                      Op := Symb
                      Nextsymb()
                      B := Rexp(34)
                      A := List3(Op, A, B)
                      GOTO L

           CASE plus:
           CASE minus: IF n GE 34 RESULTIS A
                       Op := Symb
                       Nextsymb()
                       B := Rexp(34)
                       A := List3(Op, A, B)
                       GOTO L

           CASE eq:CASE ne:
           CASE ls:CASE gr:
           CASE le:CASE ge:
                       IF n GE 30 RESULTIS A
                       Op := Symb
                       Nextsymb()
                       B := Rexp(29)      // This is the only call of Rexp(29)
                       A := List3(Op, A, B)
                       UNLESS n=29 DO A := List2(rel, A)
                       GOTO L

            CASE lshift:
            CASE rshift: IF n GE 25 RESULTIS A
                         Op := Symb
                         Nextsymb()
                         B := Rexp(30)
                         A := List3(Op, A, B)
                         GOTO L

            CASE logand: IF n GE 24 RESULTIS A
                         Nextsymb()
                         B := Rexp(23)
                         A := List3(logand, A, B)
                         GOTO L

            CASE logor:  IF n GE 23 RESULTIS A
                         Nextsymb()
                         B := Rexp(22)
                         A := List3(logor, A, B)
                         GOTO L

            CASE eqv:
            CASE neqv:   IF n GE 22 RESULTIS A
                         Op := Symb
                         Nextsymb()
                         B := Rexp(22)
                         A := List3(Op, A, B)
                         GOTO L

            CASE cond:   IF n GE 13 RESULTIS A
                         Nextsymb()
                         B := Rexp(12)
                         UNLESS Symb=comma DO Report(30)
                         Nextsymb()
                         C := Rexp(12)
                         A := List4(cond, A, B, C)
                         GOTO L

            CASE comma:  IF n GE 12 RESULTIS A
                         Nextsymb()
                         B := Rexp(0)
                         A := List3(comma, A, B)
                         GOTO L   $)B   $)1

.

// cae3.b 02/13/68 10.02

GET "libhdr"
GET "head1"

LET Rdef() = VALOF
   $(1 LET A, B, Op = 0, 0, 0
       LET N = Rnamelist()
       SWITCHON Symb INTO
       $( CASE sbra:Nextsymb()
                    UNLESS H1!(N)=name DO Report(40)
                    IF Symb=name DO A := Rnamelist()
                    UNLESS Symb=sket DO Report(41)
                    Nextsymb()
                    IF Symb=be DO
                           $( Nextsymb()
                              B := Rblock()
                              A := List4(rtdef, N, A, B)
                              GOTO M  $)
                    IF Symb=eq DO
                           $( Nextsymb()
                              B := Rexp(0)
                              A := List4(fndef, N, A, B)
                              GOTO M  $)
                    Report(42)
                    A := List3(valdef, N, List2(number, 0))
                    GOTO M

           DEFAULT: Report(44)

           CASE eq: Op := valdef
                    Nextsymb()
                    IF Symb=vec DO
                           $( Op := vecdef
                              Nextsymb()
                              UNLESS H1!(N)=name DO Report(43)  $)
                    A := Rexp(0)
                    A := List3(Op, N, A)
                    GOTO M

           M:       IF Symb=and DO
                           $( Nextsymb()
                              B := Rdef()
                              RESULTIS List3(and, A, B)  $)
                    RESULTIS A  $)1

AND Rcom() = VALOF
  $(1 LET A, B, C, Op = 0, 0, 0, 0

      SWITCHON Symb INTO
      $( DEFAULT: RESULTIS 0

         CASE name:CASE number:CASE stringconst:
         CASE true:CASE false:CASE lv:CASE rv:
         CASE rbra:CASE valof:CASE plus:CASE minus:
         // these are all the symbols which can start an expression
                   A := Rexp(0)
                   IF Symb=ass DO $(    Nextsymb()
                                        B := Rexp(0)
                                        A := List3(ass, A, B)
                                        GOTO L  $)
                   IF Symb=colon DO
                          $( UNLESS H1!(A)=name DO Report(50)
                             Nextsymb()
                             B := Rcom()
                             A := List3(colon, A, B)
                             GOTO L  $)
                   IF H1!(A)=fnap DO
                          $( H1!(A) := rtap
                             GOTO L  $)
                   Report(51)
                   GOTO L

         CASE goto:
         CASE resultis: Op := Symb
                        Nextsymb()
                        A := Rexp(0)
                        A := List2(Op, A)
                        GOTO L

         CASE if:
         CASE unless:
         CASE while:
         CASE until: Op := Symb
                     Nextsymb()
                     A := Rexp(0)
                     UNLESS Symb=do DO Report(52)
                     Nextsymb()
                     B := Rcom()
                     A := List3(Op, A, B)
                     GOTO L

          CASE test: Nextsymb()
                     A := Rexp(0)
                     UNLESS Symb=do DO Report(53)
                     Nextsymb()
                     B := Rcom()
                     UNLESS Symb=or DO Report(54)
                     Nextsymb()
                     C := Rcom()
                     A := List4(test, A, B, C)
                     GOTO L

          CASE for: Nextsymb()
                    TEST Symb=name THEN A := Rname()
                                   OR $( Report(64)
                                         Nextsymb()
                                         A := errorname  $)
                    UNLESS Symb=eq DO Report(57)
                    Nextsymb()
                 $( LET I, J = 0, 0
                    I := Rexp(0)
                    UNLESS Symb=to DO Report(58)
                    Nextsymb()
                    J := Rexp(0)
                    UNLESS Symb=do DO Report(59)
                    Nextsymb()
                    B := Rcom()
                    A := List5(for, A, I, J, B)
                    GOTO L  $)

          CASE break:
          CASE finish:
          CASE return: A := List1(Symb)
                       Nextsymb()
                       GOTO L

          CASE switchon: Nextsymb()
                         A := Rexp(0)
                         UNLESS Symb=into DO Report(60)
                         Nextsymb()
                         B := Rblock()
                         A := List3(switchon, A, B)
                         GOTO L

          CASE case: Nextsymb()
                     A := Rexp(0)
                     UNLESS Symb=colon DO Report(61)
                     Nextsymb()
                     B := Rcom()
                     A := List3(case, A, B)
                     GOTO L

          CASE default: Nextsymb()
                        UNLESS Symb=colon DO Report(62)
                        Nextsymb()
                        A := Rcom()
                        A := List2(default, A)
                        GOTO L

          CASE sectbra: A := Rblock()
                        GOTO L  $)

       L: SWITCHON Symb INTO
          $( DEFAULT: RESULTIS A

             CASE repeat: Nextsymb()
                          A := List2(repeat, A)
                          GOTO L

             CASE repeatwhile:
             CASE repeatuntil: Op := Symb
                               Nextsymb()
                               B := Rexp(0)
                               A := List3(Op, A, B)
                               GOTO L  $)1

.

// plist.b 02/13/10:10
// with hand written corrections

GET "libhdr"
GET "head1"

LET Plist(x, n, d) BE
      $(1 LET Size = 0
          IF x=0 DO $( writes( "Nil" )
                       RETURN  $)
          SWITCHON H1!(x) INTO
       $( CASE number: writef( "** Number %n", H2!x)
                       RETURN

          CASE name: writef( "** NAME "); writes(x+2)
                     RETURN

          CASE stringconst: writef( "** String "); writes(x+1)
                            RETURN

          CASE for: Size := Size + 1

          CASE cond:CASE fndef:CASE rtdef:
          CASE test:CASE constdef:
                    Size := Size + 1

          CASE vecap:CASE fnap:
          CASE mult:CASE div:CASE rem:CASE plus:CASE minus:
          CASE eq:CASE ne:CASE gr:CASE ge:CASE ls:CASE le:
          CASE lshift:CASE rshift:CASE logand:CASE logor:
          CASE eqv:CASE neqv:CASE comma:
          CASE and:CASE valdef:CASE vecdef:
          CASE ass:CASE rtap:CASE colon:CASE if:CASE unless:
          CASE while:CASE until:CASE repeatwhile:CASE repeatuntil:
          CASE switchon:CASE case:CASE seq:CASE let:
          CASE manifest:CASE global:CASE static:
                    Size := Size + 1

          CASE valof:CASE lv:CASE rv:CASE neg:CASE not:CASE rel:
          CASE table:
          CASE goto:CASE resultis:CASE repeat:
                    Size := Size + 1

          CASE true:CASE false:CASE break: CASE return:CASE finish:
                    Size := Size + 1

                    IF n=d DO $( writes( "Etc" )
                                 RETURN $)

                    writef( "Op %n", H1!x)
                    FOR i = 2 TO Size DO
                            $( newline()
                               FOR j=0 TO n DO writes( ". " )
                               Plist(H1!(x+i-1), n+1, d)  $)
                    RETURN    $)1

.

// trn0.b 06/14/68 12:19

GET "libhdr"
GET "lbhead"
GET "nhead2"

LET Nextparam() = VALOF $( Paramnumber := Paramnumber + 1
                           RESULTIS Paramnumber  $)

AND Transreport(n, x) BE
       $( //LET a = OUTPUT
          //OUTPUT := MONITOR
          LET a = output()
          selectoutput(stdout)
          Reportcount := Reportcount + 1
          writes( "Report ")
          writen(n)
          writes("   Commands compiled ")
          writen(Comcount); Writech(OUTPUT, '*n')
          Plist(x, 0, 4); Writech(OUTPUT, '*n')
          selectoutput(a)  $)
          //OUTPUT := a  $)

LET CompileAE(x) BE
      $(1 LET a = VEC 1400      // FOR Dvec
          LET c = VEC 20        // FOR Labvec
          LET d = VEC 100       // FOR Globdecl
          LET e = VEC 300       // FOR Casetable

          Dvec, DvecS, DvecE, DvecP, DvecL, DvecT := a, 3, 3, 3, 3, 1400
          DvecB := 3
          Dvec!(0), Dvec!(1), Dvec!(2) := 0, 0, 0

          Labvec, LabvecS, LabvecT := c, 0, 20

          Globdecl, GlobdeclS, GlobdeclT := d, 0, 100

          Casetable, CaseB, CaseP, CaseT := e, 0, 0, 300

          Resultlabel, Breaklabel, Defaultlabel := 0, 0, 0

          Comcount, Currentbranch := 0, x

          Paramnumber := 0
          Savespacesize := 2
ocodestream := stdout
       $( LET L = Nextparam()
          ssp := 0
          Out2(stack, ssp)
          Compjump(L)
          Decllabels(x)
          Checkdistinct(DvecB, DvecS)
          DvecE, DvecL := DvecS, DvecS
          Trans(x)
          Out1(finish)
//sawritef("CompileAE: calling Outputconsts*n")
          Outputconsts()
          Complab(L)
          Out2(global, GlobdeclS/2)
       $( LET i = 0
          UNTIL i=GlobdeclS DO
                 $( OutN(Globdecl!(i))
                    OutL(Globdecl!(i+1))
                    i := i + 2  $)
          Out1(end)
          RETURN  $)1

.

// trn1.b 06/19/68 10:00

GET "libhdr"
GET "nhead2"

LET Trans(x) BE
   $(Trans
       IF x=0 RETURN
       Currentbranch := x
       SWITCHON H1!(x) INTO
       $( CASE let: $( LET a, b, c, S = DvecB, DvecE, DvecS, ssp
                       LET V = VecSSP
                       DvecB := DvecS
                       Declnames(H2!(x))
                       Checkdistinct(DvecB, DvecS)
                       DvecE := DvecS
                       VecSSP := ssp
                       ssp := S
                       Transdef(H2!(x))
                       ssp := VecSSP
                       Out2(stack, ssp)
                       Out1(store)
                       Trans(H3!(x))
                       VecSSP := V
                       DvecB, DvecE, DvecS, ssp := a, b, c, S
                       Out2(stack, ssp)
                       RETURN  $)

          CASE global:
          CASE manifest:
                $(1 LET a, b, c, S = DvecB, DvecE, DvecS, ssp
                    AND P = H1!(x)=global -> global, number
                    DvecB := DvecS
                 $( LET y = H2!(x)
                    UNTIL y=0 DO $( Addname(H3!(y), P, Evalconst(H4!(y)))
                                    y := H2!(y)  $)  $)
                    Checkdistinct(DvecB, DvecS)
                    DvecE := DvecS
                    Trans(H3!(x))
                    DvecB, DvecE, DvecS, ssp := a, b, c, S
                    RETURN  $)1

          CASE static:
                $(1 LET a, b, c, S = DvecB, DvecE, DvecS, ssp
                    LET L = Nextparam()
                    Compjump(L)
                    DvecB := ssp

                 $( LET y = H2!(x)
                    UNTIL y=0 DO
                          $( LET M = Nextparam()
                             Compdatalab(M)
                             Out2(itemn, Evalconst(H4!(y)))
                             Addname(H3!(y), label, M)
                             y := H2!(y)   $)  $)
                    Checkdistinct(DvecB, DvecS)
                    DvecE := DvecS
                    Complab(L)
                    Trans(H3!(x))
                    DvecB, DvecE, DvecS, ssp := a, b, c, S
                    RETURN   $)1

          CASE ass: Assign(H2!(x), H3!(x))
                    RETURN

          CASE rtap:
                 $( LET S = ssp
                    ssp := ssp+Savespacesize
                    Out2(stack, ssp)
                    Loadlist(H3!(x))
                    Load(H2!(x))
                    Out2(rtap, S)
                    ssp := S
                    RETURN    $)

          CASE goto: Load(H2!(x))
                     Out1(goto)
                     ssp := ssp - 1
                     Outputconsts()
                     RETURN

          CASE colon: $( LET t = Cellwithname(H2!(x))
                         IF t GE DvecL & Dvec!(t+1) NE global DO
                                                   Transreport(140, x)
                         Translabel(H2!(x))
                         Out2(stack, ssp)
                         Trans(H3!(x))
                         RETURN  $)

          CASE if:
          CASE unless: $( LET L = Nextparam()
                          Jumpcond(H2!(x), H1!(x)=unless, L)
                          Trans(H3!(x))
                          Complab(L)
                          RETURN  $)

          CASE test: $( LET L, M = Nextparam(), Nextparam()
                        Jumpcond(H2!(x), FALSE, L)
                        Trans(H3!(x))
                        Compjump(M)
                        Complab(L)
                        Trans(H4!(x))
                        Complab(M)
                        RETURN  $)

          CASE break: IF Breaklabel=0 DO Breaklabel := Nextparam()
                      Compjump(Breaklabel)
                      RETURN

          CASE return: Out1(rtrn)
                       RETURN

          CASE finish: Out1(finish)
                       RETURN

          CASE resultis: Load(H2!(x))
                         Out2P(res, Resultlabel)
                         ssp := ssp - 1
                         RETURN

          CASE while:
          CASE until:
                 $( LET L, M = Nextparam(), Nextparam()
                    LET bl = Breaklabel
                    Breaklabel := 0
                    Compjump(M)
                    Complab(L)
                    Trans(H3!(x))
                    Complab(M)
                    Jumpcond(H2!(x), H1!(x)=while, L)
                    UNLESS Breaklabel=0 DO $( Complab(Breaklabel)
                                              Out2(stack, ssp)  $)
                    Breaklabel := bl
                    RETURN  $)

          CASE repeat:
          CASE repeatwhile:
          CASE repeatuntil:
                 $( LET L, bl = Nextparam(), Breaklabel
                    Breaklabel := 0
                    Complab(L)
                    Trans(H2!(x))
                    TEST H1!(x)=repeat
                              THEN Compjump(L)
                                OR Jumpcond(H3!(x), H1!(x)=repeatwhile, L)
                    UNLESS Breaklabel=0 DO $( Complab(Breaklabel)
                                              Out2(stack, ssp)  $)
                    Breaklabel := bl
                    RETURN  $)

          CASE case: $( LET L, y = Nextparam(), Evalconst(H2!(x))
                        IF CaseP GE CaseT DO Transreport(141,x)
                        Casetable!(CaseP) := y
                        Casetable!(CaseP+1) := L
                        CaseP := CaseP + 2
                        Complab(L)
                        Trans(H3!(x))
                        RETURN  $)

          CASE default: UNLESS Defaultlabel=0 DO Transreport(101,x)
                        Defaultlabel := Nextparam()
                        Complab(Defaultlabel)
                        Trans(H2!(x))
                        RETURN

          CASE switchon: Transswitch(x)
                         RETURN

          CASE for:
                 $( LET a, b = DvecE, DvecS
                    LET L, M = Nextparam(), Nextparam()
                    LET bl = Breaklabel
                    LET S1 = ssp
                    Breaklabel := 0
                    Addname(H2!(x), local, S1)
                    DvecE := DvecS
                    Load(H3!(x))
                 $( LET S2 = ssp
                    Load(H4!(x))
                    Out1(store)
                    Compjump(L)
                    Complab(M)
                    Trans(H5!(x))
                    Out2(lp, S1); Out2(ln, 1); Out1(plus); Out2(sp, S1)
                    Complab(L)
                    Out2(lp, S1); Out2(lp, S2); Out1(le); Out2P(jt, M)
                    UNLESS Breaklabel=0 DO Complab(Breaklabel)
                    Breaklabel, ssp := bl, S1
                    Out2(stack, ssp)
                    DvecE, DvecS := a, b
                    RETURN  $)  $)

          CASE seq: Trans(H2!(x))
                    Comcount := Comcount + 1
                    Trans(H3!(x))
                    RETURN              $)Trans

.

// trns2.b 06/14/68 12:30

GET "libhdr"
GET "nhead2"

LET Declnames(x) BE
  $(dn IF x=0 RETURN
       SWITCHON H1!(x) INTO
       $( CASE and: Declnames(H2!(x))
                    Declnames(H3!(x))
                    RETURN

          CASE vecdef:
          CASE valdef: Declvars(H2!(x))
                       RETURN

          CASE rtdef:
          CASE fndef: Declconst(H2!(x))
                      RETURN

          DEFAULT: Transreport(102,x)    $)dn

AND Declvars(x) BE
       $( IF x=0 RETURN
          IF H1!(x)=name DO
                    $( Addname(x,local,ssp)
                       ssp := ssp + 1
                       RETURN  $)
          IF H1!(x)=comma DO
                    $( Addname(H2!(x),local,ssp)
                       ssp := ssp + 1
                       Declvars(H3!(x))
                       RETURN  $)
          Transreport(103,x)  $)

AND Declconst(x) BE
       $( LET t = Cellwithname(x)
          TEST Dvec!(t+1)=global THEN Addname(x,global,Dvec!(t+2))
                                   OR Addname(x,label,Nextparam())  $)

AND Checkdistinct(E, S) BE
          $( UNTIL E=S DO $( LET p = E + 3
                             AND N = Dvec!(E)
                             WHILE p LS S DO
                                    $( IF Dvec!(p)=N DO
                                           $( Transreport(142,N)  $)
                                       p := p + 3  $)
                             E := E + 3 $)  $)

AND Addname(N, P, A) BE
          $( IF DvecS GE DvecT DO Transreport(143, N)
             Dvec!(DvecS), Dvec!(DvecS+1), Dvec!(DvecS+2) := N, P, A
             DvecS := DvecS + 3  $)

AND Cellwithname(N) = VALOF
                    $( LET x = DvecE
                       $( x := x - 3
                          IF x=0 RESULTIS 0  $) REPEATUNTIL Dvec!(x)=N
                       RESULTIS x  $)

AND Loadlist(x) BE
       $( IF x=0 RETURN
          IF H1!(x)=comma DO $( Loadlist(H2!(x))
                                Loadlist(H3!(x))
                                RETURN  $)
          Load(x)  $)

AND Translabel(x) BE      // This creates the Rvalue OF a Fn Rt or label
       $( LET L = Nextparam()
          LET N = Cellwithname(x)
          Complab(L)
          TEST Dvec!(N+1)=global
                    THEN $(   IF GlobdeclS GE GlobdeclT DO Transreport(144,x)
                              Globdecl!(GlobdeclS) := Dvec!(N+2)
                              Globdecl!(GlobdeclS+1) := L
                              GlobdeclS := GlobdeclS + 2  $)

                    OR   $(   IF LabvecS GE LabvecT DO
                                               $( LET L = Nextparam()
                                                  Compjump(L)
                                                  Complab(L)  $)
                              Labvec!(LabvecS) := Dvec!(N+2)
                              Labvec!(LabvecS+1) := L
                              LabvecS := LabvecS + 2  $)  $)

AND Decllabels(x) BE
    $( IF x=0 RETURN
       SWITCHON H1!(x) INTO
       $( DEFAULT:  RETURN

          CASE colon: Declconst(H2!(x))
                      Decllabels(H3!(x))
                      RETURN

          CASE let:CASE case:CASE manifest:CASE global:CASE static:
          CASE if:CASE unless:CASE while:CASE until:
          CASE switchon:
                    Decllabels(H3!(x))
                    RETURN

          CASE repeatwhile:CASE repeatuntil:
          CASE default:CASE repeat:
                    Decllabels(H2!(x))
                    RETURN

          CASE seq: Decllabels(H2!(x))
                    Decllabels(H3!(x))
                    RETURN

          CASE test: Decllabels(H3!(x))
                     Decllabels(H4!(x))
                     RETURN

          CASE for: Decllabels(H5!(x))
                    RETURN               $)  $)

AND Transdef(x) BE
   $(1 IF x=0 RETURN
       SWITCHON H1!(x) INTO
       $( CASE and: Transdef(H2!(x))
                    Transdef(H3!(x))
                    RETURN

          CASE vecdef: Out2(llp, VecSSP)
                       ssp := ssp + 1
                       VecSSP := VecSSP + 1 + Evalconst(H3!(x))
                       RETURN

          CASE valdef: Loadlist(H3!(x))
                       RETURN

          CASE fndef:
          CASE rtdef:
                $(2 LET L = Nextparam()
                    Compjump(L)         // compile jump round body

                $(3 LET a, b, c, d, e = DvecE, DvecB, DvecS, DvecL, DvecP
                    LET S = ssp

                    Translabel(H2!(x))   // Compile the entry
                    ssp := Savespacesize

                    DvecP, DvecB := DvecS, DvecS
                    Declvars(H3!(x))   // declare the fpl
                    Checkdistinct(DvecB, DvecS)
                    DvecE, DvecB := DvecS, DvecS
                    Decllabels(H4!(x))    // declare the labels
                    Checkdistinct(DvecB, DvecS)
                    DvecE, DvecL := DvecS, DvecS

                    Out2(save, ssp)

                    TEST H1!(x)=fndef
                              THEN $( Load(H4!(x)); Out1(fnrn)  $)
                                OR $( Trans(H4!(x)); Out1(rtrn)  $)
                    Outputconsts()
                    ssp := S
                    Out2(stack, ssp)
                    DvecE, DvecB, DvecS, DvecL, DvecP := a, b, c, d, e  $)3

                    Complab(L)
                    RETURN  $)2

          DEFAULT: RETURN  $)1

.

// trn3.b 06/14/68 12:39

GET "libhdr"
GET "nhead2"

LET Jumpcond(x, B, L) BE
  $(jc SWITCHON H1!(x) INTO
       $( CASE true: IF B DO Compjump(L)
                     RETURN

          CASE false: UNLESS B DO Compjump(L)
                      RETURN

          CASE rel: Jumpcond(H2!(x), B, L)
                    RETURN

          CASE not: Jumpcond(H2!(x), NOT B, L)
                    RETURN

          CASE logand: TEST B THEN $( LET M = Nextparam()
                                      Jumpcond(H2!(x), FALSE, M)
                                      Jumpcond(H3!(x), TRUE, L)
                                      Complab(M)  $)
                              OR   $( Jumpcond(H2!(x), FALSE, L)
                                      Jumpcond(H3!(x), FALSE, L)  $)
                       RETURN

          CASE logor:  TEST B THEN $( Jumpcond(H2!(x), TRUE, L)
                                      Jumpcond(H3!(x), TRUE, L)  $)
                              OR   $( LET M = Nextparam()
                                      Jumpcond(H2!(x), TRUE, M)
                                      Jumpcond(H3!(x), FALSE, L)
                                      Complab(M)  $)
                       RETURN

          CASE cond: $( LET M, N = Nextparam(), Nextparam()
                        Jumpcond(H2!(x), FALSE, M)
                        Jumpcond(H3!(x), B, L)
                        Compjump(N)
                        Complab(M)
                        Jumpcond(H4!(x), B, L)
                        Complab(N)
                        RETURN  $)

          DEFAULT: Load(x)
                   Out2P(B -> jt, jf, L)
                   ssp := ssp - 1
                   RETURN     $)jc

.

// trn4.b 06/14/68 12:42

GET "nhead2"

LET Transswitch(x) BE
      $(1 LET P, dl = CaseP, Defaultlabel
          LET L, M = Nextparam(), Nextparam()

          Compjump(L)
          Defaultlabel := 0
          Trans(H3!(x))
          Compjump(M)
          Complab(L)
          Load(H2!(x))
          IF Defaultlabel=0 DO Defaultlabel := M
          Out3P(switchon, (CaseP-P)/2, Defaultlabel)
       $( LET i = P
          UNTIL i=CaseP DO $( OutN(Casetable!(i))
                              OutL(Casetable!(i+1))
                              i := i + 2  $)
          ssp := ssp - 1
          Complab(M)
          CaseP, Defaultlabel := P, dl  $)1

.

// trn5.BCPL 06/14/68 12:43

GET "libhdr"
GET "nhead2"

LET Load(x) BE
   $(1 IF x=0 DO $( Transreport(148, Currentbranch)
                    Out2(ln, 0)
                    ssp := ssp + 1
                    RETURN  $)
    $( LET Op = H1!(x)
       SWITCHON Op INTO
       $( DEFAULT: Transreport(147, Currentbranch)
                   Out2(ln, 0)
                   ssp := ssp + 1
                   RETURN

          CASE div:CASE rem:
          CASE minus:
          CASE ls:CASE gr:CASE le:CASE ge:
          CASE lshift:CASE rshift:
                    Load(H2!(x))
                    Load(H3!(x))
                    Out1(Op)
                    ssp := ssp - 1
                    RETURN

          CASE mult:CASE plus:CASE eq:CASE ne:
          CASE logand:CASE logor:CASE eqv:CASE neqv:
                 $( LET A, B = H2!(x), H3!(x)
                    IF H1!(A)=name LOGOR H1!(A)=number DO
                                        A, B := H3!(x), H2!(x)
                    Load(A)
                    Load(B)
                    Out1(Op)
                    ssp := ssp - 1
                    RETURN  $)

          CASE vecap: $( LET A, B = H2!(x), H3!(x)
                         IF H1!(A)=name DO
                                     A, B := H3!(x), H2!(x)
                         Load(A)
                         Load(B)
                         Out1(plus)
                         Out1(rv)
                         ssp := ssp - 1
                         RETURN   $)

          CASE neg:CASE not:CASE rv:
                    Load(H2!(x))
                    Out1(Op)
                    RETURN

          CASE true:CASE false:
                    Out1(Op)
                    ssp := ssp + 1
                    RETURN

          CASE lv: LoadLV(H2!(x))
                   RETURN

          CASE rel: Load(H2!(x))         // temporary fix
                    RETURN               // for compatibility

          CASE number: Out2(ln, H2!(x))
                       ssp := ssp + 1
                       RETURN

          CASE stringconst: $(  LET v = VEC 520
                                // Unpack the string from 64-bit words
                                unpackstring(LV H2!(x), v)
                                Out2(lstr, v!(0))
                                FOR i = 1 TO v!(0) DO OutC(v!(i))
                                Writech(OUTPUT, '*n')
                                ssp := ssp + 1
                                RETURN  $)

          CASE name:
                 $( LET t = Cellwithname(x)
                    LET K, N = Dvec!(t+1), Dvec!(t+2)
                    IF t=0 DO Transreport(115,x)
                    IF t LS DvecP & K=local DO Transreport(116,x)
                    ssp := ssp + 1
                    SWITCHON K INTO
                    $( DEFAULT:
                       CASE number: Out2(ln, N); RETURN

                       CASE local:  Out2(lp, N); RETURN

                       CASE global: Out2(lg, N); RETURN

                       CASE label: Out2P(ll, N); RETURN    $)  $)

           CASE valof: $( LET rl = Resultlabel
                          LET a, b, c, d = DvecL, DvecB, DvecS, DvecE
                          DvecB := DvecS
                          Decllabels(H2!(x))
                          Checkdistinct(DvecB, DvecS)
                          DvecE, DvecL := DvecS, DvecS
                          Resultlabel := Nextparam()
                          Trans(H2!(x))
                          Complab(Resultlabel)
                          Out2(rstack, ssp)
                          ssp := ssp + 1
                          DvecL, DvecB, DvecS, DvecE := a, b, c, d
                          Resultlabel := rl
                          RETURN  $)

           CASE fnap: $( LET S = ssp
                         ssp := ssp + Savespacesize
                         Out2(stack, ssp)
                         Loadlist(H3!(x))
                         Load(H2!(x))
                         Out2(fnap, S)
                         ssp := S + 1
                         RETURN   $)

           CASE cond: $( LET L, M = Nextparam(), Nextparam()
                         LET S = ssp
                         Jumpcond(H2!(x), FALSE, M)
                         Load(H3!(x))
                         Compjump(L)
                         ssp := S; Out2(stack, ssp)
                         Complab(M)
                         Load(H4!(x))
                         Complab(L)
                         RETURN   $)

           CASE table: $( LET L, M = Nextparam(), Nextparam()
                          Compjump(L)
                          Compdatalab(M)
                          x := H2!(x)
                          WHILE H1!(x)=comma DO
                                      $( Out2(itemn, Evalconst(H2!(x)))
                                         x := H3!(x)  $)
                          Out2(itemn, Evalconst(x))
                          Complab(L)
                          Out2P(lll, M)
                          ssp := ssp + 1
                          RETURN  $)
                                         $)1

AND LoadLV(x) BE
   $(1 IF x=0 DO  $( Transreport(113, Currentbranch)
                     Out2(ln, 0)
                     ssp := ssp + 1
                     RETURN  $)

       SWITCHON H1!(x) INTO
       $( DEFAULT: $( Transreport(113, Currentbranch)
                      Out2(ln, 0)
                      ssp := ssp + 1
                      RETURN  $)

          CASE name: $( LET t = Cellwithname(x)
                        LET K, N = Dvec!(t+1), Dvec!(t+2)
                        IF t=0 DO Transreport(115, x)
                        IF t LS DvecP & K=local DO Transreport(116, x)
                        ssp := ssp + 1
                        SWITCHON K INTO
                        $( CASE local:  Out2(llp, N); RETURN

                           CASE global: Out2(llg, N); RETURN

                           CASE label: Out2P(lll, N); RETURN   $)

                        Transreport(113, Currentbranch)
                        Out2(ln, 0)
                        //ssp := ssp + 1   corrected
                        RETURN  $)

           CASE rv: Load(H2!(x))
                    RETURN

           CASE vecap: $( LET A, B = H2!(x), H3!(x)
                          IF H1!(x)=name DO
                                      A, B := H3!(x), H2!(x)
                          Load(A)
                          Load(B)
                          Out1(plus)
                          ssp := ssp - 1
                          RETURN    $)
                                         $)1
.

// trn6.b 06/14/68 12:52

GET "libhdr"
GET "nhead2"

LET Evalconst(x) = VALOF
    $( IF x=0 DO $( Transreport(117, Currentbranch)
                    RESULTIS 0  $)
       SWITCHON H1!(x) INTO
       $( DEFAULT:  Transreport(118,x)
                    RESULTIS 0

          CASE name: $( LET t = Cellwithname(x)
                        IF Dvec!(t+1)=number RESULTIS Dvec!(t+2)
                        Transreport(119,x)
                        RESULTIS 0  $)

          CASE number: RESULTIS H2!(x)

          CASE neg: RESULTIS -Evalconst(H2!(x))

          CASE mult: RESULTIS Evalconst(H2!(x)) * Evalconst(H3!(x))
          CASE div:  RESULTIS Evalconst(H2!(x)) / Evalconst(H3!(x))
          CASE plus: RESULTIS Evalconst(H2!(x)) + Evalconst(H3!(x))
          CASE minus:RESULTIS Evalconst(H2!(x)) - Evalconst(H3!(x))  $)  $)

AND Assign(x, y) BE
   $(1 IF x=0 LOGOR y=0 DO
              $( UNLESS x=0 & y=0 DO Transreport(110, Currentbranch)
                 RETURN  $)
       SWITCHON H1!(x) INTO
       $( CASE comma: UNLESS H1!(y)=comma DO
                              $( Transreport(112, Currentbranch)
                                 RETURN  $)
                      Assign(H2!(x), H2!(y))
                      Assign(H3!(x), H3!(y))
                      RETURN

          CASE name:$( LET t = Cellwithname(x)
                       LET K, N = Dvec!(t+1), Dvec!(t+2)
                       IF t=0 DO $( Transreport(115, x); RETURN $)
                       IF t LS DvecP & K=local DO
                                        Transreport(116, x)
                       Load(y)
                       ssp := ssp - 1
                       SWITCHON K INTO
                       $( DEFAULT: abort(9123) // Should never happen

                          CASE number: Transreport(116, x)
                                       N := 0

                          CASE local: Out2(sp, N); RETURN

                          CASE global: Out2(sg, N); RETURN

                          CASE label: Out2P(sl, N); RETURN  $)  $)

          CASE rv:
          CASE vecap:
                      Load(y)
                      LoadLV(x)
                      Out1(stind)
                      ssp := ssp - 2
                      RETURN

          DEFAULT: Transreport(109, Currentbranch)  $)1

.

// trn7.b 06/14/68 17;50

GET "libhdr"
GET "nhead2"

LET Complab(L) BE
          $( Out2P(lab, L)  $)

AND Compdatalab(L) BE
          $( Out2P(datalab, L)  $)

AND Compjump(L) BE
          $( Out2P(jump,L)
             Outputconsts()  $)

AND Outputconsts() BE
       $(1 
           UNTIL LabvecS=0 DO
                    $( Compdatalab(Labvec!(LabvecS-2))
                       Out2P(iteml, Labvec!(LabvecS-1))
                       LabvecS := LabvecS - 2  $)1

AND Out1(x) BE
       $( Writeop(x); Writech(OUTPUT, '*n') $)

AND Out2(x, y) BE
       $( Writeop(x); Writech(OUTPUT, '*t')
          WriteN(y); Writech(OUTPUT, '*n')  $)

AND Out2P(x, y) BE
       $( Writeop(x); writes("*tL")
          WriteN(y); Writech(OUTPUT, '*n')  $)

AND Out3P(x, y, z) BE
       $( Writeop(x); Writech(OUTPUT, '*t')
          WriteN(y); writes("*tL")
          WriteN(z); Writech(OUTPUT, '*n')  $)

AND OutN(x) BE
       $( WriteN(x)  $)

AND OutL(x) BE
       $( writes("*tL"); WriteN(x); Writech(OUTPUT, '*n')  $)

AND OutC(x) BE
       $( WriteN(x)
          Writech(OUTPUT, '*s')  $)

AND Writeop(x) BE
   $(1 LET S = VALOF
       $( SWITCHON x INTO
       $( DEFAULT:  writef("writeop: x=%n*n", x)
                    RESULTIS "$ $ $ $ $ $ $ $ $ $"

          CASE end:            RESULTIS "END"
          CASE mult:           RESULTIS "MULT"
          CASE div:            RESULTIS "DIV"
          CASE rem:            RESULTIS "REM"
          CASE plus:           RESULTIS "PLUS"
          CASE minus:          RESULTIS "MINUS"
          CASE eq:             RESULTIS "EQ"
          CASE ne:             RESULTIS "NE"
          CASE ls:             RESULTIS "LS"
          CASE gr:             RESULTIS "GR"
          CASE le:             RESULTIS "LE"
          CASE ge:             RESULTIS "GE"
          CASE lshift:         RESULTIS "LSHIFT"
          CASE rshift:         RESULTIS "RSHIFT"
          CASE logand:         RESULTIS "LOGAND"
          CASE logor:          RESULTIS "LOGOR"
          CASE eqv:            RESULTIS "EQV"
          CASE neqv:           RESULTIS "NEQV"

          CASE neg:            RESULTIS "NEG"
          CASE not:            RESULTIS "NOT"
          CASE rv:             RESULTIS "RV"

          CASE true:           RESULTIS "TRUE"
          CASE false:          RESULTIS "FALSE"

          CASE lp:             RESULTIS "LP"
          CASE lg:             RESULTIS "LG"
          CASE ln:             RESULTIS "LN"
          CASE lstr:           RESULTIS "LSTR"
          CASE ll:             RESULTIS "LL"

          CASE llp:            RESULTIS "LLP"
          CASE llg:            RESULTIS "LLG"
          CASE lll:            RESULTIS "LLL"

          CASE sp:             RESULTIS "SP"
          CASE sg:             RESULTIS "SG"
          CASE sl:             RESULTIS "SL"
          CASE stind:          RESULTIS "STIND"

          CASE jump:           RESULTIS "JUMP"
          CASE jt:             RESULTIS "JT"
          CASE jf:             RESULTIS "JF"
          CASE goto:           RESULTIS "GOTO"
          CASE lab:            RESULTIS "LAB"
          CASE stack:          RESULTIS "STACK"
          CASE store:          RESULTIS "STORE"

          CASE save:           RESULTIS "SAVE"
          CASE fnap:           RESULTIS "FNAP"
          CASE fnrn:           RESULTIS "FNRN"
          CASE rtap:           RESULTIS "RTAP"
          CASE rtrn:           RESULTIS "RTRN"
          CASE res:            RESULTIS "RES"
          CASE rstack:         RESULTIS "RSTACK"
          CASE finish:         RESULTIS "FINISH"

          CASE switchon:       RESULTIS "SWITCHON"
          CASE global:         RESULTIS "GLOBAL"
          CASE datalab:        RESULTIS "DATALAB"
          CASE itemn:          RESULTIS "ITEMN"
          CASE iteml:          RESULTIS "ITEML"     $)   $)

       writes(S)      $)1
.

// ncg0.b 05/23/68 11:56

GET "libhdr"
GET "lbhead"
GET "nhead3"

// This section is only here for the cross reference listing

LET start1() BE
$(1       LET V = VEC 1778
          InitializeIO(V, 1778)
          MONITOR := Createoutput(0, 0, 0)
          OUTPUT := MONITOR
          Setmem(#o77377)
          writes("Cgfap Mk 4 entered*n")

       $( LET N1, N2 = 0, BCDword("OCODE")
          Listing, BSSing, ocode, Filing := FALSE, TRUE, FALSE, FALSE
          FOR i = 1 TO 20 DO
                 $( LET W, M = Getcom(i), FALSE
                    IF W = #o777777777777 BREAK
                    IF W=BCDword(" nobss") DO M, BSSing := TRUE, FALSE
                    IF W=BCDword("  list") DO M, Listing := TRUE,TRUE
                    IF W=BCDword("  file") DO M, Filing := TRUE, TRUE
                    UNLESS M DO
                           $( IF i=1 DO N1 := W
                              IF i=2 DO N2 := W  $)
Rep:      INPUT := Findinput(N1, N2)
          Endread(INPUT)
          IF N1=0 GOTO Rep
          Chncom(0)   $)1

.

// ncg1.b 05/23/68 11:58

GET "libhdr"
GET "nhead3"

LET Readop() = VALOF
      $(1 LET LvCh = LV Ch
          LET S = VEC 100
          LET v = VEC 20
          LET T(S) = VALOF
                $(2 LET i, j = 0, bytesperword-1

                    $( UNLESS WordV!(i)=S!(i) RESULTIS FALSE
                       IF j GE Vp RESULTIS TRUE
                       i, j := i+1, j+bytesperword  $) REPEAT  $)2

          Readch(INPUT, LvCh) REPEATWHILE Ch LE '*s'
          WordV := v
          S!(1) := Ch
          Vp := 1
          Readch(INPUT, LvCh)

          $( Vp := Vp + 1
             S!(Vp) := Ch
             Readch(INPUT, LvCh)  $) REPEATWHILE 'A' LE Ch LE 'Z'

          S!(0) := Vp
          packstring(S, WordV)

          SWITCHON S!(1) INTO

       $( DEFAULT: IF Ch=endstreamch RESULTIS end
                   RESULTIS error

          CASE 'D':
          RESULTIS T("DATALAB") -> datalab,
                   T("DIV") -> div, error

          CASE 'E':
          RESULTIS T("EQ") -> eq,
                   T("EQV") -> eqv,
                   T("END") -> end, error

          CASE 'F':
          RESULTIS T("FNAP") -> fnap,
                   T("FNRN") -> fnrn,
                   T("FALSE") -> false,
                   T("FINISH") -> finish, error

          CASE 'G':
          RESULTIS T("GOTO") -> goto,
                   T("GE") -> ge,
                   T("GR") -> gr,
                   T("GLOBAL") -> global, error

          CASE 'I':
          RESULTIS T("ITEML") -> iteml,
                   T("ITEMN") -> itemn, error

          CASE 'J':
          RESULTIS T("JUMP") -> jump,
                   T("JF") -> jf,
                   T("JT") -> jt, error

          CASE 'L':
          IF Vp=2 DO
                 SWITCHON S!(2) INTO
                 $( DEFAULT:  RESULTIS error
                    CASE 'E': RESULTIS le
                    CASE 'N': RESULTIS ln
                    CASE 'G': RESULTIS lg
                    CASE 'P': RESULTIS lp
                    CASE 'L': RESULTIS ll
                    CASE 'S': RESULTIS ls  $)

          RESULTIS T("LAB") -> lab,
                   T("LLG") -> llg,
                   T("LLL") -> lll,
                   T("LLP") -> llp,
                   T("LOGAND") -> logand,
                   T("LOGOR") -> logor,
                   T("LSHIFT") -> lshift,
                   T("LSTR") -> lstr, error

          CASE 'M':
          RESULTIS T("MINUS") -> minus,
                   T("MULT") -> mult, error

          CASE 'N':
          RESULTIS T("NE") -> ne,
                   T("NEG") -> neg,
                   T("NEQV") -> neqv,
                   T("NOT") -> not, error

          CASE 'P':
          RESULTIS T("PLUS") -> plus, error

          CASE 'R':
          RESULTIS T("RES") -> res,
                   T("REM") -> rem,
                   T("RTAP") -> rtap,
                   T("RTRN") -> rtrn,
                   T("RSHIFT") -> rshift,
                   T("RSTACK") -> rstack,
                   T("RV") -> rv, error

          CASE 'S':
          RESULTIS T("SG") -> sg,
                   T("SP") -> sp,
                   T("SL") -> sl,
                   T("STIND") -> stind,
                   T("STACK") -> stack,
                   T("SAVE") -> save,
                   T("SWITCHON") -> switchon,
                   T("STORE") -> store, error

          CASE 'T':
          RESULTIS T("TRUE") -> true, error
                                              $)1

AND ReadN() = VALOF
      $(1 LET Ch, A, Neg = 0, 0, FALSE

          LET LvCh = LV Ch
          Readch(INPUT, LvCh) REPEATWHILE Ch LE '*s'
          IF Ch='-' DO $( Neg := TRUE; Readch(INPUT, LvCh)  $)

          WHILE '0' LE Ch LE '9' DO
                    $( A := A * 10 + Ch - '0'
                       Readch(INPUT, LvCh)  $)
          RESULTIS Neg -> -A, A  $)1

AND ReadL() = VALOF
      $( LET Ch, A = 0, 0
         LET LvCh = LV Ch
         Readch(INPUT, LvCh) REPEATWHILE Ch LE '*s'

         UNLESS Ch='L' DO Report(302)

         Readch(INPUT, LvCh)
         WHILE '0' LE Ch LE '9' DO
                   $( A := A * 10 + Ch - '0'
                      Readch(INPUT, LvCh)  $)
         RESULTIS A  $)

.

// ncg2.b 05/23/68 12:52
 
GET "libhdr"
GET "lbhead"
GET "nhead3"

LET Cgfap(N) BE
      $(1 LET v = VEC 200
          ConstV, ConstP, ConstT := v, 0, 200
       $( LET v = VEC 200
          ConstL := v
       $( LET v = VEC 300
          Svec, SvecP, SvecT := v, 0, 300
       $( LET v = VEC 300
          StatV, StatP, StatT := v, 0, 300
       $( LET v = VEC 500
          TempV, TempT := v, v+500
       $( LET v = VEC 2000
          Parv, Paramnumber := v, 1000
       $( LET v = VEC 2000
          RefV, RefP := v, 0
       $( LET v = VEC 4000
          stv := v

          writes("Cgfap Mk 4 entered*n")
          //writef("N=%s*n", BCD2ASCII(N, TABLE 0,0,0,0))
          Nulladdr := TABLE 0, 0, 0, 0, 0, 0
          Glob0 := TABLE 0, 0, 0, 1, 0, 0
          V1 := TABLE 0, 0, 0, 0, 0, 0
          V2 := TABLE 0, 0, 0, 0, 0, 0

          Commonbreak := #o76640
          Initstack(0)

          SetupBSS(N)

          fapstream := stdout
          IF fapname DO
          { fapstream := findoutput(fapname)
            UNLESS fapstream DO
            { writef("Unable to open output file: %s*n", fapname)
              RETURN
            }
          }

          selectoutput(fapstream)
      
          //IF Filing & N NE 0 DO OUTPUT := Createoutput(N, BCDword("  LIST"), 0)
          Endlab := Nextparam()
          Scan()
          Outconsts()
          Outnumbs()
          wrlab(Endlab)
          Compile(pca, Nulladdr)

          //IF Filing & N NE 0 DO Endwrite(OUTPUT)
          //OUTPUT := MONITOR

          UNLESS fapstream=stdout DO
          { endstream(fapstream)
            fapstream := 0
          }
          selectoutput(stdout)

          //IF N=0 DO N := BCDword(".bcpl.")
          IF BSSing DO wrbss(N)
  $)1

AND Nextparam() = VALOF
          $( Paramnumber := Paramnumber + 1
             RESULTIS Paramnumber  $)

AND Initstack(S) BE
       $( Arg2, Arg1 := TempV, TempV + Tempsize
          ssp := S
          H1!(Arg2), H2!(Arg2), H3!(Arg2), H5!(Arg2) := local, 0, ssp-2, ssp-2
          H1!(Arg1), H2!(Arg1), H3!(Arg1), H5!(Arg1) := local, 0, ssp-1, ssp-1  $)

.

// ncg3.b 05/23/68 12:54

GET "libhdr"
GET "lbhead"
GET "nhead3"

LET Scan() BE
   $(1 LET A1 = 0

  Next: Op := Readop()

     L: SWITCHON Op INTO
        $( DEFAULT: Report(303)
                    GOTO Next

           CASE end: IF ocode DO writef("# END*n")
                     RETURN

           CASE lg: A1 := ReadN()
                    IF ocode DO writef("# LG %n*n", A1)
                    LoadT(global, A1); GOTO Next
           CASE lp: A1 := ReadN()
                    IF ocode DO writef("# LP %n*n", A1)
                    LoadT(local, A1); GOTO Next
           CASE ll: A1 := ReadL()
                    IF ocode DO writef("# LL L%n*n", A1)
                    LoadT(label, A1); GOTO Next

           CASE ln: A1 := ReadN()
                    IF ocode DO writef("# LN %n*n", A1)
                    LoadT(number, A1); GOTO Next

           CASE lstr: A1 := ReadN()
                      CGstring(A1); GOTO Next

           CASE true: IF ocode DO writef("# TRUE*n")
                      LoadT(number, TRUE); GOTO Next
           CASE false: IF ocode DO writef("# FALSE*n")
                       LoadT(number, FALSE); GOTO Next

           CASE llp: A1 := ReadN()
                     IF ocode DO writef("# LLP %n*n", A1)
                     FreeAC()
                     wrfaps(pca, 0, 0, 0, 0, 4, 0)
                     wrfaps(add, 0, 0, CellN(A1), 0, 0, 0)
                     LoadT(ACreg, 0)
                     GOTO Next

           CASE llg: A1 := ReadN()
                     IF ocode DO writef("# LLG %n*n", A1)
                     LoadT(label, Staticcell(A1, 0)); GOTO Next
           CASE lll: A1 := ReadL()
                     IF ocode DO writef("# LLL L%n*n", A1)
                     LoadT(label, Staticcell(0, A1)); GOTO Next

           CASE sp: A1 := ReadN()
                    IF ocode DO writef("# SP %n*n", A1)
                    Storein(local, A1); GOTO Next
           CASE sg: A1 := ReadN()
                    IF ocode DO writef("# SG %n*n", A1)
                    Storein(global, A1); GOTO Next
           CASE sl: A1 := ReadL()
                    IF ocode DO writef("# SL L%n*n", A1)
                    Storein(label, A1); GOTO Next
           CASE stind: IF ocode DO writef("# STIND*n")
                       StoreI();
                       GOTO Next

           CASE mult: IF ocode DO writef("# MULT*n")
                      $( LET A1, A2 = Arg1, Arg2
                         IF Addrble(Arg2) DO A1, A2 := Arg2, Arg1
                         Makeaddrble(A1)
                         MovetoMQ(A2)
                         FreeAC()
                         Compile(mpy, Addr(A1, V1))
                         Lose1(MQreg, 0)
                         GOTO Next  $)

           CASE div:
           CASE rem: IF ocode DO writef(Op=div -> "# DIV*n", "# REM*n")
                     Makeaddrble(Arg1)
                     FreeMQ()
                     MovetoAC(Arg2)
                     wrfaps(lrs, 0, 35, 0, 0, 0, 0)
                     Compile(dvp, Addr(Arg1, V1))
                     Lose1(Op=div->MQreg,ACreg, 0)
                     GOTO Next

           CASE plus: IF ocode DO writef("# PLUS*n")
                      CGplus(); GOTO Next
           CASE minus: IF ocode DO writef("# PLUS*n")
                       CGsubt(); GOTO Next

           CASE eq:CASE ne:
           CASE ls:CASE gr:CASE le:CASE ge:
                     IF ocode DO writef(Op=eq -> "# EQ*n",
                                        Op=ne -> "# NE*n",
                                        Op=ls -> "# LS*n",
                                        Op=gr -> "# GR*n",
                                        Op=le -> "# LE*n",
                                        Op=ge -> "# GE*n",
                                        "BAD REL*n")
                     CGsubt()

                     $( LET Relop = Op
                        Op := Readop()
                        IF Op=jt LOGOR Op=jf DO
                                      $( A1 := ReadL()
                                         IF ocode DO { IF Op=jt DO writef("# JT")
                                                       IF Op=jf DO writef("# JF")
                                                       writef(" L%n*n", A1)
                                                     }
                                         CGrel(Relop, Op=jt, A1)
                                         GOTO Next  $)
                     $( LET m, n = Nextparam(), Nextparam()
                        CGrel(Relop, FALSE, m)
                        wrfaps(cla, 0, 0, CellN(TRUE), 0, 0, 0)
                        wrfaps(tra, 0, 0, n, 0, 0, 0)
                        wrlab(m)
                        Compile(pca, Nulladdr)
                        wrlab(n)
                        LoadT(ACreg, 0)
                        GOTO L  $)  $)

            CASE lshift:
            CASE rshift: IF ocode DO writef(Op=lshift -> "# LSHIFT*n", "# RSHIFT*n")
                         CGshift(Op); GOTO Next

            CASE logand:
            CASE logor:
            CASE eqv:
            CASE neqv: IF ocode DO writef(Op=logand -> "# LOGAND*n",
                                          Op=logor  -> "# LOGOR*n",
                                          Op=eqv    -> "# EQV*n",
                                          Op=neqv   -> "# NEQV*n",
                                          "BAD LOGOP*n")
                       CGlogop(Op); GOTO Next

            CASE not: IF ocode DO writef("# NOT*n")
                      MovetoLAC(Arg1)
                      wrcom()
                      GOTO Next

            CASE neg: IF ocode DO writef("# NEG*n")
                      IF Addrble(Arg1) DO $( FreeAC()
                                             Compile(cls, Addr(Arg1, V1))
                                             H1!(Arg1), H2!(Arg1) := ACreg, 0
                                             GOTO Next  $)
                      MovetoAC(Arg1)
                      wrchs()
                      GOTO Next

            CASE rv: IF ocode DO writef("# RV*n")
                     CGrv(); GOTO Next

            CASE jump: A1 := ReadL()
                       IF ocode DO writef("# JUMP L%n*n", A1)
                       Store(0,ssp)
                       wrfaps(tra, 0, 0, A1, 0, 0, 0)
                       Outconsts()
                       GOTO Next

            CASE jt:
            CASE jf: A1 := ReadL()
                     IF ocode DO { writef(Op=jt -> "# JT", "# JF")
                                   writef(" L%n*n", A1)
                                 }
                     Store(0, ssp-2)
                     MovetoAC(Arg1)
                     wrfaps(Op=jt->tnz,tze, 0, 0, A1, 0, 0, 0)
                     Stack(ssp-1)
                     GOTO Next

            CASE goto: IF ocode DO writef("# GOTO*n")
                       Store(0, ssp-2)
                       Makeaddrble(Arg1)
                       Compile(tra, Addr(Arg1, V1))
                       Initstack(ssp-1)
                       Outconsts()
                       GOTO Next

            CASE lab: A1 := ReadL()
                      IF ocode DO writef("# LAB L%n*n", A1)
                      Store(0, ssp)
                      Initstack(ssp)
                      wrlab(A1)
                      GOTO Next

            CASE stack: A1 := ReadN()
                        IF ocode DO writef("# STACK %n*n", A1)
                        Stack(A1)
                        GOTO Next

            CASE store: IF ocode DO writef("# STORE*n")
                        Store(0, ssp)
                        Initstack(ssp)
                        GOTO Next

            CASE save: A1 := ReadN()
                       IF ocode DO writef("# SAVE %n*n", A1)
                       $( LET n = A1
                          wrfaps(sti, 0, 1, 0, 0, 4, 0)
                          Initstack(n)
                          GOTO Next  $)

            CASE fnap:
            CASE rtap: A1 := ReadN()
                       IF ocode DO { writef(Op=fnap -> "# FNAP", "# RTAP")
                                     writef(" %n*n", A1)
                                   }
                       CGapply(Op, A1)
                       GOTO Next

            CASE fnrn: IF ocode DO writef("# FNRN*n")
                       MovetoAC(Arg1)
                       ssp := ssp-1

            CASE rtrn: IF ocode DO writef("# RTRN*n")
                       wrfaps(tra, 0, 1, 0, 0, 4, 0)
                       Initstack(ssp)
                       Outconsts()
                       GOTO Next

            CASE res: A1 := ReadL()
                      IF ocode DO writef("# LAB L%n*n", A1)
                      Store(0, ssp-2)
                      MovetoAC(Arg1)
                      wrfaps(tra, 0, 0, A1, 0, 0, 0)
                      Stack(ssp-1)
                      Outconsts()
                      GOTO Next

            CASE rstack: A1 := ReadN()
                         IF ocode DO writef("# RSTACK %n*n", A1)
                         Stack(A1)
                         LoadT(ACreg, 0)
                         GOTO Next

            CASE finish: IF ocode DO writef("# FINISH*n")
                         wrfaps(tsx, 0, 3, 0, 1, 2, 0)
                         GOTO Next

            CASE switchon: CGswitch()
                           GOTO Next

            CASE global: CGglobal()
                         GOTO Next

            CASE datalab: A1 := ReadL()
                          IF ocode DO writef("# DATALAB L%n*n", A1)
                          wrlab(A1)
                          GOTO Next

            CASE iteml: A1 := ReadL()
                        IF ocode DO writef("# ITEML L%n*n", A1)
                        wrfaps(tra, 0, 0, A1, 0, 0, 0)
                        GOTO Next

            CASE itemn: A1 := ReadN()
                        IF ocode DO writef("# ITEMN %n*n", A1)
                        wrdata(A1, 0, 0)
                        GOTO Next                  $)1

.

// ncg4.b 05/23/13:08

GET "libhdr"
GET "nhead3"

LET LoadT(a, b) BE
       $( Arg2 := Arg1
          Arg1 := Arg1 + Tempsize
          H1!(Arg1), H2!(Arg1) := a, 0
          H3!(Arg1) := b
          H5!(Arg1) := ssp
          ssp := ssp + 1  $)

AND Lose1(a, b, c, d) BE
       $( ssp := ssp - 1
          TEST Arg2=TempV
                 THEN $( H1!(Arg2), H2!(Arg2) := local, 0
                         H3!(Arg2), H5!(Arg2) := ssp-2, ssp-2  $)
                   OR Arg1, Arg2 := Arg2, Arg2 - Tempsize
          H1!(Arg1), H2!(Arg1), H3!(Arg1), H4!(Arg1) := a, b, c, d
          H5!(Arg1) := ssp - 1  $)

AND Stack(n) BE
      $(1 
          IF n GE ssp+3 DO
                 $( Store(0, ssp)
                    Initstack(n)
                    RETURN  $)

          WHILE n GR ssp DO LoadT(local, ssp)

       L: 
          IF n=ssp RETURN

          UNLESS Arg2=TempV DO $( Arg1 := Arg2
                                  Arg2 := Arg1 - Tempsize
                                  ssp := ssp - 1
                                  GOTO L  $)

          IF n=ssp-1 DO
                 $( FOR i = 0 TO Tempsize-1 DO Arg1!(i) := Arg2!(i)
                    ssp := n
                    H1!(Arg2), H2!(Arg2), H3!(Arg2) := local, 0, ssp-2 
                    H5!(Arg2) := ssp-2
                    RETURN  $)
          Initstack(n)
    $)1

AND Store(P, R) BE
      $(1 LET t = TempV
          UNTIL t GR Arg1 DO
                 $( LET S = H5!(t)
                    IF S GR R RETURN
                    IF S GE P DO StoreT(t)
                    t := t + Tempsize   $)1

AND Storecode(x) = VALOF
      $(1 IF H2!(x)=plus DO $( MovetoAC(x)
                               RESULTIS sto   $)
          IF H2!(x)=0 DO
                 SWITCHON H1!(x) INTO
                 $( CASE ACreg: RESULTIS sto
                    CASE LACreg: RESULTIS slw
                    CASE MQreg: RESULTIS stq
                    CASE number: IF H3!(x)=0 RESULTIS stz  $)

          Makeaddrble(x)
          Compile(ldi, Addr(x, TABLE 0, 0, 0, 0, 0, 0))
          RESULTIS sti   $)1

AND Storein
(K, N) BE
       $( LET A, L, G, n = 0, 0, 0, 0
          IF K=local  DO A, n := N, 4
          IF K=global DO A, G := N, 1
          IF K=label  DO L := N

          wrfaps(Storecode(Arg1), 0, A, L, G, n, 0)

          Stack(ssp-1)  $)

AND FreeAC() BE
      $(1 LET x = TempV
          UNTIL x GR Arg1 DO
                 $( IF H1!(x)=ACreg LOGOR H1!(x)=LACreg DO
                                         $( StoreT(x)
                                            RETURN  $)
                    x := x + Tempsize   $)1

AND FreeMQ() BE
      $(1 LET x = TempV
          UNTIL x GR Arg1 DO
                 $( IF H1!(x)=MQreg DO $( StoreT(x)
                                          RETURN  $)
                    x := x + Tempsize   $)1

AND StoreT(x) BE
       $(1 
           IF H1!(x)=local & H2!(x)=0 & H3!(x)=H5!(x) RETURN
           wrfaps(Storecode(x), 0, H5!(x), 0, 0, 4, 0)
           H1!(x), H2!(x), H3!(x) := local, 0, H5!(x)   $)1

AND StoreI() BE
       $( IF H2!(Arg1)=rv LOGOR H2!(Arg1)=rvplus DO MovetoAC(Arg1)

          H2!(Arg1) := H2!(Arg1)=0 -> rv, rvplus

          Makeaddrble(Arg1)
          Compile(Storecode(Arg2), Addr(Arg1, V1))
          Stack(ssp-2)
   $)

AND IsXfree(i) = VALOF
       $( LET P = TempV
          IF i=4 RESULTIS FALSE
          $( IF H1!(P)=Xreg & H3!(P)=i RESULTIS FALSE
             P := P + Tempsize  $) REPEATUNTIL P GE Arg1

          RESULTIS TRUE   $)

AND NextX() = VALOF
       $( FOR i = 1 TO 6 DO
                    IF IsXfree(i) RESULTIS i
          Report(304)
          RESULTIS 7  $)

AND MovetoX(x) = VALOF
       $( LET F = 0
          LET A, L, G = 0, 0, 0
          LET i = NextX()

          IF H2!(x)=0 DO
                  SWITCHON H1!(x) INTO
                  $( CASE global: F, A, G := lac, H3!(x), 1
                                  GOTO N

                     CASE label:  F, L := lac, H3!(x)
                                  GOTO N

                     CASE number: F, A := axc, H3!(x)
                                  GOTO N   $)
          MovetoAC(x)
          F := pac

       N: wrfaps(F, 0, A, L, G, i, 0)
          H1!(x), H2!(x), H3!(x) := Xreg, 0, i
          RESULTIS i  $)

.

// ncg5.b 06/14/68 18:07

GET "libhdr"
GET "lbhead"
GET "nhead3"

LET Compile(F, v) BE
          $( wrfaps(F, v!(0), v!(1), v!(2), v!(3), v!(4), v!(5))  $)

AND wrfaps(F,I,A,L,G,n,D) BE
       $( IF Listing DO
                 $( Writech(OUTPUT, '*t')
                    wropcode(F)
                    TEST I=1 THEN writes( "***t" )
                             OR Writech(OUTPUT, '*t')
                    IF A NE 0 LOGOR L=0 LOGOR G=1 DO WriteN(A)
                    IF L NE 0 DO $( IF A NE 0 DO Writech(OUTPUT, '+')
                                    Writech(OUTPUT, 'L')
                                    WriteN(L)  $)
                    IF G = 1 DO writes( "+G" )
                    IF n NE 0 DO $( Writech(OUTPUT, ',')
                                    WriteN(n)  $)
                    IF D NE 0 DO $( IF n=0 DO Writech(OUTPUT, ',')
                                    Writech(OUTPUT, ',')
                                    WriteN(D)  $)
                     Writech(OUTPUT, '*n')  $)
           IF BSSing DO
                  $( LET W = 0
                     IF stp=stvl DO Nextcard()
                     IF D NE 0 DO $( Addaddr(LV W, D)
                                     W := W LSHIFT 18  $)
                     W := F LSHIFT 24 LOGOR n LSHIFT 15 LOGOR W
                     IF I=1 DO W := W LOGOR #o60000000
                     IF G=1 DO Addaddr(LV W, Commonbreak)
                     Addaddr(LV W, A)
                     stv!(stp) := W
                     IF L NE 0 DO $( RefV!(RefP),RefV!(RefP+1) := stp,L
                                     RefP := RefP+2  $)
                     Strefbit(0)
                     UNLESS L=0 & G=0 DO Strefbit(1)
                     Strefbit(0)
                     stp := stp + 1  $)
            stvq := stvq+1  $)

AND wrlab(n) BE
       $( IF Listing DO
                 $( writes( "*nL" )
                    WriteN(n)
                    Writech(OUTPUT, '*n')  $)
          IF BSSing DO Parv!(n) := stvq $)

AND wrfapr(F,A,n) BE
       $( IF Listing DO
                 $( Writech(OUTPUT, '*t')
                    wropcode(F)
                    Writech(OUTPUT,'*t'); WriteN(A)
                    TEST n=0 THEN writes("+**")
                             OR $( writes("+**,")
                                   WriteN(n)  $)
                    Writech(OUTPUT, '*n')  $)
           IF BSSing DO
                  $( LET W = 0
                     IF stp=stvq DO Nextcard()
                     W := F LSHIFT 24 LOGOR n LSHIFT 15
                     Addaddr(LV W, A + stvq)
                     stv!(stp) := W
                     Strefbit(0); Strefbit(1); Strefbit(0)
                     stp := stp + 1  $)
           stvq := stvq + 1  $)

AND wrcom() BE
       $( IF Listing DO writes( "*tCOM*n" )
          IF BSSing DO $( IF stp=stvq DO Nextcard()
                          stv!(stp) := #o076000000006
                          Strefbit(0); Strefbit(0)
                          stp := stp+1  $)
          stvq := stvq + 1 $)

AND wrchs() BE
       $( IF Listing DO writes( "*tCHS*n" )
          IF BSSing DO $( IF stp=stvq DO Nextcard()
                          stv!(stp) := #o076000000002
                          Strefbit(0); Strefbit(0)
                          stp := stp+1  $)
          stvq := stvq + 1 $)

AND wrdata(A,L,G) BE
       $( IF Listing DO
                 $( writes( "*tVFD*t36/" )
                    WriteN(A)
                    IF L NE 0 DO $( writes( "+L" )
                                    WriteN(L)  $)
                    IF G = 1 DO writes( "+G" )
                    Writech(OUTPUT, '*n')  $)
          IF BSSing DO
                 $( LET W, B = 0, L=0 & G=0
                    IF stp=stvq DO Nextcard()
                    stv!(stp) := A
                    TEST B THEN W := A OR Addaddr(LV W, A)
                    IF L NE 0 DO $( RefV!(RefP),RefV!(RefP+1) := stp,L
                                    RefP := RefP+2  $)
                    IF G=1 DO Addaddr(LV W, Commonbreak)
                    stv!(stp) := W
                    Strefbit(0)
                    UNLESS B DO Strefbit(1)
                    Strefbit(0)
                    stp := stp + 1  $)
          stvq := stvq + 1  $)

AND wropcode(F) BE
       $( LET S = VALOF $( SWITCHON F INTO
                           $( DEFAULT: RESULTIS "ERROR"
                              CASE add:RESULTIS "ADD"
                              CASE als:RESULTIS "ALS"
                              CASE ana:RESULTIS "ANA"
                              CASE ars:RESULTIS "ARS"
                              CASE axc:RESULTIS "AXC"
                              CASE cal:RESULTIS "CAL"
                              CASE cas:RESULTIS "CAS"
                              CASE cla:RESULTIS "CLA"
                              CASE cls:RESULTIS "CLS"
                              CASE dvp:RESULTIS "DVP"
                              CASE era:RESULTIS "ERA"
                              CASE hpr:RESULTIS "HPR"
                              CASE lac:RESULTIS "LAC"
                              CASE ldi:RESULTIS "LDI"
                              CASE ldq:RESULTIS "LDQ"
                              CASE lrs:RESULTIS "LRS"
                              CASE mpy:RESULTIS "MPY"
                              CASE ora:RESULTIS "ORA"
                              CASE pac:RESULTIS "PAC"
                              CASE pai:RESULTIS "PAI"
                              CASE pca:RESULTIS "PCA"
                              CASE pia:RESULTIS "PIA"
                              CASE slw:RESULTIS "SLW"
                              CASE sta:RESULTIS "STA"
                              CASE sti:RESULTIS "STI"
                              CASE sto:RESULTIS "STO"
                              CASE stq:RESULTIS "STQ"
                              CASE stz:RESULTIS "STZ"
                              CASE sub:RESULTIS "SUB"
                              CASE tmi:RESULTIS "TMI"
                              CASE tnz:RESULTIS "TNZ"
                              CASE tpl:RESULTIS "TPL"
                              CASE tra:RESULTIS "TRA"
                              CASE tsx:RESULTIS "TSX"
                              CASE txi:RESULTIS "TXI"
                              CASE tze:RESULTIS "TZE"
                              CASE xca:RESULTIS "XCA"
                              CASE xcl:RESULTIS "XCL"  $)  $)
       writes(S)  $)

.

// ncg6.b 06/14/68 18:15

GET "libhdr"
GET "lbhead"
GET "nhead3"

LET SetupBSS(N1) BE
       $( FOR i = 1 TO 28 DO stv!(i) := 0
          stv!(0) := #o400504000000
          stv!(3) := Commonbreak
          stv!(4) := Entryname(N1)
          stv!(5) := 0
          LastcardP, RefP, stvq := 0, 0, 0
          Nextcard()   $)

AND Entryname(N) = VALOF
       $( FOR i = 1 TO 6 DO
                    IF ( N RSHIFT 30 ) = #o60 DO N := N LSHIFT 6 LOGOR #o60
          RESULTIS N  $)

AND Nextcard() BE
       $( LastcardP := LastcardP + 28
          stv!(LastcardP) := #o200524000000 LOGOR stvq
          FOR i = LastcardP+1 TO LastcardP+27 DO stv!(i) := 0
          RelwordP, Relbit := LastcardP+2, 35
          stp, stvl := LastcardP + 4, LastcardP + 24  $)

AND Strefbit(n) BE
       $( stv!(RelwordP) := stv!(RelwordP) LOGOR n LSHIFT Relbit
          Relbit := Relbit - 1
          IF Relbit GE 0 RETURN
          Relbit, RelwordP := 35, RelwordP+1  $)

AND wrbss(N1) BE
      $(1 stv!(LastcardP) := stv!(LastcardP) & #o777700777777 LOGOR
                                        ( stp-LastcardP-4 ) LSHIFT 18
          stv!(2) := stv!(2) + stvq
       $( LET i = 0
          UNTIL i GR RefP-1 DO
                    $( Addaddr(LV stv!(RefV!(i)),Parv!(RefV!(i+1)))
                       i := i + 2  $)  $)

          //Writefile(N1, BCDword("   bss"), stv, LastcardP+28)
          IF BSSing DO
          { selectoutput(bssstream)
            FOR i = 0 TO LastcardP+27 DO
            { IF i MOD 28 = 0 DO newline()
              IF i MOD 4 = 0 DO newline()
              writef(" %12o", stv!i)
            }
            newline()
            endstream(bssstream)
            bssstream := 0
            selectoutput(stdout)
          }

          writes( "Length*s" ); WriteN(stvq)
          writes( "*tCommon BREAK*s" ); WriteO(Commonbreak)
          writes("*s*n")  $)1

AND Writefile(N1, N2, V, n) BE
       $( LET Errorcode = 0
          Delfil(N1, N2, L, LV Errorcode)
       L: Open(BCDword("     W"), N1, N2, 0)
          Wrwait(N1, N2, 0, V, n)
          Close(N1, N2)   $)

AND Addaddr(x, y) BE
       $( LET L, R = RV x & #o777777700000, RV x & #o77777
          LET A = y & #o77777
          IF y LS 0 DO A := #o100000 - A
          RV x := L LOGOR R+A & #o77777  $)

.

// ncg7.b 06/14/68 18:22

LET Dummy() BE $( FINISH $)

.

// ncg8.b 06/14/68 18:23

GET "libhdr"
GET "lbhead"
GET "nhead3"

LET Switch(Ub, Ulim, Lb, Llim, p, q, Dlabel) BE

      $(1 LET x, y = 0, 0

       L: IF p GR q DO $( wrfaps(tra, 0, 0, Dlabel, 0, 0, 0)
                          RETURN  $)

       x, y := CaseK!(p), CaseK!(p+1)

       IF x-0 DO $( wrfaps(tze, 0, 0, CaseL!(p), 0, 0, 0)
                    p := p + 1
                    GOTO L  $)

       IF q GR p + 7 DO
              $( LET M = Nextparam()
                 LET T = ( p + q ) / 2
                 LET z = CaseK!(T)
                 IF z=0 DO wrfaps(tze, 0, 0, CaseL!(T), 0, 0, 0)
                 wrcas(z, M, CaseL!(T))
                 Switch(TRUE, z, Lb, Llim, T+1, q, Dlabel)
                 wrlab(M)
                 Switch(Ub, Ulim, TRUE, z, p, T-1, Dlabel)
                 RETURN  $)

       IF p=q DO $( IF Ub & Lb & Ulim-Llim LE 2 DO
                                  $( wrfaps(tra, 0, 0, CaseL!(p), 0, 0, 0)
                                     RETURN  $)
                    wrcas(x, Dlabel, CaseL!(p))
                    wrfaps(tra, 0, 0, Dlabel, 0, 0, 0)
                    RETURN  $)

       UNLESS Ub & Ulim-1=x DO
                 $( wrcas(x, Dlabel, CaseL!(p))
                    Ub, Ulim, p := TRUE, x, p+1
                    GOTO L  $)

       IF x=y+1 DO $( wrcas(y, CaseL!(p), CaseL!(p+1))
                      Ulim, p := y, p+2
                      GOTO L  $)

       wrcas(x-1, CaseL!(p), Dlabel)
       Ulim, p := x-1, p+1
       GOTO L   $)1

AND wrcas(N, L1, L2) BE
       $( wrfaps(cas, 0, 0, CellN(N), 0, 0, 0)
          wrfaps(tra, 0, 0, L1, 0, 0, 0)
          wrfaps(tra, 0, 0, L2, 0, 0, 0)  $)

AND CGswitch() BE
      $(1 LET A = VEC 200
          LET B = VEC 200
          LET N = ReadN()
          LET Default = ReadL()
          IF ocode DO writef("# SWITCHON %n L%n*n", N, Default)
          CaseK, CaseL := A, B
          FOR i = 1 TO N DO
                 $( LET A = ReadN()
                    LET L = ReadL()
                    LET j = i-1
                              IF ocode DO writef("# %n L%n*n", A, N)
                    UNTIL j=0 DO
                           $( IF A LS CaseK!(j) BREAK
                              CaseK!(j+1), CaseL!(j+1) := CaseK!(j), CaseL!(j)
                              j := j - 1  $)
                    CaseK!(j+1), CaseL!(j+1) := A, L  $)
           Store(0, ssp-2)
           MovetoAC(Arg1)
           Switch(FALSE, 0, FALSE, 0, 1, N, Default)
           Initstack(ssp-1)   $)1

.

// ncg9.b 06/14/68 18:27

GET "libhdr"
GET "lbhead"
GET "nhead3"

LET CellN(n) = VALOF
       $( FOR i = 1 TO ConstP DO
                    IF ConstV!(i)=n RESULTIS ConstL!(i)
          ConstP := ConstP + 1
          ConstV!(ConstP), ConstL!(ConstP) := n, Nextparam()
          RESULTIS ConstL!(ConstP)  $)

AND Staticcell(G, L) = VALOF
       $( LET M = Nextparam()
          StatV!(StatP) := M
          StatV!(StatP+1), StatV!(StatP+2) := G, L
          StatP := StatP + 3
          UNLESS StatP GE  StatT RESULTIS M
          Report(304)
          StatP := 0
          RESULTIS M  $)

AND CGapply(Op, S) BE
       $( LET V = VEC 5

          UNLESS Addrble(Arg1) DO $( Storein(global, 0)
                                     LoadT(global, 0)  $)

          $( Addr(Arg1, V)
             IF V!(0)=0 & V!(4)=0 BREAK
             Storein(global, 0)
             LoadT(global, 0)  $) REPEAT

          V!(4), V!(5) := 4, -S

          Store(S, ssp-2)
          FreeAC(); FreeMQ()

       $( LET L = Nextparam()

          wrfapr(ldi, 2, 0)
          Compile(txi, V)
          V!(1), V!(2), V!(3), V!(5)  := 0, L, 0, S
          Compile(txi, V)
          Outconsts()
          wrlab(L)  $)

          Stack(S)
          IF Op=fnap DO LoadT(ACreg, 0)
          RETURN   $)

AND CGrv() BE
       $( IF H2!(Arg1)=0 DO  $( H2!(Arg1) := rv
                                RETURN $)
          IF H2!(Arg1)=plus DO
                    $( H2!(Arg1) := rvplus
                       RETURN  $)
          MovetoAC(Arg1)
          Lose1(ACreg, rv)    $)

AND CGplus() BE
       $( LET A1, A2 = Arg1, Arg2

          IF H1!(Arg2)=number & H2!(Arg2)=0 DO A1, A2 := Arg2, Arg1

          IF H1!(A1)=number & H2!(A1)=0 DO
                 $( IF H1!(A2)=local & H3!(A2)=ssp-1 DO MovetoAC(A2)
                    IF H3!(A1)=0 GOTO Ret
                    SWITCHON H2!(A2) INTO
                    $( CASE rv:
                       CASE rvplus: MovetoAC(A2)

                       CASE 0: TEST H1!(A2)=number
                                     THEN H3!(A2) := H3!(A2) + H3!(A1)
                                       OR H2!(A2), H4!(A2) := plus, H3!(A1)
                               GOTO Ret

                       CASE plus:
                                 H4!(A2) := H4!(A2) + H3!(A1)   $)

               Ret: UNLESS A2=Arg2 DO
                           FOR i = 0 TO 3 DO Arg2!(i) := A2!(i)
                    Stack(ssp-1)
                    RETURN   $)

          IF Addrble(Arg2) DO A1, A2 := Arg2, Arg1
          Makeaddrble(A1)
          MovetoAC(A2)
          Compile(add, Addr(A1, V1))
          Lose1(ACreg, 0)  $)

AND CGsubt() BE
       $( IF Iszero(Arg1) DO $( Stack(ssp-1)
                                RETURN  $)
          IF Iszero(Arg2) DO
                 $( IF Addrble(Arg1) DO
                              $( FreeAC()
                                 Compile(cls, Addr(Arg1, V1))
                                 Lose1(ACreg, 0)
                                 RETURN  $)
                    MovetoAC(Arg1)
                    wrchs()
                    Lose1(ACreg, 0)
                    RETURN  $)
           Makeaddrble(Arg1)
           MovetoAC(Arg2)
           Compile(sub, Addr(Arg1, V1))
           Lose1(ACreg, 0)
                                     $)

AND CGrel(Relop, B, L) BE
      $(1 LET T = TABLE 0, 0, 0, 0, 0, 0
          T!(2) := L
          Store(0, ssp-2)
          MovetoAC(Arg1)
          Initstack(ssp-1)
          SWITCHON Relop INTO
          $( CASE eq: UNLESS B GOTO L2
                  L1: Compile(tze, T)
                      RETURN

             CASE ne: UNLESS B GOTO L1
                  L2: Compile(tnz, T)
                      RETURN

             CASE ls: UNLESS B GOTO L4
                  L3: wrfapr(tze, 2, 0)
                      Compile(tmi, T)
                      RETURN

             CASE ge: UNLESS B GOTO L3
                  L4: Compile(tpl, T)
                      Compile(tze, T)
                      RETURN

             CASE gr: UNLESS B GOTO L6
                  L5: wrfapr(tze, 2, 0)
                      Compile(tpl, T)
                      RETURN

             CASE le: UNLESS B GOTO L5
                  L6: Compile(tmi, T)
                      Compile(tze, T)
                      RETURN    $)  $)1

AND CGshift(Op) BE
       $( LET T = TABLE 0, 0, 0, 0, 0, 0
          TEST H1!(Arg1)=number
                    THEN T!(1), T!(4) := H3!(Arg1), 0
                      OR T!(1), T!(4) := 0, MovetoX(Arg1)
          MovetoLAC(Arg2)
          Compile(Op=lshift -> als, ars, T)
          Lose1(LACreg, 0)  $)

AND CGlogop(Op) BE
       $( LET A1, A2 = Arg1, Arg2
          IF Addrble(Arg2) DO A1, A2 := Arg2, Arg1
          Makeaddrble(A1)
          MovetoLAC(A2)
          Compile(Op=logand -> ana, Op=logor -> ora, era, Addr(A1, V1))
          IF Op=eqv DO wrcom()
          Lose1(LACreg, 0)  $)

AND CGglobal() BE
       $( LET A1 = ReadN()
          IF ocode DO writef("# GLOBAL %n*n", A1)
          Compile(tsx, TABLE 0, 2, 0, 1, 2, 0)
          
          FOR i = 1 TO A1 DO
                           $( LET N = ReadN()
                              LET L = ReadL()
                              IF ocode DO writef("# %n L%n*n", N, L)
                              wrfaps(txi, 0, 0, L, 0, 0, N)  $)
          wrdata(0, 0, 0)
          wrfaps(tra, 0, 0, Endlab, 0, 0, 0)  $)

AND Outconsts() BE
       $( LET i = 0
          UNTIL i=SvecP DO
                 $( LET Size = Svec!(i+1)
                    wrlab(Svec!(i))
                    FOR j = i+2 TO i+Size+1 DO wrdata(Svec!(j), 0, 0)
                    i := i + Size + 2  $)
          SvecP := 0

          i := 0
          UNTIL i=StatP DO
                 $( LET G, L = StatV!(i+1), StatV!(i+2)
                    wrlab(StatV!(i))
                    wrdata(G, L, G=0 -> 0, 1)
                    i := i + 3   $)

          StatP := 0  $)

AND Outnumbs() BE
       $( FOR i = 1 TO ConstP DO
                 $( wrlab(ConstL!(i))
                    wrdata(ConstV!(i), 0, 0)  $)  $)

AND CGstring(n) BE
       $( LET L = Nextparam()
          FreeAC()
          wrfaps(axc, 0, 0, L, 0, 7, 0)
          wrfaps(pca, 0, 0, 0, 0, 7, 0)
          LoadT(ACreg, 0)

       $( LET v = VEC 520
          LET Size = n/Bytesperword + 1
          IF SvecP+Size+2 GR SvecT DO
                    $( LET M = Nextparam()
                       wrfaps(tra, 0, 0, M, 0, 0, 0)
                       Outconsts()
                       wrlab(M)   $)
          IF ocode DO { writef("# LSTR %n*n", n)
                        writef("# ")
                        FOR i = 1 TO n DO
                        { LET c = ReadN()
                          writef(" %n", c)
                          v!(i) := c
                        }
                        newline()
                      }
          v!(0) := n
          Svec!(SvecP) := L
          Svec!(SvecP+1) := Size
          // Pack the string of 9-bit bytes into 36-bit words
          // with the length in byte zero.
          Packstring(v, LV Svec!(SvecP+2))
          SvecP := SvecP + Size + 2   $)   $)

.

// ncg10.b 06/14/68 18:37

GET "libhdr"
GET "nhead3"

LET Addrble(x) = VALOF
       $( // H1!x = Xreg local global label number
          // H2!x = 0 rv plus rvplus
          // H3!x = value to go with H1!x
          // H4!x = constant to add to (H1!,H3!x) quantity
          // H5!x = Stack offset for this item
          LET M = H2!(x)
          SWITCHON H1!(x) INTO
          $( CASE Xreg:  RESULTIS M=rvplus LOGOR M=rv

             CASE local:
             CASE global:
             CASE label:
             CASE number: RESULTIS M=0 LOGOR M=rv

             DEFAULT: RESULTIS FALSE   $)   $)

AND Addr(x, V) = VALOF
   $(1 FOR i = 0 TO 5 DO V!(i) := 0
       SWITCHON H1!(x) INTO
       $( CASE label: V!(2) := H3!(x)
                      GOTO L

          CASE global: V!(1), V!(3) := H3!(x), 1
                       GOTO L

          CASE local: V!(1), V!(4) := H3!(x), 4
                       GOTO L

          CASE number: V!(2) := CellN(H3!(x))
                       GOTO L

          CASE Xreg: V!(4) := H3!(x)
                     IF H2!(x)=rvplus DO
                              $( V!(1) := H4!(x)
                                 RESULTIS V  $)
                     IF H2!(x)=rv DO RESULTIS V

          DEFAULT:   writef("addr: Bad H1!x=%n*n", H1!x)
                     IF H1!x=2 DO writef("LACreg=2*n")
                     IF H1!x=3 DO writef("MQreg=3*n")
                     IF H1!x=4 DO writef("SIreg=4*n")
                     IF H1!x=5 DO writef("ACreg=5*n")
                     IF H1!x=6 DO writef("Xreg=6*n")
                     IF H1!x=7 DO writef("Rvplus=7*n")
                     Report(306)

                     RESULTIS V   $)

     L: IF H2!(x)=0 RESULTIS V

        IF H2!(x)=rv DO $( V!(0) := 1
                           RESULTIS V  $)
        Report(306)
        RESULTIS V   $)1

AND Makeaddrble(x) BE
      $(1 IF Addrble(x) RETURN

       $( LET M = H2!(x)

          IF M=rv LOGOR M=rvplus DO
                    $( H2!(x) := 0
                       MovetoX(x)
                       H2!(x) := M
                       RETURN  $)

          IF M=plus DO $( LET n = H4!(x)
                          H2!(x) := 0
                          MovetoAC(x)
                          wrfaps(add, 0, 0, CellN(n), 0, 0, 0)  $)

          StoreT(x)   $)1

AND MovetoAC(x) BE
       $( LET n = 0
          LET K = H1!(x)

          UNLESS K=ACreg LOGOR K=LACreg DO FreeAC()

          IF H2!(x)=plus DO H2!(x), n := 0, H4!(x)

          IF H2!(x)=0 DO
                $(2 SWITCHON K INTO
                    $( CASE LACreg: FreeMQ()
                                    Compile(xcl, Nulladdr)

                       CASE MQreg:  Compile(xca, Nulladdr)

                       CASE ACreg:  GOTO L

                       CASE number: IF Iszero(x) DO
                                        $( Compile(pca, Nulladdr)
                                           GOTO L   $)2

          Makeaddrble(x)
          Compile(cla, Addr(x, TABLE 0, 0, 0, 0, 0, 0))

       L: IF n NE 0 DO wrfaps(add, 0, 0, CellN(n), 0, 0, 0)
          H1!(x), H2!(x) := ACreg, 0  $)

AND MovetoLAC(x) BE
       $( LET K = H1!(x)

          UNLESS K=ACreg LOGOR K=LACreg DO FreeAC()

          IF H2!(x)=0 DO
                $(2 SWITCHON K INTO
                    $( CASE ACreg: FreeMQ()
                                   Compile(xca, Nulladdr)

                       CASE MQreg: Compile(xcl, Nulladdr)

                       CASE LACreg:  GOTO L

                       CASE number: IF Iszero(x) DO
                                        $( Compile(pca, Nulladdr)
                                           GOTO L   $)2

          Makeaddrble(x)
          Compile(cal, Addr(x, TABLE 0, 0, 0, 0, 0, 0))

       L: H1!(x), H2!(x) := LACreg, 0  $)

AND MovetoMQ(x) BE
       $( LET K = H1!(x)

          UNLESS K=MQreg DO FreeMQ()

          IF H2!(x)=0 DO
                $(2 SWITCHON K INTO
                    $( CASE MQreg: RETURN

                       CASE ACreg: Compile(xca, Nulladdr)
                                   GOTO L

                       CASE LACreg: Compile(xcl, Nulladdr)
                                    GOTO L
                                                    $)2

          Makeaddrble(x)
          Compile(ldq, Addr(x, TABLE 0, 0, 0, 0, 0, 0))

       L: H1!(x), H2!(x) := MQreg, 0   $)

AND Iszero(x) = H1!(x)=number & H2!(x)=0 & H3!(x)=0


