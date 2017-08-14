package IFComp::ColossalFund::Year;

use Moose;
use IFComp::ColossalFund::Donor;

has 'data_file' => (
    isa => 'Path::Class::File',
    is => 'ro',
    required => 1,
);

has 'year' => (
    isa => 'Num',
    is => 'ro',
    lazy_build => 1,
);

has 'donors' => (
    isa => 'ArrayRef[IFComp::ColossalFund::Donor]',
    is => 'rw',
    default => sub { [] },
);

sub _build_year {
    my $self = shift;

    # The year is just the data file's filename.
    my ( $year ) = $self->data_file =~ /^(\d+)/;

    return $year;
}

sub BUILD {
    my $self = shift;

    my @lines = $self->data_file->slurp(
        chomp => 1,
        split => qr/\s*,\s*/,
        iomode => '<:encoding(UTF-8)',
    );

    # The CSV might contain multiple donations from the same person, as
    # identified by email address, so we'll flatten em out first.
    my %donors_by_email;

    for my $line ( @lines ) {
        my ($date, $gross, $net, $name, $email, $permission) = @$line;
        next unless $date =~ /\d/;

        foreach ( $gross, $net ) {
            s/^\s*\$//;
        }

        unless ( $donors_by_email{ $email } ) {
            $donors_by_email{ $email } = {
                donation => 0,
                name => $name,
                email => $email,
                permission_to_name => $permission,
            };
        }

        $donors_by_email{ $email }->{ donation } += $gross;
    }

    # Now sort the donors by donation, and make our donors from that.
    my @donor_data = values %donors_by_email;
    @donor_data = sort { $a->{donation} <=> $b->{donation} } @donor_data;
    @donor_data = map { IFComp::ColossalFund::Donor->new( $_ ) } @donor_data;

    $self->donors( \@donor_data );

}

sub named_donors_between {
    my $self = shift;
    my ( $min, $max ) = @_;

    return $self->_donors_between( $min, $max, 1 );
}

sub anonymous_donors_between {
    my $self = shift;
    my ( $min, $max ) = @_;

    return $self->_donors_between( $min, $max, 0 );
}

sub _donors_between {
    my $self = shift;
    my ( $min, $max, $permission ) = @_;

    my @donors;
    for my $donor ( @{ $self->donors} ) {
        if (
            ( $donor->donation >= $min )
            && ( not( defined $max ) || $donor->donation <= $max )
            && ( $donor->permission_to_name == $permission )
        ) {
            push @donors, $donor;
        }
    }
    return @donors;
}

1;
