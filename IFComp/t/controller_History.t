use strict;
use warnings;
use Test::More;


unless (eval q{use Test::WWW::Mechanize::Catalyst 0.55; 1}) {
    plan skip_all => 'Test::WWW::Mechanize::Catalyst >= 0.55 required';
    exit 0;
}

ok( my $mech = Test::WWW::Mechanize::Catalyst->new(catalyst_app => 'IFComp'), 'Created mech object' );

$mech->get_ok( 'http://localhost/history' );
done_testing();
