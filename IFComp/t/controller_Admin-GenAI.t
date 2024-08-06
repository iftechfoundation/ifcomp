use strict;
use warnings;
use Test::More;

use Catalyst::Test 'IFComp';
use IFComp::Controller::Admin::GenAI;

ok( request('/admin/genai')->is_success, 'Request should succeed' );
done_testing();
