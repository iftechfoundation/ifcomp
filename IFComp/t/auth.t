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

#
# Set the comp to a specific phase
#
sub set_phase_after($) {
    use DateTime;
    my ( $phase ) = @_;
    my @phases = qw(announcement intents_open intents_close entries_due
        judging_begins judging_ends comp_closes);
    my $past_ymd = DateTime->now->subtract( days => 2 )->ymd;
    my $future_ymd = DateTime->now->add( days => 2 )->ymd;

    my $hit = 0;
    my @before = ();
    my @after = ();
    foreach ( @phases ) {
        if ( $hit ) {
            push( @after, $_ );
        } else {
            push( @before, $_ );
        }
        $hit = 1 if ( $_ eq $phase );
    }
    shift(@before); # remove the 'announcement' pseudo-phase

    my $comp = $schema->resultset( 'Comp' )->find( 2 );
    foreach ( @before ) {
        $comp->$_( $past_ymd );
    }
    foreach ( @after ) {
        $comp->$_( $future_ymd );
    }
    $comp->update;
}

ok( my $mech =
        Test::WWW::Mechanize::Catalyst->new( catalyst_app => 'IFComp' ),
    'Created mech object'
);

my $res = $mech->get( 'http://localhost/' );
is( $res->code, 200, 'Can get to home page when not logged in');
$res = $mech->get( 'http://localhost/xyzzy-plugh-plover/');
is( $res->code, 404, 'Invalid page gets us a 404 code');
$res = $mech->get( 'http://localhost/admin/' );
is( $res->code, 403, 'Admin page generates 403 when user not logged in' );

set_phase_after( 'announcement' );
$res = $mech->get( 'http://localhost/ballot' );
is( $res->code, 403, 'Ballot page generates 403 before judging begins' );

$res = $mech->get( 'http://localhost/ballot/vote' );
is( $res->code, 403, '**** Attempt 1 - expecting 403' );

$res = $mech->get( 'http://localhost/ballot/vote' );
is( $res->code, 403, '**** Attempt 2 - expecting 403 again' );

set_phase_after( 'judging_begins' );
$res = $mech->get( 'http://localhost/ballot' );
is( $res->code, 200, 'Ballot visible when not logged in' );
$res = $mech->get( 'http://localhost/ballot/vote' );
is( $res->code, 200, 'Vote page message when not logged in' );


IFCompTest::log_in_as_judge($mech);
set_phase_after( 'announcement' );
$res = $mech->get( 'http://localhost/ballot' );
is( $res->code, 403, 'Judges cannot judge before judging period starts' );

set_phase_after('judging_begins');
$res = $mech->get('http://localhost/ballot');
is( $res->code, 200, 'Ballot visible to judges' );
$res = $mech->get( 'http://localhost/admin/' );
is( $res->code, 403, 'Judges cannot access admin page' );

$res = $mech->get( 'http://localhost/play/100/cover' );
is( $res->code, 200, 'Judges can access games to play' );

set_phase_after('judging_ends');
$res = $mech->get('http://localhost/ballot/vote');
is( $res->code, 403, 'Judges cannot vote after judging ends' );

IFCompTest::log_in_as_votecounter($mech);

set_phase_after( 'announcement' );
$res = $mech->get( 'http://localhost/ballot' );
is( $res->code, 403, 'Vote counter cannot access ballot before judging' );
$res = $mech->get( 'http://localhost/admin/' );
is( $res->code, 200, 'Admin page accessible by votecounters' );
$res = $mech->get( 'http://localhost/admin/voting' );
is( $res->code, 200, 'Vote results page accessible by curators' );


IFCompTest::log_in_as_author($mech);

set_phase_after( 'announcement' );
$res = $mech->get( 'http://localhost/admin/' );
is( $res->code, 403, 'Authors cannot access admin page' );
$res = $mech->get( 'http://localhost/admin/feedback' );
is( $res->code, 403, 'Authors cannot access feedback page' );
$res = $mech->get( 'http://localhost/admin/voting' );
is( $res->code, 403, 'Authors cannot access voting page' );



IFCompTest::log_in_as_curator($mech);

set_phase_after( 'announcement' );
$res = $mech->get( 'http://localhost/ballot' );
is( $res->code, 200, 'Curator can access ballots before judging period' );
$res = $mech->get( 'http://localhost/admin/' );
is( $res->code, 200, 'Admin page accessible by curators' );
$res = $mech->get( 'http://localhost/admin/feedback' );
is( $res->code, 200, 'Feedback page accessible by curators' );
$res = $mech->get( 'http://localhost/admin/voting' );
is( $res->code, 200, 'Authors cannot access voting page' );


done_testing();
