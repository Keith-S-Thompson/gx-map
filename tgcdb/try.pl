#!/usr/bin/perl -w

# $Id: try.pl,v 1.2 2005-02-14 17:58:12-08 kst Exp $
# $Source: /home/kst/gx-map-redacted/tgcdb/try.pl,v $

use strict;
use TGCDB;

my($tg) = new TGCDB (host   => 'delphi.ncsa.uiuc.edu',
		     db     => 'tgcdb_test',
		     user   => 'gxmap',
		     passwd => 'gxmap');
$tg->beginTransaction;
$tg->gxmap_remove_dn('dtf.ncsa.teragrid', 'mshapiro', 'DN/YYY');
$tg->gxmap_add_dn('dtf.ncsa.teragrid', 'mshapiro', 'DN/XXX');
$tg->commitTransaction;
