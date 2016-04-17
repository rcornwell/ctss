USER=' M1416    27'
echo -n > fib_src.bcd
echo -n > fib_ext.dat
for i in delfib.mad fib.mad fibmon.mad prfib.mad setfib.mad ; do
     NAME=`basename $i .mad | sed 's/_/./g'`
     obj2img -A -a "$USER" -t -c -f $NAME -e 'MAD' -o tmp.img $i
     cat tmp.img >> fib_src.bcd
done
for i in delfib.runcom fibmon.runcom fib.runcom prfib.runcom \
	setfib.runcom ; do
     NAME=`basename $i .runcom | sed 's/_/./g'`
     obj2img -A -a "$USER" -t -f $NAME -e 'RUNCOM' -o tmp.img $i
     cat tmp.img >> fib_src.bcd
     grep '(LIST)' $i \
	| awk '{x="      " $2; print substr(x,length(x)-5,6) "   BCD     I'"$USER"'"}' >>fib_ext.dat
done
#cat EOF.BIN >>fib_src.bcd
rm tmp.img
