#!/usr/bin/env perl 
use strict;
use warnings;
use Test::More;

use FindBin;
use lib ("$FindBin::Bin/lib");

use IFCompTest;
IFCompTest->init_schema();

# use IFComp;

# my $users = IFComp->model("Model::UserDB");
# ok($users, "Fetch users model");

# my $u = $users->search({id => 1})->single();
# ok($u->name == "user1", "Found test user");




done_testing();
