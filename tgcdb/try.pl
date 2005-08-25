#!/usr/bin/perl -w

# $Id: try.pl,v 1.5 2005-08-24 20:46:24-07 kst Exp $
# $Source: /home/kst/gx-map-redacted/tgcdb/try.pl,v $

use strict;

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

########################################################################

#
# The TGCDB package is included inline.
#

{
    package TGCDB;

    use DBI;

    sub new
    {
        my($self, %attr) = @_;
        my($host, $port, $db, $user, $passwd);
        my($raiseError) = 1;
        my($printError) = 0;
        local($_);
        my($key, $value);

        while ( ($key, $value) = each(%attr))
        {
            $host       = $value if lc($key) eq "host";
            $port       = $value if lc($key) eq "port";
            $db         = $value if lc($key) eq "db";
            $user       = $value if lc($key) eq "user";
            $passwd     = $value if lc($key) eq "passwd";
            $raiseError = $value if lc($key) eq "raiseerror";
            $printError = $value if lc($key) eq "printerror";
        }
        die "host not defined"   unless (defined $host);
        die "db not defined"     unless (defined $db);
        die "user not defined"   unless (defined $user);
        die "passwd not defined" unless (defined $passwd);

        my($dsn) = "dbi:Pg:dbname=$db;host=$host";
        $dsn .= ";$port" if (defined $port);
        my($dbh) = DBI->connect($dsn, $user, $passwd,
                                  {AutoCommit=>1,
                                   RaiseError=>$raiseError,
                                   PrintError=>$printError});
        my($h) = {dbh=>$dbh, transLevel=>0};
        bless $h, $self;
    }

    sub gxmap_add_dn
    {
        my($self, $resource, $user, $dn) = @_;
        $self->_gxmap_insert_dn_tbl($resource, $user, $dn, "add");
    }

    sub gxmap_remove_dn
    {
        my($self, $resource, $user, $dn) = @_;
        $self->_gxmap_insert_dn_tbl($resource, $user, $dn, "remove");
    }

    sub _gxmap_insert_dn_tbl
    {
        my($self, $resource, $user, $dn, $action) = @_;
        my($sql) = sprintf ("select gxmap.insert_dn_tbl(%s,%s,%s,%s)",
                               $self->quote($resource, $user, $dn, $action));

        $self->dbh->do ($sql);
    }

    sub dbh
    {
        shift->{dbh};
    }

    sub quote
    {
        my($dbh) = shift->{dbh};
        map {$dbh->quote($_)} @_;
    }

    sub beginTransaction
    {
        my($self) = shift;
        $self->{dbh}->{AutoCommit} = 0 unless ($self->{transLevel} > 0);
        $self->{transLevel}++;
    }

    sub commitTransaction
    {
        my($self) = shift;
        die "not in a transaction" unless ($self->{transLevel} > 0);
        $self->{transLevel}--;
        if ($self->{transLevel} == 0)
        {
            $self->{dbh}->commit;
            $self->{dbh}->{AutoCommit} = 1;
        }
    }

    sub rollbackTransaction
    {
        my($self) = shift;
        die "not in a transaction" unless ($self->{transLevel} > 0);
        $self->{dbh}->rollback;
        $self->{dbh}->{AutoCommit} = 1;
        $self->{transLevel} = 0;
    }

    sub DESTROY
    {
        my($dbh) = shift->{dbh};
        $dbh->disconnect if ($dbh);
    }

} # end of package TGCDB
