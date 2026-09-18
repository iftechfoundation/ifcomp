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
use Catalyst::Test 'IFComp';
use DateTime;
use File::Copy::Recursive qw(dircopy);

my $schema = IFCompTest->init_schema();

ok( my $mech =
        Test::WWW::Mechanize::Catalyst->new( catalyst_app => 'IFComp' ),
    'Created mech object'
);

my ($entry_id) =
    $schema->storage->dbh->selectrow_array('select max(id) from entry');
$entry_id = $entry_id + 1;

IFCompTest::set_phase_after( $schema, 'intents_open' );
IFCompTest::log_in_as_author($mech);
$mech->get_ok('http://localhost/entry/create');
$mech->submit_form_ok(
    {   form_number => 2,
        fields      => {
            'entry.title' => 'Balloting Game',
            'entry.main_upload' =>
                "$FindBin::Bin/test_files/misc/my_game.html",
            'entry.genai' => ['nothing'],
        },
    },
    'Submitted a declaration'
);
my $entry = $schema->resultset('Entry')->find($entry_id);
is( $entry->title, 'Balloting Game' );

IFCompTest::log_in_as_judge($mech);

IFCompTest::set_phase_after( $schema, 'judging_begins' );
$mech->get_ok('http://localhost/ballot');
$mech->content_contains("Balloting Game");

$mech->content_contains("Your rating");

$entry->discard_changes;

# ---------------------------------------------------------------------------
# Guard against ballot N+1 queries
# ---------------------------------------------------------------------------

sub _count_ballot_queries {
    my ($mech) = @_;

    my $count   = 0;
    my $storage = IFComp->model('IFCompDB')->schema->storage;
    $storage->debug(1);
    $storage->debugcb(
        sub {
            my ( $op, $info ) = @_;
            my $msg
                = !defined $info ? ( $op // '' )
                : ref($info)     ? ( $info->{sql} // '' )
                :                  "$info";
            return unless $msg =~ /^\s*(?:SELECT|INSERT|UPDATE|DELETE)\b/i;
            $count++;
        }
    );

    $mech->get('http://localhost/ballot');
    $storage->debug(0);
    $storage->debugcb(undef);

    return $count;
}

sub _add_ballot_entries {
    my ( $schema, $n ) = @_;

    # Simple website entry with on-disk files we can clone.
    my $donor = $schema->resultset('Entry')->find(106);
    BAIL_OUT('Expected fixture entry 106 to exist') unless $donor;

    for my $i ( 1 .. $n ) {
        my $new_entry = $schema->resultset('Entry')->create(
            {   author   => 1,
                title    => "Query Budget Game $i",
                comp     => 2,
                platform => 'website',
                blurb    => 'n-plus-one regression fixture',
            }
        );
        dircopy( $donor->directory->stringify,
            $new_entry->directory->stringify );
        $new_entry->clear_directory;
        $new_entry->update_content_directory;

        $schema->resultset('EntryUpdate')->create(
            {   entry => $new_entry->id,
                note  => 'fixture update',
                time  => DateTime->now( time_zone => 'UTC' ),
            }
        );
        $schema->resultset('EntryCoauthor')->create(
            {   entry_id         => $new_entry->id,
                coauthor_id      => 2,
                pseudonym        => "Perf Coauthor $i",
                reveal_pseudonym => 1,
            }
        );
    }
}

# Count as anonymous so session/auth noise stays minimal and stable.
$mech->get('http://localhost/auth/logout');

my $queries_before = _count_ballot_queries($mech);
ok( $mech->success, 'ballot loads before adding entries' );

my $added = 15;
_add_ballot_entries( $schema, $added );

my $queries_after = _count_ballot_queries($mech);
ok( $mech->success, 'ballot loads after adding entries' );
$mech->content_contains('Query Budget Game 1');
$mech->content_contains('Query Budget Game 15');

diag(
    "ballot SQL statements before=$queries_before after=$queries_after (added $added entries with coauthors+updates)"
);

# Batch loading keeps statement count flat; classic N+1 would add ~3+ per entry.
cmp_ok(
    $queries_after - $queries_before,
    '<=', 3,
    "adding $added entries adds at most 3 SQL statements (not O(n))"
);
cmp_ok(
    $queries_after, '<',
    $added,
    'total ballot queries stay below entry-count (N+1 would exceed this)'
);

done_testing();
