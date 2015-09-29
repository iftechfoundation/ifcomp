#!/usr/bin/env perl

use warnings;
use strict;

use FindBin;
use lib "$FindBin::Bin/../lib";
use IFComp::Schema;

my $schema = IFComp::Schema->connect( 'dbi:mysql:ifcomp', 'root', '' );
$schema->entry_directory( Path::Class::Dir->new( "$FindBin::Bin/../entries" ) );

my $entries_rs = $schema->resultset( 'Comp' )->current_comp->entries;
my %emails;
while ( my $entry = $entries_rs->next ) {
    next unless $entry->is_qualified;

    $emails{ $entry->author->email }++;
}

foreach ( sort keys %emails ) {
    print "$_\n";
}
