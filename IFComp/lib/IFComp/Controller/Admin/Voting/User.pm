package IFComp::Controller::Admin::Voting::User;
use Moose;
use namespace::autoclean;
use JSON;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

IFComp::Controller::Admin::Voting

=head1 DESCRIPTION

A controller for voting reports.

=head1 METHODS

=cut

=head2 index

=cut

# /admin/voting/user/:user_id/:comp_id
# Show how this user voted for this comp
sub show_user : Chained("/admin/voting") : Path : Args(2) {
    my ( $self, $c, $user_id, $comp_id ) = @_;

    my $comp = $c->model('IFCompDB::Comp')->find($comp_id);
    my $user = $c->model('IFCompDB::User')->find($user_id);
    my @comp_entries =
        $c->model('IFCompDB::Entry')->search( { comp => $comp_id } );
    my @comp_ids = map { $_->id } @comp_entries;

    my $vote  = $c->model('IFCompDB::Vote');
    my @votes = $vote->search(
        {   entry => \@comp_ids,
            user  => $user_id,
        }
    );
    my @score_buckets;
    for my $vote (@votes) {
        $score_buckets[ $vote->score ] += 1;
    }
    shift @score_buckets;

    $c->stash->{votes}              = \@votes;
    $c->stash->{user}               = $user;
    $c->stash->{comp}               = $comp;
    $c->stash->{score_buckets_json} = JSON::to_json( \@score_buckets );

    $c->stash->{template} = "admin/voting/show_user.tt";
}

__PACKAGE__->meta->make_immutable;

1;
