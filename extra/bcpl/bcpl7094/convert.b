/*

This program is designed to convert the 1968 version of BCPL programs
to ones that can be compiled using the modern Cintcode BCPL system. It
is primarily to be used to convert bcpl7094.bcpl to bcpl7094.b.

It copies the from file to the to file changing the case of some words
of consective letters. Words of 2 or more lowere case letters are
converted to uppercase and words of 2 or more uppercase letters are
converted to lowercase. All other words and characters are left
unchanged.

Implemented by Martin Richards (c) November 2016

*/

GET "libhdr"

GLOBAL {
  stdin:ug
  stdout
  fromname
  fromstream
  toname
  tostream

  ch
  charv
  n
  upper
  lower
}

LET start() = VALOF
{ LET v = VEC 2550
  AND argv = VEC 50

  charv := v
  stdin := input()
  stdout := output()

  UNLESS rdargs("from,to/K", argv, 50) DO
  { writef("Bad arguments for convert*n")
    RESULTIS 0
  }

  fromname := "bcpl7094.bcpl"
  fromstream := 0
  toname := "bcpl7094.b"
  tostream := 0

  IF argv!0 DO fromname := argv!0   // from
  IF argv!1 DO toname := argv!1     // to/K

  fromstream := findinput(fromname)
  UNLESS fromstream DO
  { writef("Trouble with from file: %s*n", fromname)
    GOTO fin
  }

  tostream := findoutput(toname)
  UNLESS tostream DO
  { writef("Trouble with to file: %s*n", toname)
    GOTO fin
  }

  selectinput(fromstream)
  selectoutput(tostream)

  ch := rdch()

  UNTIL ch=endstreamch DO
  { //sawritef("ch = %n '%c'*n", ch, ch)
    //abort(1000)
    SWITCHON ch INTO
    { DEFAULT:  wrch(ch); ch := rdch(); LOOP

      CASE 'A':CASE 'B':CASE 'C':CASE 'D':CASE 'E':
      CASE 'F':CASE 'G':CASE 'H':CASE 'I':CASE 'J':
      CASE 'K':CASE 'L':CASE 'M':CASE 'N':CASE 'O':
      CASE 'P':CASE 'Q':CASE 'R':CASE 'S':CASE 'T':
      CASE 'U':CASE 'V':CASE 'W':CASE 'X':CASE 'Y':
      CASE 'Z':
      CASE 'a':CASE 'b':CASE 'c':CASE 'd':CASE 'e':
      CASE 'f':CASE 'g':CASE 'h':CASE 'i':CASE 'j':
      CASE 'k':CASE 'l':CASE 'm':CASE 'n':CASE 'o':
      CASE 'p':CASE 'q':CASE 'r':CASE 's':CASE 't':
      CASE 'u':CASE 'v':CASE 'w':CASE 'x':CASE 'y':
      CASE 'z':
                n, upper, lower := 0, FALSE, FALSE

                { //sawritef("ch='%c' upper=%i2 lower=%i2 n=%n*n", ch, upper, lower, n)
                  IF 'A' <= ch <= 'Z' DO
                  { upper := TRUE
                    n := n+1
                    charv!n := ch
                    ch := rdch()
                    LOOP
                  }
                  IF 'a' <= ch <= 'z' DO
                  { lower := TRUE
                    n := n+1
                    charv!n := ch
                    ch := rdch()
                    LOOP
                  }
                  BREAK
                } REPEAT

                //sawritef("ch='%c' upper=%i2 lower=%i2 n=%n*n", ch, upper, lower, n)
                //abort(1001)
                // ch is not a letter

                IF n>1 DO
                { IF  upper & ~lower FOR  i = 1 TO n DO charv!i := charv!i -'A' + 'a'
                  IF ~upper &  lower FOR  i = 1 TO n DO charv!i := charv!i -'a' + 'A'
                }

                FOR i = 1 TO n DO wrch(charv!i)
                //newline()
                //abort(1002)
    }
  }

  sawritef("Convertion complete*n")

fin:
  IF fromstream DO endstream(fromstream)
  IF tostream DO endstream(tostream)

  selectinput(stdin)
  selectoutput(stdout)
  RESULTIS 0
}
