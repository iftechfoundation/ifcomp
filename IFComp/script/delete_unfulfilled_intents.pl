#!/usr/env perl

# This script marks every entry without a main file as disqualified.
# Useful for marking unfulfilled intents, post-deadline.

use warnings;
use strict;
use FindBin;
use Path::Class;

use lib "$FindBin::Bin/../lib";
use IFComp::Schema;

my $schema = IFComp::Schema->connect( 'dbi:mysql:ifcomp', 'root', '' );
$schema->entry_directory( Path::Class::Dir->new("$FindBin::Bin/../entries") );

my $current_comp = $schema->resultset('Comp')->current_comp;

for my $entry ( $current_comp->entries ) {
    unless ( $entry->main_file ) {
        $entry->delete;
    }
}
