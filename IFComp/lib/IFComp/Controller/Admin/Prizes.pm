package IFComp::Controller::Admin::Prizes;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

use IFComp::Form::UpdatePrize;

has 'prize_form' => (
    is => 'ro',
    isa => 'IFComp::Form::UpdatePrize',
    lazy_build => 1,
);

has 'prize' => (
    is => 'rw',
    isa => 'Maybe[IFComp::Schema::Result::Prize]',
);

sub root : Chained('/admin/root') : PathPart('prizes') : CaptureArgs(0) {
    my ( $self, $c ) = @_;

    unless ( $c->user && $c->check_any_user_role('prizemanager') ) {
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

    my $prize_list = $c->model('IFCompDB::Prize')->search(
        { comp => $comp->id, },
        { order_by => [ 'category' ] }
    );

    $c->stash(
        prize_form => $self->prize_form,
        prize_list => $prize_list,
        current_comp => $comp,
        template => 'admin/prizes/index.tt',
        year => $year
    );
}

sub index : Chained('root') : PathPart('list') : Args(0) {
}

sub create : Chained('root') : PathPart('create') : Args(0) {
    my ( $self, $c ) = @_;

    my %new_result_args = (
        comp => $c->stash->{current_comp},
    );

    $c->stash( prize =>
        $c->model('IFCompDB::Prize')->new_result( \%new_result_args ) );
    if ( $self->_process_prize_form($c) ) {
        # $c->res->redirect( $c->uri_for_action('/admin') );
    }
}

sub _build_prize_form {
    return IFComp::Form::UpdatePrize->new;
}

sub fetch_prize: Chained('root') : PathPart('') : CaptureArgs(1) {
    my ( $self, $c, $id ) = @_;

    my $prize = $c->model('IFCompDB::Prize')->find($id);
    if ( $prize ) {
        $c->stash->{prize} = $prize;
        $self->prize($prize);
    } else {
        $c->res->redirect('/');
    }
}

sub update : Chained('fetch_prize') : PathPart('update') : Args(0) {
    my ( $self, $c ) = @_;

    my $prize = $c->stash->{prize};
    my $prize_id = $prize->id;

    return $self->_process_prize_form($c);
}

sub _process_prize_form {
    my ( $self, $c ) = @_;

    $c->stash(
         form => $self->prize_form,
         template => 'admin/prizes/update.tt',
    );

    my $prize = $c->stash->{prize};

    if ( $self->prize_form->process( item => $prize, params => $c->req->params, ) ) {
        #  prizedit.category                   | av
        #  prizedit.donor                      | Cindy Sinful
        #  prizedit.donor_email                | cindy@example.com
        #  prizedit.location                   |
        #  prizedit.name                       | Pirated Copy of Infidel
        #  prizedit.notes                      |
        #  prizedit.ships_internationally      | 1
        #  prizedit.submit                     | Update Prize
        #  prizedit.url                        |

        $c->res->redirect( $c->uri_for_action('/admin/prizes/index') );
        return 1;
    }

    $c->stash->{prize_form} = $self->prize_form;
}

__PACKAGE__->meta->make_immutable;

1;
