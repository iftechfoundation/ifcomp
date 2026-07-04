#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
use v5.10;
use FindBin;

use lib "$FindBin::Bin/../lib";
use IFComp::Schema;

use Path::Class;
use File::Basename;
use Archive::Zip qw(AZ_OK);
use Unicode::Normalize qw(NFD);
use Encode qw(decode encode);

my $schema = IFComp::Schema->connect( 'dbi:mysql:ifcomp', 'root', '' );
$schema->entry_directory( Path::Class::Dir->new("$FindBin::Bin/../entries") );
my $comp = $schema->resultset('Comp');

my $home = $ENV{HOME} || $ENV{USERPROFILE} || '/var/tmp';
my $zipdir = dir($home, $comp->current_comp->year);

my $games_dir      = $zipdir->subdir('Games');
my $walkthroughs_dir = $zipdir->subdir('Walkthroughs');

$games_dir->mkpath unless -d $games_dir;
$walkthroughs_dir->mkpath unless -d $walkthroughs_dir;

my $count = 0;

for my $entry ( $comp->current_comp->entries->all ) {
    next unless $entry->is_qualified;

    say "Processing: " . $entry->title . " - " . $entry->main_file->stringify;

    my $raw_title = decode('UTF-8', $entry->title);

    my $title = NFD($raw_title);                   # Decompose Unicode characters
    $title =~ s/\p{NonspacingMark}//g;             # Strip diacritics
    $title =~ s/[^\x00-\x7F]/_/g;                  # Replace remaining non-ASCII with underscore
    $title =~ s/[^\w\d\s]//g;                      # Kill remaining non-word characters
    $title =~ s/ +/ /g;                            # Collapse multiple spaces
    $title =~ s/^\s+|\s+$//g;                      # Trim leading/trailing whitespace

    unless ($title) {
        warn "Unable to ascii-ify $raw_title";
        next;
    }
    if ( $raw_title ne $title) {
	say "\tNew Name: $title";
    }

    my $main_file_obj = $entry->main_file;
    next unless $main_file_obj && -f $main_file_obj->stringify;

    my $src_path = $main_file_obj->stringify;
    my $dest_main = $games_dir->file("$title.zip");

    # If there's another file with the same name, cheat by
    # adding the unique ifdb to it.
    if (-e $dest_main->stringify) {
	    my $ifdb_id = $entry->ifdb_id;
	    $dest_main = $games_dir->file("$title-$ifdb_id.zip");
    }

    # We want to make sure that all the files in the zip-of-zips are zips.
    # Some authors upload non-zip files (e.g. a single index.html), so we
    # need to zip that up here.
    if ($src_path =~ /\.zip$/i) {
        $main_file_obj->copy_to($dest_main);
	say "\tCopied over as zipfile";
    } else {
        my $zip = Archive::Zip->new();
	my $zipfile = $zip->addFile($src_path);
	unless (defined $zipfile) {
            warn "Failed to add file to zip: $!\n";
	    last;
        }
        unless ($zip->writeToFileNamed($dest_main->stringify) == AZ_OK) {
            warn "Failed to write zip file: $!\n";
	    last;
        }
	say "\tCompressed into zipfile";
    }

    # ...and, if there's a walkthrough, copy that over as well
    if ( $entry->walkthrough_file && -f $entry->walkthrough_file->stringify ) {
        my $walk_ext = (basename($entry->walkthrough_file->stringify) =~ /\.(\w+)$/)[0] || 'txt';
        my $dest_walk = $walkthroughs_dir->file("$title.$walk_ext");
        $entry->walkthrough_file->copy_to($dest_walk);
	say "\tIncluded walkthrough";
    }

    $count++;
}

print "Processed $count entries.\n";

