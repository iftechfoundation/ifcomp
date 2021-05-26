#!/usr/bin/env perl
use strict;
use warnings;

use v5.10;

use lib ("/opt/IFComp/lib");
use lib ("/opt/IFComp/t/lib");

use IFComp;
use IFCompTestData;

my $schema = IFComp->component("IFComp::Model::IFCompDB")->schema;

say "Adding test data to schema";
IFCompTestData->add_test_data_to_schema($schema);

say "Copying test files into place";
IFCompTestData->copy_test_files(
    "/opt/IFComp/t/test_files/entries" => "/opt/IFComp/entries" );

say "Processing entries";
IFCompTestData->process_entries($schema);

say "Done";
