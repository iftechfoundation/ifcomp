package IFComp::Model::ColossalFund;
use Moose;
use namespace::autoclean;

extends 'Catalyst::Model::Adaptor';

__PACKAGE__->config(
    class => 'IFComp::ColossalFund',
);

sub prepare_arguments {
    my ( $self, $c ) = @_;

    return {
        data_directory => $c->path_to( '/root/lib/data/colossal_fund' )
    };
}

__PACKAGE__->meta->make_immutable;

1;
