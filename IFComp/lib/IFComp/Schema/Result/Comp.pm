#<<<
use utf8;
package IFComp::Schema::Result::Comp;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

IFComp::Schema::Result::Comp

=cut

use strict;
use warnings;


=head1 BASE CLASS: L<IFComp::Schema::Result>

=cut

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'IFComp::Schema::Result';

=head1 TABLE: C<comp>

=cut

__PACKAGE__->table("comp");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 year

  data_type: 'char'
  default_value: (empty string)
  is_nullable: 0
  size: 4

=head2 intents_open

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 intents_close

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 entries_due

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 judging_begins

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 judging_ends

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 comp_closes

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 organizer

  data_type: 'char'
  is_nullable: 0
  size: 64

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "year",
  { data_type => "char", default_value => "", is_nullable => 0, size => 4 },
  "intents_open",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
  "intents_close",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
  "entries_due",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
  "judging_begins",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
  "judging_ends",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
  "comp_closes",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
  "organizer",
  { data_type => "char", is_nullable => 0, size => 64 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<year>

=over 4

=item * L</year>

=back

=cut

__PACKAGE__->add_unique_constraint("year", ["year"]);

=head1 RELATIONS

=head2 entries

Type: has_many

Related object: L<IFComp::Schema::Result::Entry>

=cut

__PACKAGE__->has_many(
  "entries",
  "IFComp::Schema::Result::Entry",
  { "foreign.comp" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 prizes

Type: has_many

Related object: L<IFComp::Schema::Result::Prize>

=cut

__PACKAGE__->has_many(
  "prizes",
  "IFComp::Schema::Result::Prize",
  { "foreign.comp" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

#>>>

# Created by DBIx::Class::Schema::Loader v0.07049 @ 2021-05-26 01:36:50
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:h6mBFZDliFO37V+/lUkCOQ

use DateTime::Moonpig;
use Moose::Util::TypeConstraints;

enum 'CompStatus', [
    qw(
        not_begun
        accepting_intents
        closed_to_intents
        closed_to_entries
        open_for_judging
        processing_votes
        over
        )
];

has 'status' => (
    is         => 'ro',
    isa        => 'CompStatus',
    lazy_build => 1,
);

has 'winners' => (
    is         => 'ro',
    isa        => 'ArrayRef',
    lazy_build => 1,
);

sub _build_status {
    my $self = shift;

    my $now = DateTime::Moonpig->now( time_zone => 'local' );
    if ( $now < $self->intents_open ) {
        return 'not_begun';
    }
    elsif ( $now < $self->intents_close ) {
        return 'accepting_intents';
    }
    elsif ( $now < $self->entries_due ) {
        return 'closed_to_intents';
    }
    elsif ( $now < $self->judging_begins ) {
        return 'closed_to_entries';
    }
    elsif ( $now < $self->judging_ends ) {
        return 'open_for_judging';
    }
    elsif ( $now < $self->comp_closes ) {
        return 'processing_votes';
    }
    else {
        return 'over';
    }
}

sub _build_winners {
    my $self = shift;

    return [ $self->entries->search( { place => 1 } )->all ];
}

sub get_vote_counts_from_non_unique_ips {
    my ($self) = @_;

    my $db    = $self->result_source->schema;
    my $votes = $db->resultset("User")->search(
        { 'entry.comp' => $self->id, },
        {   join     => { 'votes' => 'entry' },
            'select' => [
                'me.id',
                { count => 'votes.id', '-as' => 'total_vote_count' },
                {   sum =>
                        'CASE WHEN votes.score = 10 OR votes.score = 1 THEN 1 ELSE 0 END',
                    '-as' => 'extreme_score_count'
                }
            ],
            as => [ 'me.id', 'total_vote_count', 'extreme_score_count' ],
            group_by => 'me.id',
        }
    );

    my $data = [
        map {
            {   user => $db->resultset("User")->find( $_->get_column("id") ),
                total_vote_count    => $_->get_column("total_vote_count"),
                extreme_score_count => $_->get_column("extreme_score_count")
            };
            }
            grep {
            (         $_->get_column("extreme_score_count")
                    / $_->get_column("total_vote_count") ) >= 0.5
                && $_->get_column("total_vote_count")
                > 5
            } $votes->all
    ];

    return $data;
}

sub emails {
    my $self = shift;

    my @emails = $self->result_source->schema->resultset('User')->search(
        {   'entries.comp'            => $self->id,
            'entries.is_disqualified' => 0,
        },
        {   join     => 'entries',
            group_by => 'me.email',
            order_by => 'me.email',
        },
    )->get_column('email')->all;

    return @emails;

}

sub forum_handles {
    my $self = shift;

    my @forum_handles =
        $self->result_source->schema->resultset('User')->search(
        {   'entries.comp'            => $self->id,
            'entries.is_disqualified' => 0,
            'forum_handle'            => { '!=', undef },
        },
        {   join     => 'entries',
            group_by => 'forum_handle',
            order_by => 'forum_handle',
        },
    )->get_column('forum_handle')->all;

    return @forum_handles;

}

__PACKAGE__->meta->make_immutable;
1;
