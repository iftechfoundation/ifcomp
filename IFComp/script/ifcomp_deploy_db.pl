#!/usr/bin/env perl 

use strict;
use FindBin;
use lib ("$FindBin::Bin/../lib");
use Time::HiRes;
use Getopt::Std;

my %Opts;
getopts( 'dh?', \%Opts );

if ( $Opts{'?'} || $Opts{'h'} ) {
    print usage();
    exit(0);
}

my $start = Time::HiRes::time();

# PLEASE let me step through a debugger!
eval q[ 
    use IFComp;
];

if ($@) {
    print("Could not create IFComp\n");
    print($@);
    die;
}

print "Deploying schema\n";

my %sql_args;
if ( $Opts{'d'} ) {
    $sql_args{'add_drop_table'} = 1;
}

IFComp->component("IFComp::Model::IFCompDB")->schema->deploy( \%sql_args );

my $end = Time::HiRes::time();
printf( "Deploy took %.2f seconds\n", ( $end - $start ) );

#-----
# Sub
#-----
sub usage {
    return qq[$0 - Deploy IFComp schema to an empty MySQL database

USAGE: $0 [-d]

OPTIONS:
 ?        This screen
 h        This screen
 d        Adds 'DROP TABLE' statements before 'CREATE TABLE' statements
];
}
