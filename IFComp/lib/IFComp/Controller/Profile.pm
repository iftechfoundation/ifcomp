package IFComp::Controller::Profile;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

use JSON::Any;
use MIME::Base64;

use Readonly;
Readonly my $DEFAULT_SITE => 'ifcomp.org';

=head1 NAME

IFComp::Controller::Profile - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 auth.php

You read that correctly.  This is the endpoint that supports legacy federated logins.

=cut

sub auth : Path('auth.php') {
    my ( $self, $c ) = @_;
    my %supported_actions = (
        "login"  => \&auth_login,
        "verify" => \&auth_verify,
        "logout" => \&auth_logout,
    );
    my $type = $c->request->param("type");

    my $data;
    if ( exists $supported_actions{$type} ) {
        $data = $supported_actions{$type}->( $self, $c );
    }
    else {
        $data = {
            error_code => "UNKNOWN ACTION",
            error_text => "Do not know how to '$type'",
        };
    }

    $c->response->content_type("application/json");
    my $j = JSON::Any->new;
    $c->response->body( $j->encode($data) );
}

sub auth_check_token {
    my ( $self, $c ) = @_;
    my $token   = $c->req->param("token");
    my $user_id = $c->req->param("user_id");

    unless ( $token && $user_id ) {
        return;
    }

    $self->verify_request($c);

    my @tokens = $c->model("IFCompDB::AuthToken")->search(
        {   token => $token,
            user  => $user_id
        },
        { order_by => { -desc => "created" } },
    )->all;

    $c->log->debug(
        "Token is $token. User ID is $user_id. I found these: @tokens");

    return unless @tokens;

    if ( @tokens > 1 ) {

        # prune old tokens
        my $current_token = shift @tokens;
        for (@tokens) {
            $_->delete;
        }
    }

    return 1;
}

sub auth_login {
    my ( $self, $c ) = @_;

    my $email     = $c->req->param("email");
    my $password  = $c->req->param("password");
    my $client_id = $c->req->param("client_id") || "";

    $self->verify_request($c);

    unless ( $email && $password ) {
        return {
            error_code => "bad parameters",
            error_text => "Missing email and/or password",
        };
    }

    my @users =
        $c->model("IFCompDB::User")->search( { email => $email } )->all;
    unless (@users) {
        return {
            error_code => "bad password",
            error_text =>
                "The password passed in was invalid, or the account doesn't "
                . "exist"
        };
    }

    my $user = $users[0];
    unless ( $user->is_verified ) {
        return {
            error_code => "unverified",    # legacy
            error_text =>
                "The login was valid, but the account has not been verified",
        };
    }

    my %opts;
    if ( $client_id eq "ios_app_001" ) {
        $opts{override} = "rijndael-128";
    }

    $password = decode_base64($password);

    if ( $user->check_password($password) ) {
        $c->log->debug("Password check\n");
    }
    else {
        return {
            error_code => "bad password",    # legacy response
            error_text =>
                "The password passed in was invalid, or the account "
                . "doesn't exist",
        };
    }

    chomp( my $token_key = encode_base64( time() ^ $$ ) );

    # Delete old tokens for this user
    my @all =
        $c->model("IFCompDB::AuthToken")->search( { user => $user->id } )
        ->all;
    for (@all) {
        $_->delete;
    }

    my $token = $c->model("IFCompDB::AuthToken")->create(
        {   user    => $user->id,
            token   => $token_key,
            created => "CURRENT_TIMESTAMP",
        }
    );

    return {
        success => 1,
        user    => $user->get_api_fascade(),
    };
}

sub auth_verify {
    my ( $self, $c ) = @_;

    my $ret = {};
    if ( $self->auth_check_token($c) ) {
        my @users = $c->model("IFCompDB::User")
            ->search( { id => $c->req->param("user_id") } )->all();
        $ret = { success => 1, "user" => $users[0]->get_api_fascade };
    }
    else {
        $ret = {
            error_code => "bad token",
            error_text => "The token passed in was invalid"
        };
    }

    return $ret;
}

sub auth_logout {
    my ( $self, $c ) = @_;

    my $ret = {};
    if ( $self->auth_check_token($c) ) {
        my @users = $c->model("IFCompDB::User")
            ->search( { id => $c->req->param("user_id") } )->all();
        my @all =
            $c->model("IFCompDB::AuthToken")
            ->search( { user => $users[0]->id } )->all;
        for (@all) {
            $_->delete;
        }

        $ret = { success => 1 };
    }
    else {
        $ret = {
            "error_code" => "bad token",
            "error_text" => "The token passed in was invalid"
        };
    }
    return $ret;
}

sub check_password {
    my ( $self, $c, $user, $password ) = ( shift, shift, shift, shift );
    my %args = (
        override => undef,
        %{ $_[0] || {} }
    );

    unless ($password) {
        $c->log->debug("No password given\n");
        return;
    }

    my $hashing_method = $args{override} || 'rijndael-256';
    my $plaintext;
    if ( $hashing_method eq 'rijndael-256' ) {
        $plaintext = $self->decrypt_rijndael_256( $c, $password, $user );
    }
    elsif ( $hashing_method eq 'rijndael-128' ) {
        $c->log->debug("rijndael-128 not yet implemented");
        return;
    }
    else {
        $c->log->debug("Hashing method '$hashing_method' unknown");
        return;
    }

    return $user->check_password($plaintext);
}

sub verify_request {
    my ( $self, $c ) = @_;

    my $site_id = $c->req->param("site_id") || $DEFAULT_SITE;
    my @site =
        $c->model("IFCompDB::FederatedSite")->search( { name => $site_id } )
        ->all;
    unless ( $site[0] ) {
        die "No site '$site_id'\n";
    }

    my $site_key     = $site[0]->api_key;
    my $provided_key = $c->req->param("key") || "";

    unless ( $site_key eq $provided_key ) {
        die "Key mismatch\n";
    }
}

=encoding utf8

=head1 AUTHOR

Joe Johnston,,,



=cut

__PACKAGE__->meta->make_immutable;

1;
