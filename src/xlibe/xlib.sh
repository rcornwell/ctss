USER=' M1416    37'
echo -n > xlib_src.bcd
for i in absdat.fap abstim.fap acore.fap brake.fap bz57.fap comloc.fap \
	 delete.fap dsker.fap exit.fap fix.fap _fmt.fap fracbc.fap geta.fap \
	 getbuf.fap getim.fap gtch1.fap gtwdb.fap gtwdbx.fap hrmin.fap \
	ioconv.fap move.fap namask.fap pkwd1.fap prdata.fap prdiag.fap \
	 prfull.fap prmess.fap ptias.fap reprob.fap scan.fap snap.fap \
	 snooze.fap spray.fap tdec.fap tsk.fap wrflx.fap ; do
     NAME=`basename $i .fap | sed 's/_/./g'`
     obj2img -A -a "$USER" -t -f $NAME -e 'FAP' -o tmp.img $i
     cat tmp.img >> xlib_src.bcd
done
sh ./mkrun.sh xlibe comloc.fap acore.fap prmess.fap prfull.fap prdata.fap \
	wrflx.fap scan.fap bz57.fap reprob.fap namask.fap tdec.fap ioconv.fap \
	getim.fap abstim.fap hrmin.fap absdat.fap fix.fap fracbc.fap \
	snooze.fap exit.fap prdiag.fap snap.fap brake.fap dsker.fap tsk.fap \
	delete.fap move.fap spray.fap gtwdbx.fap gtwdb.fap pkwd1.fap gtch1.fap \
	getbuf.fap geta.fap .fmt.fap ptias.fap >xlibe.runcom
obj2img -A -a "$USER" -t -f xlibe -e 'RUNCOM' -o tmp.img xlibe.runcom
cat tmp.img >> xlib_src.bcd
grep '(LIST)' xlibe.runcom \
	| awk '{x="      " $2; print substr(x,length(x)-5,6) "   BCD     I'"$USER"'"}' >xlib_ext.dat
grep '(LIST)' xlibe.runcom \
	| awk '{x="      " $2; print substr(x,length(x)-5,6) "   BSS     B'"$USER"'"}' >xlib_bss.dat
#cat EOF.BIN >>xlib_src.bcd
rm tmp.img
