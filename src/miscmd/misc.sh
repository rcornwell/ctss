USER=' M1416    23'
echo -n > mis_src.bcd
echo -n > mis_ext.dat
for i in 7read.fap _abrv.fap args.fap comand.fap _com.fap dsker.fap fapmai.fap \
	flsrtn.fap fmstap.fap gtprob.fap _ic.fap lmsort.fap macs.fap main0.fap \
	_main.fap mergen.fap mrc1a1.fap mrc2a1.fap mrc3a1.fap nocmmd.fap nsort.fap \
	_pri.fap _profl.fap red.fap wrfx.fap write.fap zot.fap asctss.fap _ball.fap ; do
     NAME=`basename $i .fap | sed 's/_/./g'`
     obj2img -A -a "$USER" -t -c -f $NAME -e 'FAP' -o tmp.img $i
     cat tmp.img >> mis_src.bcd
done
for i in aarchv.mad aform.mad asubs.mad backup.mad chball.mad fapcom.mad \
	look.mad mail.mad mover.mad option.mad pinfo.mad prbin.mad remrk.mad \
	smail.mad tsspmt.mad getfil.mad prime.mad ; do
     NAME=`basename $i .mad | sed 's/_/./g'`
     obj2img -A -a "$USER" -t -c -f $NAME -e 'MAD' -o tmp.img $i
     cat tmp.img >> mis_src.bcd
done
for i in aarchv.runcom chball.runcom fmstap.runcom abbr.runcom mail.runcom \
	nocmmd.runcom option.runcom pinfo.runcom prbin.runcom remark.runcom \
	write.runcom zot.runcom 7read.runcom backup.runcom fapcom.runcom \
	lmsort.runcom look.runcom mover.runcom nsort.runcom upd.runcom ; do
     NAME=`basename $i .runcom | sed 's/_/./g'`
     obj2img -A -a "$USER" -t -f $NAME -e 'RUNCOM' -o tmp.img $i
     cat tmp.img >> mis_src.bcd
     grep '(LIST)' $i \
	| awk '{x="      " $2; print substr(x,length(x)-5,6) "   BCD     I'"$USER"'"}' >>mis_ext.dat
done
for i in 7750ld.fms all.fms b1prt1.fms ddsetp.fms dpatch.fms dump.fms ediprv.fms \
	editor.fms load.fms octdmp.fms phase1.fms phase2.fms primer.fms sadump.fms \
	salv.fms sort.fms stat.fms strve.fms ; do
     NAME=`basename $i .fms | sed 's/_/./g'`
     obj2img -A -a "$USER" -t -c -f $NAME -e 'FMS' -o tmp.img $i
     cat tmp.img >> mis_src.bcd
done
obj2img -A -a "$USER" -t -f 7750 -e '(PROG)' -o tmp.img 7750.prog
cat tmp.img >> mis_src.bcd
obj2img -A -a "$USER" -t -f USER -e PROFIL -o tmp.img user.profil
cat tmp.img >> mis_src.bcd
obj2img -A -a "$USER" -t -f IPC -e 6.36 -o tmp.img ipc.6.36
cat tmp.img >> mis_src.bcd
obj2img -A -a "$USER" -t -f SUPERX -e 6.36 -o tmp.img superx.6.36
cat tmp.img >> mis_src.bcd
#cat EOF.BIN >>mis_src.bcd
rm tmp.img
