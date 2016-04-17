USER=' M1416    28'
echo -n > filsim_src.bcd
for i in bprint.fap ddfap.fap enable.fap exitsm.fap fprnte.fap fsetup.fap iopac.fap \
	pack.fap prntsm.fap ssetup.fap supcal.fap trac.fap ; do
     NAME=`basename $i .fap | sed 's/_/./g'`
     obj2img -A -a "$USER" -t -f $NAME -e 'FAP' -o tmp.img $i
     cat tmp.img >> filsim_src.bcd
done
for i in ddmad.mad sldioi.mad ; do
     NAME=`basename $i .mad | sed 's/_/./g'`
     obj2img -A -a "$USER" -t -f $NAME -e 'MAD' -o tmp.img $i
     cat tmp.img >> filsim_src.bcd
done
obj2img -A -a "$USER" -t -f filsim -e 'RUNCOM' -o tmp.img filsim.runcom
cat tmp.img >> filsim_src.bcd
obj2img -A -a "$USER" -t -f salsim -e 'RUNCOM' -o tmp.img salsim.runcom
cat tmp.img >> filsim_src.bcd
#cat EOF.BIN >>filsim_src.bcd
rm tmp.img
