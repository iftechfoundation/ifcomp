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

my $comp_dir = $schema->entry_directory;

my ($entry_id) =
    $schema->storage->dbh->selectrow_array('select max(id) from entry');
$entry_id = $entry_id + 1;

IFCompTest::set_phase_after( $schema, 'intents_open' );
IFCompTest::log_in_as_author($mech);
$mech->get_ok('http://localhost/entry/create');
$mech->submit_form_ok(
    {   form_number => 2,
        fields      => {
            'entry.title' => 'Balloting Game',
            'entry.main_upload' =>
                "$FindBin::Bin/test_files/misc/my_game.html",
        },
    },
    'Submitted a declaration'
);
my $entry = $schema->resultset('Entry')->find($entry_id);
is( $entry->title, 'Balloting Game' );

IFCompTest::log_in_as_judge($mech);

IFCompTest::set_phase_after( $schema, 'judging_begins' );
$mech->get_ok('http://localhost/ballot');
$mech->content_contains("Balloting Game");
$mech->content_contains("Your rating");

$entry->discard_changes;

done_testing();
