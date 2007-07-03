#!/usr/bin/env perl
#
# mapgen - Generate grid-mapfiles from information in the TGCDB
# by Jason Brechin <brechin@ncsa.uiuc.edu>
# 6/26/2007

use strict;
use DBI;
use DBI qw(:sql_types);
use DBD::Pg qw(:pg_types);

my $gridmapfile = '/etc/grid-security/grid-mapfile';

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
if ( ! $resource_id ) {
  die "Invalid CLUSTER_NAME specified!\n";
}

my $sql = "SELECT a.dn_id, a.person_id, a.dn, s.username 
          FROM acct.distinguished_names a, acct.system_accounts s
          WHERE a.person_id=s.person_id AND s.resource_id=$resource_id";
my @userinfo = dbexecsql($dbh, $sql);

my %DNs;
my %users;

foreach my $userentry (@userinfo) {
  adduser(@$userentry);
}

addMissingGTcompat();

my @gridmap = getmap();

dbdisconnect($dbh);

print @gridmap;

compareMap($gridmapfile, @gridmap);



sub compareMap {
  my $mapfile = shift;
  my @genmap = @_;

  open(MAPFILE, $mapfile) or die "Couldn't open $mapfile: $!";
  my @map = <MAPFILE>;
  close MAPFILE;

  my @missing = getmissing(\@genmap, \@map);
  print STDERR "In generated, not local: ";
  print STDERR scalar(@missing) . "\n";

  my @extra = getmissing(\@map, \@genmap);
  print STDERR "In local, not generated: ";
  print STDERR scalar(@extra) . "\n";
}

sub getmissing {
  my( $arr1, $arr2 ) = @_;
  my @genmap = @$arr1;
  my @map = @$arr2;

  my @missing;

  my %lines;
  
  foreach my $line (@genmap) {
    $lines{$line} += 1;
  }

  foreach my $line (@map) {
    $lines{$line} += 4;
  }

  while( my ($dn, $val) = each(%lines) ) {
    if ( $val == 1 ) { #In 1st, not second
      push( @missing, $dn );
    }
  }
  return @missing;
}
  
    
sub adduser {
  my( $dn_id, $person_id, $dn, $username ) = @_;
  if ( !defined($dn) || ! defined($username) ) {
    return;
  }
  $DNs{$dn_id}{'dn'} = $dn;
  foreach my $id (@{ $users{$username} }) {
    if ( $DNs{$id}{'dn'} eq $dn ) {
#      print "$dn already in list!\n";
      return;
    }
  }
  push( @{ $users{$username} }, $dn_id );
  if ( $DNs{$dn_id}{'username'} ) {
    $DNs{$dn_id}{'username'} .= ',' . $username;
  } else {
    $DNs{$dn_id}{'username'} = $username;
  }
}

sub addMissingGTcompat {
  my $newid = '99999a';
  foreach my $user (sort keys(%users)) {
    my @dnids = @{ $users{$user} };
    foreach my $id (@dnids) {
      my $dn = $DNs{$id}{'dn'};
      adduser($newid++, 000, addgt2($dn), $user);
      adduser($newid++, 000, addgt4($dn), $user);
    }
  }
}



sub getmap {
  my %ids;
  my @mapfile;
  foreach my $user (sort keys(%users)) {
    my @dnids = @{ $users{$user} };
    foreach my $id (@dnids) {
      if ( ! $ids{$id}++ ) {
        my $entry = '"' . $DNs{$id}{'dn'} . '" ' . $DNs{$id}{'username'} . "\n";
        push( @mapfile, $entry );
        #isgt2($DNs{$id}{'dn'}) && print "GT2\n";
        #isgt3($DNs{$id}{'dn'}) && print "GT3\n";
        #isgt4($DNs{$id}{'dn'}) && print "GT4\n";
      }
    }
  }
#  print "Got " . scalar(@mapfile). " entries\n";
  return @mapfile;
}

sub isgt2 {
  my $dn = shift;
  if ( $dn =~ /USERID=(\w+)/ ) {
    my $userid = $1;
    if ( $dn =~ /Email=(\S+)\/?/ ) {
      my $email = $1;
      return $dn;
    }
  }
  return undef;
}

sub addgt2 {
  my $dn = shift;
  if ( isgt2($dn) ) {
    return;
  } else {
    if ( isgt4($dn) ) {
      $dn =~ s/emailAddress=/Email=/;
    } else { #GT3
      $dn =~ s/E=/Email=/;
    }
    $dn =~ s/UID=/USERID=/;
  }
  return isgt2($dn);
}

sub isgt4 {
  my $dn = shift;
  if ( $dn =~ /UID=(\w+)/ ) {
    my $userid = $1;
    if ( $dn =~ /emailAddress=(\S+)\/?/ ) {
      my $email = $1;
      return $dn;
    }
  }
  return undef;
}

sub addgt4 {
  my $dn = shift;
  if ( isgt4($dn) ) {
    return;
  } else {
    if ( isgt2($dn) ) {
      $dn =~ s/USERID=/UID=/;
      $dn =~ s/Email=/emailAddress=/;
      return isgt4($dn);
    } else { #GT3
      $dn =~ s/E=/emailAddress=/;
      return isgt4($dn);
    }
  }
  return undef;
}

sub isgt3 {
  my $dn = shift;
  if ( $dn =~ /UID=(\w+)/ ) {
    my $userid = $1;
    if ( $dn =~ /E=(\S+)\/?/ ) {
      my $email = $1;
      return $dn;
    }
  }
  return undef;
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
