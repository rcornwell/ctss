USER=' M1416    26'
echo -n > edt_src.bcd
echo -n > edt_ext.dat
for i in 0qed.fap 1qed.fap 2qed.fap asctss.fap bin.fap clrnam.fap cnvtbl.fap devtbl.fap \
	initdt.fap lmio12.fap lmio6.fap nclib.fap openf.fap openw.fap paknr.fap pntlin.fap \
	prnter.fap prword.fap qed.fap rename.fap setops.fap setup.fap unpnr.fap wordio.fap \
	zcmd.fap wmacs.fap prer.fap ; do
     NAME=`basename $i .fap | sed 's/_/./g'`
     obj2img -A -a "$USER" -t -c -f $NAME -e 'FAP' -o tmp.img $i
     cat tmp.img >> edt_src.bcd
done
for i in 12typ.mad 6concd.mad 6typ.mad bincon.mad binval.mad edaval.mad editcd.mad \
	editor.mad edlval.mad _mod_.mad p.mad print.mad reund.mad typval.mad ; do
     NAME=`basename $i .mad | sed 's/_/./g'`
     obj2img -A -a "$USER" -t -c -f $NAME -e 'MAD' -o tmp.img $i
     cat tmp.img >> edt_src.bcd
done
for i in  eda.runcom edb.runcom edc.runcom edl.runcom p.runcom typset.runcom \
	print.runcom prnter.runcom qed.runcom ; do
     NAME=`basename $i .runcom | sed 's/_/./g'`
     obj2img -A -a "$USER" -t -f $NAME -e 'RUNCOM' -o tmp.img $i
     cat tmp.img >> edt_src.bcd
     grep '(LIST)' $i \
	| awk '{x="      " $2; print substr(x,length(x)-5,6) "   BCD     I'"$USER"'"}' >>edt_ext.dat
done
#cat EOF.BIN >>edt_src.bcd
rm tmp.img
