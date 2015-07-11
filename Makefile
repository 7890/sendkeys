#!/usr/bin/make -f

CC ?= gcc
CFLAGS ?= -Wall -std=c99
PREFIX ?= /usr/local
INSTALLDIR ?= $(PREFIX)/bin
MANDIR ?= $(PREFIX)/share/man/man1
PROGNAME ?= sk
PROGNAME_ALT ?= sendkeys

LO_FLAGS ?= $(shell pkg-config --cflags --libs liblo)
#-I/usr/local/include  -L/usr/local/lib 
#-llo -lpthread

CURSES_FLAGS ?= $(shell pkg-config --cflags --libs ncurses)
#-lncurses -ltinfo

DISTRO_LIBS_DIR = /usr/lib/x86_64-linux-gnu
LOCAL_LIBS_DIR = /usr/local/lib

#liblo: ./configure --static to get .a
STATIC_LIBS = -l:$(LOCAL_LIBS_DIR)/liblo.a -l:$(DISTRO_LIBS_DIR)/libncurses.a -l:$(DISTRO_LIBS_DIR)/libtinfo.a -l:$(DISTRO_LIBS_DIR)/libm.a -l:$(DISTRO_LIBS_DIR)/libpthread.a

SRC=src
DOC=doc

#.deb package
SRC_URL="https://github.com/7890/sendkeys"
MAINTAINER="tom@trellis.ch"
LICENSE="GPL"
VERSION=0
RELEASE=1

#gcc -o sk sendkeys.c -std=gnu99 -lncurses -llo
###############################################################################

default: $(PROGNAME)
all: $(PROGNAME) $(PROGNAME)_static manpage

$(PROGNAME): $(SRC)/$(PROGNAME).c
	$(CC) $(SRC)/$(PROGNAME).c -o $(PROGNAME) $(CFLAGS) $(LO_FLAGS) $(CURSES_FLAGS)
	ldd $(PROGNAME)
	du -h $(PROGNAME)

#test
$(PROGNAME)_static: $(SRC)/$(PROGNAME).c
#	@echo $(STATIC_LIBS)
	$(CC) -static $(SRC)/$(PROGNAME).c -o $(PROGNAME)_static $(CFLAGS) $(STATIC_LIBS)
	strip --strip-all $(PROGNAME)_static
	readelf -h $(PROGNAME)_static
	du -h $(PROGNAME)_static

manpage: $(DOC)/$(PROGNAME).man.asciidoc
	a2x --doctype manpage --format manpage $(DOC)/$(PROGNAME).man.asciidoc
	gzip -9 -f $(DOC)/$(PROGNAME).1

deb64: 
	checkinstall -D --arch=amd64 --pkgname=$(PROGNAME) --pkgsource=$(SRC_URL) --pkgversion=$(VERSION) --pkgrelease=$(RELEASE) \
	--maintainer=$(MAINTAINER) --pkglicense=$(LICENSE) --pkggroup="shellutils" --requires="liblo7,libncurses5" --install=no make install
deb32: 
	checkinstall -D --arch=i386 --pkgname=$(PROGNAME) --pkgsource=$(SRC_URL) --pkgversion=$(VERSION) --pkgrelease=$(RELEASE) \
	--maintainer=$(MAINTAINER) --pkglicense=$(LICENSE) --pkggroup="shellutils" --requires="liblo7,libncurses5" --install=no make install
debarmhf: 
	checkinstall -D --arch=armhf --pkgname=$(PROGNAME) --pkgsource=$(SRC_URL) --pkgversion=$(VERSION) --pkgrelease=$(RELEASE) \
	--maintainer=$(MAINTAINER) --pkglicense=$(LICENSE) --pkggroup="shellutils" --requires="liblo7,libncurses5" --install=no make install

install: $(PROGNAME)
	mkdir -p $(DESTDIR)$(INSTALLDIR)/
	mkdir -p $(DESTDIR)$(MANDIR)/
	install -m755 $(PROGNAME) $(DESTDIR)$(INSTALLDIR)/
	ln $(DESTDIR)$(INSTALLDIR)/$(PROGNAME) $(DESTDIR)$(INSTALLDIR)/$(PROGNAME_ALT) 
	install -m644 $(DOC)/$(PROGNAME).1.gz $(DESTDIR)$(MANDIR)/

uninstall:
	rm -f $(DESTDIR)$(INSTALLDIR)/$(PROGNAME)
	rm -f $(DESTDIR)$(INSTALLDIR)/$(PROGNAME_ALT)
	rm -f $(DESTDIR)$(MANDIR)/$(PROGNAME).1.gz

clean:
	rm -f $(PROGNAME) $(PROGNAME)_static $(SRC)/$(PROGNAME).o
	#$(DOC)/$(PROGNAME).1.gz

.PHONY: clean all install uninstall
