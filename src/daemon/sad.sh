USER=' M1416GUEST '
echo -n > sad_src.bcd
echo -n > sad_ext.dat
for i in askopr.fap bcmeqb.fap bmcrsc.fap core.fap dcmeqb.fap dfiomb.fap ddmapb.fap \
	derazb.fap dgdtma.fap dmcrsa.fap ddpflb.fap dprt1b.fap dpusrb.fap drstrb.fap \
	extklu.fap ffsel.fap geta.fap ioa1c.fap iob.fap iohsim.fap linttb.fap liorde.fap \
	lrfldc.fap ph1.fap prcode.fap prime.fap rcard.fap rdcard.fap sadpmn.fap \
	smainc.fap sdcyca.fap sdksta.fap sldtfc.fap sleep.fap s.stup.fap swt.fap \
	tias.fap tpwait.fap tsslib.fap unique.fap valid.fap xmod.fap ; do
     NAME=`basename $i .fap | sed 's/_/./g'`
     obj2img -A -a "$USER" -t -f $NAME -e 'FAP' -o tmp.img $i
     cat tmp.img >> sad_src.bcd
done
for i in ckdate.mad ckent.mad ckufd.mad com.mad compat.mad crecap.mad dcount.mad decide.mad \
	deltab.mad ldfile.mad mail.mad recap.mad rlibe.mad settap.mad tdyfil.mad tpread.mad \
	trieve.mad ; do
     NAME=`basename $i .mad | sed 's/_/./g'`
     obj2img -A -a "$USER" -t -c -f $NAME -e 'MAD' -o tmp.img $i
     cat tmp.img >> sad_src.bcd
done
for i in define.mad nlrec.mad settim.mad ; do
     NAME=`basename $i .mad | sed 's/_/./g'`
     obj2img -A -a "$USER" -t -f $NAME -e 'MAD' -o tmp.img $i
     cat tmp.img >> fgd_src.bcd
done
for i in phase1.runcom phase2.runcom sadump.runcom strve.runcom primer.runcom ; do
     NAME=`basename $i .runcom | sed 's/_/./g'`
     obj2img -A -a "$USER" -t -f $NAME -e 'RUNCOM' -o tmp.img $i
     cat tmp.img >> sad_src.bcd
     grep '(LIST)' $i \
	| awk '{x="      " $2; print substr(x,length(x)-5,6) "   BCD     I'"$USER"'"}' >>sad_ext.dat
done
#cat EOF.BIN >>sad_src.bcd
rm tmp.img
