USER=' M1416    29'
echo -n > fsys_src.bcd
echo -n > fsys_ext.dat
for i in bucm2e.fap cma.d.fap cmb.c.fap cmm.d.fap cmq.c.fap cmv.c.fap ddap4c.fap \
	ddapb.fap ddst2i.fap iocm2e.fap ioequa.fap ioequb.fap loadts.fap push2a.fap \
	qman2b.fap qman2c.fap scnd4a.fap sear2b.fap sm1a.i.fap sm1b.g.fap sm1e.d.fap \
	sm1m.c.fap sm1v.f.fap srch2a.fap stik2e.fap stmequ.fap stmmac.fap stm.mc.fap \
	tman4a.fap tpap2h.fap tpapdm.fap tpsm2q.fap tpst2a.fap trac2a.fap tracb.fap \
	tsmequ.fap fcor2o.fap ; do
     NAME=`basename $i .fap | sed 's/_/./g'`
     obj2img -A -a "$USER" -t -f $NAME -e 'FAP' -o tmp.img $i
     cat tmp.img >> fsys_src.bcd
done
for i in  fsys4a.ctssld ; do
     NAME=`basename $i .ctssld | sed 's/_/./g'`
     obj2img -A -a "$USER" -t -f $NAME -e 'ctssld' -o tmp.img $i
     cat tmp.img >> fsys_src.bcd
done
for i in  fsa.runcom fsb.runcom upd.runcom ; do
     NAME=`basename $i .runcom | sed 's/_/./g'`
     obj2img -A -a "$USER" -t -f $NAME -e 'RUNCOM' -o tmp.img $i
     cat tmp.img >> fsys_src.bcd
     grep '(LIST)' $i \
	| awk '{x="      " $2; print substr(x,length(x)-5,6) "   BCD     I'"$USER"'"}' >>fsys_ext.dat
done
#cat EOF.BIN >>fsys_src.bcd
rm tmp.img
