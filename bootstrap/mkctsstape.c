#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>

int  verbose = 1;		/* 1 for verbose mode (default), 0 for "quiet" mode */
int  p7b = 0;
int  reclen = 84;		/* Default record len. */
int  block = 10;		/* Default records per block. */
char *eot_rec = NULL;		/* Record to write at end of tape */
typedef unsigned long int	uint32;	/* Header unit */
unsigned char	blocking[20] = "$BLOCK         BCD,";
unsigned char	eofmark[20] =  "$EOF               ";
unsigned char   datamark[20] = "$DATA              ";
unsigned char   ctssmark[20] = "$CTSS              ";
unsigned char   insert[20] =   "       INSERT      ";
unsigned char   endcard[20] =  "       END         ";

/*
 * build CTSS jobs and install tapes.
 *            1           2          3           4    
 *  123456 789012 345678 901234 567890 123456 789012 3456789
 *  $CTSS  I                                                   <exclude CTSS card >
 *  $CTSS  C      PROJ   PROG   NAME1  NAME2                   Card deck
 *  $CTSS  M      PROJ   PROG   NAME1  NAME2                   Line mark
 *  $CTSS  O      PROJ   PROG   NAME1  NAME2                   octal file
 *  $CTSS  T      PROJ   PROG   NAME1  NAME2                   Inline card deck. convert to C
 *  $CTSS  L      PROJ   PROG   NAME1  NAME2  PROJ   PROG     FNAME1   FNAME2    Link
 *  $CTSS  U      PROJ   PROG   QUOTA  DRUM                    UFD data.
 *  $CTSS  S      NAME1                                        Same as card deck, but name1 TIMACC
 *  $CTSS  B      PROJ   PROG   NAME1  NAME2  RECS             Binary #recs SYSCK2 to name
 *
 *   Next line path to native file.
 * For T and L there is no native file name.
 */
void usage();
unsigned char  *tape_buffer;
unsigned char  *line_buffer;
unsigned char  *tape_char;
int	     	record = 0;

#define TAPE_IRG 0200
#define BCD_TM 017      

/*
  	Parity table for the 64 BCD characters (without parity bit, 
  	wordmark bits, etc). 
*/


char parity_table[64] = {
        /* 0    1    2    3    4    5    6    7 */
        0000,0100,0100,0000,0100,0000,0000,0100,
        0100,0000,0000,0100,0000,0100,0100,0000,
        0100,0000,0000,0100,0000,0100,0100,0000,
        0000,0100,0100,0000,0100,0000,0000,0100,
        0100,0000,0000,0100,0000,0100,0100,0000,
        0000,0100,0100,0000,0100,0000,0000,0100,
        0000,0100,0100,0000,0100,0000,0000,0100,
        0100,0000,0000,0100,0000,0100,0100,0000
};

const char ascii_to_six[128] = {
/*   000 nul 001 soh 002 stx 003 etx 004 eot 005 enq 006 ack 007 bel */
	-1,	-1,	-1,	-1,	-1,	-1,	-1,	-1,
/*   010 bs  011 ht  012 nl  013 vt  014 np  015 cr  016 so  017 si */
	-1,	-1,	-1,	-1,	-1,	-1,	-1,	-1,
/*   020 dle 021 dc1 022 dc2 023 dc3 024 dc4 025 nak 026 syn 027 etb */
	-1,	-1,	-1,	-1,	-1,	-1,	-1,	-1,
/*   030 can 031 em  032 sub 033 esc 034 fs  035 gs  036 rs  037 us */
	-1,	-1,	-1,	-1,	-1,	-1,	-1,	-1,
/*   040 sp  041  !  042  "  043  #  044  $  045  %  046  &  047  ' */
	020,	052,	037,	032,	053,    034,    060,	014,
/*   050  (  051  )  052  *  053  +  054  ,  055  -  056  .  057  / */
	034,	074,	054,	060,	033,	040,	073,	021,
/*   060  0  061  1  062  2  063  3  064  4  065  5  066  6  067  7 */
	012,	001,	002,	003,	004,	005,	006,	007,
/*   070  8  071  9  072  :  073  ;  074  <  075  =  076  >  077  ? */
	010,	011,	015,	056,	076,	013,	016,	072,
/*   100  @  101  A  102  B  103  C  104  D  105  E  106  F  107  G */
	014,	061,	062,	063,	064,	065,	066,	067,
/*   110  H  111  I  112  J  113  K  114  L  115  M  116  N  117  O */
	070,	071,	041,	042,	043,	044,	045,	046,
/*   120  P  121  Q  122  R  123  S  124  T  125  U  126  V  127  W */
	047,	050,	051,	022,	023,	024,	025,	026,
/*   130  X  131  Y  132  Z  133  [  134  \  135  ]  136  ^  137  _ */
	027,	030,	031,	075,	036,	055,	035,	000,
/*   140  `  141  a  142  b  143  c  144  d  145  e  146  f  147  g */
	014,	061,	062,	063,	064,	065,	066,	067,
/*   150  h  151  i  152  j  153  k  154  l  155  m  156  n  157  o */
	070,	071,	041,	042,	043,	044,	045,	046,
/*   160  p  161  q  162  r  163  s  164  t  165  u  166  v  167  w */
	047,	050,	051,	022,	023,	024,	025,	026,
/*   170  x  171  y  172  z  173  {  174  |  175  }  176  ~  177 del */
	027,	030,	031,     -1,	032,	 -1,	035,	-1,
};

/* Check if new blocking command */
int check_blocking(unsigned char *buffer, int *newblock) {
     int	nblock;
     int	i;
     int	ch;
     if (strncmp(blocking, buffer, 19) == 0) {
	nblock = 0;
	for(i = 19; i < (19+4); i++) {
	   ch = buffer[i] & 077;
	   if (ch == 012)
	      ch = 0;
	   if (ch > 11)
	      return 1;
	   nblock = nblock * 10 + ch;
	}
	nblock /= reclen;
	if (nblock > 0 && nblock <= 16)
	    *newblock = nblock;
	return 1;
     }
     return 0;
}

/* Write EOM indicator */
void write_eom(FILE *f) {
   if (p7b) {
      fputc(BCD_TM|TAPE_IRG, f);
   } else {
   	static uint32 eom = 0xffffffff;
        fwrite(&eom, sizeof(uint32), 1, f);
   }
}

/* Put a tape mark on file */
void write_mark(FILE *f) {
   if (p7b) {
      fputc(BCD_TM|TAPE_IRG, f);
   } else {
      static uint32 tape_mark = 0;
      fwrite(&tape_mark, sizeof(uint32), 1, f);
   }
}

/* Write out a TAP format block */
void write_block(FILE *f, uint32 len, unsigned char *buffer) {
     if (p7b) {
	/* Put IRG at end of record */
	 buffer[0] |= TAPE_IRG;
	 fwrite(buffer, sizeof(unsigned char), len, f);
     } else {
         uint32 wlen = 0x7fffffff & ((len + 1) & ~1);
	 unsigned char	xlen[4];
	 xlen[0] = len & 0xff;
	 xlen[1] = (len >> 8) & 0xff;
	 xlen[2] = (len >> 16) & 0xff;
	 xlen[3] = (len >> 24) & 0xff;
         fwrite(xlen, sizeof(unsigned char), 4, f);
         fwrite(buffer, sizeof(unsigned char), wlen, f);
         fwrite(xlen, sizeof(unsigned char), 4, f);
     }
}

uint32          blen = 0;

/* Process a file */
void process_insert(FILE *tape, FILE *in, char *include_file, char *last, int cblk) {
    uint32	    sz;
    char  	    ch;
    int	  	    len;
    int   	    i;

    len = 0;
    tape_char = line_buffer;
next:
    while((ch = fgetc(in)) != EOF) {
	int eol = 0;
	switch(ch) {
	case '\r': break;
	case '\n': eol = 1;/* Do eol */ break;
	case '\t': 
		*tape_char++ = 0120;
		len++;
		while((len & 7) != 0 && len < reclen) {
		     *tape_char++ = 0120;
		     len++;
		}
		break;
	default:
		if (ascii_to_six[ch] == -1) 
		    fprintf(stderr, "Invalid char %c\n\r", ch);
		ch = 077 & ascii_to_six[ch];
		
		if (ch == 0)
		    ch = 012;
		ch |= parity_table[ch];
		*tape_char++ = ch;
		len++;
                if (len == 11 && strncmp(line_buffer, endcard, 10) == 0) {
fprintf(stderr, "End card\n");
                    if (blen)
      	      	        write_block(tape, blen, tape_buffer);
		    blen = 0;
		}
                if (len == 14 && include_file && strncmp(line_buffer, insert, 13) == 0) {
		    char *f = last;
                    char *p = last;
                    FILE *in_file;
                    /* Skip blanks */
                    tape_char = line_buffer;
                    len = 0;
                    while ((ch = fgetc(in)) == ' ');
                    *p++ = tolower(ch);
                    /* Grab next word */
                    while ((ch = fgetc(in)) != EOF) {
                         if (ch == ' ' || ch == '\r' || ch == '\n') 
                            break;
                         *p++ = tolower(ch);
                    }
		    *p++ = '.';
		    *p++ = 'f';
		    *p++ = 'a';
		    *p++ = 'p';
                    *p++ = '\0';
                    while ((ch = fgetc(in)) != EOF) {
                         if (ch == '\n') 
                            break;
                    }
                    /* Process a file */
		    if ((in_file = fopen(last, "r")) == NULL) {
			 f = include_file;
                         if ((in_file = fopen(include_file, "r")) == NULL) {
                             fprintf(stderr, "Can't open input file %s: ", include_file);
                             perror("");
                             exit(1);
                         }
                    }
                    if (verbose)
                        fprintf(stderr, "Inserting file %s\n", f);
                    process_insert(tape, in_file, NULL, last, cblk);
                    goto next;
                }
		break;
	}

	/* Put record into buffer if at end of line */
	if (eol) {
	   record++;
	   /* Fill in record with blanks */
	   while (len < reclen) {
	     *tape_char++ = 0120;
	     len++;
	   }

	   /* Copy to buffer */
	   for(i = 0; i < reclen; i++) {
	       tape_buffer[blen++] = line_buffer[i];
	   }
	   len = 0;
	   tape_char = line_buffer;
	   /* If buffer full, dump it */
	   if (blen == (reclen * cblk)) {
      	      write_block(tape, blen, tape_buffer);
	      blen = 0;
	   }
	}
    }
    if (len != 0) {
        record++;
        /* Fill in record with blanks */
        while (len < reclen) {
          *tape_char++ = 0120;
          len++;
        }

        /* Copy to buffer */
        for(i = 0; i < reclen; i++) {
            tape_buffer[blen++] = line_buffer[i];
        }
        len = 0;
        tape_char = line_buffer;
        /* If buffer full, dump it */
        if (blen == (reclen * cblk)) {
           write_block(tape, blen, tape_buffer);
           blen = 0;
        }
    }

    fclose(in);
}

/* Process CTSS file include */
void process_ctss(FILE *tape, FILE *in, int cblk) {
    char include_file[120];
    char *p;
    char *last;
    char ch;
    int  len;
    int  eol;
    FILE  *in_file;

    if (line_buffer[6] == 023 /*T*/ || line_buffer[6] == 043 /*L*/
       || line_buffer[6] == 024 /*U*/) 
         return;
    /* We need a file name next */
    len = 0;
    last = p = include_file;
    while((ch = fgetc(in)) != EOF && len < 119) {
        if (ch == '\n')
            break;
        if (ch != '\r') {
            if (ch == '/' || ch == '\\') 
                last = p;
            *p++ = ch;
            len++;
        }
    }
    *p = '\0';
    last++;
    /* Process a file */
    if ((in_file = fopen(include_file, "r")) == NULL) {
        fprintf(stderr, "Can't open input file %s: ", include_file);
        perror("");
        exit(1);
    }
    if (verbose)
        fprintf(stderr, "Reading file %s\n", include_file);
    process_insert(tape, in_file, ((line_buffer[6]&077) == 020)? include_file : NULL, last, cblk);
	      if (blen != 0) {
      		  write_block(tape, blen, tape_buffer);
	          blen = 0;
	      }
}


/* Process a file */
void process_file(FILE *tape, FILE *in) {
    uint32	    sz;
    char  	    ch;
    int	  	    len;
    int	  	    cblk;
    int	  	    last = 0;
    int   	    i;

    cblk = block;
    blen = len = 0;
    tape_char = line_buffer;
    while((ch = fgetc(in)) != EOF) {
	int eol = 0;
	int eof = 0;
	switch(ch) {
	case '\r': break;
	case '\n': eol = 1;/* Do eol */ break;
	case '\t': 
		*tape_char++ = 0120;
		len++;
		while((len & 7) != 0 && len < reclen) {
		     *tape_char++ = 0120;
		     len++;
		}
		break;
	case '~': 
		if (len > 0)
		    eol = 1; 
		/* Read rest of line */
		while((ch = fgetc(in)) != EOF && ch != '\n');
		eof = 1;
		break; /* term block and write EOF */
	default:
		if (ascii_to_six[ch] == -1) 
		    fprintf(stderr, "Invalid char %c\n\r", ch);
		ch = 077 & ascii_to_six[ch];
		
		if (ch == 0)
		    ch = 012;
		ch |= parity_table[ch];
		*tape_char++ = ch;
		len++;
		break;
	}

	/* If at record length, grab input until end of line */
	if (len == reclen && ch != EOF) {
	     while((ch = fgetc(in)) != EOF && ch != '\n')
	     eol = 1;
	}

	/* Put record into buffer if at end of line */
	if (eol) {
	   record++;
	   /* Fill in record with blanks */
	   while (len < reclen) {
	     *tape_char++ = 0120;
	     len++;
	   }

	   /* If first char is $ output it in it's own record */
	   if (*line_buffer == 053/*$*/) {
	       /* Flush out buffer */
	      if (blen != 0) {
      		  write_block(tape, blen, tape_buffer);
	          blen = 0;
	      }
	      /* Check for EOF or new blocking */
	      if (strncmp(line_buffer, eofmark, 16) == 0)
		  eof = 1;
	      else if(strncmp(line_buffer, ctssmark, 6) == 0) {
                  /* Process a CTSS file */
fprintf(stderr, "CTSS opt %02o\n", line_buffer[6]);
                  if ((line_buffer[6] & 077) != 020/*I*/)
      	              write_block(tape, reclen, line_buffer);
                  process_ctss(tape, in, cblk);
              } else if(!check_blocking(line_buffer, &cblk))
      	          write_block(tape, reclen, line_buffer);
	      if(strncmp(line_buffer, datamark, 16) == 0)
		  cblk = 1;
	   } else {
	      /* Copy to buffer */
	      for(i = 0; i < reclen; i++) {
		 tape_buffer[blen++] = line_buffer[i];
	      }
	   }
	   len = 0;
	   tape_char = line_buffer;
	   /* If buffer full, dump it */
	   if (blen == (reclen * cblk)) {
      	      write_block(tape, blen, tape_buffer);
	      blen = 0;
	   }
	}
	   
	if (eof) {
	    /* Flush out buffer */
	    if (blen != 0) {
      	      write_block(tape, blen, tape_buffer);
	      blen = 0;
	    }
            /* Write tape mark */
   	    write_mark(tape);
    	    if (verbose)
	        fprintf(stderr, "File: %d records, recl=%d, blocking=%d\n", record - last,
			reclen,block);
	    last = record;
	    cblk = block;
	}
    }

    /* If buffer not empty, flush it */
    if (len != 0) {
       int i;
       /* Fill in record with blanks */
       while (len < reclen) {
           *tape_char++ = 0120;
	   len++;
       }

       /* Put $ lines in record by themselfs */
       if (*line_buffer == 053/*$*/) {
	  if (blen != 0) {
      	      write_block(tape, blen, tape_buffer);
              blen = 0;
	   }
	   /* Check for EOF or new blocking */
	   if (strncmp(line_buffer, eofmark, 16) == 0) {
   	    	write_mark(tape);
    	        if (verbose)
	            fprintf(stderr, "File: %d records, recl=%d, blocking=%d\n", record - last,
			reclen,block);
	        last = record;
	   } else if(!check_blocking(line_buffer, &cblk))
      	        write_block(tape, reclen, line_buffer);
           cblk = block;
       } else {
           for(i = 0; i < len; i++) {
              tape_buffer[blen++] = line_buffer[i];
           }
       }
       len = 0;
       tape_char = line_buffer;
    }
    fclose(in);
}

int main(int argc, char **argv)
{
   FILE *tape;
   FILE *in;
   char	*tname = NULL;
   uint32	sz;
   char	 	ch;
   int		len;
   int		cblk;
   int		last = 0;
   int 		i;

   /*	Do options processing */
   while(--argc && **(++argv) == '-') {
   	switch(tolower((*argv)[1])) {
      case 'o':
	 tname = *++argv;
	 --argc;
	 break;
      case 'q':
      	 verbose = 0;
         break;
      case 'r':
      	 reclen = atoi(&(*argv)[2]);
         break;
      case 'b':
      	 block = atoi(&(*argv)[2]);
         break;
      case 'e':
	 eot_rec = *++argv;
	 --argc;
	 break;
      case 'p':
	 p7b = 1;
	 break;
      default:
      	fprintf(stderr,"Unknown option: %s\n",*argv);
         usage();
      }
   }

   /* If nothing to do, report usage and exit */
   if(argc == 0 || tname == NULL) {
   	usage();
   }

   if(verbose) {
	   printf("Tape file name is %s\n",tname);
   }

   if((tape = fopen(tname,"wb")) == NULL) {
   	fprintf(stderr,"Can't open tape file %s: ",tname);
      perror("");
      exit(1);
   }

   if((tape_buffer = (unsigned char  *)calloc(4096,1)) == NULL) {
   	fprintf(stderr,"calloc of tape buffer failed...\n");
      exit(1);
   }

   if((line_buffer = (unsigned char  *)calloc(250,1)) == NULL) {
   	fprintf(stderr,"calloc of tape buffer failed...\n");
      exit(1);
   }

   /* Translate message for quicker compare */
   for(i = 0; i < 20; i++) {
	ch = blocking[i];
	ch = ascii_to_six[ch];
	ch |= parity_table[ch];
	blocking[i] = ch;
	ch = eofmark[i];
	ch = ascii_to_six[ch];
	ch |= parity_table[ch];
	eofmark[i] = ch;
	ch = datamark[i];
	ch = ascii_to_six[ch];
	ch |= parity_table[ch];
	datamark[i] = ch;
	ch = ctssmark[i];
	ch = ascii_to_six[ch];
	ch |= parity_table[ch];
	ctssmark[i] = ch;
	ch = insert[i];
	ch = ascii_to_six[ch];
	ch |= parity_table[ch];
	insert[i] = ch;
	ch = endcard[i];
	ch = ascii_to_six[ch];
	ch |= parity_table[ch];
	endcard[i] = ch;
   }

   /* Process files */
   while(--argc >= 0) {
	tname = *argv++;
	if (strcmp(tname, "-") == 0) {
	   /* Flush out buffer if anything in it. */
	   if (blen != 0) {
 	      write_block(tape, blen, tape_buffer);
	      blen = 0;
           }
	   /* Put out a tape mark */
	   write_mark(tape);
	   if (verbose)
	       fprintf(stderr, "EOF: %d records, reclen=%d blocking=%d\n", record - last,
			reclen, block);
	   last = record;
           cblk = block;
	} else if (strncmp(tname, "-r", 2) == 0) {
      	   reclen = atoi(&tname[2]);
	} else if (strncmp(tname, "-b", 2) == 0) {
      	   block = atoi(&tname[2]);
	} else {
	    /* Process a file */
	    if ((in = fopen(tname, "r")) == NULL) {
	        fprintf(stderr, "Can't open input file %s: ", tname);
	        perror("");
	        exit(1);
	    }
	    if (verbose)
                fprintf(stderr, "Reading file %s\n", tname);
            process_file(tape, in);
        }   
   }

   /* Flush out buffer if anything in it. */
   if (blen != 0) 
        write_block(tape, blen, tape_buffer);

   /* Write tape mark */
   write_mark(tape);
 
   /* Write out EOT record if there is one. */
   if (eot_rec) {
	/* Process a file */
	if ((in = fopen(eot_rec, "r")) == NULL) {
	    fprintf(stderr, "Can't open input file %s: ", tname);
	    perror("");
	    exit(1);
	}
	if (verbose)
	    fprintf(stderr, "Reading file %s\n", eot_rec);
	len = 0;
	tape_char = line_buffer;
	while((ch = fgetc(in)) != EOF) {
	    int eol = 0;
	    switch(ch) {
	    case '\r': break;
	    case '\n': eol = 1;/* Do eol */ break;
	    case '\t': 
		while((len & 7) != 0 && len < reclen) {
		     *tape_char++ = 0120;
		     len++;
		}
		break;
	    default:
		if (ascii_to_six[ch] == -1) 
		    fprintf(stderr, "Invalid char %c\n\r", ch);
		ch = 077 & ascii_to_six[ch];
		
		if (ch == 0)
		    ch = 012;
		ch |= parity_table[ch];
		*tape_char++ = ch;
		len++;
		break;
	    }

	    /* Put record at end of tape */
	    if (eol) {
	       record++;
	       write_block(tape, len, line_buffer);
	       len = 0;
	    }
	}

	/* If buffer not empty, flush it */
	if (len != 0) 
	    write_block(tape, len, line_buffer);
	fclose(in);
   }

   /* Put EOM */
   write_eom(tape);

   if (verbose) {
       if (record != last)  
           fprintf(stderr, "EOF: %d records, reclen=%d blocking=%d\n", record - last,
		reclen, block);
       fprintf(stderr, "Output after %d records\n",record);
   }

   free(tape_buffer);
   free(line_buffer);
   fclose(tape);
   if (verbose) 
       fprintf(stderr, "Done.\n");
   return(0);
}


void usage()
{
   fprintf(stderr,"Usage: mkbcdtape [-o <tapefile>] [-b#] [-r#] <inputfiles>\n");
   fprintf(stderr,"	-o: name Output file name\n");
   fprintf(stderr,"	-b#: # lines per block\n");
   fprintf(stderr,"	-r#: Characters per record #\n");
   fprintf(stderr,"     -e: name Name of end of tape record\n");
   fprintf(stderr,"     -p: write BCD tape instead of TAP format\n");
   exit(1);
}

