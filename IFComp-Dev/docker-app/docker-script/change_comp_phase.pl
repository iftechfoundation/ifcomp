#!/usr/bin/env perl
use strict;
use warnings;

use v5.10;

use lib ("/opt/IFComp/lib");

use DateTime::Moonpig;
use IFComp;

my @PHASES = (
    qw/
        not_begun
        accepting_intents
        closed_to_intents
        closed_to_entries
        open_for_judging
        processing_votes
        over
        /
);
my $schema = IFComp->component("IFComp::Model::IFCompDB")->schema;

my $comp = $schema->resultset('Comp')->current_comp;
die "Unable to find the current comp" unless ($comp);

say "Current status: " . $comp->status;

if (@ARGV) {
    my $phase_num = $ARGV[0];
    unless ( $phase_num =~ /^\d$/ ) {
        say "\nERROR: Invalid phase number '$phase_num'";
        help_and_exit();
    }

    my $new_phase = $PHASES[ $phase_num - 1 ];
    unless ($new_phase) {
        say "\nERROR: Invalid phase number '$phase_num'";
        help_and_exit();
    }

    say "\nSetting comp phase to $new_phase";
    set_phase($phase_num);
}
else {
    help_and_exit();
}

exit;

sub set_phase {
    my $phase_num = shift;

    my $now        = DateTime::Moonpig->now( time_zone => 'local' );
    my $last_month = $now->minus( 30 * 24 * 60 * 60 );
    my $next_month = $now->plus( 30 * 24 * 60 * 60 );

    # Set all dates to next month
    # then set just the appropriate dates to last month

    $comp->intents_open($next_month);
    $comp->intents_close($next_month);
    $comp->entries_due($next_month);
    $comp->judging_begins($next_month);
    $comp->judging_ends($next_month);
    $comp->comp_closes($next_month);

    if ( $phase_num > 1 ) {
        $comp->intents_open($last_month);
    }
    if ( $phase_num > 2 ) {
        $comp->intents_close($last_month);
    }
    if ( $phase_num > 3 ) {
        $comp->entries_due($last_month);
    }
    if ( $phase_num > 4 ) {
        $comp->judging_begins($last_month);
    }
    if ( $phase_num > 5 ) {
        $comp->judging_ends($last_month);
    }
    if ( $phase_num > 6 ) {
        $comp->comp_closes($last_month);
    }

    $comp->update();
}

sub help_and_exit {
    say <<HELP;

Usage: change_comp_phase.sh <PHASE NUMBER>

Possible Phases:
HELP

    for my $num ( 1 .. scalar @PHASES ) {
        say "\t$num) $PHASES[$num - 1]";
    }

    exit;
}
