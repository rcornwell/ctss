USER=' M1416    33'
echo -n > dae_src.bcd
echo -n > dae_ext.dat
for i in askopr.fap bcmeqf.fap bmcrsc.fap daemon.fap dcmeqf.fap dcycle.fap \
	dfiomb.fap ddmapa.fap derazb.fap dgdtma.fap dksta.fap dmcrsa.fap \
	ddpflb.fap dpusrb.fap drstrb.fap dsdump.fap dsload.fap geta1.fap iob.fap \
	linttb.fap liorde.fap lrfldc.fap mount.fap prcode.fap putin.fap setup.fap \
	sldtfc.fap swt.fap valid.fap xmod.fap unique.fap bcmeqa.fap core.fap \
	dcmeqa.fap ddmapb.fap dprt1b.fap extklu.fap ffsel.fap geta.fap ioa1c.fap \
	iohsim.fap ph1.fap  prime.fap rcard.fap rdcard.fap sadpmn.fap smainc.fap \
	sdcyca.fap sdksta.fap  sleep.fap s.stup.fap tias.fap tpwait.fap  \
	tsslib.fap key.fap ; do
     NAME=`basename $i .fap | sed 's/_/./g'`
     obj2img -A -a "$USER" -t -f $NAME -e 'FAP' -o tmp.img $i
     cat tmp.img >> dae_src.bcd
done
for i in ckent.mad ckufd.mad com.mad crecap.mad dcount.mad decide.mad deltab.mad \
        ldfile.mad mail.mad recap.mad rlibe.mad settap.mad tdyfil.mad tpread.mad \
	trieve.mad ckdate.mad compat.mad prime.mad ; do
     NAME=`basename $i .mad | sed 's/_/./g'`
     obj2img -A -a "$USER" -t -c -f $NAME -e 'MAD' -o tmp.img $i
     cat tmp.img >> dae_src.bcd
done
for i in prim4b.ctssld psh14b.ctssld psh24b.ctssld sdmp4.ctssld strv4a.ctssld ; do
     NAME=`basename $i .ctssld | sed 's/_/./g'`
     obj2img -A -a "$USER" -t -f $NAME -e 'CTSSLD' -o tmp.img $i
     cat tmp.img >> dae_src.bcd
done
for i in define.mad nlrec.mad settim.mad ; do
     NAME=`basename $i .mad | sed 's/_/./g'`
     obj2img -A -a "$USER" -t -f $NAME -e 'MAD' -o tmp.img $i
     cat tmp.img >> dae_src.bcd
done
for i in daemon.runcom dsdump.runcom dsload.runcom trieve.runcom phase1.runcom \
	 phase2.runcom sadump.runcom strve.runcom primer.runcom upd.runcom ; do
     NAME=`basename $i .runcom | sed 's/_/./g'`
     obj2img -A -a "$USER" -t -f $NAME -e 'RUNCOM' -o tmp.img $i
     cat tmp.img >> dae_src.bcd
     grep '(LIST)' $i \
	| awk '{x="      " $2; print substr(x,length(x)-5,6) "   BCD     I'"$USER"'"}' >>dae_ext.dat
done
#cat EOF.BIN >>dae_src.bcd
rm tmp.img
