# $Id: Makefile,v 1.2 2003-07-16 21:14:52-07 kst Exp $
# $Source: /home/kst/gx-map-redacted/Makefile,v $

all:
	@echo "Valid targets are 'clean' and 'install'"
	@echo "Run ./configure-gx-map <config-file> before installation"

clean:
	./cleanup-gx-map

install:
	./install-gx-map
