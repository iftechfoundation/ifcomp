use utf8;
package IFComp::Schema::Result::Comp;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

IFComp::Schema::Result::Comp

=cut

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime");

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
  default_value: (empty string)
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
  { data_type => "char", default_value => "", is_nullable => 0, size => 64 },
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


# Created by DBIx::Class::Schema::Loader v0.07043 @ 2015-12-27 04:55:28
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:IYAhuBMI6CH5OD4iCQrx+w

use DateTime::Moonpig;
use Moose::Util::TypeConstraints;

enum 'CompStatus', [qw(
    not_begun
    accepting_intents
    closed_to_intents
    closed_to_entries
    open_for_judging
    processing_votes
    over
) ];

has 'status' => (
    is => 'ro',
    isa => 'CompStatus',
    lazy_build => 1,
);

has 'winners' => (
    is => 'ro',
    isa => 'ArrayRef',
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

# A shill is a voter who casts many extreme votes (10s or 1s) for the
# current comp
use Data::Dumper;
sub get_possible_shills {
    my ($self) = @_;

    my $db = $self->result_source->schema;
    $db->storage->debug(0);
    my $votes = $db->resultset("User")->search({
                                                'entry.comp' => $self->id,
                                               },
                                               {
                                                join => { 'votes' => 'entry' },
                                                'select' => [
                                                             'me.id',
                                                             { count => 'votes.id', '-as' => 'total_vote_count' },
                                                             { sum => 'CASE WHEN votes.score = 10 OR votes.score = 1 THEN 1 ELSE 0 END', '-as' => 'extreme_score_count'}
                                                            ],
                                                as => [ 'me.id', 'total_vote_count', 'extreme_score_count'],
                                                group_by => 'me.id',
                                               }
                                              );

    # Shills have voted a lot (> 5 times) and they have extreme votes
    my $data = [
                map {
                      {
                          user => $db->resultset("User")->find($_->get_column("id")),
                          total_vote_count => $_->get_column("total_vote_count"),
                          extreme_score_count => $_->get_column("extreme_score_count")
                      };
                }
        grep {
               ($_->get_column("extreme_score_count") / $_->get_column("total_vote_count")) >= 0.5
                && $_->get_column("total_vote_count") > 5
             } $votes->all ];

    $db->storage->debug(0);
    return $data;
}

sub get_vote_counts_from_non_unique_ips {
    my ($self) = @_;

    my $db = $self->result_source->schema;
    $db->storage->debug(0);
    my $votes = $db->resultset("User")->search({
                                                'entry.comp' => $self->id,
                                               },
                                               {
                                                join => { 'votes' => 'entry' },
                                                'select' => [
                                                             'me.id',
                                                             { count => 'votes.id', '-as' => 'total_vote_count' },
                                                             { sum => 'CASE WHEN votes.score = 10 OR votes.score = 1 THEN 1 ELSE 0 END', '-as' => 'extreme_score_count'}
                                                            ],
                                                as => [ 'me.id', 'total_vote_count', 'extreme_score_count'],
                                                group_by => 'me.id',
                                               }
                                              );

    # Shills have voted a lot (> 5 times) and they have extreme votes
    my $data = [
                map {
                      {
                          user => $db->resultset("User")->find($_->get_column("id")),
                          total_vote_count => $_->get_column("total_vote_count"),
                          extreme_score_count => $_->get_column("extreme_score_count")
                      };
                }
        grep {
               ($_->get_column("extreme_score_count") / $_->get_column("total_vote_count")) >= 0.5
                && $_->get_column("total_vote_count") > 5
             } $votes->all ];

    $db->storage->debug(0);
    return $data;
}

__PACKAGE__->meta->make_immutable;
1;
