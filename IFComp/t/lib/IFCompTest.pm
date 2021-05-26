package IFCompTest;
use strict;
use warnings;
use Carp qw( cluck );

$SIG{__WARN__} = sub { cluck shift };

use FindBin;

$ENV{CATALYST_CONFIG}        = "$FindBin::Bin/conf/ifcomp.conf";
$ENV{EMAIL_SENDER_TRANSPORT} = 'Test';

use utf8;
use Carp qw(croak);
use DateTime qw();
use English;
use File::Path qw(make_path remove_tree);

use IFComp::Schema;
use IFCompTestData;

my $db_dir  = "$FindBin::Bin/db";
my $db_file = "$db_dir/IFComp.db";
my $dsn     = "dbi:SQLite:$db_file";

sub connect_info {
    my ($self) = shift;
    return (
        $dsn, '', '',
        {   sqlite_unicode  => 1,
            on_connect_call => 'use_foreign_keys',
        }
    );
}

sub init_schema {
    my $self = shift;
    my %args = @_;

    if ( -e $db_file ) {
        unless ( unlink $db_file ) {
            croak("Couldn't unlink $db_file: $OS_ERROR");
        }
    }

    my $schema = IFComp::Schema->connect( $self->connect_info() );

    # The default dir for deploy is "./", which means that if you run
    # the tests from IFComp_HOME it tries to read IFComp.sql to get the
    # deployment statements rather than generating them for SQLite.
    # So we have to specify the dir here, even though it actually uses
    # the path in the $dsn to write the SQLite file...
    $schema->deploy( undef, $db_dir );

    IFCompTestData->add_test_data_to_schema($schema);

    my $entry_directory = Path::Class::Dir->new("$FindBin::Bin/entries");
    $schema->entry_directory($entry_directory);

    IFCompTestData->copy_test_files(
        "$FindBin::Bin/test_files/entries" => $entry_directory );

    IFCompTestData->process_entries($schema);

    return $schema;
}

sub log_in_as_judge {
    my ($mech) = @_;
    _log_in_as( $mech, 'nobody@example.com', 'user1' );
}

sub log_in_as_author {
    my ($mech) = @_;
    _log_in_as( $mech, 'author@example.com', 'Alice Author' );
}

sub log_in_as_votecounter {
    my ($mech) = @_;
    _log_in_as( $mech, 'votecounter@example.com', 'Victor Votecounter' );
}

sub log_in_as_curator {
    my ($mech) = @_;
    _log_in_as( $mech, 'curator@example.com', 'Connie Curator' );
}

sub _log_in_as {
    my ( $mech, $email, $name ) = @_;

    # Quietly clear out any existing login first
    $mech->get('http://localhost/auth/logout');

    # Now try (with tests!) the requested login
    $mech->get_ok('http://localhost/auth/login');
    $mech->submit_form_ok(
        {   fields => {
                email    => $email,
                password => 'fool',
            },
        },
        'Submitted the login form'
    );

    $mech->content_like( qr/$name/, 'Login successful' );
}

sub process_test_entries {
    my ( $class, $schema ) = @_;
    IFCompTestData->process_entries($schema);
}

#
# Set the comp to a specific phase
#
sub set_phase_after {
    my ( $schema, $phase ) = @_;
    my @phases = qw(announcement intents_open intents_close entries_due
        judging_begins judging_ends comp_closes);
    my $past_ymd   = DateTime->now->subtract( days => 2 )->ymd;
    my $future_ymd = DateTime->now->add( days => 2 )->ymd;

    my $hit    = 0;
    my @before = ();
    my @after  = ();
    foreach (@phases) {
        if ($hit) {
            push( @after, $_ );
        }
        else {
            push( @before, $_ );
        }
        $hit = 1 if ( $_ eq $phase );
    }
    shift(@before);    # remove the 'announcement' pseudo-phase

    my $comp = $schema->resultset('Comp')->find(2);
    foreach (@before) {
        $comp->$_($past_ymd);
    }
    foreach (@after) {
        $comp->$_($future_ymd);
    }
    $comp->update;
}

1;

__END__

=head1 NAME

IFCompTest

=head1 SYNOPSIS

    use lib qw(t/lib);
    use IFCompTest;
    use Test::More;

    my $schema = IFCompTest->init_schema;

=head1 DESCRIPTION

This module provides the basic utilities to write tests against
IFComp. Shamelessly stolen from SpoilerificTest (itself stolen from
DBICTest in the DBIx::Class test suite -- actually it's stolen from a
consulting colleague of Jason's, who stole it in turn from DBIC...)

=head1 METHODS

=head2 init_schema

    my $schema = IFCompTest->init_schema;

This method removes the test SQLite database in t/db/IFComp.db
and then creates a new database populated with default test data.
