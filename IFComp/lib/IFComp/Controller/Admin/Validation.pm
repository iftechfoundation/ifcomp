package IFComp::Controller::Admin::Validation;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

IFComp::Controller::Admin::Validation - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 index

=cut

sub index : Chained('/admin/root') : PathPart('validation') : Args(0) {
    my ( $self, $c ) = @_;

    unless ( $c->user && $c->check_any_user_role('cheez') ) {
        $c->res->redirect('/');
        return;
    }

    my @unverified =
        $c->model('IFCompDB::User')
        ->search( { verified => undef, access_token => { '!=', undef }, },
        { order_by => 'created desc' } )->all;

    $c->stash(
        template => 'admin/validation/index.tt',
        badlist  => \@unverified,
    );
}

=encoding utf8

=head1 AUTHOR

root

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
