# This is the Makefile for bcpl7094 and bcplctss.

# Writen by Martin Richards (c) 31 Oct 2016

help:
	@echo
	@echo "make all      Compile all the bcplctss sections"
	@echo "make bcpl7094 Recompile bcpl7094"
	@echo "make lb1a     Compile .lb1a to FAP"
	@echo "make xref     Create xrefbcpl7094"
	@echo "make clean    Delete all re-makeable files"
	@echo

all:	bcpl7094

bcpl7094:	bcpl7094.b lbhead.h head1.h nhead2.h nhead3.h
	cintsys64 -c c b64 bcpl7094

lb1a:
	(cd ..; cintsys64 -- bcpl7094/bcpl7094 LB1A BCPL fap FAP/lb1a.fap)

t1:
	(cd ..; cintsys64 -- bcpl7094/bcpl7094 T1 BCPL fap FAP/t1.fap tree)

test:
	(cd ..; cintsys64 -- bcpl7094/bcpl7094 TEST BCPL fap FAP/test.fap)

xref:
	cintsys64 -c c b64 bcpl7094 xref >rawxref
	cintsys -c sortxref rawxref to xrefbcpl7094
	rm rawxref

clean:
	rm -f bcpl7094 *~

