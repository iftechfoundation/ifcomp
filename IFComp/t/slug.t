use strict;
use warnings;
use utf8;
use Test::More;

use IFComp::Slug qw(title_to_base_slug entry_slugs_for_entries);

{

    package SlugTestEntry;

    sub new {
        my ( $class, %args ) = @_;
        return bless \%args, $class;
    }

    sub id    { $_[0]->{id} }
    sub title { $_[0]->{title} }
}

sub entry {
    my ( $id, $title ) = @_;
    return SlugTestEntry->new( id => $id, title => $title );
}

is( title_to_base_slug("The Wise-Woman's Dog"),
    'Wise-Womans_Dog',
    'strips leading article, preserves hyphens, underscores spaces' );
is( title_to_base_slug("Caf\x{e9} Noir"), 'Cafe_Noir', 'strips diacritics' );
is( title_to_base_slug('MY GAME'),        'MY_GAME',   'preserves case' );
is( title_to_base_slug('the foo'),  'foo',  'strips lowercase article' );
is( title_to_base_slug('A Tale'),   'Tale', 'strips A' );
is( title_to_base_slug('An Hour'),  'Hour', 'strips An' );
is( title_to_base_slug("Z\x{f6}e"), 'Zoe',  'handles umlauts' );
is( title_to_base_slug('  Spaces  '), 'Spaces',
    'trims and collapses spaces' );
ok( !defined title_to_base_slug('!!!'),
    'punctuation-only title returns undef'
);

my $unique = entry_slugs_for_entries( entry( 100, 'The Foo' ) );
is( $unique->{100}, 'Foo', 'unique title gets bare slug' );

my $identical = entry_slugs_for_entries(
    entry( 100, 'The Foo' ),
    entry( 101, 'The Foo' ),
);
is( $identical->{100}, 'Foo-100',
    'identical titles both get entry-id suffix' );
is( $identical->{101}, 'Foo-101',
    'identical titles both get entry-id suffix' );

my $case_only = entry_slugs_for_entries(
    entry( 100, 'My Game' ),
    entry( 101, 'MY GAME' ),
);
is( $case_only->{100}, 'My_Game-100',
    'case-only collision suffixes first entry' );
is( $case_only->{101}, 'MY_GAME-101',
    'case-only collision suffixes second entry' );

my $triple = entry_slugs_for_entries(
    entry( 100, 'Same' ),
    entry( 101, 'Same' ),
    entry( 102, 'Same' ),
);
is( $triple->{100}, 'Same-100', 'three-way collision suffixes all entries' );
is( $triple->{101}, 'Same-101', 'three-way collision suffixes all entries' );
is( $triple->{102}, 'Same-102', 'three-way collision suffixes all entries' );

my $empty = entry_slugs_for_entries( entry( 42, '!!!' ) );
is( $empty->{42}, 'entry-42', 'unslugifiable title falls back to entry id' );

# Two "Foo" entries get Foo-100 / Foo-101; a third titled "Foo-100" must
# not reuse Foo-100, so it becomes Foo-100-102. Chained titles keep appending.
my $cross = entry_slugs_for_entries(
    entry( 100, 'Foo' ),
    entry( 101, 'Foo' ),
    entry( 102, 'Foo-100' ),
    entry( 103, 'Foo-100-102' ),
);
is( $cross->{100}, 'Foo-100',     'Foo collision: entry 100 gets Foo-100' );
is( $cross->{101}, 'Foo-101',     'Foo collision: entry 101 gets Foo-101' );
is( $cross->{102}, 'Foo-100-102', 'title Foo-100 becomes Foo-100-102' );
is( $cross->{103}, 'Foo-100-102-103',
    'title Foo-100-102 becomes Foo-100-102-103' );

my %seen;
my $duplicate;
for my $slug ( values %$cross ) {
    if ( $seen{ lc $slug }++ ) {
        $duplicate = $slug;
        last;
    }
}
ok( !defined $duplicate, 'all final slugs are unique' );

done_testing();
