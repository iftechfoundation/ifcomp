package IFComp::Controller::Root;
use Moose;
use namespace::autoclean;
use MIME::Base64;
use Crypt::Eksblowfish::Blowfish;

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

sub restricted : Path('restricted') : Args(0) {
    my ( $self, $c ) = @_;

    $c->stash->{template} = 'restricted.tt';
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

    $self->_set_userid_cookie($c) if $c->user;
}

=head2 error_404

Sends a 404 response, and displays a friendly file-not-found page.

=cut

sub error_404 : Private {
    my ( $self, $c ) = @_;

    $c->response->status(404);
    $c->stash( template => 'error_404.tt' );
}

=head2 error_403

Sends a 403 Forbidden response, and displays a stern permission denied page

=cut

sub error_403 : Private {
    my ( $self, $c ) = @_;

    $c->response->status(403);
    $c->stash( template => 'error_403.tt' );
}

# _set_userid_cookie: If the current user is authenticated, give them an
# additional identity cookie that works across all our subdomains. This is
# useful in certain circumstances for author- or role-locked game access.
sub _set_userid_cookie {
    my ( $self, $c ) = @_;

    return unless $c->user;

    my $key = $c->config->{user_id_cookie_key};

    unless ( defined $key ) {
        $c->log->warn(
            'No user_id_cookie_key configured! I will not set a userid cookie.'
        );
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

=head1 AUTHOR

Jason McIntosh



=cut

__PACKAGE__->meta->make_immutable;

1;
