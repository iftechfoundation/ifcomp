package IFComp::Controller::Root;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller' }

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config( namespace => '' );

=encoding utf-8

=head1 NAME

IFComp::Controller::Root - Root Controller for IFComp

=head1 DESCRIPTION

[enter your description here]

=head1 METHODS

=head2 index

The root page (/)

=cut

sub index : Path : Args(0) {
    my ( $self, $c ) = @_;
    $c->stash->{template} = 'welcome.tt2';
    $c->stash->{cf}       = $c->model('ColossalFund');
}

=head2 default

Standard 404 error page

=cut

sub default : Path {
    my ( $self, $c ) = @_;
    $c->detach('/error_404');
}

=head2 end

Attempt to render a view, if needed.

=cut

sub end : ActionClass('RenderView') {
    my ( $self, $c ) = @_;
    $c->stash( meta => {} );

    unless ( $c->stash->{current_comp} ) {
        my $current_comp = $c->model('IFCompDB::Comp')->current_comp;
        $c->stash->{current_comp} = $current_comp;
    }
}

=head2 error_404

Sends a 404 response, and displays a friendly file-not-found page.

=cut

sub error_404 : Private {
    my ( $self, $c ) = @_;

    $c->response->status(404);
    $c->stash( template => 'error_404.tt' );
}

=head1 AUTHOR

Jason McIntosh



=cut

__PACKAGE__->meta->make_immutable;

1;
