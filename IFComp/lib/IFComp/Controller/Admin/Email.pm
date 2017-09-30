package IFComp::Controller::Admin::Email;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

sub index : Chained("/admin/root") : PathPart('email') : Args(0) {
    my ( $self, $c, ) = @_;

    my $comp = $c->model('IFCompDB::Comp')->current_comp;

    my @emails = $comp->emails;

    $c->stash( emails => \@emails, );

}

__PACKAGE__->meta->make_immutable;

1;
