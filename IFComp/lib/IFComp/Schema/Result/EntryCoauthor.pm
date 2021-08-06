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

=head2 entry_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 1

=head2 coauthor_id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 1

=head2 pseudonym

  data_type: 'char'
  is_nullable: 1
  size: 128

=head2 reveal_pseudonym

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "entry_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "coauthor_id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 1,
  },
  "pseudonym",
  { data_type => "char", is_nullable => 1, size => 128 },
  "reveal_pseudonym",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
);

=head1 RELATIONS

=head2 coauthor

Type: belongs_to

Related object: L<IFComp::Schema::Result::User>

=cut

__PACKAGE__->belongs_to(
  "coauthor",
  "IFComp::Schema::Result::User",
  { id => "coauthor_id" },
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
  { id => "entry_id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "CASCADE",
    on_update     => "RESTRICT",
  },
);

#>>>

# Created by DBIx::Class::Schema::Loader v0.07049 @ 2021-06-25 01:48:38
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:2bqOVYRFncg/F2skd4eCmg

sub display_name {
    my $self = shift;

    if ( !$self->pseudonym ) {
        return $self->coauthor->name;
    }

    if (   $self->entry->comp->ok_to_reveal_pseudonyms
        && $self->reveal_pseudonym )
    {
        return
              $self->coauthor->name
            . " (writing as "
            . $self->pseudonym . ")";
    }

    return $self->pseudonym;
}

__PACKAGE__->meta->make_immutable;
1;
