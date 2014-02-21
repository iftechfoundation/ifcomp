package IFComp::Controller::Comp;
use Moose;
use namespace::autoclean;
use DateTime;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

IFComp::Controller::Comp - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


sub comp :Path :Args(0) {
    my ( $self, $c ) = @_;

    # XXX A low-quality hack that just grabs last calendar-year and forwards us there.
    #     It ought to instead send us to the most recent closed-down comp, specifically.
    my $last_year = DateTime->now->year - 1;
    $c->res->redirect( $c->uri_for_action( '/comp/index', [ $last_year ] ) );
}

sub fetch_comp :Chained('/') :PathPart('comp') :CaptureArgs(1) {
    my ( $self, $c, $comp_year ) = @_;

    my $comp = $c->model( 'IFCompDB::Comp' )->search( { year => $comp_year } )->single;

    unless ( $comp ) {
        $c->res->redirect( $c->uri_for_action( '/' ) );
    }

    $c->stash->{ comp } = $comp;
}

sub index :Chained('fetch_comp') :PathPart('') :Args(0) {
    my ( $self, $c ) = @_;

    $c->stash->{ entries } = [ $c->stash->{ comp }->entries->search(
        {},
        {
            order_by => 'place',
        },
    )->all ];
    $c->stash->{ template } = 'comp/index.tt';

    my @comp_years = $c->model( 'IFCompDB::Comp' )->search(
        {},
        { order_by => 'year' },
    )->get_column( 'year' )->all;

    my $comp = $c->stash->{ comp };
    $c->stash->{ comp_years } = \@comp_years;
    if ( $comp->year > $comp_years[0] ) {
        $c->stash->{ previous_year } = $comp->year - 1;
    }
    if ( $comp->year < $comp_years[-1] ) {
        $c->stash->{ next_year } = $comp->year + 1;
    }

    $c->stash->{ there_is_a_tie_for } = _get_tie_hash( $comp, 'place' );
    $c->stash->{ there_is_a_miss_congeniality_tie_for } =
        _get_tie_hash( $comp, 'miss_congeniality_place' );
}

sub _get_tie_hash {
    my ( $comp, $place_field ) = @_;

    my $dbh = $comp->result_source->schema->storage->dbh;
    my $tied_place_sql = "select e1.$place_field from entry e1, entry e2 "
                         . 'where e1.id != e2.id '
                         . "and e1.$place_field=e2.$place_field "
                         . 'and e1.comp = ? and e2.comp = ? '
                         . "group by e1.$place_field ";
    my $ties_ref = $dbh->selectcol_arrayref(
        $tied_place_sql,
        {},
        $comp->id,
        $comp->id,
    );
    my %ties;
    foreach ( @$ties_ref ) {
        $ties{ $_ } = 1;
    }

    return \%ties;
}

=encoding utf8

=head1 AUTHOR

Jason McIntosh

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
