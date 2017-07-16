package IFComp::Schema::Result;
use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components( 'EncodedColumn', 'InflateColumn::DateTime',
    'Core', );

1;
