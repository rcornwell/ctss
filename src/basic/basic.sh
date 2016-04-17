USER=' M1416    22'
echo -n > bas_src.bcd
echo -n > bas_ext.dat
for i in call3.fap call4.fap comfl.fap copy.fap getmd.fap  \
	list4.fap list5.fap macs.fap move.fap newmod.fap nullb.fap \
	reprb.fap unique.fap update.fap dsker.fap delete.fap do.fap \
        runcom.fap schain.fap gencom.fap blip.fap mount.fap \
	tapfil.fap verify.fap brake.fap printf.fap ; do
     NAME=`basename $i .fap | sed 's/_/./g'`
     obj2img -A -a "$USER" -t -c -f $NAME -e 'FAP' -o tmp.img $i
     cat tmp.img >> bas_src.bcd
done
for i in call1.mad call2.mad chmde.mad link.mad list1.mad list2.mad \
	 list3.mad setfil.mad unlink.mad permit.mad revok.mad ; do
     NAME=`basename $i .mad | sed 's/_/./g'`
     obj2img -A -a "$USER" -t -c -f $NAME -e 'MAD' -o tmp.img $i
     cat tmp.img >> bas_src.bcd
done
for i in  call.runcom chmode.runcom comfil.runcom link.runcom listf.runcom \
	move.runcom permit.runcom revok.runcom setfil.runcom \
	unlink.runcom update.runcom  do.runcom runcom.runcom gencom.runcom \
        blip.runcom mount.runcom verify.runcom tapfil.runcom printf.runcom ; do
     NAME=`basename $i .runcom | sed 's/_/./g'`
     obj2img -A -a "$USER" -t -f $NAME -e 'RUNCOM' -o tmp.img $i
     cat tmp.img >> bas_src.bcd
     grep '(LIST)' $i \
	| awk '{x="      " $2; print substr(x,length(x)-5,6) "   BCD     I'"$USER"'"}' >>bas_ext.dat
done
#cat EOF.BIN >>bas_src.bcd
rm tmp.img
