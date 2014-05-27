package IFComp::UserStore;

use Moose;
use namespace::autoclean;
extends 'Catalyst::Authentication::Store::DBIx::Class::User';

use Digest::MD5 qw( md5_hex );

sub check_password {
    my $self = shift;
    my ( $password ) = @_;
    my $user = $self->get_object;
    if ( $user->verified ) {
        my $hashed = $user->hash_password( $password );
        my $stored = $user->password;

        return $stored eq $hashed;
    }
    else {
        return 0;
    }
}

1;
