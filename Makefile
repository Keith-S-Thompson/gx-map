# $Id: Makefile,v 1.1 2003-05-27 20:45:57-07 kst Exp $
# $Source: /home/kst/gx-map-redacted/Makefile,v $

all:
	@echo "Valid targets are 'clean' and 'install'"
	@echo "Run ./configure-gx-map <config-file> before installation"

clean:
	./Cleanup

install:
	./Install
