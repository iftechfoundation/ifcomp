use strict;
use warnings;
use Test::More;

use FindBin;
use lib ("$FindBin::Bin/lib");
use IFCompTest;
my $schema = IFCompTest->init_schema();

my $u = $schema->resultset("User")->search({id => 1})->single();
ok($u && $u->name eq "user1", "Found test user");

done_testing();
