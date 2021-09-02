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
ok( file_contains( 100, 'index.html', qr{/static/interpreter/main.js} ),
    'Links to local parchment.',
);
is( $schema->resultset('Entry')->find(100)->platform,
    'inform', 'Platform is correct.',
);
ok( $schema->resultset('Entry')->find(100)->supports_transcripts,
    'Supports transcripts.',
);
is( $schema->resultset('Entry')->find(100)->play_file,
    'index.html', 'Play-file set correctly.',
);

note('Testing naked Glulx upload...');
ok( file_exists( 101, 'index.html' ), 'Generated an index.html file.', );
ok( file_contains( 101, 'index.html', qr{/static/interpreter/main.js} ),
    'Links to local interpreter.',
);
is( $schema->resultset('Entry')->find(101)->platform,
    'inform', 'Platform is correct.',
);
ok( $schema->resultset('Entry')->find(101)->supports_transcripts,
    'Supports transcripts.',
);
is( $schema->resultset('Entry')->find(101)->play_file,
    'index.html', 'Play-file set correctly.',
);

note('Testing Quixe upload...');
ok( file_contains( 102, 'play.html', qr{game_options\.recording_url} ),
    'Configures the transcription service.',
);
is( $schema->resultset('Entry')->find(102)->platform,
    'quixe', 'Platform is correct.',
);
ok( $schema->resultset('Entry')->find(102)->supports_transcripts,
    'Supports transcripts.',
);
is( $schema->resultset('Entry')->find(102)->play_file,
    'index.html', 'Play-file set correctly.',
);
ok( not( $schema->resultset('Entry')->find(102)->has_extra_content ),
    'Does not report having any extra content.' );

note('Testing Quixe upload (with extra content...');
is( $schema->resultset('Entry')->find(112)->platform,
    'quixe', 'Platform is correct.',
);
ok( $schema->resultset('Entry')->find(112)->supports_transcripts,
    'Supports transcripts.',
);
is( $schema->resultset('Entry')->find(112)->play_file,
    'index.html', 'Play-file set correctly.',
);
ok( $schema->resultset('Entry')->find(112)->has_extra_content,
    'Reports having extra content.' );

note('Testing Parchment...');
ok( file_contains( 103, 'play.html', qr{parchment_options\.recording_url} ),
    'Configures the transcription service.',
);
is( $schema->resultset('Entry')->find(103)->platform,
    'parchment', 'Platform is correct.',
);
is( $schema->resultset('Entry')->find(103)->play_file,
    'index.html', 'Play-file set correctly.',
);
ok( $schema->resultset('Entry')->find(103)->supports_transcripts,
    'Supports transcripts.',
);

note('Testing custom Inform websites...');
is( $schema->resultset('Entry')->find(104)->platform,
    'inform-website', 'Platform is correct. (typical layout)',
);
is( $schema->resultset('Entry')->find(104)->play_file,
    'index.html', 'Play-file set correctly.',
);

is( $schema->resultset('Entry')->find(107)->platform,
    'inform-website', 'Platform is correct. (weird layout)',
);
is( $schema->resultset('Entry')->find(107)->play_file,
    'index.html', 'Play-file set correctly.',
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

note('Testing hugo detection');
is( $schema->resultset('Entry')->find(113)->platform,
    'hugo', 'Platform is correct' );
is( $schema->resultset('Entry')->find(113)->play_file,
    undef, 'Play-file set correctly.',
);

note('Testing miscellaneous platform detection...');
is( $schema->resultset('Entry')->find(105)->platform,
    'website', 'Platform is correct. (website with index.html)',
);
ok( not( $schema->resultset('Entry')->find(105)->supports_transcripts ),
    'Does not support transcripts.',
);
is( $schema->resultset('Entry')->find(105)->play_file,
    'index.html', 'Play-file set correctly.',
);

is( $schema->resultset('Entry')->find(115)->platform,
    'website', 'Platform is correct. (website with other front page)',
);
ok( not( $schema->resultset('Entry')->find(115)->supports_transcripts ),
    'Does not support transcripts.',
);
is( $schema->resultset('Entry')->find(115)->play_file,
    'my-game.html', 'Play-file set correctly.',
);

note('Testing Single HTML file game');
is( $schema->resultset('Entry')->find(106)->platform,
    'website', 'Platform is correct. (single HTML file)',
);
ok( not( $schema->resultset('Entry')->find(106)->supports_transcripts ),
    'Does not support transcripts.',
);
is( $schema->resultset('Entry')->find(106)->play_file,
    'my-game.html', 'Play-file set correctly.',
);

note('Testing Quest game');
is( $schema->resultset('Entry')->find(108)->platform,
    'quest', 'Platform is correct. (quest)',
);
ok( not( $schema->resultset('Entry')->find(108)->supports_transcripts ),
    'Does not support transcripts.',
);
is( $schema->resultset('Entry')->find(108)->play_file,
    undef, 'Play-file set correctly.',
);

note('Testing TADS 2 game');
is( $schema->resultset('Entry')->find(109)->platform,
    'tads', 'Platform is correct. (tads)',
);
ok( file_exists( 109, 'index.html' ), 'Generated an index.html file.', );
ok( file_contains( 109, 'index.html', qr{/static/interpreter/main.js} ),
    'Links to local interpreter.',
);
is( $schema->resultset('Entry')->find(109)->platform,
    'inform', 'Platform is correct.',
);
ok( $schema->resultset('Entry')->find(109)->supports_transcripts,
    'Supports transcripts.',
);
is( $schema->resultset('Entry')->find(109)->play_file,
    'index.html', 'Play-file set correctly.',
);

note('Testing Alan game');
is( $schema->resultset('Entry')->find(110)->platform,
    'alan', 'Platform is correct. (alan)',
);
ok( not( $schema->resultset('Entry')->find(110)->supports_transcripts ),
    'Does not support transcripts.',
);
is( $schema->resultset('Entry')->find(110)->play_file,
    undef, 'Play-file set correctly.',
);

note('Testing Adrft game');
is( $schema->resultset('Entry')->find(111)->platform,
    'adrift', 'Platform is correct. (adrift)',
);
ok( not( $schema->resultset('Entry')->find(111)->supports_transcripts ),
    'Does not support transcripts.',
);
is( $schema->resultset('Entry')->find(111)->play_file,
    undef, 'Play-file set correctly.',
);

note('Testing Adventuron game');
is( $schema->resultset('Entry')->find(116)->platform,
    'adventuron', 'Platform is correct. (adventuron)',
);
ok( not( $schema->resultset('Entry')->find(116)->supports_transcripts ),
    'Does not support transcripts.',
);
is( $schema->resultset('Entry')->find(116)->play_file,
    'index.html', 'Play-file set correctly.',
);

note('Testing ChoiceScript game');
is( $schema->resultset('Entry')->find(117)->platform,
    'choicescript', 'Platform is correct. (choicescript)',
);
ok( not( $schema->resultset('Entry')->find(117)->supports_transcripts ),
    'Does not support transcripts.',
);
is( $schema->resultset('Entry')->find(117)->play_file,
    'index.html', 'Play-file set correctly.',
);

note('Testing Ink game');
is( $schema->resultset('Entry')->find(118)->platform,
    'ink', 'Platform is correct. (ink)',
);
ok( not( $schema->resultset('Entry')->find(118)->supports_transcripts ),
    'Does not support transcripts.',
);
is( $schema->resultset('Entry')->find(118)->play_file,
    'index.html', 'Play-file set correctly.',
);

note('Testing Texture game');
is( $schema->resultset('Entry')->find(119)->platform,
    'texture', 'Platform is correct. (texture)',
);
ok( not( $schema->resultset('Entry')->find(119)->supports_transcripts ),
    'Does not support transcripts.',
);
is( $schema->resultset('Entry')->find(119)->play_file,
    'index.html', 'Play-file set correctly.',
);

note('Testing Twine game');
is( $schema->resultset('Entry')->find(120)->platform,
    'twine', 'Platform is correct. (twine)',
);
ok( not( $schema->resultset('Entry')->find(120)->supports_transcripts ),
    'Does not support transcripts.',
);
is( $schema->resultset('Entry')->find(120)->play_file,
    'index.html', 'Play-file set correctly.',
);

note('Testing Unity game');
is( $schema->resultset('Entry')->find(121)->platform,
    'unity', 'Platform is correct. (unity)',
);
ok( not( $schema->resultset('Entry')->find(121)->supports_transcripts ),
    'Does not support transcripts.',
);
is( $schema->resultset('Entry')->find(121)->play_file,
    'index.html', 'Play-file set correctly.',
);

done_testing();
