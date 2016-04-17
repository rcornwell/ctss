USER=' M1416    38'
echo -n > run_src.bcd
echo -n > run_ext.dat
for i in bin.fap frame.fap lmio12.fap rlib.fap remap.fap rout.fap wordio.fap ; do
     NAME=`basename $i .fap | sed 's/_/./g'`
     obj2img -A -a "$USER" -t -c -f $NAME -e 'FAP' -o tmp.img $i
     cat tmp.img >> run_src.bcd
done
for i in adjust.mad frame1.mad hdft.mad numcon.mad nxchar.mad rmain.mad \
	runoff.mad settyp.mad symsto.mad rcom.mad _xor_.mad ; do
     NAME=`basename $i .mad | sed 's/_/./g'`
     obj2img -A -a "$USER" -t -c -f $NAME -e 'MAD' -o tmp.img $i
     cat tmp.img >> run_src.bcd
done
obj2img -A -a "$USER" -t -x -f "tmring" -e 'RUNOFF' -o tmp.img tmring.run
cat tmp.img >> run_src.bcd
for i in  runoff.runcom ; do
     NAME=`basename $i .runcom | sed 's/_/./g'`
     obj2img -A -a "$USER" -t -f $NAME -e 'RUNCOM' -o tmp.img $i
     cat tmp.img >> run_src.bcd
     grep '(LIST)' $i \
	| awk '{x="      " $2; print substr(x,length(x)-5,6) "   BCD     I'"$USER"'"}' >>run_ext.dat
done
#cat EOF.BIN >>run_src.bcd
rm tmp.img
