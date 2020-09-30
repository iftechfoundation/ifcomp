package IFCompTest;
use strict;
use warnings;
use Carp qw( cluck );

$SIG{__WARN__} = sub { cluck shift };

use base qw( Exporter );
our @EXPORT    = qw( elt );
our @EXPORT_OK = qw( elt );

use FindBin;

$ENV{CATALYST_CONFIG}        = "$FindBin::Bin/conf/ifcomp.conf";
$ENV{EMAIL_SENDER_TRANSPORT} = 'Test';

use utf8;
use Carp qw(croak);
use English;
use File::Path qw(make_path remove_tree);
use FindBin;

use IFComp::Schema;

use Readonly;
Readonly my $SALT => '123456';

my $db_dir  = "$FindBin::Bin/db";
my $db_file = "$db_dir/IFComp.db";
my $dsn     = "dbi:SQLite:$db_file";

sub connect_info {
    my ($self) = shift;
    return (
        $dsn, '', '',
        {   sqlite_unicode  => 1,
            on_connect_call => 'use_foreign_keys',
        }
    );
}

sub init_schema {
    my $self = shift;
    my %args = @_;

    if ( -e $db_file ) {
        unless ( unlink $db_file ) {
            croak("Couldn't unlink $db_file: $OS_ERROR");
        }
    }

    my $schema = IFComp::Schema->connect( $self->connect_info() );

    # The default dir for deploy is "./", which means that if you run
    # the tests from IFComp_HOME it tries to read IFComp.sql to get the
    # deployment statements rather than generating them for SQLite.
    # So we have to specify the dir here, even though it actually uses
    # the path in the $dsn to write the SQLite file...
    $schema->deploy( undef, $db_dir );

    $schema->populate(
        'FederatedSite',
        [   [ 'id', 'name', 'api_key', 'hashing_method' ],
            [   1, 'ifcomp.org',
                'fD0TDnRsQQlTLB/LXMPkkpYDsQXFRVDpFqFqIb//c6s=',
                'rijndael-256'
            ],
        ],
    );

    $schema->populate(
        'User',
        [   [   'id',           'name',
                'password_md5', 'salt_md5',
                'email',        'email_is_public',
                'url',          'verified',
                'forum_handle',
            ],
            [   1,                                  'user1',
                'f4384fd7e541f4279d003cf89fc40c33', $SALT,
                'nobody@example.com',               1,
                'http://example.com/',              1,
                'user1_forum',
            ],
            [   2,     'Alice Author', 'f4384fd7e541f4279d003cf89fc40c33',
                $SALT, 'author@example.com', 1, undef, 1, undef,
            ],
            [   3,
                'Victor Votecounter',
                'f4384fd7e541f4279d003cf89fc40c33',
                $SALT, 'votecounter@example.com', 1, undef, 1, undef,
            ],
            [   4,
                'Connie Curator',
                'f4384fd7e541f4279d003cf89fc40c33',
                $SALT, 'curator@example.com', 1, undef, 1, undef,
            ]
        ],
    );

    $schema->populate( 'Role',
        [ [ 'id', 'name' ], [ 1, 'votecounter' ], [ 2, 'curator' ] ] );

    $schema->populate( 'UserRole',
        [ [ 'id', 'user', 'role' ], [ 1, 3, 1, ], [ 2, 4, 2 ] ],
    );

    # There are two comps - last year and this year. The current comp is open
    # for intents all year long.
    my $this_year = DateTime->now->year;
    my $last_year = $this_year - 1;
    $schema->populate(
        'Comp',
        [   [   'id',           'year',
                'intents_open', 'intents_close',
                'entries_due',  'judging_begins',
                'judging_ends', 'comp_closes',
                'organizer',
            ],
            [   1,                  $last_year,
                "$last_year-07-01", "$last_year-09-01",
                "$last_year-09-28", "$last_year-10-01",
                "$last_year-11-15", "$last_year-12-01",
                "Alice Testersdottir",
            ],
            [   2,                  $this_year,
                "$this_year-01-01", "$this_year-12-31",
                "$this_year-12-31", "$this_year-12-31",
                "$this_year-12-31", "$this_year-12-31",
                "Bob Testersson",
            ],
        ],
    );

    $schema->populate(
        'Entry',
        [   [ 'id', 'author', 'title', 'comp', 'place', 'platform' ],

            [ 100, 1, 'Test Z-code game',        2, 1, 'inform', ],
            [ 101, 1, 'Test Glulx game',         2, 2, 'inform', ],
            [ 102, 1, 'Test Quixe game',         1, 3, 'quixe', ],
            [ 103, 1, 'Test Parchment game',     1, 4, 'parchment', ],
            [ 104, 1, 'Test Z-code website',     1, 5, 'inform-website', ],
            [ 105, 1, 'Test non-Inform website', 1, 6, 'website', ],
            [ 106, 1, 'Test HTML page',          1, 7, 'website', ],
            [   107, 1, 'Test Z-code website with buried story file',
                1,   8, 'inform-website',
            ],
            [ 108, 1, 'Test Quest game',              1, 9,  'quest', ],
            [ 109, 1, 'Test TADS game',               1, 10, 'tads', ],
            [ 110, 1, 'Test Alan game',               1, 11, 'alan', ],
            [ 111, 1, 'Test ADRIFT game',             1, 12, 'adrift', ],
            [ 112, 1, 'Quixe game, with extra stuff', 1, 13, 'quixe', ],
            [ 113, 1, 'Test Hugo game',               1, 14, 'hugo', ],
            [ 114, 1, 'Test subdir-based ulx game',   1, 15, 'inform', ],
            [   115, 1,  'Test non-Inform website, no index.html',
                1,   16, 'website',
            ],
        ],
    );

    my $entry_directory =
        Path::Class::Dir->new("$FindBin::Bin/platform_test_entries");

    $schema->entry_directory($entry_directory);

    return $schema;
}

sub log_in_as_judge {
    my ($mech) = @_;
    _log_in_as( $mech, 'nobody@example.com', 'user1' );
}

sub log_in_as_author {
    my ($mech) = @_;
    _log_in_as( $mech, 'author@example.com', 'Alice Author' );
}

sub log_in_as_votecounter {
    my ($mech) = @_;
    _log_in_as( $mech, 'votecounter@example.com', 'Victor Votecounter' );
}

sub log_in_as_curator {
    my ($mech) = @_;
    _log_in_as( $mech, 'curator@example.com', 'Connie Curator' );
}

sub _log_in_as {
    my ( $mech, $email, $name ) = @_;

    # Quietly clear out any existing login first
    $mech->get('http://localhost/auth/logout');

    # Now try (with tests!) the requested login
    $mech->get_ok('http://localhost/auth/login');
    $mech->submit_form_ok(
        {   fields => {
                email    => $email,
                password => 'fool',
            },
        },
        'Submitted the login form'
    );

    $mech->content_like( qr/$name/, 'Login successful' );
}

sub process_test_entries {
    my ( $class, $schema ) = @_;
    for my $entry ( $schema->resultset('Entry')->all ) {
        $entry->update_content_directory;
    }
}

#
# Set the comp to a specific phase
#
sub set_phase_after {
    use DateTime;
    my ( $schema, $phase ) = @_;
    my @phases = qw(announcement intents_open intents_close entries_due
        judging_begins judging_ends comp_closes);
    my $past_ymd   = DateTime->now->subtract( days => 2 )->ymd;
    my $future_ymd = DateTime->now->add( days => 2 )->ymd;

    my $hit    = 0;
    my @before = ();
    my @after  = ();
    foreach (@phases) {
        if ($hit) {
            push( @after, $_ );
        }
        else {
            push( @before, $_ );
        }
        $hit = 1 if ( $_ eq $phase );
    }
    shift(@before);    # remove the 'announcement' pseudo-phase

    my $comp = $schema->resultset('Comp')->find(2);
    foreach (@before) {
        $comp->$_($past_ymd);
    }
    foreach (@after) {
        $comp->$_($future_ymd);
    }
    $comp->update;
}

1;

__END__

=head1 NAME

IFCompTest

=head1 SYNOPSIS

    use lib qw(t/lib);
    use IFCompTest;
    use Test::More;

    my $schema = IFCompTest->init_schema;

=head1 DESCRIPTION

This module provides the basic utilities to write tests against
IFComp. Shamelessly stolen from SpoilerificTest (itself stolen from
DBICTest in the DBIx::Class test suite -- actually it's stolen from a
consulting colleague of Jason's, who stole it in turn from DBIC...)

=head1 METHODS

=head2 init_schema

    my $schema = IFCompTest->init_schema;

This method removes the test SQLite database in t/db/IFComp.db
and then creates a new database populated with default test data.

