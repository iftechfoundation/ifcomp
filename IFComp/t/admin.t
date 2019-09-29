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

my $VOTING_TITLE_REGEX = qr/Admin - Voting/;

IFCompTest::log_in_as_votecounter($mech);
$mech->get_ok('http://localhost/admin/voting');
$mech->title_like( $VOTING_TITLE_REGEX,
    'Admin-access attempt with an appropriate role worked just fine',
);

note('Test email lists');
IFCompTest::log_in_as_votecounter($mech);
$mech->get_ok('http://localhost/admin/email');
$mech->content_like( qr/nobody\@example.com/, 'Email list looks OK', );
$mech->content_like( qr/user1_forum/,         'Forum-handle list looks OK', );

done_testing();
