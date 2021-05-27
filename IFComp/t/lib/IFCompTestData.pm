package IFCompTestData;
use strict;
use warnings;

use DateTime qw();
use Path::Class qw();
use File::Copy::Recursive qw(dircopy);

use Readonly;
Readonly my $SALT => '123456';

sub add_test_data_to_schema {
    my ( $class, $schema ) = @_;

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
            ],
            [   5,
                'David Developer',
                'f4384fd7e541f4279d003cf89fc40c33',
                $SALT, 'developer@example.com', 1, undef, 1, undef,
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
            [ 102, 1, 'Test Quixe game',         1, 1, 'quixe', ],
            [ 103, 1, 'Test Parchment game',     1, 2, 'parchment', ],
            [ 104, 1, 'Test Z-code website',     1, 3, 'inform-website', ],
            [ 105, 1, 'Test non-Inform website', 1, 4, 'website', ],
            [ 106, 1, 'Test HTML page',          1, 5, 'website', ],
            [   107, 1, 'Test Z-code website with buried story file',
                1,   6, 'inform-website',
            ],
            [ 108, 1, 'Test Quest game',              1, 7,  'quest', ],
            [ 109, 1, 'Test TADS game',               1, 8,  'tads', ],
            [ 110, 1, 'Test Alan game',               1, 9,  'alan', ],
            [ 111, 1, 'Test ADRIFT game',             1, 10, 'adrift', ],
            [ 112, 1, 'Quixe game, with extra stuff', 1, 11, 'quixe', ],
            [ 113, 1, 'Test Hugo game',               1, 12, 'hugo', ],
            [ 114, 1, 'Test subdir-based ulx game',   1, 13, 'inform', ],
            [   115, 1,  'Test non-Inform website, no index.html',
                1,   14, 'website',
            ],
        ],
    );

    return;
}

sub copy_test_files {
    my ( $class, %directory_map ) = @_;

    # %directory_map is a map of source directories to destination directories.
    #
    # Both source and destination directories should be full paths.
    #
    # Each destination directory will be removed, recreated, and then the
    # contents of the source directory will be copied over.
    foreach my $source ( keys %directory_map ) {
        my $source_dir = Path::Class::Dir->new($source);
        unless ( -d "$source_dir" ) {
            warn "Missing test file directory: $source_dir";
            next;
        }

        my $dest_dir = Path::Class::Dir->new( $directory_map{$source} );
        $dest_dir->rmtree();
        $dest_dir->mkpath();

        dircopy( $source_dir, $dest_dir );
    }
}

sub process_entries {
    my ( $class, $schema ) = @_;
    for my $entry ( $schema->resultset('Entry')->all ) {
        $entry->update_content_directory;
    }
}

1;

__END__

=head1 NAME

IFCompTestData

=head1 SYNOPSIS

    use lib qw(t/lib);
    use IFCompTestData;

    IFCompTestData->add_test_data_to_schema($schema);

=head1 DESCRIPTION

This module provides a set of test data suitable for use by the test framework
as well as by the developer environment.

=head1 METHODS

=head2 add_test_data_to_schema($schema)

Populates C<$schema> with test data. The schema must already be connected and
deployed.

=head2 copy_test_files(source_dir1 => dest_dir1, ... )

Copies directories of test files into their final locations.

Both source_dir and dest_dir should be full paths.

The destination directories will be destroyed before the test files are copied
in.

=head2 process_entries($schema)

Call C<update_content_directory()> on each entry in the schema.
