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

=head2 transcripts

Type: has_many

Related object: L<IFComp::Schema::Result::Transcript>

=cut

__PACKAGE__->has_many(
  "transcripts",
  "IFComp::Schema::Result::Transcript",
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


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2014-08-26 18:15:45
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:lxzKmlz6iM3KFmmM13W2Nw

use Moose::Util::TypeConstraints;
use Lingua::EN::Numbers::Ordinate;
use Path::Class::Dir;
use File::Copy qw( move );
use Archive::Zip;

use Readonly;
Readonly my $I7_REGEX => qr/\.z\d$|\.[gz]?blorb$|\.ulx$/i;

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

has 'main_directory' => (
    is => 'ro',
    isa => 'Path::Class::Dir',
    lazy_build => 1,
);

has 'walkthrough_directory' => (
    is => 'ro',
    isa => 'Path::Class::Dir',
    lazy_build => 1,
);

has 'content_directory' => (
    is => 'ro',
    isa => 'Path::Class::Dir',
    lazy_build => 1,
);

has 'cover_directory' => (
    is => 'ro',
    isa => 'Path::Class::Dir',
    lazy_build => 1,
);

has 'cover_file' => (
    is => 'ro',
    isa => 'Maybe[Path::Class::File]',
    lazy_build => 1,
);

enum 'Platform', [qw(
    html
    website
    parchment
    inform
    other
) ];

has 'platform' => (
    is => 'ro',
    isa => 'Platform',
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

# If an entry's DB record gets deleted, then so does all its files.
after delete => sub {
    my $self = shift;
    return $self->directory->rmtree;
};


around update => sub {
    my $orig = shift;
    my $self = shift;

    for my $file_type ( qw( main walkthrough ) ) {
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

    return ($self->main_directory->children( no_hidden => 1 ) )[0];
}

sub _build_walkthrough_file {
    my $self = shift;

    return ($self->walkthrough_directory->children( no_hidden => 1 ) )[0];
}

sub _build_cover_file {
    my $self = shift;

    return ($self->cover_directory->children( no_hidden => 1 ) )[0];
}

sub _build_main_directory {
    my $self = shift;

    return $self->_build_subdir_named( 'main' );
}

sub _build_content_directory {
    my $self = shift;

    return $self->_build_subdir_named( 'content' );
}

sub _build_walkthrough_directory {
    my $self = shift;

    return $self->_build_subdir_named( 'walkthrough' );
}

sub _build_cover_directory {
    my $self = shift;

    return $self->_build_subdir_named( 'cover' );
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

sub _build_platform {
    my $self = shift;

    my $file = $self->main_file;
    if ( $self->main_file =~ /\.html?$/i ) {
        return 'html';
    }

    if ( $self->main_file =~ $I7_REGEX ) {
        return 'inform';
    }

    my @content_files = map { $_->basename } $self->content_directory->children;
    if (
        ( grep { $I7_REGEX } @content_files )
        && ( grep { /^index\.html?$/i } @content_files )
        && ( grep { /^play\.html?$/i } @content_files )
    ) {
        return 'parchment';
    }

    if ( grep { /\.html?$/i } @content_files ) {
        return 'website';
    }

    return 'other';

}

sub cover_exists {
    my $self = shift;

    if ( $self->cover_file ) {
        return -e $self->cover_file;
    }
    else {
        return 0;
    }
}

# update_content_directory: Clean up (and possibly create) the content directory,
#                           then populate it with the main .zip, if there is one.
sub update_content_directory {
    my $self = shift;

    my $content_directory = $self->content_directory;
    $content_directory->rmtree;
    $content_directory->mkpath;

    if ( $self->main_file =~ /\.zip$/i ) {
        my $zip = Archive::Zip->new;
        $zip->read( $self->main_file->stringify );
        $zip->extractTree( { zipName => $content_directory } );

        # If the result is a single subdir, move all its contents up a level,
        # then erase it.
        if (
            ( $content_directory->children == 1 )
            && ( ($content_directory->children)[0]->is_dir )
        ) {
            my $sole_dir = ($content_directory->children)[0];
            for my $child ( $sole_dir->children ) {
                my $destination;
                if ( $child->is_dir ) {
                    $destination =
                        $content_directory->subdir( $child->basename );
                }
                else {
                    $destination =
                        $content_directory->file( $child->basename );
                }
                move( $child => $destination->stringify ) or die $!;
            }
            $sole_dir->rmtree;
        }
    }
    else {
        $self->main_file->copy_to( $self->content_directory );
    }

    if ( $self->platform eq 'inform' ) {
        $self->_create_parchment_page;
    }
    elsif ( $self->platform eq 'parchment' ) {
        $self->_mangle_parchment_head;
    }
}

sub _create_parchment_page {
    my $self = shift;

    my $title = $self->title;
    my $main_file = $self->main_file->basename;
    my $entry_id = $self->id;

    my $html = <<EOF
<!DOCTYPE html>
<html>
<head>
  <title>IFComp — $title — Play</title>
  <meta http-equiv="Content-Type" content="text/html;charset=utf-8">
  <meta name="viewport" content="width=device-width, user-scalable=no">
  <link rel="stylesheet" href="style.css">

  <script src="../../static/interpreter/jquery.min.js"></script>
<script src="../../static/interpreter/parchment.min.js"></script>
<script src="../../static/interpreter/if-recorder.js"></script>
<link rel="stylesheet" type="text/css" href="../../static/interpreter/parchment.min.css">
<link rel="stylesheet" type="text/css" href="../../static/interpreter/i7-glkote.css">
<link rel="stylesheet" type="text/css" href="../../static/interpreter/dialog.css">
<script>
parchment_options = {
default_story: [ "$main_file" ],
lib_path: '../../static/interpreter/',
lock_story: 1,
page_title: 0
};

ifRecorder.saveUrl = "../../../play/$entry_id/transcribe";
ifRecorder.story.name = "$title";
ifRecorder.story.version = "1";
</script>

 </head>
<body class="play">
<div class="container">

<div id="gameport">
<div id="about">
<h1>Parchment</h1>
<p>is an interpreter for Interactive Fiction. <a href="http://parchment.googlecode.com">Find out more.</a></p>
<noscript><p>Parchment requires Javascript. Please enable it in your browser.</p></noscript>
</div>
<div id="parchment"></div>
</div>

</div>
<div class="interpretercredit"><a href="http://parchment.googlecode.com">Parchment for Inform 7</a></div>
</body>
</html>

EOF
    ;

    my $html_file = $self->content_directory->file( 'index.html' );
    my $html_fh = $html_file->openw;

    print $html_fh $html;

}

sub _mangle_parchment_head {
    my $self = shift;

    my $title = $self->title;
    my $entry_id = $self->id;

    my $game_file;
    foreach ( map { $_->basename } $self->content_directory->children ) {
        if ( /$I7_REGEX/ ) {
            $game_file = $_;
            last;
        }
    }

    my $play_file = $self->content_directory->file( 'play.html' );

    unless ( ( -e $play_file ) && $game_file ) {
        # No play.html? OK, this isn't a standard I7 "with interpreter" arrangement,
        # so we won't do anything.
        return;
    }

    my $play_html = $play_file->slurp;

    # Discard all invocations of interpreter/.
    $play_html =~ s{<script src="interpreter/.*?</script>}{}g;
    $play_html =~ s{<link.*?href="interpreter/.*?>}{}g;

    # Add new head tags.
    my $head_html = <<EOF;
<script src="../../static/interpreter/jquery.min.js"></script>
<script src="../../static/interpreter/parchment.min.js"></script>
<script src="../../static/interpreter/if-recorder.js"></script>
<link rel="stylesheet" type="text/css" href="../../static/interpreter/parchment.min.css">
<link rel="stylesheet" type="text/css" href="../../static/interpreter/i7-glkote.css">
<link rel="stylesheet" type="text/css" href="../../static/interpreter/dialog.css">
<script>
parchment_options = {
default_story: [ "$game_file" ],
lib_path: '../../static/interpreter/',
lock_story: 1,
page_title: 0
};

ifRecorder.saveUrl = "../../../play/$entry_id/transcribe";
ifRecorder.story.name = "$title";
ifRecorder.story.version = "1";
</script>

EOF
    ;

    $play_html =~ s{</head>}{$head_html\n</head>};

    $play_file->spew( $play_html );

}

__PACKAGE__->meta->make_immutable;

1;
