use strict;
use warnings;
use Test::More;
use Path::Class;

unless ( eval q{use Test::WWW::Mechanize::Catalyst 0.55; 1} ) {
    plan skip_all => 'Test::WWW::Mechanize::Catalyst >= 0.55 required';
    exit 0;
}

use FindBin;
use lib ("$FindBin::Bin/lib");
use IFCompTest;
my $schema = IFCompTest->init_schema();

IFComp::Schema->entry_directory(
    Path::Class::Dir->new("$FindBin::Bin/entries") );
ok( my $mech =
        Test::WWW::Mechanize::Catalyst->new( catalyst_app => 'IFComp' ),
    'Created mech object'
);

$schema->entry_directory->mkpath unless ( $schema->entry_directory->stat );
foreach ( $schema->entry_directory->children ) {
    $_->rmtree;
}

IFCompTest::log_in_as_author($mech);

$mech->get_ok('http://localhost/entry');
$mech->content_like( qr/You have not declared/,
    'At the entry-management page' );

my $comp_dir = $schema->entry_directory;

my ($entry_id) =
    $schema->storage->dbh->selectrow_array('select max(id) from entry');
$entry_id = $entry_id + 1;

$mech->get_ok('http://localhost/entry/create');

is( $comp_dir->children, 0, "Entry directory ($comp_dir) is still empty." );

$mech->submit_form_ok(
    {   form_number => 2,
        fields      => { 'entry.title' => 'Fun Game', },
    },
    'Submitted a declaration'
);

my $entry = $schema->resultset('Entry')->find($entry_id);
is( $entry->title, 'Fun Game', 'New entry is in the DB.' );

$mech->get_ok("http://localhost/entry/$entry_id/update");
$mech->submit_form_ok(
    {   form_number => 2,
        fields      => { 'entry.title' => 'Super-Fun Game', },
    },
);
$entry->discard_changes;
is( $entry->title, 'Super-Fun Game' );

is( $comp_dir->children, 1, "Entry directory contains 1 child." );

done_testing();
