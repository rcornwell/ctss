#! /bin/sh
lib=`echo $1 | tr '[a-z]' '[A-Z]'`
lb=
shift
n=0
for i in $* ; do
    j=`echo $i | tr '[a-z]' '[A-Z]'`
    case $j in
    *.FAP) b=`basename $j .FAP`
	   c="FAP"
           sym="$sym $b SYMTB"
	   ;;
    *.MAD) b=`basename $j .MAD`
	   c="MAD"
    esac
    echo "$c $b (LIST)"
    f="$f $b"
    bcd="$bcd $b BCD"
    bss="$bss $b BSS"
    l=`expr "$bcd" : '.*'`
    l1=`expr "$sym" : '.*'`
    if [ \( $l -ge 60 \) -o \( $l1 -ge 55 \) ] ; then
        echo "COMBIN * $lib BSS $lb$f"
        lb=$lib
        echo "APENDA $lib BCD *$f"
        echo "DELETE$bss"
        echo "DELETE$bcd"
	if [ "$sym" ] ; then echo "DELETE$sym" ; fi
        bcd=""
        bss=""
        sym=""
        f=""
   fi
done
if [ "$bcd" ] ; then
        echo "COMBIN * $lib BSS $lb$f"
        echo "APENDA $lib BCD *$f"
        echo "DELETE$bss"
        echo "DELETE$bcd"
	if [ "$sym" ] ; then echo "DELETE$sym" ; fi
fi
