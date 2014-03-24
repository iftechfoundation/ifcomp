#!/usr/bin/env perl 

use strict;
use FindBin;
use lib ("$FindBin::Bin/../lib");
use Time::HiRes;
use Getopt::Std;
use FindBin;

my %Opts;
getopts('h?', \%Opts);

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

print "Creating DDL for schema\n";

my $curr_version = "0.1";
my $next_version = "0.2";

my $ddl_dir = "$FindBin::Bin/../sql";

# IFComp->component("IFComp::Model::IFCompDB")->schema->connect()->create_ddl_dir(['MySQL', ],
# 										$curr_version,
# 										$ddl_dir,
# 										$curr_version
# 									       ),;

IFComp->component("IFComp::Model::IFCompDB")->schema->connect()->create_ddl_dir(['MySQL', ],
										$next_version,
										$ddl_dir,
										$curr_version
									       ),;

my $end = Time::HiRes::time();
printf("DDL Create took %.2f seconds\n", ($end - $start));

#-----
# Sub 
#-----
sub usage
{
    return qq[$0 - Create DDL for IFComp schema 

USAGE: $0 [-d]

OPTIONS:
 ?        This screen
 h        This screen
];
}
