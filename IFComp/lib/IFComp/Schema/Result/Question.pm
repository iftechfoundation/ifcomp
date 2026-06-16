#<<<
use utf8;
package IFComp::Schema::Result::Question;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

IFComp::Schema::Result::Question

=cut

use strict;
use warnings;


=head1 BASE CLASS: L<IFComp::Schema::Result>

=cut

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'IFComp::Schema::Result';

=head1 TABLE: C<questions>

=cut

__PACKAGE__->table("questions");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 question_text

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 disabled

  data_type: 'tinyint'
  default_value: 1
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "question_text",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "disabled",
  { data_type => "tinyint", default_value => 1, is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 entry_answers

Type: has_many

Related object: L<IFComp::Schema::Result::EntryAnswer>

=cut

__PACKAGE__->has_many(
  "entry_answers",
  "IFComp::Schema::Result::EntryAnswer",
  { "foreign.question_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

#>>>

# Created by DBIx::Class::Schema::Loader v0.07053 @ 2026-06-16 19:53:01
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:zRSkaJHmZmFhsF+2NtgpTg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
