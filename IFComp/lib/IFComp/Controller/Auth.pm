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
use MIME::Base64;

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
            $self->_set_userid_cookie($c);
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
    $c->res->redirect('/');
}

sub _set_userid_cookie {
    my ( $self, $c ) = @_;
    my $key = $c->config->{user_id_cookie_key};

    unless ( defined $key ) {
        $c->log->warn(
            'No blowfish key configured! I will not set a userid cookie.');
        return;
    }

    # Zero-pad the current user ID into an eight-character string, then
    # encrypt it with Blowfish, then base64-encode it.
    # And then stuff that into a special cookie.
    $c->res->cookies->{user_id} = {
        domain  => $c->req->uri->host,
        expires => '+' . $c->config->{'Plugin::Session'}->{expires} . 'S',
        value   => encode_base64(
            Crypt::Eksblowfish::Blowfish->new($key)
                ->encrypt( sprintf '%08d', $c->user->id )
        )
    };

}

=encoding utf8

=head1 AUTHOR

Jason McIntosh



=cut

__PACKAGE__->meta->make_immutable;

1;
