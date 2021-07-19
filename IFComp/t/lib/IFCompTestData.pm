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
        [   [   'id',    'author',   'title', 'comp',
                'place', 'platform', 'coauthor_code',
            ],

            [   100, 1, 'Test Z-code game',
                2,   1, 'inform', '8ad0cfd053b7ed08124d',
            ],
            [   101, 1, 'Test Glulx game',
                2,   2, 'inform', 'cb596f31d709901e66e0',
            ],
            [   102, 1, 'Test Quixe game',
                1,   1, 'quixe', '1d85063fad228a35b48f',
            ],
            [   103, 3, 'Test Parchment game',
                2,   2, 'parchment', '2e44258d59ccfca797d8',
            ],
            [   104, 1, 'Test Z-code website',
                2,   3, 'inform-website', '570afe4434136a35b97e',
            ],
            [   105, 3, 'Test non-Inform website',
                2,   4, 'website', '70d146f955a9be7ee657',
            ],
            [   106, 3, 'Test HTML page',
                2,   5, 'website', '11740856d5392f4f099c',
            ],
            [   107, 3, 'Test Z-code website with buried story file',
                2,   6, 'inform-website', '62584e5198e8ce160921',
            ],
            [   108, 1, 'Test Quest game',
                2,   7, 'quest', 'ec0460756f55e774c47a',
            ],
            [   109, 1, 'Test TADS game',
                2,   8, 'tads', '701d72d3c91885849902',
            ],
            [   110, 1, 'Test Alan game',
                1,   9, 'alan', '1f27146aef4840d23890',
            ],
            [   111, 1,  'Test ADRIFT game',
                1,   10, 'adrift', '50b2ebe54c374d8a30ce',
            ],
            [   112, 1,  'Quixe game, with extra stuff',
                1,   11, 'quixe', 'e2ffd42661e14703fc4e',
            ],
            [   113, 1,  'Test Hugo game',
                1,   12, 'hugo', '1eada264ce7e16e9871b',
            ],
            [   114, 1,  'Test subdir-based ulx game',
                1,   13, 'inform', 'dc828daacbc60b2355fb',
            ],
            [   115, 1,  'Test non-Inform website, no index.html',
                1,   14, 'website', '7ed8e2cdcc37e33beb1c',
            ],
            [   116, 1,  'Test Adventuron game',
                1,   15, 'adventuron', 'fbbfc1a939a75253bd9d',
            ],
            [   117, 1,  'Test ChoiceScript game',
                1,   16, 'choicescript', '1dc6f3f624b4d41d6722',
            ],
            [   118, 1, 'Test Ink game', 1, 17, 'ink', 'dbf9363f8cd1e93f3896',
            ],
            [   119, 1,  'Test Texture game',
                1,   18, 'texture', 'eaab524bcce5d4b4c066',
            ],
            [   120, 1,  'Test Twine game',
                1,   19, 'twine', 'd7307f76e70989897684',
            ],
            [   121, 1,  'Test Unity game',
                1,   20, 'unity', 'dfed9407cd2c1c82ae9c',
            ],
        ],
    );

    $schema->populate(
        'Vote',
        [   [ 'id', 'user', 'score', 'entry', ],
            [ 1,    1,      3,       100 ],
            [ 2,    2,      7,       100 ],
            [ 3,    3,      5,       100 ],
            [ 4,    3,      6,       101 ],
            [ 5,    3,      7,       109 ],
            [ 6,    3,      8,       103 ],
            [ 7,    3,      9,       104 ],
            [ 8,    3,      10,      106 ],
            [ 9,    4,      1,       100 ],
            [ 10,   4,      2,       101 ],
            [ 11,   4,      3,       102 ],
            [ 12,   4,      4,       103 ],
            [ 13,   4,      5,       104 ],
        ],
    );

    $schema->populate(
        'EntryCoauthor',
        [   [ 'entry_id', 'coauthor_id', 'pseudonym', 'reveal_pseudonym', ],
            [ 101,        2,             'Looking-Glass Girl', 0 ],
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
