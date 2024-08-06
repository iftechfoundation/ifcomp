package IFComp::Controller::Admin::GenAI;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

IFComp::Controller::Admin::GenAI - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 index

=cut

sub index : Path : Args(0) {
    my ( $self, $c ) = @_;

    my $comp    = $c->model('IFCompDB::Comp')->current_comp;
    my @entries = $comp->entries;

    $c->stash( entries => \@entries );
}

=encoding utf8

=head1 AUTHOR

Mark Musante

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
