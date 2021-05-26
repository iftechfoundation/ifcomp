#!/usr/bin/env perl
use strict;
use warnings;

use lib ("/opt/IFComp/lib");
use lib ("/opt/IFComp/t/lib");

use IFComp;
use IFCompTestData;

my $schema = IFComp->component("IFComp::Model::IFCompDB")->schema;
IFCompTestData->add_test_data_to_schema($schema);
