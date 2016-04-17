USER=' M1416    31'
echo -n > tslib2_src.bcd
for i in dbug.fap fpd0.fap fpm0.fap trac.fap ; do
     NAME=`basename $i .fap`
     obj2img -A -a "$USER" -t -f $NAME -e 'FAP' -o tmp.img $i
     cat tmp.img >> tslib2_src.bcd
done
obj2img -A -a "$USER" -t -f tslib2 -e 'RUNCOM' -o tmp.img tslib2.runcom
cat tmp.img >> tslib2_src.bcd
grep '(LIST)' tslib2.runcom \
	| awk '{x="      " $2; print substr(x,length(x)-5,6) "   BCD     I'"$USER"'"}' >tsl2_ext.dat
grep '(LIST)' tslib2.runcom \
	| awk '{x="      " $2; print substr(x,length(x)-5,6) "   BSS     B'"$USER"'"}' >tsl2_bss.dat
#cat EOF.BIN >>tslib2_src.bcd
rm tmp.img
