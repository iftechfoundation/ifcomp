package IFComp::Controller::About;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

IFComp::Controller::About - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub if :Path('if') :Args(0) {
    my ( $self, $c ) = @_;

    $c->stash->{ template } = 'about/if.tt';

}

sub contact :Path('contact') :Args(0) {
    my ( $self, $c ) = @_;

    $c->stash->{ template } = 'about/contact.tt';
}

sub comp :Path('comp') :Args(0) {
    my ( $self, $c ) = @_;

    $c->stash->{ template } = 'about/comp.tt';
}

sub guidelines :Path('guidelines') :Args(0) {
    my ( $self, $c ) = @_;

    $c->stash->{ template } = 'about/guidelines.tt';
}

sub judging :Path('judging') :Args(0) {
    my ( $self, $c ) = @_;
}

sub how_to_enter :Path('how_to_enter') :Args(0) {
}

sub prizes :Path('prizes') :Args(0) {
    my ( $self, $c ) = @_;

    my $current_comp = $c->model( 'IFCompDB::Comp' )->current_comp;
    $c->stash->{ current_comp } = $current_comp;

    my %prizes_in_category;
    for my $prize ( $current_comp->prizes->search( {}, { order_by => 'name' } )->all ) {
        $prizes_in_category{ $prize->category } ||= [];
        push @{ $prizes_in_category{ $prize->category } }, $prize;
    }

    $c->stash->{ prizes_in_category } = \%prizes_in_category;

}

sub past_prizes :Path('past_prizes') :Args(0) {
}

sub faq :Path('faq') :Args(0) {
}

=encoding utf8

=head1 AUTHOR

Jason McIntosh

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
