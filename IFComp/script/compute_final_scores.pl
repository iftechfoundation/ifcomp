#!/usr/env perl

# This script computes all qualifying entries' final scores and other information
# based on qualifying votes, and updates these entries' database records appropriately.

use warnings;
use strict;
use FindBin;
use Path::Class;

use lib "$FindBin::Bin/../lib";
use IFComp::Schema;

use Readonly;
Readonly my $MAX_MC_PLACE =>
    3;    # We care about Miss Congeniality only up to 3rd place.

my $schema = IFComp::Schema->connect( 'dbi:mysql:ifcomp', 'root', '' );
$schema->entry_directory( Path::Class::Dir->new("$FindBin::Bin/../entries") );

my $current_comp = $schema->resultset('Comp')->current_comp;

my $ifcomp_sql =
      "select entry.id as entry_id, round(avg(score), 2) as"
    . " average_score, round(std(score), 2) as standard_deviation, count(score) as "
    . " votes_cast, sum(score = 1) as total_1, sum(score = 2) as total_2, sum(score = 3) as total_3, sum(score = 4) as total_4, sum(score = 5) as total_5, sum(score = 6) as total_6, sum(score = 7) as total_7, sum(score = 8) as total_8, sum(score = 9) as total_9, sum(score = 10) as total_10"
    . " from ( select vote.* from vote left join entry on vote.user = entry.author and entry.comp = ?"
    . " where user in ( select user from vote, entry where entry.id = vote.entry and entry.comp = ?"
    . " group by user having count(score) >= 5 ) group by vote.id ) judge_vote, entry"
    . " where entry.id = judge_vote.entry and entry.comp = ? and entry.is_disqualified = 0"
    . " group by entry.id order by avg(score) desc;";
my $mc_sql =
    "select entry.id as entry_id, round(avg(score), 2) as average_score from"
    . " ( select distinct vote.* from vote, entry where"
    . " (vote.user = entry.author or vote.user in"
    . " (select user.id from entry,user,entry_coauthor eo where entry.comp = ? and eo.entry_id=entry.id and eo.coauthor_id=user.id) )"
    . " and entry.is_disqualified = 0 and entry.comp = ? ) judge_vote, entry"
    . " where entry.id = judge_vote.entry and entry.comp = ?"
    . " group by entry.id order by average_score desc;";

my $dbh = $schema->storage->dbh;

$dbh->do( 'update entry set place = NULL where comp = ?',
    {}, $current_comp->id );
$dbh->do( 'update entry set miss_congeniality_place = NULL where comp = ?',
    {}, $current_comp->id );

my $ifcomp_sth = $dbh->prepare($ifcomp_sql);
$ifcomp_sth->execute( $current_comp->id, $current_comp->id,
    $current_comp->id, );

my $current_place;
my $entry_count;
my $previous_average;
while ( my $row_ref = $ifcomp_sth->fetchrow_hashref ) {
    $entry_count++;
    my $entry = $schema->resultset('Entry')->find( $row_ref->{entry_id} );

    for my $field ( keys %$row_ref ) {
        if ( $entry->can($field) ) {
            $entry->$field( $row_ref->{$field} );
        }
    }

    if (   ( not defined $previous_average )
        || ( $previous_average > $row_ref->{average_score} ) )
    {
        $current_place = $entry_count;
    }
    $entry->place($current_place);
    $entry->update;

    $previous_average = $row_ref->{average_score};
}

my $mc_sth = $dbh->prepare($mc_sql);
$mc_sth->execute( $current_comp->id, $current_comp->id, $current_comp->id, );

undef $current_place;
undef $entry_count;
undef $previous_average;
while ( my $row_ref = $mc_sth->fetchrow_hashref ) {
    $entry_count++;
    my $entry = $schema->resultset('Entry')->find( $row_ref->{entry_id} );

    if (   ( not defined $previous_average )
        || ( $previous_average > $row_ref->{average_score} ) )
    {
        $current_place = $entry_count;
    }

    if ( $entry_count > $MAX_MC_PLACE ) {
        last;
    }
    else {
        $entry->miss_congeniality_place($current_place);
        $entry->update;
        $previous_average = $row_ref->{average_score};
    }
}
