package IFComp::Schema::Result;
use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components( 'InflateColumn::DateTime', 'Core', );

1;
