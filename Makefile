# $Id: Makefile,v 1.11 2007-01-01 13:01:32-08 kst Exp $
# $Source: /home/kst/gx-map-redacted/Makefile,v $

########################################################################
# @Copyright@
#
# Copyright (c) 2007 The Regents of the University of California. All
# rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
#
# 1. Redistributions of source code must retain the above copyright
# notice, this list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright
# notice, this list of conditions and the following disclaimer in the
# documentation and/or other materials provided with the distribution.
#
# 3. All advertising materials mentioning features or use of this
# software must display the following acknowledgement: This product
# includes software developed by the Advanced Cyberinfrastructure
# Laboratory at the San Diego Supercomputer Center and its contributors.
#
# 4. Neither the name of the Center nor the names of its contributors
# may be used to endorse or promote products derived from this software
# without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS''
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
# THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
# PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS
# BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
# BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
# OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
# IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# @Copyright@
########################################################################

########################################################################
# Developed by Keith Thompson <kst@sdsc.edu>
########################################################################

all:		FORCE
		@echo "Valid targets are 'clean' and 'install'"
		@echo "Run ./configure-gx-map <config-file> before installation"

clean:		FORCE
		./cleanup-gx-map

install:	FORCE
		./install-gx-map

FORCE:
