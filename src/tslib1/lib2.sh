USER=' M1416    35'
echo -n > lib2_src.bcd
for i in fpt0.fap free.fap fsta.fap fstt.fap gac0.fap gblp.fap gbuf.fap \
	 gclc.fap getc.fap geti.fap getm.fap gett.fap gloc.fap gmem.fap \
	 gnam.fap gopt.fap gsys.fap gtcl.fap gtcm.fap gtdy.fap gtlo.fap \
	 gtnm.fap gwrd.fap int0.fap iodg.fap ioem.fap ioh0.fap isin.fap \
	 ldfl.fap ldum.fap ljus.fap log0.fap max0.fap max1.fap min0.fap \
	 min1.fap mod0.fap moun.fap move.fap mtx0.fap ncom.fap nexc.fap \
	 ocbc.fap open.fap pack.fap pad0.fap pcmt.fap macs.fap ; do
     NAME=`basename $i .fap`
     obj2img -A -a "$USER" -t -f $NAME -e 'FAP' -o tmp.img $i
     cat tmp.img >> lib2_src.bcd
done
sh ./mkrun.sh lib2 fpt0.fap free.fap fsta.fap fstt.fap gac0.fap gblp.fap \
	gbuf.fap gclc.fap getc.fap geti.fap getm.fap gett.fap gloc.fap \
	gopt.fap gmem.fap gnam.fap gsys.fap gtcl.fap gtcm.fap gtdy.fap \
	gtlo.fap gtnm.fap gwrd.fap int0.fap iodg.fap ioem.fap ioh0.fap \
	isin.fap ldfl.fap ldum.fap ljus.fap log0.fap max0.fap max1.fap \
	min0.fap min1.fap mod0.fap moun.fap move.fap mtx0.fap ncom.fap \
	nexc.fap ocbc.fap open.fap pad0.fap pack.fap pcmt.fap >lib2.runcom
obj2img -A -a "$USER" -t -f lib2 -e 'RUNCOM' -o tmp.img lib2.runcom
cat tmp.img >> lib2_src.bcd
grep '(LIST)' lib2.runcom | \
	 awk '{x="      " $2; print substr(x,length(x)-5,6) "   BCD     I'"$USER"'"}' >ts2_ext.dat
grep '(LIST)' lib2.runcom \
	| awk '{x="      " $2; print substr(x,length(x)-5,6) "   BSS     B'"$USER"'"}' > ts2_bss.dat
#cat EOF.BIN >>lib2_src.bcd
rm tmp.img
