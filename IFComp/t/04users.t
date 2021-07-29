use strict;
use warnings;
use Test::More;

use FindBin;
use lib ("$FindBin::Bin/lib");
use IFCompTest;
my $schema = IFCompTest->init_schema();

my $u = $schema->resultset("User")->search( { id => 1 } )->single();
ok( $u && $u->name eq "user1", "Found test user" );

### Check password hashing...
# ...on ->create()
my $u2 = $schema->resultset('User')->create(
    {   name     => 'New User',
        password => 'plaintext',
        verified => 1,
    }
);
isnt( $u2->password, 'plaintext' );
ok( $u2->check_password('plaintext') );
ok( !$u2->check_password('wrong_password') );

# ...on ->update()
$u2->password('plaintext2');
isnt( $u2->password, 'plaintext2' );
ok( $u2->check_password('plaintext2') );

# ...on ->password()
$u2->password('plaintext3');
isnt( $u2->password, 'plaintext3' );
ok( $u2->check_password('plaintext3') );

my $coauthored_entry = $schema->resultset('Entry')->find( { id => 101 } );

my $primary_author =
    $schema->resultset('User')->find( { email => 'nobody@example.com' } );
is( $primary_author->id,                                          1 );
is( $primary_author->is_current_comp_author,                      1 );
is( $primary_author->is_coauthor,                                 0 );
is( $primary_author->is_author_or_coauthor_of($coauthored_entry), 1 );

my $not_an_author =
    $schema->resultset('User')->find( { email => 'curator@example.com' } );
is( $not_an_author->id,                     4 );
is( $not_an_author->is_current_comp_author, 0 );
is( $not_an_author->is_coauthor,            0 );

#is( $not_an_author->is_author_or_coauthor_of($coauthored_entry), 1 );

my $coauthor =
    $schema->resultset('User')->find( { email => 'author@example.com' } );
is( $coauthor->id,                                          2 );
is( $coauthor->is_coauthor,                                 1 );
is( $coauthor->is_current_comp_author,                      1 );
is( $coauthor->is_author_or_coauthor_of($coauthored_entry), 1 );

done_testing();
