use utf8;
package IFComp::Schema::Result::User;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

IFComp::Schema::Result::User

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

=head1 TABLE: C<user>

=cut

__PACKAGE__->table("user");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 name

  data_type: 'char'
  default_value: (empty string)
  is_nullable: 0
  size: 64

=head2 password

  data_type: 'char'
  default_value: (empty string)
  is_nullable: 0
  size: 64

=head2 salt

  data_type: 'char'
  default_value: (empty string)
  is_nullable: 0
  size: 64

=head2 email

  data_type: 'char'
  default_value: (empty string)
  is_nullable: 0
  size: 64

=head2 email_is_public

  data_type: 'tinyint'
  default_value: 1
  is_nullable: 0

=head2 url

  data_type: 'char'
  is_nullable: 1
  size: 128

=head2 twitter

  data_type: 'char'
  is_nullable: 1
  size: 32

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "name",
  { data_type => "char", default_value => "", is_nullable => 0, size => 64 },
  "password",
  { data_type => "char", default_value => "", is_nullable => 0, size => 64 },
  "salt",
  { data_type => "char", default_value => "", is_nullable => 0, size => 64 },
  "email",
  { data_type => "char", default_value => "", is_nullable => 0, size => 64 },
  "email_is_public",
  { data_type => "tinyint", default_value => 1, is_nullable => 0 },
  "url",
  { data_type => "char", is_nullable => 1, size => 128 },
  "twitter",
  { data_type => "char", is_nullable => 1, size => 32 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 entries

Type: has_many

Related object: L<IFComp::Schema::Result::Entry>

=cut

__PACKAGE__->has_many(
  "entries",
  "IFComp::Schema::Result::Entry",
  { "foreign.author" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 prize_donors

Type: has_many

Related object: L<IFComp::Schema::Result::Prize>

=cut

__PACKAGE__->has_many(
  "prize_donors",
  "IFComp::Schema::Result::Prize",
  { "foreign.donor" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 prize_recipients

Type: has_many

Related object: L<IFComp::Schema::Result::Prize>

=cut

__PACKAGE__->has_many(
  "prize_recipients",
  "IFComp::Schema::Result::Prize",
  { "foreign.recipient" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 user_roles

Type: has_many

Related object: L<IFComp::Schema::Result::UserRole>

=cut

__PACKAGE__->has_many(
  "user_roles",
  "IFComp::Schema::Result::UserRole",
  { "foreign.user" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 votes

Type: has_many

Related object: L<IFComp::Schema::Result::Vote>

=cut

__PACKAGE__->has_many(
  "votes",
  "IFComp::Schema::Result::Vote",
  { "foreign.user" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2014-01-20 14:46:13
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:lmsVxIot6O3Ek3O03Coj8g
# These lines were loaded from '/home/jjohn/perl5/perlbrew/perls/perl-5.18.2/lib/site_perl/5.18.2/IFComp/Schema/Result/User.pm' found in @INC.
# They are now part of the custom portion of this file
# for you to hand-edit.  If you do not either delete
# this section or remove that file from @INC, this section
# will be repeated redundantly when you re-create this
# file again via Loader!  See skip_load_external to disable
# this feature.

use utf8;
package IFComp::Schema::Result::User;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

IFComp::Schema::Result::User

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

=head1 TABLE: C<user>

=cut

__PACKAGE__->table("user");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 name

  data_type: 'char'
  default_value: (empty string)
  is_nullable: 0
  size: 64

User's real name

=head2 password

  data_type: 'char'
  default_value: (empty string)
  is_nullable: 0
  size: 64

=head2 email

  data_type: 'char'
  default_value: (empty string)
  is_nullable: 0
  size: 64

Email doubles as login ID

=head2 email_is_public

  data_type: 'tinyint'
  default_value: 1
  is_nullable: 0

=head2 url

  data_type: 'char'
  is_nullable: 1
  size: 128

=head2 twitter

  data_type: 'char'
  is_nullable: 1
  size: 32

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "name",
  { data_type => "char", default_value => "", is_nullable => 0, size => 64 },
  "password",
  { data_type => "char", default_value => "", is_nullable => 0, size => 64 },
  "email",
  { data_type => "char", default_value => "", is_nullable => 0, size => 64 },
  "email_is_public",
  { data_type => "tinyint", default_value => 1, is_nullable => 0 },
  "url",
  { data_type => "char", is_nullable => 1, size => 128 },
  "twitter",
  { data_type => "char", is_nullable => 1, size => 32 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 entries

Type: has_many

Related object: L<IFComp::Schema::Result::Entry>

=cut

__PACKAGE__->has_many(
  "entries",
  "IFComp::Schema::Result::Entry",
  { "foreign.author" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 prize_donors

Type: has_many

Related object: L<IFComp::Schema::Result::Prize>

=cut

__PACKAGE__->has_many(
  "prize_donors",
  "IFComp::Schema::Result::Prize",
  { "foreign.donor" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 prize_recipients

Type: has_many

Related object: L<IFComp::Schema::Result::Prize>

=cut

__PACKAGE__->has_many(
  "prize_recipients",
  "IFComp::Schema::Result::Prize",
  { "foreign.recipient" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 user_roles

Type: has_many

Related object: L<IFComp::Schema::Result::UserRole>

=cut

__PACKAGE__->has_many(
  "user_roles",
  "IFComp::Schema::Result::UserRole",
  { "foreign.user" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 votes

Type: has_many

Related object: L<IFComp::Schema::Result::Vote>

=cut

__PACKAGE__->has_many(
  "votes",
  "IFComp::Schema::Result::Vote",
  { "foreign.user" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2014-01-15 17:49:13
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:AxhlTomQm2e71Ty2Eb5vBA

use Digest::MD5 ('md5_hex');

sub check_password
{
    my ($self, $password) = @_;

    unless ($password)
    {
        warn("No password given\n");
        return;
    }

    my $hash = md5_hex($password . $self->salt);
    return $self->password eq $hash;
}

sub save_password
{
    my ($self, $clear_password) = @_;

    unless ($clear_password)
    {
        warn("No password\n");
        return;
    }

    unless ($self->salt)
    {
        warn("No salt\n");
        return;
    }

    my $hash = md5_hex($clear_password . $self->salt);
    $self->password($hash);
    $self->update;
}

__PACKAGE__->meta->make_immutable;

1;
