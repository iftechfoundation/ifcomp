package IFComp::Controller::Ballot;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

IFComp::Controller::Ballot - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    my $current_comp = $c->model( 'IFCompDB::Comp' )->current_comp;
    $c->stash->{ current_comp } = $current_comp;

    my $order_by;
    if ( $c->req->params->{ shuffle } ) {
        $order_by = 'rand()';
    }
    else {
        $order_by = 'title asc';
    }

    $c->stash->{ entries_rs } = $current_comp->entries(
        {},
        {
            order_by => $order_by,
        }
    );


    my %rating_for_entry;
    if ( $c->user ) {
        my $rating_rs = $c->model( 'IFCompDB::Vote' )->search(
            {
                user => $c->user->id,
                comp => $current_comp->id,
            },
            {
                join => { entry => 'comp' },
            },
        );

        while ( my $rating = $rating_rs->next ) {
            $rating_for_entry{ $rating->entry->id } = $rating->score;
        }
    }
    $c->stash->{ rating_for_entry } = \%rating_for_entry;

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
