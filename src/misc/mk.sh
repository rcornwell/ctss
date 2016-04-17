obj2img -A -u -f UFD -e DATA -o ufd.img ufd.dat
obj2img -A -t -f GRPUNI -e TIMACC -o grpuni.img grpuni.timacc
obj2img -A -t -f PRTYGP -e TIMACC -o prtygp.img prtygp.timacc
obj2img -A -t -f TSSFIL -e TIMACC -o tssfil.img tssfil.timacc
obj2img -A -t -f TIMUSD -e TIMACC -o timusd.img timusd.timacc
obj2img -A -t -f UACCNT -e TIMACC -o uaccnt.img uaccnt.timacc
obj2img -A -q -f QUOTA -e DATA -o quotas.img quotas.dat 
cat ufd.img quotas.img grpuni.img prtygp.img tssfil.img timusd.img uaccnt.img EOF.BIN > s.bcd
