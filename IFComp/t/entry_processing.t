use strict;
use warnings;
use Test::More;

use FindBin;
use lib ("$FindBin::Bin/lib");
use IFCompTest;
my $schema = IFCompTest->init_schema();

my $entry_directory = $schema->entry_directory;

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
        "$entry_directory/$entry_id/content/$filename");
    eval { return $file->slurp =~ $regex; };
}

note('Testing naked Z-Code upload...');
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

note('Testing naked Glulx upload...');
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

note('Testing Quixe upload...');
ok( file_contains( 102, 'play.html', qr{/static/interpreter/quixe/} ),
    'Links to local interpreter.',
);
is( $schema->resultset('Entry')->find(102)->platform,
    'quixe', 'Platform is correct.',
);

note('Testing Parchment...');
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

note('Testing custom Inform websites...');
is( $schema->resultset('Entry')->find(104)->platform,
    'inform-website', 'Platform is correct. (typical layout)',
);
is( $schema->resultset('Entry')->find(107)->platform,
    'inform-website', 'Platform is correct. (weird layout)',
);

note('Testing miscellaneous platform detection...');
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
