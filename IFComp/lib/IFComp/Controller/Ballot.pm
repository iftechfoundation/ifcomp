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

sub root :Chained('/') :PathPart('ballot') :CaptureArgs(0) {
    my ( $self, $c ) = @_;

    my $current_comp = $c->model( 'IFCompDB::Comp' )->current_comp;
    $c->stash->{ current_comp } = $current_comp;

    unless ( $current_comp->status eq 'open_for_judging' ) {
        $c->res->redirect( $c->uri_for( '/comp/comp' ) );
        return;
    }

    my $order_by;
    if ( $c->req->params->{ shuffle } ) {
        $c->stash->{ is_shuffled } = 1;
        my $seed = '';
        if ( $c->user && $c->req->params->{ personalize } ) {
            $seed = $c->user->get_object->id;
            $c->stash->{ is_personalized } = 1;
        }
        $order_by = "rand($seed)";
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

    my $user_is_author = 0;
    if ( $c->user && $c->user->get_object->current_comp_entries ) {
        $user_is_author = 1;
    }
    $c->stash->{ user_is_author } = $user_is_author;

}

sub index :Chained('root') :PathPart('') :Args(0) {
    my ( $self, $c ) = @_;

}

sub vote :Chained('root') :PathPart('vote') :Args(0) {
    my ( $self, $c ) = @_;

    my %rating_for_entry;
    if ( $c->user ) {
        my $rating_rs = $c->model( 'IFCompDB::Vote' )->search(
            {
                user => $c->user->id,
                comp => $c->stash->{ current_comp }->id,
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
