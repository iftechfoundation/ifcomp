#<<<
use utf8;
package IFComp::Schema::Result::EntryAnswer;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

IFComp::Schema::Result::EntryAnswer

=cut

use strict;
use warnings;


=head1 BASE CLASS: L<IFComp::Schema::Result>

=cut

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'IFComp::Schema::Result';

=head1 TABLE: C<entry_answers>

=cut

__PACKAGE__->table("entry_answers");

=head1 ACCESSORS

=head2 entry_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 question_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 answer

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=cut

__PACKAGE__->add_columns(
  "entry_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "question_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "answer",
  { data_type => "varchar", is_nullable => 1, size => 255 },
);

=head1 PRIMARY KEY

=over 4

=item * L</entry_id>

=item * L</question_id>

=back

=cut

__PACKAGE__->set_primary_key("entry_id", "question_id");

=head1 RELATIONS

=head2 entry

Type: belongs_to

Related object: L<IFComp::Schema::Result::Entry>

=cut

__PACKAGE__->belongs_to(
  "entry",
  "IFComp::Schema::Result::Entry",
  { id => "entry_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "RESTRICT" },
);

=head2 question

Type: belongs_to

Related object: L<IFComp::Schema::Result::Question>

=cut

__PACKAGE__->belongs_to(
  "question",
  "IFComp::Schema::Result::Question",
  { id => "question_id" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);

#>>>

# Created by DBIx::Class::Schema::Loader v0.07053 @ 2026-06-16 20:51:39
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:zfm0Hfg8Ac4nMJbK/YwfTg

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
