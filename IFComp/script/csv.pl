#!/usr/bin/env perl

use warnings;
use strict;

use Text::CSV_XS;

use FindBin;
use lib "$FindBin::Bin/../lib";
use IFComp::Schema;

my $schema = IFComp::Schema->connect( 'dbi:mysql:ifcomp', 'root', '' );
$schema->entry_directory( Path::Class::Dir->new("$FindBin::Bin/../entries") );

my $csv = Text::CSV_XS->new( { binary => 1, eol => $/ } );

# my $entries_rs = $schema->resultset('Comp')->current_comp->entries;
my $entries_rs = $schema->resultset('Comp')->current_comp->entries;
my @rows;

push @rows, [ 'CompID', "Title", "Blurb", "Platform", "Genre", "Author(s)" ];

while ( my $entry = $entries_rs->next ) {
    next unless $entry->is_qualified;

    my $author;
    if ( $entry->ok_to_reveal_pseudonym ) {
        $author =
              $entry->author->name
            . " (writing as "
            . $entry->author_pseudonym . ")";
    }
    elsif ( defined( $entry->author_pseudonym ) ) {
        $author = $entry->author_pseudonym;
    }
    else {
        $author = $entry->author->name;
    }

    if ( $entry->entry_coauthors > 0 ) {
        foreach my $ca ( $entry->entry_coauthors ) {
            $author .= " and " . $ca->display_name;
        }
    }

    push @rows,
        [
        $entry->id,       $entry->title, $entry->blurb,
        $entry->platform, $entry->genre, $author
        ];
}

$csv->print( *STDOUT, $_ ) for @rows;
