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

my $res = $mech->get('http://localhost/');
is( $res->code, 200, 'Can get to home page when not logged in' );
$res = $mech->get('http://localhost/xyzzy-plugh-plover/');
is( $res->code, 404, 'Invalid page gets us a 404 code' );
$res = $mech->get('http://localhost/admin/');
is( $res->code, 403, 'Admin page generates 403 when user not logged in' );

IFCompTest::set_phase_after( $schema, 'announcement' );
$res = $mech->get('http://localhost/ballot');
is( $res->code, 200, 'Ballot page provides redirect before judging begins' );

$res = $mech->get('http://localhost/ballot/vote');
is( $res->code, 403, 'vote request returns 403 if not logged in' );

$res = $mech->get('http://localhost/ballot/vote');
is( $res->code, 403, 'second vote request still returns 403' );

IFCompTest::set_phase_after( $schema, 'judging_begins' );
$res = $mech->get('http://localhost/ballot');
is( $res->code, 302, 'Ballot redirects when not logged in' );
$res = $mech->get('http://localhost/ballot/vote');
is( $res->code, 302, 'Vote page redirects when not logged in' );
$res = $mech->get('http://localhost/ballot/feedback/100');
is( $res->code, 200, 'Feedback attempt without a login redirects to comp' );
$mech->title_unlike( qr/Admin - Voting/,
    'Admin-access attempt without a login got us redirected' );
$mech->content_like( qr/Please log in below/,
    'Feedback attempt without a login got us redirected' );

IFCompTest::log_in_as_judge($mech);
IFCompTest::set_phase_after( $schema, 'announcement' );
$res = $mech->get('http://localhost/ballot');
is( $res->code, 403, 'Judges cannot judge before judging period starts' );
$res = $mech->get('http://localhost/ballot/feedback/100');
is( $res->code, 403, 'Locked out of feedback when judging not active' );

IFCompTest::set_phase_after( $schema, 'judging_begins' );
$res = $mech->get('http://localhost/ballot');
is( $res->code, 200, 'Ballot visible to judges' );
$res = $mech->get('http://localhost/admin/');
is( $res->code, 403, 'Judges cannot access admin page' );

$res = $mech->get('http://localhost/play/100/cover');
is( $res->code, 200, 'Judges can access games to play' );

IFCompTest::set_phase_after( $schema, 'judging_ends' );
$res = $mech->get('http://localhost/ballot/vote');
is( $res->code, 403, 'Judges cannot vote after judging ends' );

IFCompTest::log_in_as_votecounter($mech);

IFCompTest::set_phase_after( $schema, 'announcement' );
$res = $mech->get('http://localhost/ballot');
is( $res->code, 403, 'Vote counter cannot access ballot before judging' );
$res = $mech->get('http://localhost/admin/');
is( $res->code, 200, 'Admin page accessible by votecounters' );
$res = $mech->get('http://localhost/admin/voting');
is( $res->code, 200, 'Vote results page accessible by curators' );

IFCompTest::log_in_as_author($mech);

IFCompTest::set_phase_after( $schema, 'announcement' );
$res = $mech->get('http://localhost/admin/');
is( $res->code, 403, 'Authors cannot access admin page' );
$res = $mech->get('http://localhost/admin/feedback');
is( $res->code, 403, 'Authors cannot access feedback page' );
$res = $mech->get('http://localhost/admin/voting');
is( $res->code, 403, 'Authors cannot access voting page' );

IFCompTest::log_in_as_curator($mech);

IFCompTest::set_phase_after( $schema, 'announcement' );
$res = $mech->get('http://localhost/ballot');
is( $res->code, 200, 'Curator can access ballots before judging period' );
$res = $mech->get('http://localhost/admin/');
is( $res->code, 200, 'Admin page accessible by curators' );
$res = $mech->get('http://localhost/admin/feedback');
is( $res->code, 200, 'Feedback page accessible by curators' );
$res = $mech->get('http://localhost/admin/voting');
is( $res->code, 200, 'Authors cannot access voting page' );

done_testing();
