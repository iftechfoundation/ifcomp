use strict;
use warnings;
use Test::More;

use FindBin;
use lib ("$FindBin::Bin/lib");
use IFCompTest;
my $schema = IFCompTest->init_schema();

$schema->entry_directory(
    Path::Class::Dir->new("$FindBin::Bin/platform_test_entries") );

$schema->populate(
    'Entry',
    [   [ 'id', 'author', 'title',                   'comp' ],
        [ 100,  1,        'Test Z-code game',        1 ],
        [ 101,  1,        'Test Glulx game',         1 ],
        [ 102,  1,        'Test Quixe game',         1 ],
        [ 103,  1,        'Test Parchment game',     1 ],
        [ 104,  1,        'Test Z-code website',     1 ],
        [ 105,  1,        'Test non-Inform website', 1 ],
        [ 106,  1,        'Test HTML page',          1 ],
        [ 107, 1, 'Test Z-code website with buried story file', 1 ],
        [ 108, 1, 'Test Quest game',                            1 ],
        [ 109, 1, 'Test TADS game',                             1 ],
        [ 110, 1, 'Test Alan game',                             1 ],
        [ 111, 1, 'Test Quixe2 game',                           1 ],
    ],
);

my $rs = $schema->resultset('Entry');

is( $rs->find(100)->platform, 'inform' );
ok( $rs->find(100)->is_zcode );
is( $rs->find(101)->platform, 'inform' );
ok( !$rs->find(101)->is_zcode );
is( $rs->find(102)->platform, 'inform-website' );
ok( !$rs->find(102)->is_zcode );
is( $rs->find(103)->platform, 'parchment' );
ok( $rs->find(103)->is_zcode );
is( $rs->find(104)->platform, 'inform-website' );
ok( $rs->find(104)->is_zcode );
is( $rs->find(105)->platform, 'website' );
is( $rs->find(106)->platform, 'website' );
is( $rs->find(107)->platform, 'inform-website' );
ok( $rs->find(107)->is_zcode );
is( $rs->find(108)->platform, 'quest' );
is( $rs->find(109)->platform, 'tads' );
is( $rs->find(110)->platform, 'alan' );
is( $rs->find(111)->platform, 'quixe2' );

done_testing();
