package IFComp::Controller::Profile;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

use JSON::Any;

=head1 NAME

IFComp::Controller::Profile - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) 
{
    my ( $self, $c ) = @_;

    $c->response->body('Matched IFComp::Controller::Profile in Profile.');
}


=head2 auth.php

You read that correctly.  This is the endpoint that supports legacy federated logins.

=cut

sub auth :Path('auth.php')
{
    my ( $self, $c ) = @_;
    my %supported_actions = (
                             "login" => \&auth_login,
                             "verfiy" => \&auth_verify,
                             "logout" => \&auth_logout,
                            );
    my $type = $c->request->param("type");

    my $data;
    if (exists $supported_actions{$type})
    {
        # FIXME:  Try block is propagating exception
        try 
        { 
            $data = $supported_actions{$type}->($self, $c) 
        }
        catch 
        {
            $data = {
                error_code => "ERROR",
                error_text => $@,
            };
        }

    }
    else
    {
        $data = {
            error_code => "UNKNOWN ACTION",
            error_text => "Do not know how to '$type'",
        };
    }

    $c->response->content_type("application/json");
    $c->response->body(encode_json($data));
}

sub auth_login
{
    my ($self, $c) = @_;
    die("NYI\n");
}

sub auth_verify
{
    my ($self, $c) = @_;
    die("NYI\n");
}

sub auth_logout
{
    my ($self, $c) = @_;
    die("NYI\n");
}

=encoding utf8

=head1 AUTHOR

Joe Johnston,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
