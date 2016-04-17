USER=' M1416    25'
echo -n > dskedt_src.bcd
echo -n > dsk_ext.dat
for i in 03200.fap cddelt.fap chrg.b.fap chrg.s.fap corea.fap deccnv.fap \
       derbc.fap edtio.fap err.fap extbkg.fap filsys.fap flip.fap getape.fap \
       gett.fap iou.fap packfp.fap privl7.fap privlz.fap rcard.fap scan.fap \
       setup.fap sprdoc.fap stmarg.fap unpack.fap untab.fap coreb.fap \
       cardrq.fap output.fap ; do
     NAME=`basename $i .fap | sed 's/_/./g'`
     obj2img -A -a "$USER" -t -f $NAME -e 'FAP' -o tmp.img $i
     cat tmp.img >> dskedt_src.bcd
done
for i in adjprb.mad bpnch.mad comdsk.mad dpnch.mad dskedt.mad input.mad \
      mfddlt.mad pnch7.mad scnmf1.mad scnmfd.mad _sw_.mad rquest.mad ; do
     NAME=`basename $i .mad | sed 's/_/./g'`
     obj2img -A -a "$USER" -t -c -f $NAME -e 'MAD' -o tmp.img $i
     cat tmp.img >> dskedt_src.bcd
done
for i in edpv4d.ctssld edtr4d.ctssld ; do
     NAME=`basename $i .ctssld | sed 's/_/./g'`
     obj2img -A -a "$USER" -t -f $NAME -e 'CTSSLD' -o tmp.img $i
     cat tmp.img >> dskedt_src.bcd
done
for i in dskedt.runcom rquest.runcom upd.runcom ; do
     NAME=`basename $i .runcom | sed 's/_/./g'`
     obj2img -A -a "$USER" -t -f $NAME -e 'RUNCOM' -o tmp.img $i
     cat tmp.img >> dskedt_src.bcd
     grep '(LIST)' $i \
	| awk '{x="      " $2; print substr(x,length(x)-5,6) "   BCD     I'"$USER"'"}' >>dsk_ext.dat
done
for i in EDTIOA FLIPA RCARDA EDTIOB FLIPB RCARDB ; do
     echo $i \
	| awk '{x="      " $1; print substr(x,length(x)-5,6) "   BCD     I'"$USER"'"}' >>dsk_ext.dat
done
#cat EOF.BIN >>dskedt_src.bcd
rm tmp.img
