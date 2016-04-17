USER=' M1416    21'
echo -n > asclib_src.bcd
for i in nsctss.fap ; do
     NAME=`basename $i .fap`
     obj2img -A -a "$USER" -t -c -f $NAME -e 'FAP' -o tmp.img $i
     cat tmp.img >> asclib_src.bcd
done
for i in ascon.mad asctyp.mad edval.mad escape.mad getdev.mad ncanno.mad \
	nkedit.mad  ; do
     NAME=`basename $i .mad`
     obj2img -A -a "$USER" -t -c -f $NAME -e 'MAD' -o tmp.img $i
     cat tmp.img >> asclib_src.bcd
done
obj2img -A -a "$USER" -t -f asclib -e 'RUNCOM' -o tmp.img asclib.runcom
cat tmp.img >> asclib_src.bcd
grep '(LIST)' asclib.runcom \
	| awk '{x="      " $2; print substr(x,length(x)-5,6) "   BCD     I'"$USER"'"}' >asc_ext.dat
grep '(LIST)' asclib.runcom \
	| awk '{x="      " $2; print substr(x,length(x)-5,6) "   BSS     B'"$USER"'"}' >asc_bss.dat
#cat EOF.BIN >>asclib_src.bcd
rm tmp.img
