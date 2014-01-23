#!/usr/bin/env perl 
use strict;
use warnings;
use Test::More;

use FindBin;
use lib ("$FindBin::Bin/lib");

use IFCompTest;
use IFComp::Model::IFCompDB;;

IFCompTest->init_schema();

IFComp::Model::IFCompDB->config->{"connect_info"} = [ IFCompTest->connect_info() ];
my $schema = IFComp::Model::IFCompDB->new->schema;

if ($schema)
{
    my $u = $schema->resultset("User")->search({id => 1})->single();
    ok($u && $u->name eq "user1", "Found test user");
}



done_testing();
