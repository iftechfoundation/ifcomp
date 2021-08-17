#!/usr/bin/env perl

# This script reads prize data out of the legacy (pre-2014) and the new IFComp
# databases, and prints a summary of what it finds as HTML, ready for pasting
# into the IFComp website's past-prize page.
# TODO:
#   * Handle Unicode correctly. (Poor Marius!)
#   * Ignore duplicates. (Keying on year + prize name + donor email)


use warnings;
use strict;
use FindBin;

use 5.10.0;

use DBI;
use lib "$FindBin::Bin/../lib";
use IFComp::Schema;
use Scalar::Util qw( blessed );

my %category_for = (
    money => 'Money and Gift Certificates',
    food => 'Food',
    games => 'Games',
    hardware => 'Computer Hardware and Other Electronics',
    books => 'Books and Magazines',
    software => 'Non-Game Software',
    apparel => 'Clothing',
    av => 'Music and Movies',
    expertise => 'Expert Services',
    misc => 'Stuff',
    special => 'Conditional prizes',
);

my $old_comp_dbh = DBI->connect( 'dbi:mysql:old_ifcomp:db', 'root', '', { mysql_enable_utf8 => 1} );
my $new_comp_schema = IFComp::Schema->connect( 'dbi:mysql:ifcomp:db', 'root', '', { mysql_enable_utf8 => 1} );

my $prizes_ref = $old_comp_dbh->selectall_arrayref(
    'select prize.name as prize_name, donator, pseudonym, prizedesc, '
    . 'comp.name as comp_name, catdesc from prize, prize_category, comp '
    . 'where comp.comp_id = prize.comp_id and prize_category.pc_id = prize.pc_id'
);

push @$prizes_ref, $new_comp_schema->resultset( 'Prize' )->all;

my %prizes;
my %seen;
for my $prize_ref ( @$prizes_ref ) {
    my ( $prize, $donator, $pseudonym, $desc, $comp_name, $category );
    if ( blessed( $prize_ref ) ) {
        $prize = $prize_ref->name;
        $donator = $prize_ref->donor;
        $desc = $prize_ref->notes;
        $comp_name = $prize_ref->comp->year;
        $category = $category_for{ $prize_ref->category };

        foreach( $desc, $prize ) {
            s{_(.*?)_}{<em>$1</em>}g if defined;
        }

        if ( my $url = $prize_ref->url ) {
            $prize = qq{<a href="$url">$prize</a>};
        }
        if ( $desc ) {
            $prize .= '.';
        }


    }
    else {
        ( $prize, $donator, $pseudonym, $desc, $comp_name, $category ) = @$prize_ref;
    }

    my ( $year ) = $comp_name =~ /(....)$/;

    if ( $category eq 'Special Prizes' && $year > 2006 ) {
        $category = 'Expert Services';
    }

    $prizes{ $category }{ $year } ||= [];

    my $prize_text = sprintf(
        "<strong>%s</strong> %s<br /><em>Donated by %s</em>",
        $prize,
        $desc || '',
        $pseudonym? $pseudonym : $donator,
    );

    $prize_text =~ s/[ .]([,\.])/$1/g;
    $prize_text =~ s/\(USD\)/US/g;


    unless ( $seen{ $prize_text }{ $year } ) {
        push @{ $prizes{ $category }{ $year } }, $prize_text;
        $seen{ $prize_text }{ $year } = 1;
    }
}

for my $category ( sort( values ( %category_for ) ) ) {
    print "<h2>$category</h2>\n";
    for my $year ( reverse sort keys %{$prizes{ $category }} ) {
        print "<h3>$year</h3>\n";
        print "<ul>\n";
        for my $prize ( sort values @{ $prizes{ $category }{ $year } } ) {
            print "<li>$prize</li>\n";
        }
        print "</ul>\n";
    }
}
