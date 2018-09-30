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

    my $year = $c->req->param('year');
    my $comp;
    if ($year) {
        $comp =
            $c->model('IFCompDB::Comp')->search( { year => $year } )->single;
    }
    else {
        $comp = $c->model('IFCompDB::Comp')->current_comp;
        $year = $comp->year;
    }

    my $feedback_rs = $c->model('IFCompDB::Feedback')->search(
        {   comp => $comp->id,
            text => { '!=', undef },
        },
        {   join     => [ 'entry', 'judge' ],
            order_by => [ 'name',  'title' ],
        }
    );

    my @comp_years = $c->model('IFCompDB::Comp')->get_column('year')->all;

    $c->stash(
        feedback_rs => $feedback_rs,
        template    => 'admin/feedback/index.tt',
        comp_years  => \@comp_years,
        year        => $year,
    );

}

__PACKAGE__->meta->make_immutable;

1;
