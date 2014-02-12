use strict;
use warnings;
use Test::More;


use Catalyst::Test 'IFComp';
use IFComp::Controller::Profile;

ok( request('/profile')->is_success, 'Request should succeed' );
done_testing();
