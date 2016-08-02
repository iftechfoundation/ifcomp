package IFComp::Controller::Admin::Voting;
use Moose;
use namespace::autoclean;
use Data::Dumper;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

IFComp::Controller::Admin::Voting

=head1 DESCRIPTION

A controller for voting reports.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    my $comp = $c->model('IFCompDB::Comp');
    my $entry = $c->model('IFCompDB::Entry');

    my $current_comp;
    if (my $id = $c->req->param("comp_id")) {
      $current_comp = $comp->find($id);
    } else {
      $current_comp = $comp->current_comp;
    }

    $c->stash->{ current_comp } = $current_comp;
    my @available_comps = $comp->search({
                                         year => {'>=' => 2014},
                                        },
                                        { order_by => 'year'}
                                       )->all;

    $c->stash->{ available_comps } = \@available_comps;

    # Get all entries for this comp
    my @all_entries = $entry->search({comp => $current_comp->id,
                                      is_disqualified => 0
                                     },
                                     )->all;
    # sort list by vote count
    # not super-efficient, but still fast for this data
    @all_entries =
      map { $_->[0] }
      sort { $b->[1] <=> $a->[1] }
      map {
        [ $_, $_->average_score ]
      } @all_entries;

    $c->stash->{ entries } = \@all_entries;
    $c->stash->{ template } = "admin/voting/index.tt";
}

# /admin/voting/:entry_id
sub show_entry :Path :Args(1) {
  my ($self, $c, $entry_id) = @_;

  my $entry = $c->model('IFCompDB::Entry');
  my $this_entry = $entry->find($entry_id);

  $c->stash->{ entry } = $this_entry;

  $c->stash->{ template } = "admin/voting/show_entry.tt";

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
