#<<<
use utf8;
package IFComp::Schema::Result::Entry;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

IFComp::Schema::Result::Entry

=cut

use strict;
use warnings;


=head1 BASE CLASS: L<IFComp::Schema::Result>

=cut

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'IFComp::Schema::Result';

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

=head2 is_disqualified

  data_type: 'tinyint'
  default_value: 0
  is_nullable: 0

=head2 average_score

  data_type: 'decimal'
  is_nullable: 1
  size: [6,2]

=head2 standard_deviation

  data_type: 'decimal'
  is_nullable: 1
  size: [5,2]

=head2 total_1

  data_type: 'tinyint'
  is_nullable: 1

=head2 total_2

  data_type: 'tinyint'
  is_nullable: 1

=head2 total_3

  data_type: 'tinyint'
  is_nullable: 1

=head2 total_4

  data_type: 'tinyint'
  is_nullable: 1

=head2 total_5

  data_type: 'tinyint'
  is_nullable: 1

=head2 total_6

  data_type: 'tinyint'
  is_nullable: 1

=head2 total_7

  data_type: 'tinyint'
  is_nullable: 1

=head2 total_8

  data_type: 'tinyint'
  is_nullable: 1

=head2 total_9

  data_type: 'tinyint'
  is_nullable: 1

=head2 total_10

  data_type: 'tinyint'
  is_nullable: 1

=head2 votes_cast

  data_type: 'integer'
  is_nullable: 1

=head2 warning

  data_type: 'text'
  is_nullable: 1

=head2 playtime

  data_type: 'enum'
  extra: {list => ["15 minutes or less","half an hour","one hour","an hour and a half","two hours","longer than two hours"]}
  is_nullable: 1

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
  "is_disqualified",
  { data_type => "tinyint", default_value => 0, is_nullable => 0 },
  "average_score",
  { data_type => "decimal", is_nullable => 1, size => [6, 2] },
  "standard_deviation",
  { data_type => "decimal", is_nullable => 1, size => [5, 2] },
  "total_1",
  { data_type => "tinyint", is_nullable => 1 },
  "total_2",
  { data_type => "tinyint", is_nullable => 1 },
  "total_3",
  { data_type => "tinyint", is_nullable => 1 },
  "total_4",
  { data_type => "tinyint", is_nullable => 1 },
  "total_5",
  { data_type => "tinyint", is_nullable => 1 },
  "total_6",
  { data_type => "tinyint", is_nullable => 1 },
  "total_7",
  { data_type => "tinyint", is_nullable => 1 },
  "total_8",
  { data_type => "tinyint", is_nullable => 1 },
  "total_9",
  { data_type => "tinyint", is_nullable => 1 },
  "total_10",
  { data_type => "tinyint", is_nullable => 1 },
  "votes_cast",
  { data_type => "integer", is_nullable => 1 },
  "warning",
  { data_type => "text", is_nullable => 1 },
  "playtime",
  {
    data_type => "enum",
    extra => {
      list => [
        "15 minutes or less",
        "half an hour",
        "one hour",
        "an hour and a half",
        "two hours",
        "longer than two hours",
      ],
    },
    is_nullable => 1,
  },
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

#>>>

# Created by DBIx::Class::Schema::Loader v0.07047 @ 2017-07-05 11:06:47
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:RL9A3QkTI1E2soORe7DzJg

use Moose::Util::TypeConstraints;
use Lingua::EN::Numbers::Ordinate;
use Path::Class::Dir;
use File::Copy qw( move );
use Archive::Zip;
use List::Compare;
use MIME::Base64;

use Readonly;
Readonly my $I7_REGEX      => qr/\.z\d$|\.[gz]?blorb$|\.ulx$/i;
Readonly my $ZCODE_REGEX   => qr/\.z\d$|\.zblorb$/i;
Readonly my $TADS_REGEX    => qr/\.gam$|\.t3$/i;
Readonly my $QUEST_REGEX   => qr/\.quest$/i;
Readonly my $ALAN_REGEX    => qr/\.a3c$/i;
Readonly my $WINDOWS_REGEX => qr/\.exe$/i;
Readonly my $HTML_REGEX    => qr/\.html?$/i;
Readonly my $INDEX_REGEX   => qr/^index\.html?$/i;

Readonly my @DEFAULT_PARCHMENT_CONTENT => (
    'Cover.jpg',       'index.html', 'interpreter', 'play.html',
    'Small Cover.jpg', 'style.css',
);
Readonly my @DEFAULT_INFORM_CONTENT => qw(
    index.html
);

has 'sort_title' => (
    is         => 'ro',
    isa        => 'Maybe[Str]',
    lazy_build => 1,
    clearer    => 'clear_sort_title',
    predicate  => 'has_sort_title',
);

has 'directory' => (
    is         => 'ro',
    isa        => 'Path::Class::Dir',
    lazy_build => 1,
    clearer    => 'clear_directory',
);

has 'directory_name' => (
    is         => 'ro',
    isa        => 'Maybe[Str]',
    lazy_build => 1,
    clearer    => 'clear_directory_name',
);

has 'main_file' => (
    is         => 'ro',
    isa        => 'Maybe[Path::Class::File]',
    lazy_build => 1,
    clearer    => 'clear_main_file',
);

has 'walkthrough_file' => (
    is         => 'ro',
    isa        => 'Maybe[Path::Class::File]',
    lazy_build => 1,
    clearer    => 'clear_walkthrough_file',
);

has 'main_directory' => (
    is         => 'ro',
    isa        => 'Path::Class::Dir',
    lazy_build => 1,
);

has 'walkthrough_directory' => (
    is         => 'ro',
    isa        => 'Path::Class::Dir',
    lazy_build => 1,
);

has 'content_directory' => (
    is         => 'ro',
    isa        => 'Path::Class::Dir',
    lazy_build => 1,
);

has 'cover_directory' => (
    is         => 'ro',
    isa        => 'Path::Class::Dir',
    lazy_build => 1,
);

has 'cover_file' => (
    is         => 'ro',
    isa        => 'Maybe[Path::Class::File]',
    lazy_build => 1,
);

has 'inform_game_file' => (
    is         => 'ro',
    isa        => 'Maybe[Path::Class::File]',
    lazy_build => 1,
);

has 'inform_game_js_file' => (
    is         => 'ro',
    isa        => 'Maybe[Path::Class::File]',
    lazy_build => 1,
);

enum 'Platform', [
    qw(
        html
        website
        quixe
        parchment
        inform
        inform-website
        tads
        quest
        windows
        alan
        other
        )
];

has 'contents_data' => (
    is         => 'ro',
    init_arg   => undef,
    lazy_build => 1,
    clearer    => 'clear_contents_data',
);

has 'platform' => (
    is         => 'ro',
    isa        => 'Platform',
    lazy_build => 1,
    clearer    => 'clear_platform',
);

has 'play_file' => (
    is         => 'ro',
    isa        => 'Maybe[Path::Class::File]',
    lazy_build => 1,
    clearer    => 'clear_play_file',
);

has 'is_qualified' => (
    is         => 'ro',
    isa        => 'Bool',
    lazy_build => 1,
);

has 'interpreter_tag_text' => (
    is         => 'ro',
    isa        => 'Str',
    lazy_build => 1,
);

has 'is_zcode' => (
    is         => 'ro',
    isa        => 'Bool',
    lazy_build => 1,
);

has 'has_extra_content' => (
    is         => 'ro',
    isa        => 'Bool',
    lazy_build => 1,
);

has 'supports_transcripts' => (
    is         => 'ro',
    isa        => 'Bool',
    lazy_build => 1,
);

has 'latest_update' => (
    is         => 'ro',
    isa        => 'Maybe[IFComp::Schema::Result::EntryUpdate]',
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

# If an entry's DB record gets deleted, then so does all its files.
after delete => sub {
    my $self = shift;
    return $self->directory->rmtree;
};

around update => sub {
    my $orig = shift;
    my $self = shift;

    for my $file_type (qw( main walkthrough )) {
        my $column = "${file_type}_filename";
        if ( $self->is_column_changed($column) && not $self->$column ) {
            my $file_method = "${file_type}_file";
            my $file        = $self->$file_method;
            unless ( $file->remove ) {
                die "Failed to remove $file. And: $file_method.";
            }
        }
    }

    if ( $self->is_column_changed('title') && $self->has_sort_title ) {
        $self->clear_sort_title;
    }

    return $self->$orig(@_);
};

sub _build_sort_title {
    my $self  = shift;
    my $title = $self->title;

    # for right now, just remove initial articles
    $title =~ s/^(?:the|a|an) //i;
    return $title;
}

sub _build_directory_name {
    my $self = shift;

    return $self->_directory_name_from( $self->title );
}

sub _directory_name_from {
    my $self = shift;
    my ($name) = @_;

    $name =~ s/\s+/_/g;
    $name =~ s/[^\w\d]//g;

    return $name;
}

sub _build_directory {
    my $self = shift;

    my $dir_path =
        Path::Class::Dir->new( '',
        $self->result_source->schema->entry_directory,
        $self->id, );

    unless ( -e $dir_path ) {
        mkdir($dir_path);
    }

    return $dir_path;

}

sub _build_main_file {
    my $self = shift;

    return ( $self->main_directory->children( no_hidden => 1 ) )[0];
}

sub _build_walkthrough_file {
    my $self = shift;

    return ( $self->walkthrough_directory->children( no_hidden => 1 ) )[0];
}

sub _build_cover_file {
    my $self = shift;

    return ( $self->cover_directory->children( no_hidden => 1 ) )[0];
}

sub _build_main_directory {
    my $self = shift;

    return $self->_build_subdir_named('main');
}

sub _build_content_directory {
    my $self = shift;

    return $self->_build_subdir_named('content');
}

sub _build_walkthrough_directory {
    my $self = shift;

    return $self->_build_subdir_named('walkthrough');
}

sub _build_cover_directory {
    my $self = shift;

    return $self->_build_subdir_named('cover');
}

sub _build_subdir_named {
    my $self = shift;
    my ($subdir_name) = @_;

    my $path = $self->directory->subdir($subdir_name);
    unless ( -e $path ) {
        mkdir($path);
    }

    return $path;
}

sub _build_contents_data {
    my $self = shift;

    my @content_files;
    $self->content_directory->recurse(
        callback => sub {
            push @content_files, $_[0]->relative( $self->content_directory );
        }
    );

    # ensure a predictable order:
    @content_files = sort { $a cmp $b } @content_files;

    my $quixe_extra_check = sub {
        if ( my $js_file = $self->inform_game_js_file ) {
            my $fh         = $js_file->openr;
            my $first_line = <$fh>;
            return
                scalar(
                $first_line =~ /^\$\(document\)\.ready\(function\(\) \{/ );
        }
        return 0;
    };

    # This is a list of tuples of:
    # - platform name
    # - list of regexes for files required to exist
    # - optional additional validation func
    # Assuming all the regexes pass, the file matched by the first is
    # what's used for the play file
    my @platforms = (
        [   'parchment',
            [   $INDEX_REGEX,       $I7_REGEX,
                qr/^play\.html?$/i, qr/^(interpreter\/)?parchment.*js$/i
            ]
        ],
        [   'quixe',
            [ $INDEX_REGEX, $I7_REGEX, qr/^(interpreter\/)?quixe.*js$/i ],
            $quixe_extra_check
        ],
        [ 'inform-website', [ $INDEX_REGEX, $I7_REGEX ] ],
        [ 'inform',         [$I7_REGEX] ],
        [ 'tads',           [$TADS_REGEX] ],
        [ 'quest',          [$QUEST_REGEX] ],
        [ 'alan',           [$ALAN_REGEX] ],
        [ 'windows',        [$WINDOWS_REGEX] ],

        # two possible cases for the "website" platform: either there's
        # an index.html in the top level dir and some other html files,
        # in which case we take the index.html file; or if that fails,
        # then we consider the case where there's at least one html file
        # in the top level dir, in which case we take it (or take the first
        # alphabetically if there are multiple)
        [ 'website', [ $INDEX_REGEX, $HTML_REGEX ] ],
        [ 'website', [qr/^[^\/]+$HTML_REGEX/] ],
    );

    for my $platform_info (@platforms) {
        my ( $name, $regexes, $extra_check ) = @$platform_info;
        $extra_check = sub { return 1 }
            unless defined $extra_check;
        my @found_files = _find_fileset( $regexes, @content_files );
        if ( @found_files && $extra_check->() ) {
            return { 'platform' => $name, 'play_file' => $found_files[0] };
        }
    }

    return { 'platform' => 'other', 'play_file' => undef };
}

sub _find_file {
    my ( $regex, @files ) = @_;
    for my $file (@files) {
        return $file if $file->stringify =~ $regex;
    }
    return undef;
}

sub _find_fileset {
    my ( $regexes, @files ) = @_;
    my @ret;
    for my $regex (@$regexes) {
        my $found = _find_file( $regex, @files );
        return () unless defined $found;
        push @ret, $found;
    }
    return @ret;
}

sub _build_platform {
    my $self = shift;

    return $self->contents_data->{'platform'};
}

sub _build_play_file {
    my $self = shift;

    return $self->contents_data->{'play_file'};
}

sub _build_is_qualified {
    my $self = shift;

    if ( $self->is_disqualified ) {
        return 0;
    }
    elsif ( $self->main_file ) {
        return 1;
    }
    else {
        return 0;
    }
}

sub _build_inform_game_file {
    my $self = shift;

    my $inform_file;
    $self->content_directory->recurse(
        callback => sub {
            my ($file) = @_;
            if ( $file->basename =~ /$I7_REGEX/ ) {
                $inform_file = $file;
            }
        }
    );

    return $inform_file;
}

sub _build_inform_game_js_file {
    my $self = shift;

    my $js_file;
    $self->content_directory->recurse(
        callback => sub {
            my ($file) = @_;
            if ( $file->basename =~ /\.js$/ ) {
                my $filename = $file->basename;
                $filename =~ s/\.js$//;
                if ( $filename =~ /$I7_REGEX/ ) {
                    $js_file = $file;
                }
            }
        }
    );

    return $js_file;
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

        # Clean up any Mac OS indexing folders that might have gotten caught in the
        # amber.
        my @dirs_to_delete;
        $content_directory->recurse(
            callback => sub {
                my ($subdir) = @_;
                if ( $subdir->basename eq '__MACOSX' ) {
                    push @dirs_to_delete, $subdir;
                }
            }
        );
        for my $deletable_dir (@dirs_to_delete) {
            $deletable_dir->rmtree if -e $deletable_dir;
        }

        # If the result is a single subdir, move all its contents up a level,
        # then erase it.
        if (   ( $content_directory->children == 1 )
            && ( ( $content_directory->children )[0]->is_dir ) )
        {
            my $sole_dir = ( $content_directory->children )[0];
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

    $self->clear_contents_data;
    $self->clear_platform;
    $self->clear_play_file;

    if ( $self->platform eq 'inform' ) {
        if ( $self->is_zcode ) {
            $self->_create_parchment_page;
        }
        else {
            $self->_create_quixe_page;
        }

        # and then we have to recalculate again since doing this changes the
        # platform type and play file
        $self->clear_contents_data;
        $self->clear_platform;
        $self->clear_play_file;
    }
    elsif ( $self->platform eq 'parchment' ) {
        $self->_mangle_parchment_head;
    }
    elsif ( $self->platform eq 'quixe' ) {
        $self->_make_js_file( $self->inform_game_file,
            $self->inform_game_js_file );
        $self->_mangle_quixe_head;
    }
}

sub _make_js_file {
    my $self = shift;

    my ( $source_file, $js_file ) = @_;
    $js_file //= $source_file;

    $js_file->spew( q/$(document).ready(function() {/
            . q/  GiLoad.load_run(null, '/
            . encode_base64( $source_file->slurp, '' )
            . q/', 'base64');/
            . q/});/ );
}

sub _create_parchment_page {
    my $self = shift;

    my $title = $self->title;

    # Search the content directory for the I7 file to link to.
    my $i7_file = $self->inform_game_file;

    unless ($i7_file) {
        die "Could not find an I7 file in this entry's content directory.";
    }

    $i7_file = $i7_file->basename;

    my $entry_id = $self->id;

    my $tag_text = $self->interpreter_tag_text;
    my $html     = <<EOF
<!DOCTYPE html>
<html>
<head>
  <title>IFComp — $title — Play</title>
  <meta http-equiv="Content-Type" content="text/html;charset=utf-8">
  <meta name="viewport" content="width=device-width, user-scalable=no">
$tag_text
<script>
parchment_options = {
default_story: [ "$i7_file" ],
lib_path: '/static/interpreter/parchment/',
lock_story: 1,
page_title: 0
};

ifRecorder.saveUrl = "/play/$entry_id/transcribe";
ifRecorder.story.name = "$title";
ifRecorder.story.version = "1";
</script>

 </head>
<body class="play">
<div class="container">

<div id="gameport">
<div id="about">
<h1>Parchment</h1>
<p>is an interpreter for Interactive Fiction. <a href="https://github.com/curiousdannii/parchment">Find out more.</a></p>
<noscript><p>Parchment requires Javascript. Please enable it in your browser.</p></noscript>
</div>
<div id="parchment"></div>
</div>

</div>
<div class="interpretercredit"><a href="https://github.com/curiousdannii/parchment">Parchment for Inform 7</a></div>
</body>
</html>

EOF
        ;

    my $html_file = $self->content_directory->file('index.html');
    my $html_fh   = $html_file->openw;
    $html_fh->binmode(':utf8');

    print $html_fh $html;

}

sub _create_quixe_page {
    my $self = shift;

    my $title = $self->title;

    # Search the content directory for the I7 file to link to.
    my $i7_file = $self->inform_game_file;

    unless ($i7_file) {
        die "Could not find an I7 file in this entry's content directory.";
    }

    # Create a JS file for this game.
    my $js_file = Path::Class::File->new( $i7_file . '.js' );
    $self->_make_js_file( $i7_file, $js_file );

    my $js_filename = $js_file->basename;

    my $entry_id = $self->id;

    my $tag_text = $self->interpreter_tag_text;
    my $html     = <<EOF
<!DOCTYPE html>
<html>
<head>
<title>IFComp — $title — Play</title>

<meta name="viewport" content="width=device-width, user-scalable=no">

$tag_text

<style type="text/css">

body {
  margin: 0px;
  height: 100%;
}

#gameport {
  position: absolute;
  overflow: hidden;
  width: 100%;
  height: 100%;
  background: #CCAA88;
  margin: 0px;
}

</style>

<script type="text/javascript">
game_options = {
  use_query_story: false,
  set_page_title: true,
  recording_url: '/play/$entry_id/transcribe',
  recording_label: '$title',
  recording_format: 'simple'
};
</script>

<script src="$js_filename" type="text/javascript"></script>

</head>
<body>

<div id="gameport">
<div id="windowport">
<noscript><hr>
<p>You'll need to turn on Javascript in your web browser to play this game.</p>
<hr></noscript>
</div>
<div id="loadingpane">
<img src="/static/interpreter/quixe/media/waiting.gif" alt="LOADING"><br>
<em>&nbsp;&nbsp;&nbsp;Loading...</em>
</div>
<div id="errorpane" style="display:none;"><div id="errorcontent">...</div></div>
</div>

</body>
</html>
EOF
        ;

    my $html_file = $self->content_directory->file('index.html');
    my $html_fh   = $html_file->openw;
    $html_fh->binmode(':utf8');

    print $html_fh $html;

}

sub _mangle_parchment_head {
    my $self = shift;

    my $title    = $self->title;
    my $entry_id = $self->id;

    my $game_file = $self->inform_game_file->basename;

    my $play_file = $self->content_directory->file('play.html');

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
    my $tag_text  = $self->interpreter_tag_text;
    my $head_html = <<EOF;
$tag_text
<script>
parchment_options = {
default_story: [ "$game_file" ],
lib_path: '/static/interpreter/parchment/',
lock_story: 1,
page_title: 0
};

ifRecorder.saveUrl = "/play/$entry_id/transcribe";
ifRecorder.story.name = "$title";
ifRecorder.story.version = "1";
</script>

EOF

    $play_html =~ s{</head>}{$head_html\n</head>};

    $play_file->spew($play_html);

}

sub _mangle_quixe_head {
    my $self = shift;

    my $play_file = $self->content_directory->file('play.html');

    my $game_file = $self->inform_game_file->basename;

    unless ( ( -e $play_file ) && $game_file ) {

        # No play.html? OK, this isn't a standard I7 "with interpreter" arrangement,
        # so we won't do anything.
        return;
    }

    my $play_html = $play_file->slurp;

    # Re-aim interpreter links to our own Quixe interpreter.
    # (Via re-writing <script src="..." /> invocations.)
    $play_html =~ s{"interpreter/jquery-.*?min.js"}
            {"/static/interpreter/quixe/lib/jquery-1.12.4.min.js"};
    $play_html =~ s{"interpreter/glkote.min.js"}
            {"/static/interpreter/quixe/lib/glkote.min.js"};
    $play_html =~ s{"interpreter/quixe.min.js"}
            {"/static/interpreter/quixe/lib/quixe.min.js"};

    # Activate transcription, aiming it at the local transcription action.
    # (Via injecting additional values into the game_options config object.)
    my $entry_id = $self->id;
    my $transcription_options =
          "recording_url: '/play/$entry_id/transcribe',\n"
        . "recording_format: 'simple',\n";
    $play_html =~ s[(game_options\s*=\s*{\s*)]
            [$1$transcription_options]s;

    $play_file->spew($play_html);

}

sub _build_interpreter_tag_text {
    my $self = shift;

    if ( $self->is_zcode ) {
        return <<EOF;
<script src="/static/interpreter/parchment/jquery.min.js"></script>
<script src="/static/interpreter/parchment/parchment.min.js"></script>
<script src="/static/interpreter/transcript_recorder/if-recorder.js"></script>
<link rel="stylesheet" type="text/css" href="/static/interpreter/parchment/parchment.css">
<link rel="stylesheet" type="text/css" href="/static/interpreter/parchment/style.css">
EOF
    }
    else {
        return <<EOF;
<script src="/static/interpreter/quixe/lib/jquery-1.12.4.min.js"></script>
<script src="/static/interpreter/quixe/lib/glkote.min.js"></script>
<script src="/static/interpreter/quixe/lib/quixe.min.js"></script>
<link rel="stylesheet" type="text/css" href="/static/interpreter/quixe/media/glkote.css">
<link rel="stylesheet" type="text/css" href="/static/interpreter/quixe/media/dialog.css">
EOF
    }
}

sub _build_is_zcode {
    my $self = shift;

    my @content_files;
    $self->content_directory->recurse(
        callback => sub {
            push @content_files, $_[0]->basename;
        }
    );

    if ( grep {/$ZCODE_REGEX/} @content_files ) {
        return 1;
    }
    else {
        return 0;
    }
}

sub _build_has_extra_content {
    my $self = shift;

    my @default_list;
    if ( $self->platform =~ /^inform/ ) {
        @default_list = @DEFAULT_INFORM_CONTENT;
    }
    elsif (( $self->platform eq 'parchment' )
        || ( $self->platform eq 'quixe' ) )
    {
        @default_list = @DEFAULT_PARCHMENT_CONTENT;
    }
    else {
        return 0;
    }

    my $lc = List::Compare->new(
        [   map { $_->basename }
                $self->content_directory->children( no_hidden => 1 )
        ],
        \@default_list,
    );

    if ( $lc->get_unique > 1 ) {
        return 1;
    }
    else {
        return 0;
    }
}

sub _build_supports_transcripts {
    my $self = shift;

    if (
        ($self->platform eq 'parchment')
        || ( $self->platform eq 'quixe' )
        || ( $self->platform eq 'inform-website' )
    ) {
        return 1;
    }
    else {
        return 0;
    }
}

sub _build_latest_update {
    my $self = shift;

    my $updates_rs =
        $self->entry_updates->search( {}, { order_by => 'time desc', } );
    return $updates_rs->next;
}

__PACKAGE__->meta->make_immutable;

1;
