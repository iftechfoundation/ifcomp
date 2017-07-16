#<<<
use utf8;
package IFComp::Schema::Result::Transcript;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

IFComp::Schema::Result::Transcript

=cut

use strict;
use warnings;


=head1 BASE CLASS: L<IFComp::Schema::Result>

=cut

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'IFComp::Schema::Result';

=head1 TABLE: C<transcripts>

=cut

__PACKAGE__->table("transcripts");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 session

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 timestamp

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 output

  data_type: 'text'
  is_nullable: 0

=head2 input

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 inputcount

  data_type: 'integer'
  is_nullable: 0

=head2 outputcount

  data_type: 'integer'
  is_nullable: 0

=head2 window

  data_type: 'integer'
  is_nullable: 0

=head2 styles

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 entry

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "session",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "timestamp",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
  "output",
  { data_type => "text", is_nullable => 0 },
  "input",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "inputcount",
  { data_type => "integer", is_nullable => 0 },
  "outputcount",
  { data_type => "integer", is_nullable => 0 },
  "window",
  { data_type => "integer", is_nullable => 0 },
  "styles",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "entry",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 entry

Type: belongs_to

Related object: L<IFComp::Schema::Result::Entry>

=cut

__PACKAGE__->belongs_to(
  "entry",
  "IFComp::Schema::Result::Entry",
  { id => "entry" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "RESTRICT",
    on_update     => "RESTRICT",
  },
);

#>>>

# Created by DBIx::Class::Schema::Loader v0.07047 @ 2017-07-05 11:06:47
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:E30c3Lpisp0OsRzyEj09BA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
