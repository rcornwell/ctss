USER=' M1416    26'
echo -n > edit_src.bcd
for i in 0qed.fap 1qed.fap 2qed.fap bin.fap clrnam.fap cnvtbl.fap devtbl.fap qed.fap \
        rename.fap setup.fap setops.fap write6.fap prword.fap wrword.fap zcmd.fap \
         initdt.fap writ12.fap ; do
     NAME=`basename $i .fap | sed 's/_/./g'`
     obj2img -A -a "$USER" -t -f $NAME -e 'FAP' -o tmp.img $i
     cat tmp.img >> edit_src.bcd
done
for i in 6concd.mad bincon.mad binval.mad edaval.mad editcd.mad edlval.mad editor.mad \
         _mod_.mad 6typ.mad typval.mad 12typ.mad reund.mad ; do
     NAME=`basename $i .mad | sed 's/_/./g'`
     obj2img -A -a "$USER" -t -c -f $NAME -e 'MAD' -o tmp.img $i
     cat tmp.img >> edit_src.bcd
done
obj2img -A -a "$USER" -t -f edit -e 'RUNCOM' -o tmp.img edit.runcom
cat tmp.img >> edit_src.bcd
awk '{x="      " $1; print substr(x,length(x)-5,6) "   BCD     I'"$USER"'"}' edit.dat >edt_ext.dat
#cat EOF.BIN >>edit_src.bcd
rm tmp.img
