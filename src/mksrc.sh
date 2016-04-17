(cd arch; sh arch.sh)
(cd asclib; sh asclib.sh)
(cd basic; sh basic.sh)
(cd daemon; sh daemon.sh)
(cd debug; sh madbug.sh)
(cd dskedt; sh dskedt.sh)
(cd edit; sh edit.sh)
(cd fib; sh fib.sh)
(cd filsim; sh filsim.sh)
(cd fsys4d; sh fsys.sh)
(cd login; sh login.sh)
(cd madtrn; sh madtrn.sh)
(cd miscmd; sh misc.sh)
(cd mit8c0; sh mit.sh)
(cd plibe; sh plibe.sh)
(cd runoff; sh runoff.sh)
(cd salv4a; sh salv.sh)
(cd s.util; sh sutl.sh)
(cd tools; sh mksrc.sh)
(cd tslib1; sh lib1.sh)
(cd tslib1; sh lib2.sh)
(cd tslib1; sh lib3.sh)
(cd tslib2; sh tslib2.sh)
(cd xlibe; sh xlib.sh)
cat arch/arc_src.bcd asclib/asclib_src.bcd basic/bas_src.bcd daemon/dae_src.bcd \
    debug/bug_src.bcd dskedt/dskedt_src.bcd edit/edt_src.bcd fib/fib_src.bcd \
    filsim/filsim_src.bcd fsys4d/fsys_src.bcd login/log_src.bcd madtrn/mad_src.bcd \
    miscmd/mis_src.bcd mit8c0/mit_src.bcd plibe/plib_src.bcd runoff/run_src.bcd \
    salv4a/sal_src.bcd s.util/sutl_src.bcd tools/src_src.bcd tslib1/lib1_src.bcd \
    tslib1/lib2_src.bcd tslib1/lib3_src.bcd tslib2/tslib2_src.bcd xlibe/xlib_src.bcd >src.bcd
