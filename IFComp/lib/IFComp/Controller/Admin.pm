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
    close $fh;

    $c->res->header(
        'Content-Disposition' => qq{attachment; filename="results.csv"} );
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
