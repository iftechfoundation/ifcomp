package IFComp::Controller::Admin::Voting::IP;
use Moose;
use namespace::autoclean;
use JSON;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

IFComp::Controller::Admin::Voting::IP

=head1 DESCRIPTION

A controller for voting reports.

=head1 METHODS

=cut


=head2 index

=cut


# /admin/voting/ip/:ip/:comp_id
# Show the voting from this IP for this entry
sub show_ip :Path :Args(2) {
    my ($self, $c, $ip, $comp_id) = @_;

    my $comp = $c->model('IFCompDB::Comp')->find($comp_id);
    my @entries = $c->model('IFCompDB::Entry')->search({comp => $comp_id});
    my @entry_ids = map { $_->id } @entries;
    my @votes = $c->model('IFCompDB::Vote')->search({entry => \@entry_ids,
                                                     ip => $ip,
                                                    });
    my @score_buckets;
    for my $vote (@votes) {
        $score_buckets[$vote->score] += 1;
    }


    $c->stash->{comp} = $comp;
    $c->stash->{ip} = $ip;
    $c->stash->{votes} = \@votes;
    $c->stash->{ score_buckets_json } = JSON::to_json(\@score_buckets);
    $c->stash->{template} = "admin/voting/show_ip.tt";
}


=encoding utf8

=head1 AUTHOR

Joe Johnston

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
