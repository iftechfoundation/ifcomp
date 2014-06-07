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

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 0

=head2 intents_close

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 0

=head2 entries_due

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 0

=head2 judging_begins

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 0

=head2 judging_ends

  data_type: 'date'
  datetime_undef_if_invalid: 1
  is_nullable: 0

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
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 0 },
  "intents_close",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 0 },
  "entries_due",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 0 },
  "judging_begins",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 0 },
  "judging_ends",
  { data_type => "date", datetime_undef_if_invalid => 1, is_nullable => 0 },
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


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2014-06-06 22:37:19
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:ebZT91k4+Fe5FTsBinTkKQ

use MooseX::Enumeration;
use Time::Zone;
use DateTime::Moonpig;
use Moose::Util::TypeConstraints;

enum 'CompStatus', [qw(
    not_begun
    accepting_intents
    closed_to_intents
    open_for_judging
    over
) ];

has 'status' => (
    is => 'ro',
    isa => 'CompStatus',
    traits => [ 'Enumeration' ],
    handles => [qw/
                    is_not_begun
                    is_accepting_intents
                    is_closed_to_intents
                    is_closed_to_entries
                    is_open_for_judging
                    is_over
                / ],

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
    else {
        return 'over';
    }
}

__PACKAGE__->meta->make_immutable;
1;
