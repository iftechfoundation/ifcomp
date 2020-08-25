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

$mech->get_ok('http://localhost/', 'Loaded home page');
$mech->content_like(qr/Colossal Fund drive will kick off/,
    'Found pre-kickoff text');

# insert something here that will activate the colossal Fund
# $mech->content_like(qr/4,532/, 'Found colossal fund amount');

done_testing();
