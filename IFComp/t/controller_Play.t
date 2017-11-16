use strict;
use warnings;
use Test::More;
use JSON::XS;
use FindBin;
use Readonly;
use lib ("$FindBin::Bin/lib");
use Test::WWW::Mechanize::Catalyst;
use IFCompTest;
my $schema = IFCompTest->init_schema();

ok( my $mech =
        Test::WWW::Mechanize::Catalyst->new( catalyst_app => 'IFComp' ),
    'Created mech object'
);

Readonly my $INPUT  => 'x me';
Readonly my $OUTPUT => 'As good-looking as ever.';

my $count = $schema->resultset('Transcript')->count;
is( $count, 0, 'Transcription table is empty at start of test.' );

IFCompTest->process_test_entries($schema);

# Change the phase of the current test-competition to open-for-judging.
use DateTime;
my $past_ymd = DateTime->now->subtract( days => 2 )->ymd;
my $future_ymd = DateTime->now->add( days => 2 )->ymd;
my $comp = $schema->resultset('Comp')->find(2);
foreach (qw(intents_open intents_close entries_due judging_begins)) {
    $comp->$_($past_ymd);
}
foreach (qw(judging_ends comp_closes)) {
    $comp->$_($future_ymd);
}
$comp->update;

note('Testing Parchment transcription...');
{
    my $data = {
        data => {
            session => 1,
            log     => {
                input       => $INPUT,
                output      => $OUTPUT,
                window      => 0,
                inputcount  => 1,
                outputcount => 1,
            },
        },
    };
    my $json_data = encode_json($data);

    $mech->post(
        'http://localhost/play/100/transcribe',
        'Content-Type' => 'application/json',
        Content        => $json_data,
    );

    my $transcription = $schema->resultset('Transcript')->find(1);
    is( $transcription->input,     $INPUT,  'Input recorded correctly.' );
    is( $transcription->output,    $OUTPUT, 'Output recorded correctly.' );
    is( $transcription->entry->id, 100,     'Entry is correct.' );
}
note('Testing Quixe transcription...');
{
    my $data = {
        sessionId => 1,
        input     => $INPUT,
        output    => $OUTPUT,
    };
    my $json_data = encode_json($data);

    $mech->post(
        'http://localhost/play/101/transcribe',
        'Content-Type' => 'application/json',
        Content        => $json_data,
    );

    my $transcription = $schema->resultset('Transcript')->find(2);
    is( $transcription->input,     $INPUT,  'Input recorded correctly.' );
    is( $transcription->output,    $OUTPUT, 'Output recorded correctly.' );
    is( $transcription->entry->id, 101,     'Entry is correct.' );
}

note('Testing cover art...');
{
    my $entry = $schema->resultset('Entry')->find(100);

    $mech->get_ok('http://localhost/play/100/cover');
    $mech->header_is( 'Content-Type',   'image/png' );
    $mech->header_is( 'Content-Length', 19242 );

    $mech->get_ok('http://localhost/play/100/full_cover');
    $mech->header_is( 'Content-Type',   'image/png' );
    $mech->header_is( 'Content-Length', 35185 );
}

done_testing();

