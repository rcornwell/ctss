USER=' M1416    20'
echo -n > arc_src.bcd
echo -n > arc_ext.dat
for i in clrnam.fap ioerr.fap setup.fap lmio6.fap wordio.fap \
	prword.fap daytim.fap rename.fap ; do
     NAME=`basename $i .fap | sed 's/_/./g'`
     obj2img -A -a "$USER" -t -f $NAME -e 'FAP' -o tmp.img $i
     cat tmp.img >> arc_src.bcd
done
for i in combin.mad iocard.mad split.mad squash.mad 6typ.mad xpand.mad \
        aform.mad apenda.mad append.mad archa.mad archiv.mad asubs.mad ; do
     NAME=`basename $i .mad | sed 's/_/./g'`
     obj2img -A -a "$USER" -t -c -f $NAME -e 'MAD' -o tmp.img $i
     cat tmp.img >> arc_src.bcd
done
for i in apend.runcom archiv.runcom xpand.runcom squash.runcom \
	split.runcom combin.runcom ; do
     NAME=`basename $i .runcom | sed 's/_/./g'`
     obj2img -A -a "$USER" -t -f $NAME -e 'RUNCOM' -o tmp.img $i
     cat tmp.img >> arc_src.bcd
     grep '(LIST)' $i \
	| awk '{x="      " $2; print substr(x,length(x)-5,6) "   BCD     I'"$USER"'"}' >>arc_ext.dat
done
#cat EOF.BIN >>arc_src.bcd
rm tmp.img
