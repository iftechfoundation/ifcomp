package IFComp::ColossalFund;

use Moose;
use JSON::XS;
use Try::Tiny;

use IFComp::ColossalFund::Year;

use Readonly;
Readonly my $CURRENT_DATA_FILENAME => 'current_progress.json';
Readonly my $DONORS_DIRNAME => 'contributors';


has 'data_directory' => (
    required => 1,
    isa => 'Path::Class::Dir',
    is => 'ro',
);

has 'current_data' => (
    isa => 'HashRef',
    is => 'ro',
    lazy_build => 1,
);

has 'goal' => (
    isa => 'Num',
    is => 'ro',
    lazy_build => 1,
);

has 'estimated_entries' => (
    isa => 'Num',
    is => 'ro',
    lazy_build => 1,
);

has 'estimated_winners' => (
    isa => 'Num',
    is => 'ro',
    lazy_build => 1,
);

has 'collected' => (
    isa => 'Num',
    is => 'ro',
    lazy_build => 1,
);

has 'top_prize' => (
    isa => 'Num',
    is => 'ro',
    lazy_build => 1,
);

has 'years' => (
    isa => 'ArrayRef[IFComp::ColossalFund::Year]',
    is => 'ro',
    lazy_build => 1,
);

has 'years_by_year' => (
    isa => 'HashRef',
    is => 'ro',
    lazy_build => 1,
);

has 'minimum_prize' => (
    isa => 'Num',
    is => 'ro',
    lazy_build => 1,
);

has 'maximum_prize' => (
    isa => 'Num',
    is => 'ro',
    lazy_build => 1,
);

sub _build_goal {
    my $self = shift;

    return $self->current_data->{ goal_dollars } || 0;
}

sub _build_estimated_entries {
    my $self = shift;

    return $self->current_data->{ estimated_entries } || 0;
}

sub _build_collected {
    my $self = shift;

    return $self->current_data->{ collected_dollars } || 0;
}

sub _build_minimum_prize {
    my $self = shift;

    return $self->current_data->{ minimum_prize } || 0;
}


sub _build_years {
    my $self = shift;

    my @years;

    my $donor_dir = Path::Class::Dir->new(
        $self->data_directory,
        $DONORS_DIRNAME,
    );

    for my $file ( $donor_dir->children ) {
        if ( $file =~ /csv$/ ) {
            push @years,
                 IFComp::ColossalFund::Year->new( data_file => $file );
        }
    }

    return \@years;

}

sub _build_years_by_year {
    my $self = shift;

    my %years_by_year;

    for my $year ( @{ $self->years } ) {
        $years_by_year{ $year->year } = $year;
    }

    return \%years_by_year;
}

sub _build_estimated_winners {
    my $self = shift;

    return int( $self->estimated_entries * .6667 + 0.5 );
}

sub _build_current_data {
    my $self = shift;

    my $file = Path::Class::File->new(
        $self->data_directory,
        $CURRENT_DATA_FILENAME,
    );

    my $data = {};
    try {
        $data = decode_json( $file->slurp );
    };

    return $data;
}

sub _build_maximum_prize {
    my $self = shift;

    my $maximum;
    unless ( $maximum = $self->current_data->{ maximum_prize } ) {
        # XXX This doesn't work. Please just set it in the data for now. :b
        my $pool = $self->collected * 0.8;
        my $winners = $self->estimated_winners;
        my $minimum = $self->minimum_prize;
        my $temp = 3 * ( $pool - $minimum * $winners ) / $winners;
        $maximum = $temp * (((.5 / $winners) - 1) ^ 2) + $minimum;
    }

    return $maximum;
}

sub year {
    my ( $self, $year ) = @_;

    return $self->years_by_year->{ $year };
}

1;

