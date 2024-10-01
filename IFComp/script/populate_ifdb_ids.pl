#!/usr/bin/env perl

# This script does its best to update the IFDB ID field for every game in the
# current year's comp.

use warnings;
use strict;
use FindBin;
use Path::Class;
use LWP;
use Readonly;

use lib "$FindBin::Bin/../lib";
use IFComp::Schema;

use XML::LibXML;

use open ':std', ':encoding(UTF-8)';

Readonly my $PAUSE_BETWEEN_QUERIES => 1;

my $schema = IFComp::Schema->connect( 'dbi:mysql:ifcomp',
    'root', '', { mysql_enable_utf8 => 1 } );
$schema->entry_directory( Path::Class::Dir->new("$FindBin::Bin/../entries") );

my $current_comp = $schema->resultset('Comp')->current_comp;

my $ua = LWP::UserAgent->new;

my $year = $current_comp->year;

my $ifdb_url = "https://ifdb.org";

# my $ifdb_url = "http://localhost:8083/";

# Search for the current year's competition in the series:Annual Interactive Fiction Competition

my $competition_search_year_uri =
    "$ifdb_url/search?comp&searchfor=$year%20series%3AAnnual+Interactive+Fiction+Competition&xml";

my $competition_tuid = @{ XML::LibXML->load_xml(
        string => $ua->get($competition_search_year_uri)->content
    )->getElementsByTagName("tuid")
}[0]->textContent;

print "competition_tuid: $competition_tuid\n\n";

sleep($PAUSE_BETWEEN_QUERIES);

# Search for all games with that competitionid

my $competition_search_uri =
    "$ifdb_url/search?searchfor=competitionid:$competition_tuid&pg=all&sortby=ttl&xml";

my @games = XML::LibXML->load_xml(
    string => $ua->get($competition_search_uri)->content )
    ->getElementsByTagName("game");

my @tuids =
    map { @{ $_->getElementsByTagName('tuid') }[0]->textContent } @games;

sub entry_for_tuid {
    my $tuid = shift;

    # load the ifiction (XML) for the game
    my $ifiction_uri = "$ifdb_url/viewgame?id=$tuid&ifiction";

    sleep($PAUSE_BETWEEN_QUERIES);

    # Find all the external links
    my @links =
        @{ XML::LibXML->load_xml( string => $ua->get($ifiction_uri)->content )
            ->getElementsByTagName("links") }[0]
        ->getElementsByTagName("link");

    # Find the link whose URL looks like a ballot link, containing an IFComp entry ID
    foreach my $link (@links) {
        my $url = @{ $link->getElementsByTagName("url") }[0]->textContent;
        if ( $url =~ /^https:\/\/ifcomp.org\/ballot\/#entry-(\d+)$/ ) {
            my $entry_id = $1;
            print "entry_id $entry_id => $tuid\n";
            return $1;
        }
    }
}

my %entries = map { entry_for_tuid($_) => $_ } @tuids;

for my $entry ( $current_comp->entries ) {

    next unless $entry->is_qualified;

    my $entry_id = $entry->id;
    my $title    = $entry->title;
    my $ifdb_id  = $entries{ $entry->id };

    if ($ifdb_id) {
        $entry->ifdb_id($ifdb_id);
        $entry->update;
        warn "$title ($entry_id) has the IFDB $ifdb_id\n";
    }
    else {
        warn
            "*** WARNING: Couldn't find an IFDB ID for $title ($entry_id).\n";
    }
}

