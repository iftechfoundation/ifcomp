package IFCompTest;
use strict;
use warnings;
use Carp qw( cluck );

$SIG{ __WARN__ } = sub { cluck shift };

use base qw( Exporter );
our @EXPORT    = qw( elt );
our @EXPORT_OK = qw( elt );

use FindBin;

$ENV{IFCOMP_SITE_CONFIG} = "$FindBin::Bin/conf/ifcomp.conf";

use utf8;
use Carp qw(croak);
use English;
use File::Path qw(make_path remove_tree);

use IFComp::Schema;

my $db_dir    = "$FindBin::Bin/db";
my $db_file   = "$db_dir/IFComp.db";
my $dsn       = "dbi:SQLite:$db_file";

# XXX It's perhaps not ideal to read the config file, just to grab twitter keys, which
#     in turn are only for connecting to the Twitter API and testing the current length
#     of shortened URLs. But the alternative if just faking that API call, and I dunno
#     if that's much better...
# use Config::Any;
# my $config = Config::Any->load_files({
#     files => [
#         "$FindBin::Bin/conf/ifconf.conf",
#     ],
#     use_ext => 1,
#     flatten_to_hash => 1,
#                                      });
sub connect_info
{
    my ($self) = shift;
    return ($dsn, 
            '', 
            '', 
            {
                sqlite_unicode => 1,
                on_connect_call => 'use_foreign_keys',
            });
}

sub init_schema 
{
    my $self = shift;
    my %args = @_;

    if (-e $db_file) 
    {
        unless (unlink $db_file)
        {
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

    $schema->populate(
        'User',
        [
            ['id', 'name', 'password', 'salt', 'email', 'email_is_public', 'url'], 
            [ 1, 'user1', '', '123456', 'testing@taskboy.com', 1, 'http://taskboy.com/' ],
        ],
        );

    return $schema;
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

