package IFComp::Controller::Admin::Voting;
use Moose;
use namespace::autoclean;
use Data::Dumper;
use JSON;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

IFComp::Controller::Admin::Voting

=head1 DESCRIPTION

A controller for voting reports.

=head1 METHODS

=cut

=head2 index

=cut

sub index : Chained('/admin') : Path : Args(0) {
    my ( $self, $c ) = @_;

    # Must have a votecounter
    my @user_roles       = $c->user->user_roles;
    my $votecounter_role = 'votecounter';
    my $has_votecounter_role =
        grep { $_->role->name eq $votecounter_role } @user_roles;

    unless ($has_votecounter_role) {
        $c->log->warn(
            sprintf(
                "User %s does not have role %s",
                $c->user->name, $votecounter_role
            )
        );
        $c->res->redirect('/');
        return;
    }

    my $comp  = $c->model('IFCompDB::Comp');
    my $entry = $c->model('IFCompDB::Entry');
    my $vote  = $c->model('IFCompDB::Vote');
    my $user  = $c->model('IFCompDB::User');

    my $current_comp;
    if ( my $id = $c->req->param("comp_id") ) {
        $current_comp = $comp->find($id);
    }
    else {
        $current_comp = $comp->current_comp;
    }

    $c->stash->{current_comp} = $current_comp;
    my @available_comps =
        $comp->search( { year => { '>=' => 2014 }, }, { order_by => 'year' } )
        ->all;

    $c->stash->{available_comps} = \@available_comps;

    # Get all entries for this comp
    my @all_entries =
        grep { $_->is_qualified }
        $entry->search( { comp => $current_comp->id, },
        { order_by => { -desc => "average_score" } } )->all;
    my @entry_ids = map { $_->id } @all_entries;

    my ( @ips, @users );
    my @votes = $vote->search(
        { entry => \@entry_ids },
        {   select   => [ 'user', { 'count' => 'me.id', -as => 'cnt' } ],
            as       => [ 'user', 'cnt' ],
            group_by => ['user'],
            order_by => { -desc => ['cnt'] },
        },
    );
    my $seen = 0;
    for my $vote (@votes) {
        my ( $user_id, $cnt ) =
            ( $vote->get_column('user'), $vote->get_column('cnt') );
        push @users, [ $user->find($user_id), $cnt ];
        last if ++$seen > 4;
    }

    @votes = $vote->search(
        { entry => \@entry_ids },
        {   select   => [ 'ip', { 'count' => 'me.id', -as => 'cnt' } ],
            as       => [ 'ip', 'cnt' ],
            group_by => ['ip'],
            order_by => { -desc => ['cnt'] },
        },
    );
    $seen = 0;
    for my $vote (@votes) {
        my ( $ip, $cnt ) =
            ( $vote->get_column('ip'), $vote->get_column('cnt') );
        push @ips, [ $ip, $cnt ];
        last if ++$seen > 4;
    }

    my $total_votes  = 0;
    my $total_scores = 0;
    my (@score_buckets);
    for my $entry (@all_entries) {
        $total_votes  += $entry->votes_cast    || 0;
        $total_scores += $entry->average_score || 0;

        for my $i ( 1 .. 10 ) {
            my $method = "total_$i";
            $score_buckets[$i] += $entry->$method || 0;
        }
    }

    shift @score_buckets;    # remove first entry, for it is null
    my $score_buckets_json = JSON::to_json( \@score_buckets );

    $c->stash->{entries}     = \@all_entries;
    $c->stash->{template}    = "admin/voting/index.tt";
    $c->stash->{total_votes} = $total_votes;
    if (@all_entries) {
        $c->stash->{average_score} =
            sprintf( "%0.2f", ( $total_scores / scalar @all_entries ) );
    }
    else {
        $c->stash->{average_score} = 0;
    }

    $c->stash->{score_buckets_json} = $score_buckets_json;
    $c->stash->{ips}                = \@ips;
    $c->stash->{users}              = \@users;
}

# /admin/voting/:entry_id
sub show_entry : Chained("/admin/voting") : Path : Args(1) {
    my ( $self, $c, $entry_id ) = @_;

    my $entry      = $c->model('IFCompDB::Entry');
    my $this_entry = $entry->find($entry_id);
    my @score_buckets;

    for my $vote ( $this_entry->votes ) {
        $score_buckets[ $vote->score - 1 ] += 1;
    }

    $c->stash->{entry}              = $this_entry;
    $c->stash->{score_buckets_json} = JSON::to_json( \@score_buckets );
    $c->stash->{template}           = "admin/voting/show_entry.tt";
}

=encoding utf8

=head1 AUTHOR

Joe Johnston



=cut

__PACKAGE__->meta->make_immutable;

1;
