package IFComp::Controller::Admin::Email;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

sub index : Chained("/admin/root") : PathPart('email') : Args(0) {
    my ( $self, $c, ) = @_;

    my $comp = $c->model('IFCompDB::Comp')->current_comp;

    my $schema = $c->model('IFCompDB')->schema;
    my @emails = $schema->emails_for_comp( $comp );
    my @anti_emails = $schema->anti_emails_for_comp( $comp );

    $c->stash(
        emails      => \@emails,
        anti_emails => \@anti_emails,
    );

}

sub _get_emails {
    my ( $c, $comp, $is_disqualified ) = @_;
    my @emails = $c->model('IFCompDB::User')->search(
        {   'entries.comp'            => $comp->id,
            'entries.is_disqualified' => $is_disqualified,
        },
        {   join     => 'entries',
            group_by => 'email',
            order_by => 'email',
        },
    )->get_column('email')->all;

    return @emails;
}

__PACKAGE__->meta->make_immutable;

1;
