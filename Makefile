#!/usr/bin/make -f

CC ?= gcc
CFLAGS ?= -Wall -std=c99
PREFIX ?= /usr/local
INSTALLDIR ?= $(PREFIX)/bin
MANDIR ?= $(PREFIX)/share/man/man1
PROGNAME ?= sk

LO_FLAGS ?= $(shell pkg-config --cflags --libs liblo)
#-I/usr/local/include  -L/usr/local/lib 
#-llo -lpthread

CURSES_FLAGS ?= $(shell pkg-config --cflags --libs ncurses)
#-lncurses -ltinfo

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
all: $(PROGNAME) manpage

$(PROGNAME): $(SRC)/$(PROGNAME).c
	$(CC) $(SRC)/$(PROGNAME).c -o $(PROGNAME) $(CFLAGS) $(LO_FLAGS) $(CURSES_FLAGS)

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
	install -m644 $(DOC)/$(PROGNAME).1.gz $(DESTDIR)$(MANDIR)/

uninstall:
	rm -f $(DESTDIR)$(INSTALLDIR)/$(PROGNAME)
	rm -f $(DESTDIR)$(MANDIR)/$(PROGNAME).1.gz

clean:
	rm -f $(PROGNAME) $(SRC)/$(PROGNAME).o
	#$(DOC)/$(PROGNAME).1.gz

.PHONY: clean all install uninstall
