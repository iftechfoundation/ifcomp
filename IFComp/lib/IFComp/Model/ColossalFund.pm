package IFComp::Model::ColossalFund;
use Moose;
use namespace::autoclean;

use Path::Class::File;

extends 'Catalyst::Model::Factory';

__PACKAGE__->config( class => 'IFComp::ColossalFund', );

sub prepare_arguments {
    my ( $self, $c ) = @_;

    return {
        data_directory => Path::Class::Dir->new(
            $c->path_to('/root/lib/data/colossal_fund')
        )
    };
}

__PACKAGE__->meta->make_immutable;

1;
