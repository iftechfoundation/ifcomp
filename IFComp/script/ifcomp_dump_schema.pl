#!/usr/bin/env perl
use strict;
use warnings;

use DBIx::Class::Schema::Loader qw/make_schema_at/;
use FindBin;
use lib "$FindBin::Bin/../lib";

make_schema_at(
    'IFComp::Schema',
    {   dump_directory          => "$FindBin::Bin/../lib",
        overwrite_modifications => 1,

        result_base_class => 'IFComp::Schema::Result',

        # Add markers around generated code to avoid tidying
        filter_generated_code => sub { return "#<<<\n$_[2]\n#>>>"; },
    },
    [ 'dbi:mysql:ifcomp:mariadb', 'root', '' ],
);
