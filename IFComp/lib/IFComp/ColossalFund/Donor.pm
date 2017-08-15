package IFComp::ColossalFund::Donor;

use Moose;

has 'donation' => (
    isa      => 'Num',
    is       => 'rw',
    required => 1,
);

has 'name' => (
    isa      => 'Str',
    is       => 'ro',
    required => 1,
);

has 'email' => (
    isa      => 'Maybe[Str]',
    is       => 'ro',
    required => 1,
);

has 'is_anonymous' => (
    isa        => 'Bool',
    is         => 'ro',
    lazy_build => 1,
);

sub _build_is_anonymous {
    my $self = shift;

    my $name = lc( $self->name );

    # I'm not sure how all this whitespace is getting stuck onto the name.
    $name =~ s/\s*$//;

    if ( !$name || $name eq 'anonymous' ) {
        return 1;
    }
    else {
        return 0;
    }
}

1;

