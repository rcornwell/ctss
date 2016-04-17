USER=' M1416    35'
echo -n > lib3_src.bcd
for i in pmow.fap pr12.fap prdg.fap prer.fap prfl.fap prms.fap prnt.fap \
	 prsl.fap rann.fap rbin.fap rdata.fap rdfb.fap rdfl.fap rdms.fap \
	 rdtm.fap rdwt.fap reco.fap remn.fap rjus.fap rsbr.fap rstf.fap \
	 save.fap sch0.fap schn.fap setc.fap sete.fap setf.fap setp.fap \
	 setu.fap simc.fap slee.fap sli0.fap slo0.fap sloc.fap snap.fap \
	 sph0.fap spry.fap srch.fap sqrt.fap stb0.fap stfl.fap stom.fap \
	 stor.fap sypr.fap tanh.fap timr.fap tlck.fap tran.fap trfl.fap \
	tsh0.fap tssf.fap updm.fap vrea.fap wait.fap whoa.fap wrfl.fap \
	xdet.fap xdim.fap xecm.fap xfix.fap xloc.fap xmax.fap xmin.fap \
	 xmod.fap wrwt.fap zel0.fap macs.fap ; do
     NAME=`basename $i .fap`
     obj2img -A -a "$USER" -t -f $NAME -e 'FAP' -o tmp.img $i
     cat tmp.img >> lib3_src.bcd
done
sh ./mkrun.sh lib3 pmow.fap pr12.fap prdg.fap prer.fap prfl.fap prms.fap \
	prnt.fap prsl.fap rann.fap rbin.fap rdata.fap rdfb.fap rdfl.fap \
	rdms.fap rdtm.fap rdwt.fap reco.fap remn.fap rjus.fap rsbr.fap \
	rstf.fap save.fap sch0.fap schn.fap setc.fap sete.fap setf.fap \
	setp.fap setu.fap simc.fap slee.fap sli0.fap slo0.fap sloc.fap \
	snap.fap sph0.fap spry.fap sqrt.fap srch.fap stb0.fap stfl.fap \
	stom.fap stor.fap sypr.fap tanh.fap timr.fap tlck.fap tran.fap \
	trfl.fap tsh0.fap tssf.fap updm.fap vrea.fap wait.fap whoa.fap \
	wrfl.fap xdet.fap xdim.fap xecm.fap xfix.fap xloc.fap xmax.fap \
	xmin.fap xmod.fap wrwt.fap zel0.fap xdtr.mad >lib3.runcom
obj2img -A -a "$USER" -t -c -f xdtr -e 'MAD' -o tmp.img xdtr.mad
cat tmp.img >> lib3_src.bcd
obj2img -A -a "$USER" -t -f lib3 -e 'RUNCOM' -o tmp.img lib3.runcom
cat tmp.img >> lib3_src.bcd
grep '(LIST)' lib3.runcom | \
	awk '{x="      " $2; print substr(x,length(x)-5,6) "   BCD     I'"$USER"'"}' >ts3_ext.dat
grep '(LIST)' lib3.runcom \
	| awk '{x="      " $2; print substr(x,length(x)-5,6) "   BSS     B'"$USER"'"}' >ts3_bss.dat
#cat EOF.BIN >>lib3_src.bcd
rm tmp.img
