USER=' M1416    34'
echo -n > sal_src.bcd
echo -n > sal_ext.dat
for i in dioi.fap diot.fap indx.fap keys.fap mprt.fap rdin.fap _rst.fap setp.fap \
	stop.fap xpnd.fap ; do
     NAME=`basename $i .fap | sed 's/_/./g'`
     obj2img -A -a "$USER" -t -f $NAME -e 'FAP' -o tmp.img $i
     cat tmp.img >> sal_src.bcd
done
for i in salv4a.ctssld sort4a.ctssld stat4a.ctssld ; do
     NAME=`basename $i .ctssld | sed 's/_/./g'`
     obj2img -A -a "$USER" -t -f $NAME -e 'CTSSLD' -o tmp.img $i
     cat tmp.img >> sal_src.bcd
done
for i in cdmp.mad cent4.mad cvdt4.mad dump4.mad load4.mad pter4.mad rfil4.mad \
	rtut4.mad salequ.mad salv4.mad smfd4.mad sort.mad sortm.mad stat4.mad ; do
     NAME=`basename $i .mad | sed 's/_/./g'`
     obj2img -A -a "$USER" -t -c -f $NAME -e 'MAD' -o tmp.img $i
     cat tmp.img >> sal_src.bcd
done
for i in dump4.runcom load4.runcom salv4.runcom sort4.runcom stat4.runcom \
	libe.runcom upd.runcom ; do
     NAME=`basename $i .runcom | sed 's/_/./g'`
     obj2img -A -a "$USER" -t -f $NAME -e 'RUNCOM' -o tmp.img $i
     cat tmp.img >> sal_src.bcd
     grep '(LIST)' $i \
	| awk '{x="      " $2; print substr(x,length(x)-5,6) "   BCD     I'"$USER"'"}' >>sal_ext.dat
done
#cat EOF.BIN >>sal_src.bcd
rm tmp.img
