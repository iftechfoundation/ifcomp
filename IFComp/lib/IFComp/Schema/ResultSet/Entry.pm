package IFComp::Schema::ResultSet::Entry;

use Data::Dumper;

use Moose;
extends 'DBIx::Class::ResultSet';

#XXX I am not sure this is entirely right.  Needs review
sub get_ms_c_winners {
    my ($self, $comp_id) = @_;
    return unless $comp_id;

    my $db = $self->result_source->schema;
    $db->storage->debug(1);
    my $comp_entries = $db->resultset("Entry")->search({ comp => $comp_id }); # authors in this comp
    my $author_vote = $db->resultset("Vote")->search({
                                                      'entry.is_disqualified' => 0,
                                                      'entry.comp' => $comp_id, # votes in this comp
                                                      'me.user' => { -in => $comp_entries->get_column('author')->as_query },
                                                     },
                                                     {
                                                      join => 'entry',
                                                      select => [ 'entry.id', { count => 'me.id' }, { avg => 'me.score' } ],
                                                      as => [ 'entry_id', 'vote_count', 'average_score' ],
                                                      group_by => [ 'entry.id' ],
                                                      order_by => { -desc => [ 'average_score' ] }
                                                     }
                                                   );
    warn(Dumper(map { [ $_->get_column("entry_id") => { cnt => $_->get_column("vote_count"), avg_score => $_->get_column("average_score")} ] } $author_vote->all));

    $db->storage->debug(0);

    my @tops;
    for my $rs ($author_vote->all) {
        my $entry = $db->resultset("Entry")->find($rs->get_column("entry_id"));
        $entry->average_score($rs->get_column("average_score")); # safe to override?
        push @tops, $entry;
        last if @tops == 3;
    }

    return @tops;
}

1;
