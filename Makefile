SNAP=	20161212
REL=	20210227
ARC=	subc-$(SNAP).tgz
DIST=	subc-$(REL).tgz

OS := $(shell uname -s)
ifeq ($(OS),Darwin)
	TAROPTS= --no-mac-metadata
endif

SUM= cksum

default:
	@echo "Use 'make configure' followed by 'make install' to build and install scc."

configure: clean
	./configure

all:
	cd src && make all

install: all
	cd src && make install

tests: all
	cd src && make tests

csums:	clean
	sort -k 3 _sums > _oldsums
	find . -type f | grep -v .git | grep -v .idea | grep -v sums | sort | xargs $(SUM) >_newsums
	diff -w _oldsums _newsums || true ; rm _oldsums _newsums

sums:	clean
	find . -type f | grep -v .git | grep -v .idea | grep -v sums | sort | xargs $(SUM) >_sums

version:
	vi src/defs.h Makefile Changes

clean:
	cd src && make clean
	cd s86 && make clean
	rm -f tests/ptest.c $(ARC) $(DIST)
	rm -f tests/ptest tests/systest tests/libtest
	if [ -f src/Makefile.ORIG ]; then \
		mv -f src/Makefile.ORIG src/Makefile; \
	fi

arc:	clean
	tar cvfz $(ARC) *

dist:	clean
	(cd .. && tar -cvz -f $(DIST) \
		--numeric-owner --no-acls $(TAROPTS) \
		--exclude .git \
		--exclude .gitignore \
		--exclude .idea \
		--exclude _newsums \
		--exclude src/cg.c \
                --exclude src/cg.h \
                --exclude src/sys.h \
                --exclude src/include/limits.h \
                --exclude src/lib/crt0.s \
                --exclude src/lib/init.c \
                --exclude src/lib/ncrt0.s \
                --exclude src/lib/system.c \
		subc) && mv ../$(DIST) .

docker-build:
	docker build . -t subc

docker-run:
	docker run --mount src="`pwd`",target=/usr/src/subc,type=bind -it subc
