package IFComp::Controller::Root;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller' }

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config(namespace => '');

=encoding utf-8

=head1 NAME

IFComp::Controller::Root - Root Controller for IFComp

=head1 DESCRIPTION

[enter your description here]

=head1 METHODS

=head2 index

The root page (/)

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;
    $c->stash->{template} = 'welcome.tt2';
    if ($c->user)
    {
        $c->stash("username" => $c->user->name);
    }
}

=head2 login

The login handler

=cut

sub login :Global
{
    my ($self, $c) = @_;

    $c->stash->{template} = 'welcome.tt2';
    if ($c->req->param("username") && $c->req->param("password"))
    {
        if ($c->authenticate({ email => $c->req->param("username"),
                               password => $c->req->param("password"),
                         }))
        {
            $c->log->debug("User authed\n");
            $c->change_session_id;
            $c->session->{login} = time();
            $c->stash("username" => $c->user->name);
        }
        else
        {
            $c->log->debug("Authenication failed\n");
            $c->response->code(403);
            return $c->response->body( "FORBIDDEN" );
        }
    }

}

=head2 default

Standard 404 error page

=cut

sub default :Path {
    my ( $self, $c ) = @_;
    $c->response->body( 'Page not found' );
    $c->response->status(404);
}

=head2 end

Attempt to render a view, if needed.

=cut

sub end : ActionClass('RenderView') {
	my ($self, $c) = @_;
    $c->stash(meta => {});
}

=head1 AUTHOR

Jason McIntosh

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
