USER=' M1416    24'
echo -n > bug_src.bcd
echo -n > bug_ext.dat
for i in line.fap madbug.fap mboot.fap wget.fap ; do
     NAME=`basename $i .fap | sed 's/_/./g'`
     obj2img -A -a "$USER" -t -c -f $NAME -e 'FAP' -o tmp.img $i
     cat tmp.img >> bug_src.bcd
done
for i in addcon.mad addvar.mad argbcd.mad argsl.mad argvar.mad bk.mad \
	brk.mad card.mad con.mad edit.mad e.mad f.mad fov.mad getsl.mad \
	getvar.mad g.mad ins.mad just.mad l.mad loader.mad madtab.mad \
	nam.mad num.mad oct.mad org.mad patch.mad ready.mad save.mad \
	space.mad start.mad swork.mad syntax.mad t.mad trans.mad type.mad \
	use.mad var.mad w.mad xeq.mad ; do
     NAME=`basename $i .mad | sed 's/_/./g'`
     obj2img -A -a "$USER" -t -c -f $NAME -e 'MAD' -o tmp.img $i
     cat tmp.img >> bug_src.bcd
done
for i in madbug.runcom ; do
     NAME=`basename $i .runcom | sed 's/_/./g'`
     obj2img -A -a "$USER" -t -f $NAME -e 'RUNCOM' -o tmp.img $i
     cat tmp.img >> bug_src.bcd
     grep '(LIST)' $i \
	| awk '{x="      " $2; print substr(x,length(x)-5,6) "   BCD     I'"$USER"'"}' >>bug_ext.dat
done
#cat EOF.BIN >>bug_src.bcd
rm tmp.img
