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

sub last_comp {
    my $self = shift;

    # The current comp is *also* the last comp, if it just ended.
    my $current_comp = $self->current_comp;
    if ( $current_comp->status eq 'over' ) {
        return $current_comp;
    }
    else {
        my $last_year = DateTime::Moonpig->now->year - 1;
        return $self->search( { year => $last_year } )->single;
    }
}

1;
