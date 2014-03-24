#!/usr/bin/env perl 

use strict;
use FindBin;
use lib ("$FindBin::Bin/../lib");
use Time::HiRes;
use Getopt::Std;
use FindBin;

my %Opts;
getopts('v:ch?', \%Opts);

if ($Opts{'?'} || $Opts{'h'})
{
    print usage();
    exit(0);
}

my $start = Time::HiRes::time();

# PLEASE let me step through a debugger!
eval q[ 
    use IFComp;
];

if ($@)
{
    print("Could not create IFComp\n");
    print($@);
    die;
}

my $S = IFComp->component("IFComp::Model::IFCompDB")->schema;
$S->connect();

print "Creating DDL for schema\n";

my $curr_version = $S->schema_version() || "0.1";
my $next_version = $curr_version;
if ($Opts{v})
{
    $next_version = $Opts{v};
}
else
{
    $next_version++;
}

my $ddl_dir = "$FindBin::Bin/../sql";

if ($Opts{c})
{
    print "Creating the DDL files for the current schema '$curr_version''\n";
    $S->create_ddl_dir(['MySQL', ],
		       $curr_version,
		       $ddl_dir,
	);
}
else
{
    print "Creating Alter Table DDL files to go from schema '$curr_version' to '$next_version'\n";
    $S->create_ddl_dir(['MySQL', ],
		       $next_version,
		       $ddl_dir,
		       $curr_version
	);
}

my $end = Time::HiRes::time();
printf("DDL Create took %.2f seconds\n", ($end - $start));

#-----
# Sub 
#-----
sub usage
{
    return qq[$0 - Create DDL for IFComp schema changes 

USAGE: $0 [-d]

OPTIONS:
 ?           This screen
 h           This screen
 c           ONLY create DDLs for the current schema 
 v [VERSION] Use this as the next version number
];
}
