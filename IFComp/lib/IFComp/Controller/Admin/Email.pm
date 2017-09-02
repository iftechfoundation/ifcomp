package IFComp::Controller::Admin::Email;
use Moose;
use namespace::autoclean;

use List::Util qw(none);

BEGIN { extends 'Catalyst::Controller'; }

sub index : Chained("/admin/root") : PathPart('email') : Args(0) {
    my ( $self, $c, ) = @_;

    my $comp = $c->model('IFCompDB::Comp')->current_comp;

    my @emails = _get_emails( $c, $comp, 0 );

    my @disqualified_emails = _get_emails( $c, $comp, 1 );

    # The "anti-email" list is all holders of disqualified games that
    # don't also hold qualified games.
    my @anti_emails = grep {
        my $dq_email = $_;
        none { $_ eq $dq_email } @emails;
    } @disqualified_emails;

    $c->stash(
        emails => \@emails,
        anti_emails => \@anti_emails,
    );

}

sub _get_emails {
    my ($c, $comp, $is_disqualified) = @_;
    my @emails = $c->model( 'IFCompDB::User' )->search(
        {
            'entries.comp' => $comp->id,
            'entries.is_disqualified' => $is_disqualified,
        },
        {
            join => 'entries',
            group_by => 'email',
            order_by => 'email',
        },
    )->get_column( 'email' )->all;

    return @emails;
    die "Got this: @emails";
}

__PACKAGE__->meta->make_immutable;

1;
