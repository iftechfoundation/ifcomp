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

done_testing();
