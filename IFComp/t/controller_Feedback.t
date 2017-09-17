use strict;
use warnings;
use Test::More;

unless ( eval q{use Test::WWW::Mechanize::Catalyst 0.55; 1} ) {
    plan skip_all => 'Test::WWW::Mechanize::Catalyst >= 0.55 required';
    exit 0;
}

use FindBin;
use lib ("$FindBin::Bin/lib");
use IFCompTest;
my $schema = IFCompTest->init_schema();

ok( my $mech =
        Test::WWW::Mechanize::Catalyst->new( catalyst_app => 'IFComp' ),
    'Created mech object'
);

$mech->get_ok('http://localhost/feedback/');

# Change the phase of the current test-competition to open-for-judging.
use DateTime;
my $now = DateTime->now;
my $yesterday_ymd = $now->subtract( days => 1 )->ymd;
my $tomorrow_ymd = $now->add( days => 1 )->ymd;
my $comp = $schema->resultset('Comp')->find(2);
foreach (qw(intents_open intents_close entries_due judging_begins)) {
    $comp->$_($yesterday_ymd);
}
foreach (qw(judging_ends comp_closes)) {
    $comp->$_($tomorrow_ymd);
}

