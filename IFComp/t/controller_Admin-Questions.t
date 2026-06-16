use strict;
use warnings;
use Test::More;

use Catalyst::Test 'IFComp';
use IFComp::Controller::Admin::Questions;

ok( request('/admin/questions')->is_success, 'Request should succeed' );
done_testing();
