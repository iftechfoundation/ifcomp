package IFComp::Controller::Profile;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

use JSON::Any;
use MIME::Base64;

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
                             "verify" => \&auth_verify,
                             "logout" => \&auth_logout,
                            );
    my $type = $c->request->param("type");

    my $data;
    if (exists $supported_actions{$type})
    {
        $data = $supported_actions{$type}->($self, $c) 
    }
    else
    {
        $data = {
            error_code => "UNKNOWN ACTION",
            error_text => "Do not know how to '$type'",
        };
    }

    $c->response->content_type("application/json");
    my $j = JSON::Any->new;
    $c->response->body($j->encode($data));
}

sub auth_login
{
    my ($self, $c) = @_;

    my $email     = $c->req->param("email");
    my $password  = $c->req->param("password");
    my $site_id   = $c->req->param("site_id") || 1;
    my $client_id = $c->req->param("client_id") || "";
    my $client_ip = $c->req->param("ip");

    # Look up site by name
    my $site = $c->model("IFCompDB::FederatedSite")->search({ name => $site_id});
    unless ($site)
    {
        return { 
            error_code => "UNKNOWN SITE",
            error_text => "Cannot find site '$site_id'",
        };
    }
    
    unless ($email && $password)
    {
        return { 
            error_code => "bad parameters",
            error_text => "Missing email and/or password",
        };
    }

    my @users = $c->model("IFCompDB::User")->search({ email => $email })->all;
    unless (@users)
    {
        return { 
            error_code => "bad password",
            error_text => "The password passed in was invalid, or the account doesn't exist"
        };
    }

    my $user = $users[0];
    unless ($user->is_verified)
    {
        return { 
            error_code => "unverified", # legacy
            error_text => "The login was valid, but the account has not been verified",
        };
    }

    my %opts;
    if ($client_id eq "ios_app_001")
    {
        $opts{override} = "rijndael-128";
    }

    if ($self->check_password($c, $user, $password, \%opts))
    {
        warn("Password check\n");
    }
    else
    {
        return { error_code => "bad password", # legacy response
                 error_text => "The password passed in was invalid, or the account doesn't exist",
        };
    }

    my $token = $c->model("IFCompDB::AuthToken")->create(
        {
            user_id => $user->id,
        });

    my $user_fascade = {
        email => $email,
        name => $user->name,
        token => $token->id,
    };

    return {
        success => 1,
        user => $user_fascade
    }
}

sub auth_verify
{
    my ($self, $c) = @_;

    return { error_code => "NYI", error_text => "NYI - verify"}
}

sub auth_logout
{
    my ($self, $c) = @_;
    return { error_code => "NYI", error_text => "NYI - logout"}
}

sub check_password
{
    my ($self, $c, $user, $password) = (shift, shift, shift, shift);
    my %args = (
                 override => undef,
                 %{$_[0] || {}}
               ); 

    unless ($password)
    {
        warn("No password given\n");
        return;
    }

    my $hashing_method = $args{override} || $user->site->hashing_method;
    my $plaintext;
    if ($hashing_method eq 'rijndael-256')
    {
        $plaintext = $self->decrypt_rijndael_256($c, $password, $user);
    }
    elsif ($hashing_method eq 'rijndael-128')
    {
        warn("rijndael-128 not yet implemented");
        return;
    }
    else
    {
        warn("Hashing method '$hashing_method' unknown");
        return;
    }

    return $user->hash_password($plaintext) eq $user->password;
}

sub encrypt_rijndael_256
{
    my ($self, $c, $plaintext, $user) = @_;

    my $crypt_bin = $c->config->path_to("script", "encrypt-rijndael-256.php")->stringify;
    unless (-e $crypt_bin)
    {
        warn("Cannot find '$crypt_bin'\n");
        return;
    }

    my $api_key = $user->site->api_key;
    my $cmd = qq[/usr/bin/php $crypt_bin $plaintext $api_key];
    my $hash = qx[$cmd];
    return $hash;
}

sub decrypt_rijndael_256
{
    my ($self, $c, $hash, $user) = @_;

    my $crypt_bin = $c->path_to("script", "decrypt-rijndael-256.php")->stringify;
    unless (-e $crypt_bin)
    {
        warn("Cannot find '$crypt_bin'\n");
        return;
    }

    my $api_key = $user->site->api_key;
    my $cmd = qq[/usr/bin/php $crypt_bin $hash $api_key];
#    warn("CMD: '$cmd'\n");
    my $plaintext = qx($cmd);
    return $plaintext;
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
