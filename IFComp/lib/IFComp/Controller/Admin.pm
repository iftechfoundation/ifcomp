package IFComp::Controller::Admin;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

IFComp::Controller::Admin

=head1 DESCRIPTION

A controller for administrative functions

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    #my $current_comp = $c->model( 'IFCompDB::Comp' )->current_comp;
    #$c->stash->{ current_comp } = $current_comp;

    $c->stash->{ template } = "admin/index.tt";
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
