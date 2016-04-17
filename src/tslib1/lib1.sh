USER=' M1416    35'
echo -n > lib1_src.bcd
for i in 1300.fap 1301.fap 1311.fap 3310.fap acore.fap acos.fap adj0.fap \
	 akno.fap appe.fap atan.fap atcn.fap attn.fap bbld.fap bcdc.fap \
	bcoc.fap bfcl.fap brea.fap bsf0.fap bst0.fap btoc.fap bwrt.fap \
	bz57.fap bzel.fap chfl.fap chmd.fap chnc.fap cler.fap cloc.fap \
	cmfl.fap cmlc.fap colt.fap com0.fap coma.fap comf.fap copy.fap \
	cos0.fap cot0.fap csh0.fap defb.fap dele.fap detc.fap dfad.fap \
	dim0.fap dpnb.fap drea.fap dskd.fap dskr.fap dwrt.fap eftm.fap \
	enco.fap eofx.fap erro.fap exit.fap exme.fap exp0.fap exp1.fap \
	exp2.fap exp3.fap fint.fap macs.fap ; do
     NAME=`basename $i .fap`
     obj2img -A -a "$USER" -t -f $NAME -e 'FAP' -o tmp.img $i
     cat tmp.img >> lib1_src.bcd
done
sh ./mkrun.sh lib1 1300.fap 1301.fap 1311.fap 3310.fap acore.fap acos.fap \
	adj0.fap akno.fap appe.fap atan.fap atcn.fap attn.fap bbld.fap \
	bcdc.fap bcoc.fap bfcl.fap brea.fap bsf0.fap bst0.fap btoc.fap \
	bwrt.fap bz57.fap bzel.fap chfl.fap chmd.fap chnc.fap cler.fap \
	cloc.fap cmfl.fap cmlc.fap colt.fap com0.fap coma.fap comf.fap \
	copy.fap cos0.fap cot0.fap csh0.fap defb.fap dele.fap detc.fap \
	dfad.fap dim0.fap dpnb.fap drea.fap dskd.fap dskr.fap dwrt.fap \
	eftm.fap enco.fap eofx.fap erro.fap exit.fap exme.fap exp0.fap \
	exp1.fap exp2.fap exp3.fap fint.fap  > lib1.runcom
obj2img -A -a "$USER" -t -f lib1 -e 'RUNCOM' -o tmp.img lib1.runcom
cat tmp.img >> lib1_src.bcd
grep '(LIST)' lib1.runcom \
	| awk '{x="      " $2; print substr(x,length(x)-5,6) "   BCD     I'"$USER"'"}' >ts1_ext.dat
grep '(LIST)' lib1.runcom \
	| awk '{x="      " $2; print substr(x,length(x)-5,6) "   BSS     B'"$USER"'"}' >ts1_bss.dat
#cat EOF.BIN >>lib1_src.bcd
rm tmp.img
