use warnings;
use strict;

use v5.10;

use FindBin;

use lib "$FindBin::Bin/../lib";
use IFComp::Schema;

my $schema = IFComp::Schema->connect( 'dbi:mysql:ifcomp', 'root', '' );
$schema->entry_directory( Path::Class::Dir->new("$FindBin::Bin/../entries") );

my $current_comp = $schema->resultset('Comp')->current_comp;

for my $entry ( $current_comp->entries ) {
    $entry->create_web_cover_file;
    say sprintf( "Wrote new web cover file for (%s) %s",
        $entry->id, $entry->title, )
        if $entry->cover_exists;
}
