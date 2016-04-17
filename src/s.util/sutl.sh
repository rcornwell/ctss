USER=' M1416    39'
echo -n > sutl_src.bcd
echo -n > sutl_ext.dat
for i in 7750ch.fap 7750ld.fap 7750rd.fap b1inp1.fap b1main.fap bfs.fap cdmp1d.fap \
	clock.fap cnvt1d.fap cylod.fap ddio4c.fap ddpac.fap dsetup.fap diag.fap \
	dpatch.fap hsdt1a.fap ioconv.fap iopa2c.fap iopb2c.fap iopc2c.fap iopd2c.fap \
	iope2c.fap list1d.fap mdmp2d.fap opcd1d.fap panic.fap prntbk.fap prnter.fap \
	upck2d.fap load.fap ; do
     NAME=`basename $i .fap | sed 's/_/./g'`
     obj2img -A -a "$USER" -t -f $NAME -e 'FAP' -o tmp.img $i
     cat tmp.img >> sutl_src.bcd
done
for i in 7750ld.ctssld b1prt1.ctssld b1prtb.ctssld cloc1a.ctssld dpatch.ctssld \
	dstp4a.ctssld hsdt1a.ctssld ; do
     NAME=`basename $i .ctssld | sed 's/_/./g'`
     obj2img -A -a "$USER" -t -f $NAME -e 'ctssld' -o tmp.img $i
     cat tmp.img >> sutl_src.bcd
done
for i in cylod.runcom dsetup.runcom panic.runcom b1inp.runcom b1prt1.runcom \
	7750ld.runcom dpatch.runcom hsdt1a.runcom clock.runcom iopac.runcom \
	upd.runcom ; do
     NAME=`basename $i .runcom | sed 's/_/./g'`
     obj2img -A -a "$USER" -t -f $NAME -e 'RUNCOM' -o tmp.img $i
     cat tmp.img >> sutl_src.bcd
     grep '(LIST)' $i \
	| awk '{x="      " $2; print substr(x,length(x)-5,6) "   BCD     I'"$USER"'"}' >>sutl_ext.dat
done
#cat EOF.BIN >>sutl_src.bcd
rm tmp.img
