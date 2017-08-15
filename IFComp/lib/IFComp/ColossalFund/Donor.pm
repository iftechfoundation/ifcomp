package IFComp::ColossalFund::Donor;

use Moose;

has 'donation' => (
    isa => 'Num',
    is => 'rw',
    required => 1,
);

has 'name' => (
    isa => 'Str',
    is => 'ro',
    required => 1,
);

has 'email' => (
    isa => 'Maybe[Str]',
    is => 'ro',
    required => 1,
);

has 'permission_to_name' => (
    isa => 'Bool',
    is => 'ro',
    default => 0,
);

1;

