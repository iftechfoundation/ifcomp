#!/usr/bin/env perl

use warnings;
use strict;

use FindBin;
use lib "$FindBin::Bin/../lib";
use IFComp::Schema;

my $schema = IFComp::Schema->connect( 'dbi:mysql:ifcomp', 'root', '' );
$schema->entry_directory( Path::Class::Dir->new("$FindBin::Bin/../entries") );

my $entries_rs = $schema->resultset('Comp')->current_comp->entries;
my %forum_handles;
while ( my $entry = $entries_rs->next ) {
    next unless $entry->is_qualified;

    if ( defined $entry->author->forum_handle ) {
        $forum_handles{ $entry->author->forum_handle }++;
    }
}

foreach ( sort keys %forum_handles ) {
    print "$_\n";
}
