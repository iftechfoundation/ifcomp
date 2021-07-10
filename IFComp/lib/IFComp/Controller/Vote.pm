package IFComp::Controller::Vote;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

IFComp::Controller::Vote - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 index

=cut

sub index : Path : Args(2) {
    my ( $self, $c, $entry_id, $score ) = @_;

    my $current_comp = $c->model('IFCompDB::Comp')->current_comp;

    my $ballot_uri      = $c->uri_for_action('/ballot/index');
    my $ballot_vote_uri = $c->uri_for_action('/ballot/vote');
    unless ( $c->req->referer =~ /^$ballot_uri/
        || $c->req->referer =~ /^$ballot_vote_uri/ )
    {
        $c->res->code(400);
        $c->res->body(
            "You can vote only from the ballot page ($ballot_uri) or the voting page ($ballot_vote_uri)."
        );
        return;
    }

    unless ( $c->user ) {
        $c->res->code(401);
        $c->res->body("You can't vote because you're not logged in.");
        return;
    }

    unless ( $current_comp->status eq 'open_for_judging' ) {
        $c->res->code(404);
        $c->res->body("The competition is not accepting votes at this time.");
        return;
    }

    my $entry = $c->model('IFCompDB::Entry')->search(
        {   id   => $entry_id,
            comp => $current_comp->id,
        },
    )->single;

    unless ( $entry && $entry->is_qualified ) {
        $c->res->code(404);
        $c->res->body("Invalid entry ID.");
        return;
    }

    unless ( ( $score =~ /^\d\d?$/ ) && ( $score >= 0 ) && ( $score <= 10 ) )
    {
        $c->res->code(400);
        $c->res->body("Invalid score (must be an integer between 0 and 10).");
        return;
    }

    if ( $entry->author->id == $c->user->id ) {
        $c->res->code(403);
        $c->res->body("You may not vote on an entry you authored.");
        return;
    }

    my $coauthorship = $c->model('IFCompDB::EntryCoauthor')->search(
        {   entry_id    => $entry_id,
            coauthor_id => $c->user->id,
        },
    )->single;

    if ($coauthorship) {
        $c->res->code(403);
        $c->res->body("You may not vote on an entry you co-authored");
        return;
    }

    $score = undef unless $score;

    if ( $score > 0 ) {
        $c->model('IFCompDB::Vote')->update_or_create(
            {   score => $score,
                entry => $entry_id,
                user  => $c->user->id,
                time  => DateTime->now( time_zone => 'UTC' ),
                ip    => $c->req->address,
            },
            { key => 'user', },
        );
    }
    else {
        $c->model('IFCompDB::Vote')->search(
            {   entry => $entry_id,
                user  => $c->user->id,
            },
        )->delete_all;
    }

    $c->res->code(200);
    $c->res->body('OK');
}

=encoding utf8

=head1 AUTHOR

Jason McIntosh



=cut

__PACKAGE__->meta->make_immutable;

1;
