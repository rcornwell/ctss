USER=' M1416GUEST '
echo -n > fsb_src.bcd
for i in bucm2e.fap cma.d.fap cmb.c.fap cmm.d.fap cmq.c.fap cmv.c.fap ddap4c.fap \
        ddapb.fap ddst2i.fap fcor2o.fap iocm2e.fap ioequa.fap ioequb.fap loadts.fap \
	push2a.fap qman2b.fap scnd4a.fap sear2b.fap sm1a.i.fap sm1b.g.fap sm1e.d.fap \
	sm1m.c.fap sm1v.f.fap srch2a.fap stik2e.fap stmequ.fap stmmac.fap stm.mc.fap \
	tman4a.fap tpap2h.fap tpapdm.fap tpsm2q.fap tpst2a.fap trac2a.fap tsmequ.fap \
        tracb.fap ; do
     NAME=`basename $i .fap | sed 's/_/./g'`
     obj2img -A -a "$USER" -t -f $NAME -e 'FAP' -o tmp.img $i
     cat tmp.img >> fsb_src.bcd
done
obj2img -A -a "$USER" -t -f fsb -e 'RUNCOM' -o tmp.img fsb.runcom
cat tmp.img >> fsb_src.bcd
obj2img -A -a "$USER" -t -f fsa -e 'RUNCOM' -o tmp.img fsa.runcom
cat tmp.img >> fsb_src.bcd
#cat EOF.BIN >>fsb_src.bcd
rm tmp.img
