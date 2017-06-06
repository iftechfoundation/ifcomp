use strict;
use warnings;
use Test::More;

use FindBin;
use lib ("$FindBin::Bin/lib");
use IFCompTest;
my $schema = IFCompTest->init_schema();

use Catalyst::Test 'IFComp';

ok( request('/')->is_success, 'Request should succeed' );

done_testing();
