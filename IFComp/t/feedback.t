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

my $FEEDBACK_TEXT = 'Here is some excellent feedback.';

my $schema = IFCompTest->init_schema();

ok( my $mech =
        Test::WWW::Mechanize::Catalyst->new( catalyst_app => 'IFComp' ),
    'Created mech object'
);

IFCompTest::log_in_as_judge($mech);

# Change the phase of the current test-competition to open-for-judging.
use DateTime;
my $past_ymd   = DateTime->now->subtract( days => 2 )->ymd;
my $future_ymd = DateTime->now->add( days => 2 )->ymd;
my $comp       = $schema->resultset('Comp')->find(2);
foreach (qw(intents_open intents_close entries_due judging_begins)) {
    $comp->$_($past_ymd);
}
foreach (qw(judging_ends comp_closes)) {
    $comp->$_($future_ymd);
}
$comp->update;

$mech->get_ok('http://localhost/ballot/feedback/100');

$mech->submit_form_ok(
    {   form_number => 2,
        fields      => { text => $FEEDBACK_TEXT, },
    },
    'Submitted feedback form',
);

my $feedback = $schema->resultset('Feedback')->find(1);
is( $feedback->text, $FEEDBACK_TEXT, 'Feedback was recorded in the DB.' );
is( $feedback->entry->id, 100,       'Feedback entry is correct.' );
is( $feedback->judge->id, 1,         'Feedback judge is correct.' );

# Test the admin view of current feedback.
IFCompTest::log_in_as_curator($mech);

$mech->get_ok('http://localhost/admin/feedback');

$mech->content_like(qr/$FEEDBACK_TEXT/);

# Test the author view of current feedback, and then post-closure feedback.
{
    # Before we start: re-assign the authorship of entry 100 to Alice Author.
    my $entry = $schema->resultset('Entry')->find(100);
    $entry->author(2);
    $entry->update;

    IFCompTest::log_in_as_author($mech);

    $mech->get_ok('http://localhost/entry/feedback');
    $mech->content_unlike( qr/$FEEDBACK_TEXT/,
        "Alice can't see feedback during the comp." );

    # Set the current comp to closed.
    my $comp      = $schema->resultset('Comp')->current_comp;
    my $this_year = DateTime->now->year;
    foreach (
        qw(intents_close entries_due judging_begins judging_ends comp_closes))
    {
        $comp->$_("$this_year-01-01");
    }
    $comp->update;

    $mech->get_ok('http://localhost/entry/feedback');
    $mech->content_like( qr/$FEEDBACK_TEXT/,
        "Alice can see feedback after the comp closes." );
}

done_testing();
