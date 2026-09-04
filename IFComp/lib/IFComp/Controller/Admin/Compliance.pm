package IFComp::Controller::Admin::Compliance;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

IFComp::Controller::Admin::Compliance - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 index

=cut

sub index : Chained("/admin/root") : PathPart('uk-compliance') : Args(0) {
    my ( $self, $c ) = @_;

    unless ( $c->user && $c->check_any_user_role( 'cheez', 'curator' ) ) {
        $c->res->redirect('/');
        return;
    }

    my $comp      = $c->model('IFCompDB::Comp')->current_comp;
    my @entries   = $comp->entries->search( { is_disqualified => 0, }, )->all;
    my @questions = $c->model('IFCompDB::Question')->all;

    $c->stash(
        entries   => \@entries,
        questions => \@questions,
    );
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
