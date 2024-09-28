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

$mech->get_ok('http://localhost/comp');

IFCompTest::set_phase_after( $schema, 'intents_open' );
my $current_comp = $schema->resultset('Comp')->current_comp;
is( $current_comp->ok_to_reveal_pseudonyms,
    0, "do not reveal pseudonyms during the comp" );

IFCompTest::set_phase_after( $schema, 'comp_closes' );
$current_comp = $schema->resultset('Comp')->current_comp;
is( $current_comp->ok_to_reveal_pseudonyms,
    1, "pseudonyms can be revealed now if desired" );

$mech->get_ok( 'http://localhost/comp/' . $current_comp->year . '/json' );

done_testing();
