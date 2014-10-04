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
  size: 128

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

=head2 salt

  data_type: 'char'
  default_value: (empty string)
  is_nullable: 1
  size: 36

=head2 created

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 updated

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 verified

  data_type: 'tinyint'
  is_nullable: 1

=head2 access_token

  data_type: 'char'
  is_nullable: 1
  size: 36

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
  { data_type => "char", default_value => "", is_nullable => 0, size => 128 },
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
  "salt",
  { data_type => "char", default_value => "", is_nullable => 1, size => 36 },
  "created",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
  "updated",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
  "verified",
  { data_type => "tinyint", is_nullable => 1 },
  "access_token",
  { data_type => "char", is_nullable => 1, size => 36 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 auth_tokens

Type: has_many

Related object: L<IFComp::Schema::Result::AuthToken>

=cut

__PACKAGE__->has_many(
  "auth_tokens",
  "IFComp::Schema::Result::AuthToken",
  { "foreign.user" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

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

=head2 prizes

Type: has_many

Related object: L<IFComp::Schema::Result::Prize>

=cut

__PACKAGE__->has_many(
  "prizes",
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


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2014-07-11 01:27:56
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:ZzjqBzk4bGIBq0TsCWeEqw

use Digest::MD5 ('md5_hex');
use Email::Sender::Simple qw/ sendmail /;
use Email::MIME::Kit;
use Data::GUID;
use DateTime;

has 'password_needs_hashing' => (
    isa => 'Bool',
    is => 'rw',
    default => '0',
);

sub reset_access_token {
    my $self = shift;

    my $new_code = Data::GUID->new->as_string;

    $self->access_token( $new_code );
    $self->update;
}

sub clear_access_token {
    my $self = shift;

    $self->access_token( undef );
    $self->update;
}

sub hash_password {
    my ($self, $plaintext) = (shift, shift);

    my $salt = $self->salt;
    my $hash = md5_hex( $plaintext . $salt );

    return $hash;
}

sub is_verified {
    my ($self) = @_;
    return $self->verified > 0;
}

# a sanitize hash suitable for publishing on the legacy API
sub get_api_fascade {
    my ($self) = @_;

    return {
        id => $self->id,
        name => $self->name,
        email => $self->email,
        token => $self->auth_tokens->first->token,
    };
}

sub send_validation_email {
    my $self = shift;

    $self->_send_email_and_reset_token( 'validate_registration' );
}

sub send_password_reset_email {
    my $self = shift;

    $self->_send_email_and_reset_token( 'reset_password' );
}

sub _send_email_and_reset_token {
    my $self = shift;
    my ( $subdir ) = @_;

    my $kit = Email::MIME::Kit->new( {
        source => $self->_path_to_email_subdir( $subdir ),
    } );

    $self->reset_access_token;
    my $access_token = $self->access_token;

    my $email = $kit->assemble( {
        user => $self,
    } );

    # XXX TODO: Check the return value of sendmail(); log errors.
    my $success = sendmail( $email );
}


sub validate_token {
    my $self = shift;

    my ( $token_to_validate ) = @_;

    if ( defined $self->access_token && $self->access_token eq $token_to_validate ) {
        $self->clear_access_token;
        $self->verified( 1 );
        $self->update;
        return 1;
    }
    else {
        return 0;
    }
}

sub _build_template_dir {
    my $self = shift;

    my $base_dir = $self->result_source->schema->email_template_basedir;

    return File::Spec->catdir( $base_dir, $self->Email_template_subdir );
}

around 'new' => sub {
    my $orig = shift;
    my $class = shift;

    my ( $args_ref ) = @_;
    my $password_needs_hashing = 0;
    if ( $args_ref->{ password_needs_hashing } ) {
        delete $args_ref->{ password_needs_hashing };
        $password_needs_hashing = 1;
    }

    my $self = $class->$orig( @_ );

    $self->password_needs_hashing( 1 );

    return $self;
};

around 'insert' => sub {
    my $orig = shift;
    my $self = shift;

    unless ( $self->salt ) {
        $self->salt( Data::GUID->new );
    }

    if ( $self->password_needs_hashing ) {
        $self->password_needs_hashing( 0 );
        $self->password( $self->hash_password( $self->password ) );
    }

    unless ( $self->created ) {
        $self->created( DateTime->now );
    }

    return $self->$orig( @_ );
};

sub _path_to_email_subdir {
    my $self = shift;
    my ( $subdir ) = @_;

    return $self->result_source->schema->email_template_basedir->subdir( $subdir );
}

sub current_comp_entries {
    my $self = shift;

    my $current_comp =
        $self->result_source->schema->resultset( 'Comp' )->current_comp;

    my $entries_rs = $self->entries->search( { comp => $current_comp->id } );

    if ( ( $current_comp->status eq 'accepting_intents' )
         || ( $current_comp->status eq 'closed_to_intents' ) )
    {
        return $entries_rs->all;
    }
    else {
        return grep { $_->is_qualified } $entries_rs->all;
    }
}

__PACKAGE__->meta->make_immutable( inline_constructor => 0 );

1;


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
