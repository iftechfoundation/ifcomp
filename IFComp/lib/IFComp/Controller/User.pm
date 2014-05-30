package IFComp::Controller::User;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

IFComp::Controller::User - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

use IFComp::Form::Register;
use IFComp::Form::ResetPassword;
use IFComp::Form::RequestPasswordReset;
use IFComp::Form::EditAccount;

sub register :Path('register') :Args(0) {
    my ( $self, $c ) = @_;

    my $form = IFComp::Form::Register->new( {
        schema => $c->model( 'IFCompDB' )->schema,
    } );

    $c->stash(
        form => $form,
        template => 'user/register.tt',
    );

    if ( $form->process( params => $c->req->parameters ) ) {

        my $new_user = $c->model( 'IFCompDB::User' )->create( {
            email => $form->field( 'email' )->value,
            name  => $form->field( 'name' )->value,
            password => $form->field( 'password' )->value,
            password_needs_hashing => 1,
        } );

        $new_user->send_validation_email;

        $c->stash(
            template => 'user/registered.tt',
            user     => $new_user,
        );

    }
}

sub validate :Path('validate') :Args(2) {
    my $self = shift;
    my ( $c, $user_id, $access_token ) = @_;

    my $user = $c->model( 'IFCompDB::User' )->find( $user_id );

    if ( $user && $user->validate_token( $access_token ) ) {
        $c->stash->{ template } = 'user/verified.tt';
    }
    else {
        $self->_handle_bad_access_token( $c );
    }
}

sub request_password_reset :Path('request_password_reset') :Args(0) {
    my $self = shift;
    my ( $c ) = @_;

    my $form = IFComp::Form::RequestPasswordReset->new( {
        schema => $c->model( 'IFCompDB' )->schema,
    } );

    $c->stash(
        form => $form,
        template => 'user/request_password_reset.tt',
    );

    if ( $form->process( params => $c->req->parameters ) ) {
        my $user = $c->model( 'IFCompDB::User' )
                     ->search( { email => $form->field( 'email' )->value } )
                     ->single;
        $c->stash->{ template } = 'user/requested_password_reset.tt';
        $c->stash->{ user } = $user;

        $user->send_password_reset_email;
    }
}

sub reset_password :Path('reset_password') :Args(2) {
    my $self = shift;
    my ( $c, $user_id, $access_token ) = @_;

    my $user = $c->model( 'IFCompDB::User' )->find( $user_id );

    unless ( $user
             && $user->access_token
             && $user->access_token eq $access_token ) {
        $self->_handle_bad_access_token( $c );
        return;
    }

    my $form = IFComp::Form::ResetPassword->new( {
        schema => $c->model( 'IFCompDB' )->schema,
    } );

    $c->stash(
        form => $form,
        template => 'user/reset_password.tt',
        user => $user,
    );

    if ( $form->process( params => $c->req->parameters ) ) {
        if ( $user && $user->validate_token( $access_token ) ) {
            $user->password(
                $user->hash_password( $form->field( 'password' )->value )
            );
            $user->update;
            $c->stash->{ template } = 'user/password_has_been_reset.tt';
        }
        else {
            $self->_handle_bad_access_token( $c );
        }
    }

}

sub _handle_bad_access_token {
    my $self = shift;
    my ( $c ) = @_;

    $c->flash->{ bad_access_token } = 1;
    $c->res->redirect( '/' );
}

sub edit_account :Path('edit_account') {
    my $self = shift;
    my ( $c ) = @_;

    unless ( $c->user ) {
        $c->res->redirect( '/auth/login' );
    }

    my $user = $c->user->get_object;
    my $form = IFComp::Form::EditAccount->new( {
        user   => $user,
    } );

    $c->stash(
        form => $form,
        template => 'user/edit_account.tt',
    );

    if ( $form->process( params => $c->req->parameters, item => $user ) ) {
        $c->stash->{ edit_successful } = 1;
        $user->password(
            $user->hash_password( $form->field( 'password' )->value )
        );
        $user->update;
    }

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
