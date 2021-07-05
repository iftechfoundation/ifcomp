package IFComp::Schema::Result::VoteFromQualifiedJudgeBallot;
use strict;
use warnings;
use base qw/DBIx::Class::Core/;

# This class provides a view onto the `vote` table that restricts results to
# non-entrants of a given competition, and also only to voters who have
# submitted at least five entries.
#
# To use it, you'll need to pass in a 'bind' attribute set to the comp id.
#
# For a usage example, see script/update_current_rating_tallies.

__PACKAGE__->table_class('DBIx::Class::ResultSource::View');

__PACKAGE__->table('judge_votes');

__PACKAGE__->add_columns(
    "id",
    {   data_type         => "integer",
        extra             => { unsigned => 1 },
        is_auto_increment => 1,
        is_nullable       => 0,
    },
    "user",
    {   data_type      => "integer",
        extra          => { unsigned => 1 },
        is_foreign_key => 1,
        is_nullable    => 0,
    },
    "score",
    { data_type => "tinyint", is_nullable => 0 },
    "entry",
    {   data_type      => "integer",
        extra          => { unsigned => 1 },
        is_foreign_key => 1,
        is_nullable    => 0,
    },
    "time",
    {   data_type                 => "datetime",
        datetime_undef_if_invalid => 1,
        is_nullable               => 1,
    },
    "ip",
    {   data_type     => "char",
        default_value => "",
        is_nullable   => 0,
        size          => 15
    },
);

__PACKAGE__->result_source_instance->is_virtual(1);

__PACKAGE__->result_source_instance->view_definition(
    q[
        select v.* from entry e, vote v
        where e.comp = ? and v.entry = e.id
            and v.user in (select user from vote, entry
                            where entry.id = vote.entry and entry.comp = ?
                            group by user having count(score) >= 5)
    ]
);

1;
