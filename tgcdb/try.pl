#!/usr/bin/env perl
use strict;
use TGCDB;

my($tg) = new TGCDB (host=>'delphi',db=>'tgcdb_test',user=>'gxmap',passwd=>'gxmap');
$tg->beginTransaction;
$tg->gxmap_remove_dn('dtf.ncsa.teragrid', 'mshapiro', 'DN/YYY');
$tg->gxmap_add_dn('dtf.ncsa.teragrid', 'mshapiro', 'DN/XXX');
$tg->commitTransaction;
