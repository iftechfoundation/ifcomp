use strict;
use warnings;
use Test::More;

use FindBin;
use lib ("$FindBin::Bin/lib");

use Path::Class::Dir;

use IFComp::ColossalFund;

my $cf_data_dir = Path::Class::Dir->new( "$FindBin::Bin/colossal" );

my $cf = IFComp::ColossalFund->new( { data_directory => $cf_data_dir, } );

is( $cf->collected, 4521 );
is( @{ $cf->years }, 2, 'Current collected amount' );

is( $cf->maximum_prize, 245, 'Maximum prize' );

my $year = $cf->years->[0];
is( @{ $year->donors }, 4, 'Total donors' );

my @named_small_donors = @{ $year->named_donors_between( 0, 100 ) };
is( @named_small_donors, 2, 'Small named donors', );

my @anonymous_small_donors = @{ $year->anonymous_donors_between( 0, 100 ) };
is( @anonymous_small_donors, 1, 'Small anonymous donors', );

my @named_big_donors = @{ $year->named_donors_between( 101, undef ) };
is( @named_big_donors, 1, 'Big named donors', );

done_testing();
