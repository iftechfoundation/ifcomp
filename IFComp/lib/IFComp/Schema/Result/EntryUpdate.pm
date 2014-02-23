use utf8;
package IFComp::Schema::Result::EntryUpdate;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

IFComp::Schema::Result::EntryUpdate

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

=head1 TABLE: C<entry_update>

=cut

__PACKAGE__->table("entry_update");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 entry

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 note

  data_type: 'text'
  is_nullable: 0

=head2 time

  data_type: 'datetime'
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
  "entry",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "note",
  { data_type => "text", is_nullable => 0 },
  "time",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
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

=head2 entry

Type: belongs_to

Related object: L<IFComp::Schema::Result::Entry>

=cut

__PACKAGE__->belongs_to(
  "entry",
  "IFComp::Schema::Result::Entry",
  { id => "entry" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2014-02-23 16:14:35
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:FyfVsVjb9q5+0uEiKpAtLQ
# These lines were loaded from '/home/jjohn/perl5/perlbrew/perls/perl-5.18.2/lib/site_perl/5.18.2/IFComp/Schema/Result/EntryUpdate.pm' found in @INC.
# They are now part of the custom portion of this file
# for you to hand-edit.  If you do not either delete
# this section or remove that file from @INC, this section
# will be repeated redundantly when you re-create this
# file again via Loader!  See skip_load_external to disable
# this feature.

use utf8;
package IFComp::Schema::Result::EntryUpdate;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

IFComp::Schema::Result::EntryUpdate

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

=head1 TABLE: C<entry_update>

=cut

__PACKAGE__->table("entry_update");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 entry

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 note

  data_type: 'text'
  is_nullable: 0

=head2 time

  data_type: 'datetime'
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
  "entry",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "note",
  { data_type => "text", is_nullable => 0 },
  "time",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
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

=head2 entry

Type: belongs_to

Related object: L<IFComp::Schema::Result::Entry>

=cut

__PACKAGE__->belongs_to(
  "entry",
  "IFComp::Schema::Result::Entry",
  { id => "entry" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2014-02-15 21:09:47
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:g7hIWXEoB3oO8CiLcvUVmw
# These lines were loaded from '/home/jjohn/perl5/perlbrew/perls/perl-5.18.2/lib/site_perl/5.18.2/IFComp/Schema/Result/EntryUpdate.pm' found in @INC.
# They are now part of the custom portion of this file
# for you to hand-edit.  If you do not either delete
# this section or remove that file from @INC, this section
# will be repeated redundantly when you re-create this
# file again via Loader!  See skip_load_external to disable
# this feature.

use utf8;
package IFComp::Schema::Result::EntryUpdate;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

IFComp::Schema::Result::EntryUpdate

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

=head1 TABLE: C<entry_update>

=cut

__PACKAGE__->table("entry_update");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 entry

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 note

  data_type: 'text'
  is_nullable: 0

=head2 time

  data_type: 'datetime'
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
  "entry",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "note",
  { data_type => "text", is_nullable => 0 },
  "time",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
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

=head2 entry

Type: belongs_to

Related object: L<IFComp::Schema::Result::Entry>

=cut

__PACKAGE__->belongs_to(
  "entry",
  "IFComp::Schema::Result::Entry",
  { id => "entry" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2014-01-15 17:49:13
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:EN8nlkSfWA+2HVoMSm1HGQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
# End of lines loaded from '/home/jjohn/perl5/perlbrew/perls/perl-5.18.2/lib/site_perl/5.18.2/IFComp/Schema/Result/EntryUpdate.pm' 


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
# End of lines loaded from '/home/jjohn/perl5/perlbrew/perls/perl-5.18.2/lib/site_perl/5.18.2/IFComp/Schema/Result/EntryUpdate.pm' 


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
