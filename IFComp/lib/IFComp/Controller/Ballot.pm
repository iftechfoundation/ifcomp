package IFComp::Controller::Ballot;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

use IFComp::Form::Feedback;

=head1 NAME

IFComp::Controller::Ballot - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 index

=cut

sub root : Chained('/') : PathPart('ballot') : CaptureArgs(0) {
    my ( $self, $c ) = @_;

    my $current_comp = $c->model('IFCompDB::Comp')->current_comp;
    $c->stash->{current_comp} = $current_comp;

    unless ( $current_comp->status eq 'open_for_judging'
        || $current_comp->status eq 'processing_votes'
        || $c->check_user_roles('curator') )
    {
        $c->detach('/error_403');
        return;
    }

    my $user_is_author = 0;
    my @collabs        = ();
    if ( $c->user ) {
        if ( $c->user->get_object->current_comp_entries ) {
            $user_is_author = 1;
        }
        @collabs = $c->user->entry_coauthors;
    }

    $c->stash(
        user_is_author => $user_is_author,
        collabs        => \@collabs
    );
}

sub fetch_entries : Chained('root') : PathPart('') : CaptureArgs(0) {
    my ( $self, $c ) = @_;

    update_ratings($c);

    # If we have an 'alphabetize' param defined, sort the games by alpha.
    # Otherwise, shuffle them, also seeding off the user's ID if we're in
    # personal-shuffle mode.
    if ( $c->req->params->{alphabetize} ) {
        $c->forward('fetch_alphabetized_entries');
    }
    else {
        my @entries;
        $c->stash->{is_shuffled} = 1;
        my $seed = '';
        if ( $c->user && $c->req->params->{personalize} ) {
            $seed = $c->user->get_object->id;
            $c->stash->{is_personalized} = 1;
        }

        # Peek into our app config to see if we're running SQLite.
        # If so, randomize via random(). Otherwise, use rand().
        my $order_by;
        my $dsn = $c->config->{'Model::IFCompDB'}->{connect_info}->{dsn};
        if ( $dsn =~ /SQLite/ ) {
            $order_by = "random($seed)";
        }
        else {
            $order_by = "rand($seed)";
        }
        my $current_comp = $c->stash->{current_comp};
        @entries = $current_comp->entries( {}, { order_by => $order_by, } );
        $c->stash->{entries} = \@entries;
    }

}

sub fetch_alphabetized_entries : Chained('root') : PathPart('') :
    CaptureArgs(0) {
    my ( $self, $c ) = @_;

    my @entries;

    my $current_comp = $c->stash->{current_comp};

    @entries =
        sort { $a->sort_title cmp $b->sort_title } $current_comp->entries();
    $c->stash->{entries} = \@entries;

    update_ratings($c);
}

sub index : Chained('fetch_entries') : PathPart('') : Args(0) {
    my ( $self, $c ) = @_;

    $c->stash->{zip_file_mb} = $c->config->{zip_file_mb};
}

sub vote : Chained('fetch_alphabetized_entries') : PathPart('vote') : Args(0)
{
    my ( $self, $c ) = @_;

    if ( $c->stash->{current_comp}->status ne 'open_for_judging' ) {
        $c->detach('/error_403');
    }

}

sub feedback : Chained('root') : PathPart('feedback') : Args(1) {
    my ( $self, $c, $entry_id ) = @_;

    my $entry = $c->model('IFCompDB::Entry')->find($entry_id);
    my $comp  = $c->stash->{current_comp};

    unless ( $c->user ) {
        $c->res->redirect( $c->uri_for_action('/auth/login') );
        return;
    }

    # We accept feedback only for active entries during judging.
    unless ( $entry
        && ( $entry->comp->id eq $comp->id )
        && ( $entry->is_qualified )
        && ( $comp->status eq 'open_for_judging' ) )
    {
        $c->detach('/error_403');
        return;
    }

    my $form = IFComp::Form::Feedback->new( { title => $entry->title } );

    my $feedback = $c->model('IFCompDB::Feedback')->find_or_create(
        {   entry => $entry_id,
            judge => $c->user->id,
        }
    );

    if ($form->process(
            init_object => { text => $feedback->text },
            params      => $c->req->parameters,
        )
        )
    {
        $feedback->text( $form->field('text')->value );
        $feedback->update;
        $c->flash->{feedback_entry} = $entry;
        $c->res->redirect( $c->uri_for_action('/ballot/vote') );
    }

    $c->stash(
        form  => $form,
        entry => $entry,
    );
}

sub update_ratings() {
    my ($c) = @_;
    my %rating_for_entry;

    if ( $c->user ) {
        my $rating_rs = $c->model('IFCompDB::Vote')->search(
            {   user => $c->user->id,
                comp => $c->stash->{current_comp}->id,
            },
            { join => { entry => 'comp' }, },
        );

        while ( my $rating = $rating_rs->next ) {
            $rating_for_entry{ $rating->entry->id } = $rating->score;
        }
    }
    $c->stash->{rating_for_entry} = \%rating_for_entry;
}

=encoding utf8

=head1 AUTHOR

Jason McIntosh



=cut

__PACKAGE__->meta->make_immutable;

1;
