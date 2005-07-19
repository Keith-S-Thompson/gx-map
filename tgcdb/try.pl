#!/usr/bin/perl -w

# $Id: try.pl,v 1.3 2005-07-18 20:39:24-07 kst Exp $
# $Source: /home/kst/gx-map-redacted/tgcdb/try.pl,v $

use strict;
use TGCDB;

my @operations = @ARGV;
my @bad = grep { $_ ne 'add' and $_ ne 'remove' } @operations;
die "Usage: $0 (add|remove)...\n" if @bad;

my($tg) = new TGCDB (host   => 'delphi.ncsa.uiuc.edu',
                     db     => 'tgcdb_test',
                     user   => 'gxmap',
                     passwd => 'gxmap');
exit 0 if not @operations;

$tg->beginTransaction;

foreach my $operation (@operations) {
    if ($operation eq 'add') {
        $tg->gxmap_add_dn('dtf.ncsa.teragrid', 'mshapiro', 'DN/XXX');
    }
    elsif ($operation eq 'remove') {
        $tg->gxmap_remove_dn('dtf.ncsa.teragrid', 'mshapiro', 'DN/YYY');
    }
}

$tg->commitTransaction;
