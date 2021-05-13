#<<<
use utf8;
package IFComp::Schema::Result::EntryCoauthor;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

IFComp::Schema::Result::EntryCoauthor

=cut

use strict;
use warnings;


=head1 BASE CLASS: L<IFComp::Schema::Result>

=cut

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'IFComp::Schema::Result';

=head1 TABLE: C<entry_coauthor>

=cut

__PACKAGE__->table("entry_coauthor");

=head1 ACCESSORS

=head2 entry

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 1

=head2 coauthor

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "entry",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "coauthor",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
);

=head1 RELATIONS

=head2 coauthor

Type: belongs_to

Related object: L<IFComp::Schema::Result::User>

=cut

__PACKAGE__->belongs_to(
  "coauthor",
  "IFComp::Schema::Result::User",
  { id => "coauthor" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "RESTRICT",
    on_update     => "RESTRICT",
  },
);

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

# Created by DBIx::Class::Schema::Loader v0.07049 @ 2021-05-19 22:44:48
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:6Jkq5bN4TlegJOML9J5jbg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
