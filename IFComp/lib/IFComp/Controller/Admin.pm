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

sub root : Chained('/') : PathPart( 'admin' ) : CaptureArgs(0) {
    my ( $self, $c ) = @_;

    unless ( $c->user
        && $c->check_any_user_role( 'votecounter', 'curator', ) )
    {
        $c->detach('/error_403');
        return;
    }
}

sub index : Chained( 'root' ) : PathPart('') : Args(0) {
    my ( $self, $c ) = @_;

    $c->stash->{template} = "admin/index.tt";
}

=encoding utf8

=head1 AUTHOR

Joe Johnston



=cut

__PACKAGE__->meta->make_immutable;

1;
