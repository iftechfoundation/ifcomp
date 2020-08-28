use warnings;
use strict;

use v5.10;

use FindBin;
use Imager;

use lib "$FindBin::Bin/../lib";
use IFComp::Schema;

my $MAXHEIGHT = 700;

my $schema = IFComp::Schema->connect( 'dbi:mysql:ifcomp', 'root', '' );
$schema->entry_directory( Path::Class::Dir->new("$FindBin::Bin/../entries") );

my $current_comp = $schema->resultset( 'Comp' )->current_comp;

my $cover_count = 0;
my $modified_cover_count = 0;

for my $entry ( $current_comp->entries ) {
    next unless $entry->is_qualified;
    my $cover_file = $entry->cover_file;
    next unless $cover_file;
    say "Entry " . $entry->id . "...";
    my $image = Imager->new( file => $cover_file ) or die Imager->errstr;
    if ( $image->getheight > $MAXHEIGHT ) {
        my $resized_image = $image->scale( ypixels => $MAXHEIGHT );
        my $web_cover_file = $entry->web_cover_file;
        $resized_image->write( file => $web_cover_file ) or die Imager->errstr;
        $modified_cover_count++;
    }
    $cover_count++;
}

say "Resized $modified_cover_count of $cover_count covers.";
