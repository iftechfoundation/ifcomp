package IFComp::Schema::ResultSet::Comp;

use Moose;
extends 'DBIx::Class::ResultSet';

use DateTime::Moonpig;

sub current_comp {
    my $self = shift;

    my $this_year = DateTime::Moonpig->now->year;

    my $comp = $self->search( { year => $this_year } )->single;

    return $comp;
}

1;
