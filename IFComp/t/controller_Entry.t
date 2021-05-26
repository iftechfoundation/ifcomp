use strict;
use warnings;
use Test::More;
use Path::Class;
use Imager;

# use DateTime;

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

$schema->entry_directory->mkpath unless ( $schema->entry_directory->stat );
foreach ( $schema->entry_directory->children( no_hidden => 1 ) ) {
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

######
# Add a new entry
######

$mech->get_ok('http://localhost/entry/create');

is( $comp_dir->children( no_hidden => 1 ),
    0, "Entry directory ($comp_dir) is still empty." );

$mech->submit_form_ok(
    {   form_number => 2,
        fields      => { 'entry.title' => 'Fun Game', },
    },
    'Submitted a declaration'
);

my $entry = $schema->resultset('Entry')->find($entry_id);
is( $entry->title, 'Fun Game', 'New entry is in the DB.' );

######
# Modify entry, adding files
######

$mech->get_ok("http://localhost/entry/$entry_id/update");
$mech->submit_form_ok(
    {   form_number => 2,
        fields      => {
            'entry.title'        => 'Super-Fun Game',
            'entry.cover_upload' => "$FindBin::Bin/test_files/misc/cover.png",
            'entry.main_upload' =>
                "$FindBin::Bin/test_files/misc/my_game.html",
            'entry.walkthrough_upload' =>
                "$FindBin::Bin/test_files/misc/walkthrough.txt",
            'entry.platform' => 'website',
        },
    },
);
$entry->discard_changes;
is( $entry->title, 'Super-Fun Game' );

is( $comp_dir->children( no_hidden => 1 ),
    1, "Entry directory contains 1 child." );

my $id = $entry->id;

ok( -e "$comp_dir/$id/content/my_game.html",
    "Game file uploaded and copied."
);
ok( -e "$comp_dir/$id/walkthrough/walkthrough.txt",
    "Walkthrough uploaded and copied." );
ok( -e "$comp_dir/$id/cover/cover.png",     "Cover uploaded and copied." );
ok( -e "$comp_dir/$id/web_cover/cover.png", "Cover web-version created." );

my $web_cover_image =
    Imager->new( file => "$comp_dir/$id/web_cover/cover.png" );
is( $web_cover_image->getheight, 700, "Web-cover is scaled down." );

######
# Modify entry, changing to a smaller cover image
######

$mech->get_ok("http://localhost/entry/$entry_id/update");
$mech->submit_form_ok(
    {   form_number => 2,
        fields      => {
            'entry.title' => 'Super-Fun Game',
            'entry.cover_upload' =>
                "$FindBin::Bin/test_files/misc/tiny_cover.png",
        },
    },
);
ok( -e "$comp_dir/$id/content/my_game.html", "Game file preserved." );
ok( -e "$comp_dir/$id/walkthrough/walkthrough.txt",
    "Walkthrough preserved." );
ok( -e "$comp_dir/$id/cover/tiny_cover.png", "Cover uploaded and copied." );
ok( -e "$comp_dir/$id/web_cover/tiny_cover.png",
    "Cover web-version created." );
$web_cover_image =
    Imager->new( file => "$comp_dir/$id/web_cover/tiny_cover.png" );
is( $web_cover_image->getheight, 200, "Web-cover is NOT scaled up." );

######
# Modify an entry, removing cover files
######

$mech->get_ok("http://localhost/entry/$entry_id/update");
$mech->submit_form_ok(
    {   form_number => 2,
        fields      => {
            'entry.title'        => 'Super-Fun Game',
            'entry.cover_delete' => 1,
        },
    },
);
ok( not( -e "$comp_dir/$id/cover/tiny_cover.png" ), "Cover deleted." );
ok( not( -e "$comp_dir/$id/web_cover/tiny_cover.png" ),
    "Web cover deleted." );

######
# Modify an entry, trying to upload a bogus image
######
$mech->get_ok("http://localhost/entry/$entry_id/update");
$mech->submit_form_ok(
    {   form_number => 2,
        fields      => {
            'entry.title' => 'Super-Fun Game',
            'entry.cover_upload' =>
                "$FindBin::Bin/test_files/misc/bad_image.png",
        },
    },
);
$mech->content_like(
    qr/doesn't appear to be a valid PNG or JPEG/,
    "Pushing back on a bad-image upload.",
);

######
# Validate dates are not hardcoded
######
IFCompTest::set_phase_after( $schema, 'intents_open' );
$mech->get_ok("http://localhost/entry");
my $cur       = DateTime->now->subtract( days => 2 );
my $startdate = $cur->month_name() . " " . $cur->day();
$cur = DateTime->now->add( days => 2 );
my $enddate = $cur->month_name() . " " . $cur->day();
$mech->content_contains(
    "intents from " . $startdate . " through " . $enddate,
    "List page dates are shown dynamically" );

$mech->get_ok("http://localhost/entry/create");
$mech->content_contains(
    "please through the " . $enddate . " deadline",
    "Creation page dates are shown dynamically"
);

done_testing();
