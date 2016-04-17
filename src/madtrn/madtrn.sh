USER=' M1416    31'
echo -n > mad_src.bcd
echo -n > mad_ext.dat
for i in mlib.fap madtrn.fap ; do
     NAME=`basename $i .fap | sed 's/_/./g'`
     obj2img -A -a "$USER" -t -f $NAME -e 'FAP' -o tmp.img $i
     cat tmp.img >> mad_src.bcd
done
for i in iop9.mad mfns.mad mrrp.mad mtr2.mad mtrn.mad tdfev.mad ; do
     NAME=`basename $i .mad | sed 's/_/./g'`
     obj2img -A -a "$USER" -t -c -f $NAME -e 'MAD' -o tmp.img $i
     cat tmp.img >> mad_src.bcd
done
for i in primes.f ; do
     NAME=`basename $i .f | sed 's/_/./g'`
     obj2img -A -a "$USER" -t -f $NAME -e 'MADTRN' -o tmp.img $i
     cat tmp.img >> mad_src.bcd
done
for i in madtrn.runcom ; do
     NAME=`basename $i .runcom | sed 's/_/./g'`
     obj2img -A -a "$USER" -t -f $NAME -e 'RUNCOM' -o tmp.img $i
     cat tmp.img >> mad_src.bcd
     grep '(LIST)' $i \
	| awk '{x="      " $2; print substr(x,length(x)-5,6) "   BCD     I'"$USER"'"}' >>mad_ext.dat
done
#cat EOF.BIN >>mad_src.bcd
rm tmp.img
