#!/usr/bin/env perl
use Archive::Zip;
use Unicode::Normalize;
use FindBin;
use utf8;
use v5.10;

use lib "$FindBin::Bin/../lib";
use IFComp::Schema;

my $schema = IFComp::Schema->connect( 'dbi:mysql:ifcomp', 'root', '' );
$schema->entry_directory( Path::Class::Dir->new("$FindBin::Bin/../entries") );

my ($source_path) = @ARGV;

die "Usage: $0 destination_directory\n" unless $source_path;

my $root = Path::Class::Dir->new($source_path);

unless ( -d $root && -w $root ) {
    die "Can't write to $root: $!\n";
}

my $count = 0;

for my $entry ( $schema->resultset('Comp')->current_comp->entries->all ) {
    say "Opening up " . $entry->title;
    next unless $entry->is_qualified;
    print sprintf "I see %s by %s, a %s.\n",
        $entry->title,
        $entry->author->name,
        $entry->platform,
        ;

    $count++;

    my $title = $entry->title;

    # Remove all diacritics.
    $title = NFKD($title);
    $title =~ s/\p{NonspacingMark}//g;

    # Kill all non-word characters remaining, because Windows is stupid.
    $title =~ s/[^\w\d\s]//g;
    $title =~ s/ +/ /g;

    my $destination = $root->subdir($title);
    if ( -e $destination ) {
        $destination->rmtree;
    }

    $destination->mkpath;
    my $main_file = $destination->file( $entry->main_file->basename );

    $entry->main_file->copy_to($main_file);
    if ( $main_file->basename =~ /\.zip$/i ) {
        my $zip = Archive::Zip->new;
        $zip->read( $main_file->stringify );
        eval { $zip->extractTree( { zipName => $destination } ); };
        if ($@) {
            warn "SKIPPING: $@\n";
        }
        $main_file->remove;
    }

    if ( $entry->cover_file ) {
        my $subdir = $destination->subdir('Cover');
        $subdir->mkpath;
        $entry->cover_file->copy_to($subdir);
    }

    if ( $entry->walkthrough_file ) {
        my $subdir = $destination->subdir('Walkthrough');
        $subdir->mkpath;
        $entry->walkthrough_file->copy_to($subdir);
    }

}

print "That is $count entries.\n";

