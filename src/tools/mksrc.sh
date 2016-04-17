USER=' M1416    31'
echo -n > src_src.bcd
echo -n > src_ext.dat
for i in fap.fap load.fap nlod.fap hlod.fap ; do
	
     NAME=`basename $i .fap | sed 's/_/./g'`
     obj2img -A -a "$USER" -t -f $NAME -e 'FAP' -o tmp.img $i
     cat tmp.img >> src_src.bcd
done
for i in cksum.fap echar.fap extbss.fap macs.fap mad01.fap mad02.fap mad03.fap \
	 octdmp.fap prbss.fap pusav.fap rdbss.fap sp.fap sdump.fap \
	 svbss.fap updbss.fap wrbss.fap delete.fap dsker.fap scls.fap \
	 getbuf.fap stomap.fap ; do
     NAME=`basename $i .fap | sed 's/_/./g'`
     obj2img -A -a "$USER" -t -c -f $NAME -e 'FAP' -o tmp.img $i
     cat tmp.img >> src_src.bcd
done
obj2img -A -a "$USER" -t -c -f '(MAIN)' -e 'FAP' -o tmp.img main.fap
cat tmp.img >> src_src.bcd
for i in ldbs.mad pload.mad prelod.mad sd000.mad sp000.mad sysl.mad tiagen.mad ; do
     NAME=`basename $i .mad | sed 's/_/./g'`
     obj2img -A -a "$USER" -t -c -f $NAME -e 'MAD' -o tmp.img $i
     cat tmp.img >> src_src.bcd
done
for i in fap.runcom load.runcom mad.runcom ldabs.runcom extbss.runcom \
	 pload.runcom prelod.runcom prbss.runcom pusav.runcom sdump.runcom \
	 updbss.runcom sysl.runcom tiagen.runcom stomap.runcom ; do
     NAME=`basename $i .runcom | sed 's/_/./g'`
     obj2img -A -a "$USER" -t -f $NAME -e 'RUNCOM' -o tmp.img $i
     cat tmp.img >> src_src.bcd
     grep '(LIST)' $i \
	| awk '{x="      " $2; print substr(x,length(x)-5,6) "   BCD     I'"$USER"'"}' >>src_ext.dat
done
#cat EOF.BIN >>src_src.bcd
rm tmp.img
