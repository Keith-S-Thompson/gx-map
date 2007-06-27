#!/usr/bin/env perl
#
# mapgen - Generate grid-mapfiles from information in the TGCDB
# by Jason Brechin <brechin@ncsa.uiuc.edu>
# 6/26/2007

use strict;
use DBI;
use DBI qw(:sql_types);
use DBD::Pg qw(:pg_types);

my $DBHOST = 'tgcdb.teragrid.org';
my $DBNAME = 'teragrid';
my $DBPORT = 5432;                   # default
my $DBUSER = 'brechin';
my $DBPASS = 'brechDemo';              # read only account

my $CLUSTER_NAME = shift; # || "abe.ncsa.teragrid";

####################################################
# Global Variables
####################################################

my %gOptions         = ();
my $FALSE            = 0;
my $TRUE             = 1;
my $gRealUser        = undef;

my $gDebug = $FALSE;
#my $gDebug = $TRUE;

#username(personid, resourceid)

my $dbh = dbconnect();

#Get resource ID for this machine (via $CLUSTER_NAME)
my $sql = "SELECT resource_id FROM acct.resources WHERE resource_name='$CLUSTER_NAME'";
my $resource_id = dbexecsql($dbh, $sql);
$resource_id = $resource_id->[0];

my $sql = "SELECT a.dn_id, a.person_id, a.dn, s.username 
          FROM acct.distinguished_names a, acct.system_accounts s
          WHERE a.person_id=s.person_id AND s.resource_id=$resource_id";
my @userinfo = dbexecsql($dbh, $sql);

my %users;
foreach my $userentry (@userinfo) {
  adduser_byusername(@$userentry);
}

printmap_byusername();

dbdisconnect($dbh);


sub adduser_byusername {
  my( $dn_id, $person_id, $dn, $username ) = @_;
  $users{$username}{$dn_id} = $dn;
}

sub printmap_byusername {
  my @usernames = sort keys(%users);
  foreach my $username (@usernames) {
    my @dn_ids = sort keys(%{$users{$username}});
    foreach (@dn_ids) {
      print '"' . $users{$username}{$_} . "\" $username\n";
    }
  }
}

sub adduser_bydnid {
  my( $dn_id, $person_id, $dn, $username ) = @_;
  $users{$dn_id}{'username'} = $username;
  $users{$dn_id}{'dn'} = $dn;
}

# Connect to the database
sub dbconnect {
	my $dbh;

# I'm using RaiseError because bind_param is too stupid to do
# anything else, so this allows consistency at least.
	my %args = ( PrintError => 0, RaiseError => 1 );

	debug("connecting to $DBNAME on $DBHOST:$DBPORT as $DBUSER");

	$dbh = DBI->connect( "dbi:Pg:dbname=$DBNAME;host=$DBHOST;port=$DBPORT",
			$DBUSER, $DBPASS, \%args );
	dberror( "Can't connect to database: ", $DBI::errstr ) unless ($dbh);
	$dbh->do("SET search_path TO acct");

	if ($gDebug) {
		$dbh->do("SET client_min_messages TO debug");
  }

	return $dbh;
}

sub dbdisconnect {
	my $dbh = shift;
	my $retval;
	eval { $retval = $dbh->disconnect; };
	if ( $@ || !$retval ) {
		dberror( "Error disconnecting from database", $@ || $DBI::errstr );
	}
}

sub dbexecsql {
  my $dbh      = shift;
  my $sql      = shift;
  my $arg_list = shift;
  my $prepared = shift;

  my ( @values, $result );
  my $i      = 0;
  my $retval = -1;
  my $prepared_sql;

  eval {
    debug("SQL going in=$sql");
    if ( ! defined($prepared) ) {
      $prepared_sql = $dbh->prepare($sql);
    } else {
      $prepared_sql = $prepared;
    }

    $i = 1;
    foreach my $arg (@$arg_list) {
      $arg = '' unless $arg;
      $prepared_sql->bind_param( $i, $arg );

      debug("arg ($i) = $arg");
      $i++;
    }
    $prepared_sql->execute;

    @values = ();
    while ( $result = $prepared_sql->fetchrow_arrayref ) {
      push( @values, [@$result] );
      foreach (@$result) { $_ = '' unless defined($_); }
      debug( "result row: ", join( ":", @$result ), "" );
    }
  };

  if ($@) { dberror($@); }

  return wantarray ? @values : $values[0];
}

sub debug {
  return unless ($gDebug);
  my ( $package, $file, $line ) = caller();
  print join( '', "DEBUG (at $file $line): ", @_, "\n" );
}

sub dberror {
  my ( $errstr,  $msg );
  my ( $package, $file, $line, $junk ) = caller(1);

  if ( @_ > 1 ) { $msg = shift; }
  else { $msg = "Error accessing database"; }

  $errstr = shift;

  print STDERR "$msg (at $file $line): $errstr\n";
  exit(0);
}
