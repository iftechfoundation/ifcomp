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

sub comp : Path : Args(0) {
    my ( $self, $c ) = @_;

    my $current_comp = $c->model('IFCompDB::Comp')->current_comp;

    if (   $current_comp->status eq 'open_for_judging'
        || $current_comp->status eq 'processing_votes' )
    {
        $c->res->redirect( $c->uri_for_action('/ballot/index') );
    }
    else {
        $c->res->redirect( $c->uri_for_action('/comp/last_comp') );
    }
}

sub last_comp : Path('last_comp') : Args(0) {
    my ( $self, $c ) = @_;

    my $last_comp = $c->model('IFCompDB::Comp')->last_comp;
    $c->res->redirect(
        $c->uri_for_action( '/comp/index', [ $last_comp->year ] ) );
}

sub fetch_comp : Chained('/') : PathPart('comp') : CaptureArgs(1) {
    my ( $self, $c, $comp_year ) = @_;

    my $comp = $c->model('IFCompDB::Comp')->search( { year => $comp_year, } )
        ->single;

    if ( not($comp) ) {
        $c->res->redirect( $c->uri_for_action('/index') );
        $c->detach;
        return;
    }

    $c->stash->{comp} = $comp;
}

sub index : Chained('fetch_comp') : PathPart('') : Args(0) {
    my ( $self, $c ) = @_;

    my $comp = $c->stash->{comp};

    # If the comp's underway, bounce the user to the ballot page instead.
    if ( ( $comp->status eq 'open_for_judging' ) ) {
        $c->res->redirect( $c->uri_for_action('/ballot/index') );
        $c->detach;
        return;
    }

    # If the comp's neither underway nor over, bounce to the front page.
    elsif ( $comp->status ne 'over' ) {
        $c->res->redirect( $c->uri_for_action('/index') );
        $c->detach;
        return;
    }

    $c->stash->{entries} = [
        $c->stash->{comp}->entries->search(
            { is_disqualified => 0, },
            { order_by        => 'place', },
        )->all
    ];
    $c->stash->{template} = 'comp/index.tt';

    my @comp_years = $c->model('IFCompDB::Comp')->search(
        {   judging_ends =>
                { '<', DateTime->now( time_zone => 'US/Eastern' )->ymd, },
        },
        { order_by => 'year' },
    )->get_column('year')->all;

    $c->stash->{comp_years} = \@comp_years;
    if ( $comp->year > $comp_years[0] ) {
        $c->stash->{previous_year} = $comp->year - 1;
    }
    if ( $comp->year < $comp_years[-1] ) {
        $c->stash->{next_year} = $comp->year + 1;
    }

    $c->stash->{there_is_a_tie_for} = _get_tie_hash( $comp, 'place' );
    $c->stash->{there_is_a_miss_congeniality_tie_for} =
        _get_tie_hash( $comp, 'miss_congeniality_place' );

    if ( $c->req->params->{compact} ) {
        $c->stash->{view_is_compact} = 1;
    }
    else {
        $c->stash->{view_is_compact} = 0;
    }
}

sub cover_sheet : Chained('fetch_comp') : PathPart('cover_sheet') : Args(0) {
    my ( $self, $c ) = @_;

    unless ( $c->check_user_roles('curator') ) {
        $c->res->redirect( $c->uri_for_action('/comp/comp') );
        return;
    }

    my @entries = $c->stash->{comp}->entries->search(
        { is_disqualified => 0, },
        { order_by        => 'title', },
    )->all;

    @entries = sort { $a->sort_title cmp $b->sort_title } @entries;

    $c->stash->{entries}  = \@entries;
    $c->stash->{template} = 'comp/cover_sheet.tt';
}

sub _get_tie_hash {
    my ( $comp, $place_field ) = @_;

    my $dbh = $comp->result_source->schema->storage->dbh;
    my $tied_place_sql =
          "select e1.$place_field from entry e1, entry e2 "
        . 'where e1.id != e2.id '
        . "and e1.$place_field=e2.$place_field "
        . 'and e1.comp = ? and e2.comp = ? '
        . "group by e1.$place_field ";
    my $ties_ref =
        $dbh->selectcol_arrayref( $tied_place_sql, {}, $comp->id,
        $comp->id, );
    my %ties;
    foreach (@$ties_ref) {
        $ties{$_} = 1;
    }

    return \%ties;
}

=encoding utf8

=head1 AUTHOR

Jason McIntosh



=cut

__PACKAGE__->meta->make_immutable;

1;
