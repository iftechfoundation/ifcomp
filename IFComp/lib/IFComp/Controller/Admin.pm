package IFComp::Controller::Admin;
use Moose;
use namespace::autoclean;
use Text::CSV::Encoded;
use POSIX qw(strftime);

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

IFComp::Controller::Admin

=head1 DESCRIPTION

A controller for administrative functions

=head1 METHODS

=cut

=head2 index

=cut

sub root : Chained('/') : PathPart( 'admin' ) : CaptureArgs(0) {
    my ( $self, $c ) = @_;

    unless (
        $c->user
        && $c->check_any_user_role(
            'votecounter', 'curator', 'cheez', 'prizemanager',
        )
        )
    {
        $c->detach('/error_403');
        return;
    }
}

sub index : Chained( 'root' ) : PathPart('') : Args(0) {
    my ( $self, $c ) = @_;

    $c->stash->{template} = "admin/index.tt";
}

sub gamescsv : Chained( 'root' ) : Args(0) {
    my ( $self, $c ) = @_;

    unless ( $c->user
        && $c->check_any_user_role( 'curator', ) )
    {
        $c->detach('/error_403');
        return;
    }

    my $current_comp = $c->model('IFCompDB::Comp')->current_comp;
    my @entries      = $current_comp->entries();

    my $csv = Text::CSV::Encoded->new( { binary => 1, encoding => "utf8" } )
        or die "2 unable to create csv: $!";

    my $output = "";
    open my $fh, ">:encoding(utf8)", \$output or die "open fail $!";

    $csv->print( $fh, [ "TITLE", "PRIMARY AUTHOR" ] );
    print $fh "\n";

    for my $entry ( $current_comp->entries ) {
        next unless $entry->is_qualified;
        my $author = "";

        $author = $entry->author_pseudonym;
        if ( $author eq ""
            || ( $entry->reveal_pseudonym && $current_comp->status eq 'over' )
            )
        {
            $author = $entry->author->name;
        }
        $csv->print( $fh, [ $entry->title, $author ] );
        print $fh "\n";
    }

    close $fh;
    $c->res->header(
        'Content-Disposition' => qq{attachment; filename="game-list.csv"} );
    $c->res->content_type('text/csv; charset=utf-8');
    $c->res->code(200);
    $c->res->body($output);
}

sub ballotcsv : Chained( 'root' ) : Args(0) {
    my ( $self, $c ) = @_;

    unless ( $c->user
        && $c->check_any_user_role( 'curator', ) )
    {
        $c->detach('/error_403');
        return;
    }

    my $current_comp = $c->model('IFCompDB::Comp')->current_comp;
    my @entries      = $current_comp->entries();

    my $csv = Text::CSV::Encoded->new( { binary => 1, encoding => "utf8" } )
        or die "2 unable to create csv: $!";

    my $output = "";
    open my $fh, ">:encoding(utf8)", \$output or die "open fail $!";
    $csv->column_names( "ID", "Title", "Content Warning",
        "Name", "Email", "Last Update" );

    for my $entry ( $current_comp->entries ) {
        next unless $entry->is_qualified;
        my $modtime = ( stat( $entry->main_file ) )[9];
        next unless $modtime > 0;

        my $gmtstring = strftime( "%Y-%m-%dT%H:%M:%SZ",
            gmtime( ( stat( $entry->main_file ) )[9] ) );
        $csv->print(
            $fh,
            [   $entry->id,            $entry->title,
                $entry->warning,       $entry->author->name,
                $entry->author->email, $gmtstring
            ]
        );
        print $fh "\n";
    }
    close $fh;

    $c->res->header(
        'Content-Disposition' => qq{attachment; filename="ballot.csv"} );
    $c->res->content_type('text/csv; charset=utf-8');
    $c->res->code(200);
    $c->res->body($output);
}

sub resultscsv : Chained( 'root' ) : Args(0) {
    my ( $self, $c ) = @_;

    unless ( $c->user
        && $c->check_any_user_role( 'cheez', ) )
    {
        $c->detach('/error_403');
        return;
    }

    my $current_comp = $c->model('IFCompDB::Comp')->current_comp;
    my @entries      = $current_comp->entries();

    my $csv = Text::CSV::Encoded->new( { binary => 1, encoding => "utf8" } )
        or die "2 unable to create csv: $!";

    my $output = "";
    open my $fh, ">:encoding(utf8)", \$output or die "open fail $!";
    $csv->column_names(
        "author",  "title",  "place", "MissC",
        "average", "stddev", "total_votes"
    );

    for my $entry ( $current_comp->entries ) {
        if ( $entry->is_disqualified == 0 ) {
            $csv->print(
                $fh,
                [   $entry->author->name,  $entry->title,
                    $entry->place,         $entry->miss_congeniality_place,
                    $entry->average_score, $entry->standard_deviation,
                    $entry->votes_cast
                ]
            );
            print $fh "\n";
        }
    }
    close $fh;

    $c->res->header(
        'Content-Disposition' => qq{attachment; filename="results.csv"} );
    $c->res->content_type('text/csv; charset=utf-8');
    $c->res->code(200);
    $c->res->body($output);
}

sub votecsv : Chained( 'root' ) {
    my ( $self, $c ) = @_;

    unless ( $c->user
        && $c->check_any_user_role( 'cheez', ) )
    {
        $c->detach('/error_403');
        return;
    }

    my $comp  = $c->model('IFCompDB::Comp');
    my $entry = $c->model('IFCompDB::Entry');
    my $vote  = $c->model('IFCompDB::Vote');
    my $user  = $c->model('IFCompDB::User');

    my $current_comp;
    if ( my $id = $c->req->param("comp_id") ) {
        $current_comp = $comp->find($id);
    }
    else {
        $current_comp = $comp->current_comp;
    }

    $c->stash->{current_comp} = $current_comp;

    my @all_entries =
        grep { $_->is_qualified }
        $entry->search( { comp => $current_comp->id, } )->all;
    my @entry_ids = map { $_->id } @all_entries;

    my @votes = $vote->search( { entry => \@entry_ids },
        { select => [ 'entry', 'ip', 'time', 'score', 'user' ] } );

    my $csv = Text::CSV::Encoded->new( { binary => 1, encoding => "utf8" } )
        or die "2 unable to create csv: $!";

    my $output = "";
    open my $fh, ">:encoding(utf8)", \$output or die "open fail $!";
    $csv->column_names(
        "title",        "platform",  "voter",   "vote",
        "ip address",   "timestamp", "any GAI", "GAI cover",
        "GAI non-text", "GAI text"
    );
    $csv->print(
        $fh,
        [   "TITLE",       "PLATFORM",  "VOTER",    "VOTE",
            "IP ADDRESS",  "TIMESTAMP", "GAI-FREE", "GAI COVER",
            "GAI NONTEXT", "GAI TEXT"
        ]
    );
    print $fh "\n";

    for my $vote (@votes) {
        my $gen_used  = ( $vote->entry->genai_state & 1 ) == 1 ? "yes" : "no";
        my $gen_cover = ( $vote->entry->genai_state & 2 ) == 2 ? "yes" : "no";
        my $gen_nontext =
            ( $vote->entry->genai_state & 4 ) == 4 ? "yes" : "no";
        my $gen_text = ( $vote->entry->genai_state & 8 ) == 8 ? "yes" : "no";
        my $gmtstring =
            strftime( "%Y-%m-%dT%H:%M:%SZ", gmtime( $vote->time ) );
        $csv->print(
            $fh,
            [   $vote->entry->title, $vote->entry->platform,
                $vote->user->name,   $vote->score,
                $vote->ip,           $vote->time,
                $gen_used,           $gen_cover,
                $gen_nontext,        $gen_text,
            ]
        );
        print $fh "\n";
    }

    close $fh;
    $c->res->header(
        'Content-Disposition' => qq{attachment; filename="vote-data.csv"} );
    $c->res->content_type('text/csv; charset=utf-8');
    $c->res->code(200);
    $c->res->body($output);
}

=encoding utf8

=head1 AUTHOR

Joe Johnston



=cut

__PACKAGE__->meta->make_immutable;

1;
