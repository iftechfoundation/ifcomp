use utf8;
package IFComp::Schema::Result::Entry;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

IFComp::Schema::Result::Entry

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

=head1 TABLE: C<entry>

=cut

__PACKAGE__->table("entry");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  extra: {unsigned => 1}
  is_auto_increment: 1
  is_nullable: 0

=head2 title

  data_type: 'char'
  default_value: (empty string)
  is_nullable: 0
  size: 128

=head2 subtitle

  data_type: 'char'
  is_nullable: 1
  size: 128

=head2 author

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 author_pseudonym

  data_type: 'char'
  is_nullable: 1
  size: 64

=head2 ifdb_id

  data_type: 'char'
  is_nullable: 1
  size: 16

=head2 comp

  data_type: 'integer'
  extra: {unsigned => 1}
  is_foreign_key: 1
  is_nullable: 0

=head2 upload_time

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=head2 place

  data_type: 'tinyint'
  is_nullable: 1

=head2 blurb

  data_type: 'text'
  is_nullable: 1

=head2 reveal_pseudonym

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=head2 miss_congeniality_place

  data_type: 'integer'
  is_nullable: 1

=head2 email

  data_type: 'char'
  is_nullable: 1
  size: 64

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "title",
  { data_type => "char", default_value => "", is_nullable => 0, size => 128 },
  "subtitle",
  { data_type => "char", is_nullable => 1, size => 128 },
  "author",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "author_pseudonym",
  { data_type => "char", is_nullable => 1, size => 64 },
  "ifdb_id",
  { data_type => "char", is_nullable => 1, size => 16 },
  "comp",
  {
    data_type => "integer",
    extra => { unsigned => 1 },
    is_foreign_key => 1,
    is_nullable => 0,
  },
  "upload_time",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
  "place",
  { data_type => "tinyint", is_nullable => 1 },
  "blurb",
  { data_type => "text", is_nullable => 1 },
  "reveal_pseudonym",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "miss_congeniality_place",
  { data_type => "integer", is_nullable => 1 },
  "email",
  { data_type => "char", is_nullable => 1, size => 64 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<ifdb_id>

=over 4

=item * L</ifdb_id>

=back

=cut

__PACKAGE__->add_unique_constraint("ifdb_id", ["ifdb_id"]);

=head1 RELATIONS

=head2 author

Type: belongs_to

Related object: L<IFComp::Schema::Result::User>

=cut

__PACKAGE__->belongs_to(
  "author",
  "IFComp::Schema::Result::User",
  { id => "author" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);

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

=head2 entry_updates

Type: has_many

Related object: L<IFComp::Schema::Result::EntryUpdate>

=cut

__PACKAGE__->has_many(
  "entry_updates",
  "IFComp::Schema::Result::EntryUpdate",
  { "foreign.entry" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 votes

Type: has_many

Related object: L<IFComp::Schema::Result::Vote>

=cut

__PACKAGE__->has_many(
  "votes",
  "IFComp::Schema::Result::Vote",
  { "foreign.entry" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2014-06-21 18:32:27
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:xGA5Wl9WH3YXdxIu9jkiAg

use Lingua::EN::Numbers::Ordinate;
use Path::Class::Dir;
use File::Copy qw( move );

has 'directory' => (
    is => 'ro',
    isa => 'Path::Class::Dir',
    lazy_build => 1,
    clearer => 'clear_directory',
);

has 'directory_name' => (
    is => 'ro',
    isa => 'Maybe[Str]',
    lazy_build => 1,
    clearer => 'clear_directory_name',
);

has 'main_file' => (
    is => 'ro',
    isa => 'Maybe[Path::Class::File]',
    lazy_build => 1,
    clearer => 'clear_main_file',
);

has 'walkthrough_file' => (
    is => 'ro',
    isa => 'Maybe[Path::Class::File]',
    lazy_build => 1,
    clearer => 'clear_walkthrough_file',
);

has 'online_play_file' => (
    is => 'ro',
    isa => 'Maybe[Path::Class::File]',
    lazy_build => 1,
    clearer => 'clear_online_play_file',
);

has 'feelies_directory' => (
    is => 'ro',
    isa => 'Path::Class::Dir',
    lazy_build => 1,
    handles => {
        feelies => 'children',
    },
);

has 'data_directory' => (
    is => 'ro',
    isa => 'Path::Class::Dir',
    lazy_build => 1,
    handles => {
        data_files => 'children',
    },
);

has 'main_directory' => (
    is => 'ro',
    isa => 'Path::Class::Dir',
    lazy_build => 1,
);

has 'online_play_directory' => (
    is => 'ro',
    isa => 'Path::Class::Dir',
    lazy_build => 1,
);

has 'walkthrough_directory' => (
    is => 'ro',
    isa => 'Path::Class::Dir',
    lazy_build => 1,
);


has 'uploaded_cover_art_file' => (
    is => 'ro',
    isa => 'Maybe[Path::Class::File]',
    lazy_build => 1,
);

sub place_as_ordinate {
    my $self = shift;
    return ordinate( $self->place );
}

sub miss_congeniality_place_as_ordinate {
    my $self = shift;
    return ordinate( $self->miss_congeniality_place );
}

sub is_complete {
    my $self = shift;

}

sub delete_feelie_with_index {
    my $self = shift;
    my ( $index_to_delete ) = @_;

    my $current_index = 0;
    for my $feelie ( $self->feelies ) {
        if ( $current_index == $index_to_delete ) {
            $feelie->remove;
            last;
        }
        $current_index++;
    }
}

sub delete_data_file_with_index {
    my $self = shift;
    my ( $index_to_delete ) = @_;

    my $current_index = 0;
    for my $file ( $self->data_files ) {
        if ( $current_index == $index_to_delete ) {
            $file->remove;
            last;
        }
        $current_index++;
    }
}

# If an entry's DB record gets deleted, then so does all its files.
after delete => sub {
    my $self = shift;
    return $self->directory->rmtree;
};


around update => sub {
    my $orig = shift;
    my $self = shift;

    for my $file_type ( qw( main walkthrough online_play ) ) {
        my $column = "${file_type}_filename";
        if ( $self->is_column_changed( $column ) && not $self->$column  ) {
            my $file_method = "${file_type}_file";
            my $file = $self->$file_method;
            unless ( $file->remove ) {
                die "Failed to remove $file. And: $file_method.";
            }
        }
    }

    return $self->$orig( @_ );

};

sub _build_directory_name {
    my $self = shift;

    return $self->_directory_name_from( $self->title );
}

sub _directory_name_from {
    my $self = shift;
    my ( $name ) = @_;

    $name =~ s/\s+/_/g;
    $name =~ s/[^\w\d]//g;

    return $name;
}

sub _build_directory {
    my $self = shift;

    my $dir_path = Path::Class::Dir->new(
        '',
        $self->result_source->schema->entry_directory,
        $self->id,
    );

    unless ( -e $dir_path ) {
        mkdir ( $dir_path );
    }

    return $dir_path;

}

sub _build_main_file {
    my $self = shift;

    return ($self->main_directory->children)[0];
}

sub _build_walkthrough_file {
    my $self = shift;

    return ($self->walkthrough_directory->children)[0];
}

sub _build_online_play_file {
    my $self = shift;

    return ($self->online_play_directory->children)[0];
}

sub _build_uploaded_cover_art_file {
    my $self = shift;

    return $self->directory->file( 'cover.png' );
}

sub _build_feelies_directory {
    my $self = shift;

    return $self->_build_subdir_named( 'feelies' );
}

sub _build_data_directory {
    my $self = shift;

    return $self->_build_subdir_named( 'data' );
}

sub _build_main_directory {
    my $self = shift;

    return $self->_build_subdir_named( 'main' );
}

sub _build_online_play_directory {
    my $self = shift;

    return $self->_build_subdir_named( 'online_play' );
}

sub _build_walkthrough_directory {
    my $self = shift;

    return $self->_build_subdir_named( 'walkthrough' );
}

sub _build_subdir_named {
    my $self = shift;
    my ( $subdir_name ) = @_;

    my $path = $self->directory->subdir( $subdir_name );
    unless ( -e $path ) {
        mkdir( $path );
    }

    return $path;
}

sub uploaded_cover_art_file_exists {
    my $self = shift;

    return -e $self->uploaded_cover_art_file;
}


__PACKAGE__->meta->make_immutable;

1;
