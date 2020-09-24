package IFComp::Controller::Auth;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

with 'IFComp::Form::UserFields';

=head1 NAME

IFComp::Controller::Auth - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 login

The login handler

=cut

use IFComp::Form::Login;
use Crypt::Eksblowfish::Blowfish;

sub login : Path('login') : Args(0) {
    my ( $self, $c ) = @_;

    my $form = IFComp::Form::Login->new;

    $c->stash->{template} = 'auth/login.tt';
    $c->stash->{form}     = $form;

    if ( $form->process( params => $c->req->parameters ) ) {
        if ($c->authenticate(
                {   email    => $c->req->param('email'),
                    password => $c->req->param('password'),
                }
            )
            )
        {
            $c->log->debug("User authed\n") if ( $c->debug );
            $c->res->redirect('/');
        }
        else {
            $c->log->debug("Authenication failed\n") if ( $c->debug );
            $form->add_form_error(
                'Login failed. <a href="/user/request_password_reset">(Do you need to reset your password?)</a>'
            );
        }
    }

}

sub logout : Path('logout') : Args(0) {
    my ( $self, $c ) = @_;

    if ( $c->user ) {
        $c->logout;
    }

    # Clear the special user_id cookie set by the root controller for
    # logged-in users.
    $c->res->cookies->{user_id} = {
        expires => '-1M',
        value   => 'Deleted',
    };

    $c->res->redirect('/');
}

=encoding utf8

=head1 AUTHOR

Jason McIntosh



=cut

__PACKAGE__->meta->make_immutable;

1;
