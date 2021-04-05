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

$mech->get_ok('http://localhost/history');

$mech->content_like(
    qr/Test Quixe game/,
    "Last year's winner is on the history page",
);

$mech->content_unlike(
    qr/Test Z-code game/,
    "Current year's winner is not on the history page",
);

done_testing();
