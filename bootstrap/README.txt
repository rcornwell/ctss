Build tools for CTSS.
Compile mkctsstape.c to mkctsstape in this directory.
Copy mkbcdtape and listtape from https://github.com/rcornwell/I7000tools to here.


Step 1) Build CTSS FAP to run under IBSYS.

    Run ibfap.job with 

       i7090 ibfap.ini

    srctape3.tp is the source tape from IBSYS including IBSFAP. 

    Result in sysfap.tp an IBSYS system with CTSS FAP.

    Note this assembler does not support INSERT so all included files
  must be done manually. 

Step 2) Format disks.

   Run dsetup.job with

      i7090 dsetup.ini

   Needs sysfap.tp to build system. dsetup.cmd defines the system.

Step 3) Load base system onto disks.

   Run setup.job with

     i7090 setup.ini

   The first part of the job assembles the needed programs. These
  must be complete in one file. These include LOAD, FAP, LOGIN, INIT,
  HELLO. 

   Next the setup program is compiled, this program will read from the
   source tape and SYSPP2 and place these files on the CTSS system disk.

Step 4) Load basic system. 


