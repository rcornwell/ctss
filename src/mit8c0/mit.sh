USER=' M1416    30'
echo -n > mit_src.bcd
echo -n > mit_ext.dat
for i in adpi8a.fap ap758a.fap bksv8c.fap brkp8d.fap chne8a.fap cloc8h.fap com800.fap \
	comc8g.fap common.fap conv8a.fap cpyc8b.fap ctrl8f.fap dump8b.fap edbg8a.fap \
	equ.fap fint8b.fap high8a.fap ibuf8b.fap macro.fap main8c.fap onln8f.fap \
	pdpa8b.fap pmti8a.fap rtrn8e.fap savc8c.fap savr8b.fap scda8c.fap scdb8a.fap \
	scdc8c.fap scdd8a.fap t2char.fap tachar.fap tcor8b.fap tsto8a.fap twchar.fap \
	txchar.fap ulib8h.fap ulod8a.fap unit8b.fap util8c.fap utrp8a.fap wrfl8b.fap \
	wrhi8a.fap ; do
     NAME=`basename $i .fap | sed 's/_/./g'`
     obj2img -A -a "$USER" -t -f $NAME -e 'FAP' -o tmp.img $i
     cat tmp.img >> mit_src.bcd
done
for i in  mit8c0.ctssld ; do
     NAME=`basename $i .ctssld | sed 's/_/./g'`
     obj2img -A -a "$USER" -t -f $NAME -e 'ctssld' -o tmp.img $i
     cat tmp.img >> mit_src.bcd
done
for i in mit.runcom upd.runcom ; do
     NAME=`basename $i .runcom | sed 's/_/./g'`
     obj2img -A -a "$USER" -t -f $NAME -e 'RUNCOM' -o tmp.img $i
     cat tmp.img >> mit_src.bcd
     grep '(LIST)' $i \
	| awk '{x="      " $2; print substr(x,length(x)-5,6) "   BCD     I'"$USER"'"}' >>mit_ext.dat
done
#cat EOF.BIN >>mit_src.bcd
rm tmp.img
