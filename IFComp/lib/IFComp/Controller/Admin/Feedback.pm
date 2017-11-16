package IFComp::Controller::Admin::Feedback;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

sub index : Chained('/admin/root') : PathPart( 'feedback') : Args(0) {
    my ( $self, $c ) = @_;

    unless ( $c->user && $c->check_any_user_role('curator') ) {
        $c->res->redirect('/');
        return;
    }

    my $current_comp = $c->model('IFCompDB::Comp')->current_comp;

    my $feedback_rs = $c->model('IFCompDB::Feedback')->search(
        {   comp => $current_comp->id,
            text => { '!=', undef },
        },
        {   join     => [ 'entry', 'judge' ],
            order_by => [ 'name',  'title' ],
        }
    );

    $c->stash->{feedback_rs} = $feedback_rs;
    $c->stash->{template}    = "admin/feedback/index.tt";

}

__PACKAGE__->meta->make_immutable;

1;
