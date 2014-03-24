#!/usr/bin/env perl 

use strict;
use FindBin;
use lib ("$FindBin::Bin/../lib");
use Time::HiRes;
use Getopt::Std;
use FindBin;

my %Opts;
getopts('udh?', \%Opts);

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

print "Deploying schema\n";

my %sql_args;
if ($Opts{'d'})
{
    $sql_args{'add_drop_table'} = 1;
}

my $S = IFComp->component("IFComp::Model::IFCompDB")->schema->connect();

if ($Opts{u})
{
    my $dir = "$FindBin::Bin/../sql";
    unless (-e $dir)
    {
	die("Cannot find upgrade director $dir\n");
    }
    
    print "Upgrading schema\n";
    
    $S->upgrade_directory($dir);
    $S->upgrade();
}
else
{
    print "Deploying schema\n";
    $S->deploy(\%sql_args);
}

my $end = Time::HiRes::time();
printf("Deploy took %.2f seconds\n", ($end - $start));

#-----
# Sub 
#-----
sub usage
{
    return qq[$0 - Deploy IFComp schema to an empty MySQL database

USAGE: $0 [-d]

OPTIONS:
 ?        This screen
 h        This screen
 d        Adds 'DROP TABLE' statements before 'CREATE TABLE' statements
 u        Upgrade schema, if possible
];
}
