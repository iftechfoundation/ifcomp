use strict;
use warnings;
use Test::More;
use DateTime;

unless ( eval q{use Test::WWW::Mechanize::Catalyst 0.55; 1} ) {
    plan skip_all => 'Test::WWW::Mechanize::Catalyst >= 0.55 required';
    exit 0;
}

use FindBin;
use lib ("$FindBin::Bin/lib");
use IFCompTest;

ok( my $mech =
        Test::WWW::Mechanize::Catalyst->new( catalyst_app => 'IFComp' ),
    'Created mech object'
);

my $schema = IFCompTest->init_schema();

$mech->get_ok('http://localhost/about/if');
$mech->get_ok('http://localhost/about/contact');

#
# Check that dates automatically update
#
IFCompTest::set_phase_after( $schema, 'intents_open' );
my $starttime = DateTime->now->subtract( days => 2 );
my $endtime   = DateTime->now->add( days => 2 );
my $strstart  = $starttime->month_name() . " " . $starttime->day();
my $strend    = $endtime->month_name() . " " . $endtime->day();
$mech->get('http://localhost/about/schedule');
$mech->content_contains(
    $strstart . ":</strong> The competition website is open",
    "Correct date for intents to open" );
$mech->get('http://localhost/about/how_to_enter');
$mech->content_contains(
    "and the final entry deadline of " . $strend . ".",
    "Author's Handbook dates are dynamically displayed"
);

IFCompTest::set_phase_after( $schema, 'judging_begins' );
my $settime   = DateTime->now->add( days => 2 );
my $expecting = $settime->month_name() . " " . $settime->day();
$mech->get('http://localhost/about/faq');
$mech->content_contains( "time on " . $expecting . " to rate as many games",
    "FAQ judging deadline is dynamic" );

IFCompTest::set_phase_after( $schema, 'entries_due' );
$settime   = DateTime->now->subtract( days => 2 );
$expecting = $settime->month_name() . " " . $settime->day();
$mech->get('http://localhost/about/comp');
$mech->content_contains(
    "before the " . $expecting . " deadline (see the full schedule below)",
    "Correct date for authors to submit" );

done_testing();
