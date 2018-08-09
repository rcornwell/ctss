# This makefile is used to create .tgz and .zip versions
# of the BCPLCTSS distribution.

PUB = /homes/mr/public_html

# Public HTML directory if not mountable on this machine
# and the shared drive is called E: (/dose on Linux).
# Remember to call ssh-add before calling make sshpub.
SSHPUB = ely.cl.cam.ac.uk:public_html

help:
	@echo
	@echo "make all      Construct the files: bcplctss.tgz and bcplctss.zip"
	@echo "make dose     Put them in my E drive (/dose)"
	@echo "make sshpube  Put them in /dose and my home page using scp"
	@echo

all:	
	rm -f *~ */*~
	echo >TGZDATE
	echo -n "Distributed from machine: " >>TGZDATE
	hostname >>TGZDATE
	date >>TGZDATE
	rm -f FILES
	(cd ..; tar cvzf bcplctss.tgz BCPLCTSS)
	rm -f ../bcplctss.zip
	(cd ..; zip -rv9 bcplctss.zip BCPLCTSS)
	cp TGZDATE FILES
	ls -l ../bcplctss.tgz ../bcplctss.zip>>FILES

sshpube:	dose
	scp README FILES ../bcplctss.tgz ../bcplctss.zip $(SSHPUB)/BCPLCTSS
	cat FILES

dose:	all
	cp ../bcplctss.tgz ../bcplctss.zip /dose

