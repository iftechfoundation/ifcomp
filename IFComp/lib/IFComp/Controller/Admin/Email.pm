package IFComp::Controller::Admin::Email;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

sub index : Chained("/admin/root") : PathPart('email') : Args(0) {
    my ( $self, $c, ) = @_;

    my $comp = $c->model('IFCompDB::Comp')->current_comp;

    my @emails        = $comp->emails;
    my @forum_handles = $comp->forum_handles;

    $c->stash( emails => \@emails, forum_handles => \@forum_handles );

}

__PACKAGE__->meta->make_immutable;

1;
