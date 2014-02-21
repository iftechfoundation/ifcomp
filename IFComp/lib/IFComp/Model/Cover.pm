package IFComp::Model::Cover;

use strict;
use base 'Catalyst::Model';

use File::Spec;

__PACKAGE__->config(
    cover_dir => 'root/static/images/covers'
);

sub exists_for_ifdb_id {
    my ( $self, $ifdb_id ) = @_;

    my $path = File::Spec->catfile( $self->config->{ cover_dir }, $ifdb_id );

    return -e $path;
}

1;
