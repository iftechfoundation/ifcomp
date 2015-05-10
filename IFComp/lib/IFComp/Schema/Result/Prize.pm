use utf8;
package IFComp::Schema::Result::Prize;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

IFComp::Schema::Result::Prize

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

=head1 TABLE: C<prize>

=cut

__PACKAGE__->table("prize");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 comp

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 donor

  data_type: 'char'
  default_value: (empty string)
  is_nullable: 0
  size: 64

=head2 donor_email

  data_type: 'char'
  default_value: (empty string)
  is_nullable: 0
  size: 64

=head2 name

  data_type: 'char'
  default_value: (empty string)
  is_nullable: 0
  size: 128

=head2 notes

  data_type: 'text'
  is_nullable: 1

=head2 entry

  data_type: 'integer'
  extra: {unsigned => 1}
  is_nullable: 1

=head2 url

  data_type: 'char'
  is_nullable: 1
  size: 128

=head2 category

  data_type: 'enum'
  default_value: 'misc'
  extra: {list => ["money","expertise","food","apparel","games","hardware","software","books","av","misc","special"]}
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
  "comp",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "donor",
  { data_type => "char", default_value => "", is_nullable => 0, size => 64 },
  "donor_email",
  { data_type => "char", default_value => "", is_nullable => 0, size => 64 },
  "name",
  { data_type => "char", default_value => "", is_nullable => 0, size => 128 },
  "notes",
  { data_type => "text", is_nullable => 1 },
  "entry",
  { data_type => "integer", extra => { unsigned => 1 }, is_nullable => 1 },
  "url",
  { data_type => "char", is_nullable => 1, size => 128 },
  "category",
  {
    data_type => "enum",
    default_value => "misc",
    extra => {
      list => [
        "money",
        "expertise",
        "food",
        "apparel",
        "games",
        "hardware",
        "software",
        "books",
        "av",
        "misc",
        "special",
      ],
    },
    is_nullable => 0,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 comp

Type: belongs_to

Related object: L<IFComp::Schema::Result::Comp>

=cut

__PACKAGE__->belongs_to(
  "comp",
  "IFComp::Schema::Result::Comp",
  { id => "comp" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2014-11-16 12:20:29
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:9csXK597UhtDcutnd2ckYw
# These lines were loaded from '/home/jjohn/perl5/perlbrew/perls/perl-5.18.2/lib/site_perl/5.18.2/IFComp/Schema/Result/Prize.pm' found in @INC.
# They are now part of the custom portion of this file
# for you to hand-edit.  If you do not either delete
# this section or remove that file from @INC, this section
# will be repeated redundantly when you re-create this
# file again via Loader!  See skip_load_external to disable
# this feature.

# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
