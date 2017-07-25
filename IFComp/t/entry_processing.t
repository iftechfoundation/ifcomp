use strict;
use warnings;
use Test::More;

use FindBin;
use lib ("$FindBin::Bin/lib");
use IFCompTest;
my $schema = IFCompTest->init_schema();

my $entry_directory =
    Path::Class::Dir->new("$FindBin::Bin/platform_test_entries");

$schema->entry_directory($entry_directory);

$schema->populate(
    'Entry',
    [   [ 'id', 'author', 'title',                   'comp' ],
        [ 100,  1,        'Test Z-code game',        1 ],
        [ 101,  1,        'Test Glulx game',         1 ],
        [ 102,  1,        'Test Quixe game',         1 ],
        [ 103,  1,        'Test Parchment game',     1 ],
        [ 104,  1,        'Test Z-code website',     1 ],
        [ 105,  1,        'Test non-Inform website', 1 ],
        [ 106,  1,        'Test HTML page',          1 ],
        [ 107, 1, 'Test Z-code website with buried story file', 1 ],
        [ 108, 1, 'Test Quest game',                            1 ],
        [ 109, 1, 'Test TADS game',                             1 ],
        [ 110, 1, 'Test Alan game',                             1 ],
    ],
);

for my $entry ( $schema->resultset('Entry')->all ) {
    $entry->update_content_directory;
}

sub file_exists ($$) {
    my ( $entry_id, $filename ) = @_;
    return -e "$entry_directory/$entry_id/content/$filename";
}

sub file_contains ($$$) {
    my ( $entry_id, $filename, $regex ) = @_;
    my $file = Path::Class::File->new(
        "$entry_directory/$entry_id/content/$filename" );
    eval { return $file->slurp =~ $regex; };
}

diag('Testing naked Z-Code upload...');
ok( file_exists( 100, 'index.html' ), 'Generated an index.html file.', );
ok( file_contains( 100, 'index.html', qr{/static/interpreter/parchment/} ),
    'Links to local parchment.',
);
ok( file_contains(
        100, 'index.html', qr{/static/interpreter/transcript_recorder/}
    ),
    'Links to local transcript recorder.',
);
is( $schema->resultset('Entry')->find(100)->platform,
    'inform-website', 'Platform is correct.',
);

diag('Testing naked Glulx upload...');
ok( file_exists( 101, 'index.html' ), 'Generated an index.html file.', );
ok( file_exists( 101, 'Naked Glulx.gblorb.js' ),
    'Generated a JavaScript game file.',
);
ok( file_contains( 101, 'index.html', qr{/static/interpreter/quixe/} ),
    'Links to local interpreter.',
);
is( $schema->resultset('Entry')->find(101)->platform,
    'inform-website', 'Platform is correct.',
);

diag('Testing Quixe upload...');
ok( file_contains( 102, 'play.html', qr{/static/interpreter/quixe/} ),
    'Links to local interpreter.',
);
is( $schema->resultset('Entry')->find(102)->platform,
    'quixe', 'Platform is correct.',
);

diag('Testing Parchment...');
ok( file_contains( 103, 'play.html', qr{/static/interpreter/parchment/} ),
    'Links to local interpreter.',
);
is( $schema->resultset('Entry')->find(103)->platform,
    'parchment', 'Platform is correct.',
);
ok( file_contains(
        103, 'play.html', qr{/static/interpreter/transcript_recorder/}
    ),
    'Links to local transcript recorder.',
);

diag('Testing custom Inform websites...');
is( $schema->resultset('Entry')->find(104)->platform,
    'inform-website', 'Platform is correct. (typical layout)',
);
is( $schema->resultset('Entry')->find(107)->platform,
    'inform-website', 'Platform is correct. (weird layout)',
);

diag('Testing miscellaneous platform detection...');
is( $schema->resultset('Entry')->find(105)->platform,
    'website', 'Platform is correct. (website)',
);
is( $schema->resultset('Entry')->find(106)->platform,
    'website', 'Platform is correct. (html page)',
);
is( $schema->resultset('Entry')->find(108)->platform,
    'quest', 'Platform is correct. (quest)',
);
is( $schema->resultset('Entry')->find(109)->platform,
    'tads', 'Platform is correct. (tads)',
);
is( $schema->resultset('Entry')->find(110)->platform,
    'alan', 'Platform is correct. (alan)',
);

done_testing();
