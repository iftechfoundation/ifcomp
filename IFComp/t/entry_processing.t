use strict;
use warnings;
use Test::More;

use FindBin;
use lib ("$FindBin::Bin/lib");
use IFCompTest;
my $schema = IFCompTest->init_schema();

my $entry_directory = $schema->entry_directory;

IFCompTest->process_test_entries($schema);

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
ok( $schema->resultset('Entry')->find(100)->supports_transcripts,
    'Supports transcripts.',
);

note('Testing naked Glulx upload...');
ok( file_exists( 101, 'index.html' ), 'Generated an index.html file.', );
ok( file_exists( 101, 'Naked glulx.gblorb.js' ),
    'Generated a JavaScript game file.',
);
ok( file_contains( 101, 'index.html', qr{/static/interpreter/quixe/} ),
    'Links to local interpreter.',
);
is( $schema->resultset('Entry')->find(101)->platform,
    'inform-website', 'Platform is correct.',
);
ok( $schema->resultset('Entry')->find(101)->supports_transcripts,
    'Supports transcripts.',
);

note('Testing Quixe upload...');
ok( file_contains( 102, 'play.html', qr{/static/interpreter/quixe/} ),
    'Links to local interpreter.',
);
is( $schema->resultset('Entry')->find(102)->platform,
    'quixe', 'Platform is correct.',
);
ok( $schema->resultset('Entry')->find(102)->supports_transcripts,
    'Supports transcripts.',
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
ok( $schema->resultset('Entry')->find(103)->supports_transcripts,
    'Supports transcripts.',
);

note('Testing custom Inform websites...');
is( $schema->resultset('Entry')->find(104)->platform,
    'inform-website', 'Platform is correct. (typical layout)',
);
is( $schema->resultset('Entry')->find(107)->platform,
    'inform-website', 'Platform is correct. (weird layout)',
);
TODO: {
    local $TODO = "Some 'inform-website' games don't actually support "
        . "transcripts. We need to improve platform labels.";
    ok( not $schema->resultset('Entry')->find(104)->supports_transcripts,
        'Does not support transcripts.',
    );
    ok( not $schema->resultset('Entry')->find(107)->supports_transcripts,
        'Does not support transcripts.',
    );
}

note('Testing miscellaneous platform detection...');
is( $schema->resultset('Entry')->find(105)->platform,
    'website', 'Platform is correct. (website)',
);
ok( not( $schema->resultset('Entry')->find(105)->supports_transcripts ),
    'Does not support transcripts.',
);
is( $schema->resultset('Entry')->find(106)->platform,
    'website', 'Platform is correct. (html page)',
);
ok( not( $schema->resultset('Entry')->find(106)->supports_transcripts ),
    'Does not support transcripts.',
);

is( $schema->resultset('Entry')->find(108)->platform,
    'quest', 'Platform is correct. (quest)',
);
ok( not( $schema->resultset('Entry')->find(108)->supports_transcripts ),
    'Does not support transcripts.',
);
is( $schema->resultset('Entry')->find(109)->platform,
    'tads', 'Platform is correct. (tads)',
);
ok( not( $schema->resultset('Entry')->find(109)->supports_transcripts ),
    'Does not support transcripts.',
);
is( $schema->resultset('Entry')->find(110)->platform,
    'alan', 'Platform is correct. (alan)',
);
ok( not( $schema->resultset('Entry')->find(110)->supports_transcripts ),
    'Does not support transcripts.',
);

done_testing();
