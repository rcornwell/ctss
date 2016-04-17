USER=' M1416    32'
echo -n > plib_src.bcd
for i in minmax.fap numb.fap nump.fap plotr.fap sym5.fap ; do
     NAME=`basename $i .fap | sed 's/_/./g'`
     obj2img -A -a "$USER" -t -f $NAME -e 'FAP' -o tmp.img $i
     cat tmp.img >> plib_src.bcd
done
for i in axis1.mad cmbplt.mad dxdy1.mad ernote.mad fixup.mad graph1.mad \
	graph.mad _ops_.mad pictur.mad scale1.mad sclgph.mad set.mad \
	_xr_.mad ; do
     NAME=`basename $i .mad | sed 's/_/./g'`
     obj2img -A -a "$USER" -t -c -f $NAME -e 'MAD' -o tmp.img $i
     cat tmp.img >> plib_src.bcd
done
sh ./mkrun.sh plibe ernote.mad sclgph.mad scale1.mad pictur.mad \
	graph.mad graph1.mad dxdy1.mad axis1.mad set.mad cmbplt.mad \
	fixup.mad numb.fap nump.fap sym5.fap minmax.fap plotr.fap >plibe.runcom
obj2img -A -a "$USER" -t -f plibe -e 'RUNCOM' -o tmp.img plibe.runcom
cat tmp.img >> plib_src.bcd
grep '(LIST)' plibe.runcom \
	| awk '{x="      " $2; print substr(x,length(x)-5,6) "   BCD     I'"$USER"'"}' >plib_ext.dat
grep '(LIST)' plibe.runcom \
	| awk '{x="      " $2; print substr(x,length(x)-5,6) "   BSS     B'"$USER"'"}' >plib_bss.dat
#cat EOF.BIN >>plib_src.bcd
rm tmp.img
