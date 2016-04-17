USER=' M1416    10'
echo -n > log_src.bcd
echo -n > log_ext.dat
for i in adutil.fap deltem.fap dial.fap geta.fap gtpass.fap gtprob.fap \
	hello.fap login.fap logmai.fap logout.fap messg.fap seterr.fap \
	svcpu.fap ttpeek.fap report.fap init.fap logutl.fap dial.fap ; do
     NAME=`basename $i .fap | sed 's/_/./g'`
     obj2img -A -a "$USER" -t -c -f $NAME -e 'FAP' -o tmp.img $i
     cat tmp.img >> log_src.bcd
done
for i in common.fap equ.fap com000.fap macro.fap tempb.fap bequ.fap ; do
     NAME=`basename $i .fap | sed 's/_/./g'`
     obj2img -A -a "$USER" -t -f $NAME -e 'FAP' -o tmp.img $i
     cat tmp.img >> log_src.bcd
done
for i in admin.mad who1.mad _xor_.mad ; do
     NAME=`basename $i .mad | sed 's/_/./g'`
     obj2img -A -a "$USER" -t -c -f $NAME -e 'MAD' -o tmp.img $i
     cat tmp.img >> log_src.bcd
done
for i in admin.runcom dial.runcom login.runcom logout.runcom loglib.runcom \
	 hello.runcom ttpeek.runcom who.runcom init.runcom ; do
     NAME=`basename $i .runcom | sed 's/_/./g'`
     obj2img -A -a "$USER" -t -f $NAME -e 'RUNCOM' -o tmp.img $i
     cat tmp.img >> log_src.bcd
     grep '(LIST)' $i \
	| awk '{x="      " $2; print substr(x,length(x)-5,6) "   BCD     I'"$USER"'"}' >>log_ext.dat
done
#cat EOF.BIN >>log_src.bcd
rm tmp.img
