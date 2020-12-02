package IFComp::Controller::History;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

IFComp::Controller::History - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 index

=cut

sub index : Path : Args(0) {
    my ( $self, $c ) = @_;

    $c->stash->{template} = 'history/history.tt';

    # Fetch the current comp, so that we can exclude it from the
    # winners list if it isn't over yet.
    my $current_comp  = $c->model('IFCompDB::Comp')->current_comp;
    my @comp_sql_args = ();
    unless ( $current_comp->status eq 'over' ) {
        @comp_sql_args = ( comp => { '!=', $current_comp->id } );
    }

    my @winners = $c->model('IFCompDB::Entry')->search(
        {   place => 1,
            @comp_sql_args,
        },
        {   join     => ['comp'],
            order_by => 'comp.year desc',
        },
    );

    $c->stash->{winners} = \@winners;
}

=encoding utf8

=head1 AUTHOR

Jason McIntosh



=cut

__PACKAGE__->meta->make_immutable;

1;
