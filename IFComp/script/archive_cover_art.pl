#!/usr/bin/env perl

# This script rolls the current comp's cover art into its permanent location.

use warnings;
use strict;
use FindBin;
use Path::Class;
use Readonly;
use File::Copy qw( copy );

use lib "$FindBin::Bin/../lib";
use IFComp::Schema;

my $schema = IFComp::Schema->connect( 'dbi:mysql:ifcomp', 'root', '' );
$schema->entry_directory( Path::Class::Dir->new("$FindBin::Bin/../entries") );

my $current_comp = $schema->resultset('Comp')->current_comp;

my $images_directory = "$FindBin::Bin/../root/static/images/covers";

for my $entry ( $current_comp->entries ) {

    next unless $entry->is_qualified;

    if ( -e $entry->cover_file ) {
        my $ifdb_id = $entry->ifdb_id;
        unless ( defined $ifdb_id ) {
            warn $entry->title . " has no IFDB ID set. Skipping.\n";
            next;
        }

        copy( $entry->web_cover_file, "$images_directory/$ifdb_id" );
    }
}

