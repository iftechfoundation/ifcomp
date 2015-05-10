package Plack::Middleware::IFComp;

use Moose;
extends 'Plack::Middleware';

use IFComp::Schema;
use Config::Any;
use FindBin;

has 'schema' => (
    is => 'ro',
    isa => 'IFComp::Schema',
    lazy_build => 1,
);

sub _build_schema {
    my $config_ref = Config::Any->load_files(
        {
            files => [
                "$FindBin::Bin/conf/ifcomp_local.conf",
                "$FindBin::Bin/conf/ifcomp.conf",
            ],
            flatten_to_hash => 1,
        },
    );

    my $connect_info_ref;
    for my $file ( keys %$config_ref ) {
        if ( $config_ref->{ $file }->{ 'Model::IFCompDB' } ) {
            $connect_info_ref =
                $config_ref->{ $file }->{ 'Model::IFCompDB' }->{ connect_info };
            last if $connect_info_ref;
        }
    }

    unless ( $connect_info_ref ) {
        die "Can't find any DB connect info in the app's config files?";
    }

    my $schema = IFComp::Schema->connect( $connect_info_ref );
    return $schema;
}

sub call {
    my ( $self, $env ) = @_;

    my $res;
    if ( $env->{ PATH_INFO } =~m{^/(\d+)} ) {
        my $entry_id = $1;
        my $entry = $self->schema->resultset( 'Entry' )->find( $entry_id );
        if (
            $entry
            && ( $entry->comp->status ne 'open_for_judging' )
            && $entry->ifdb_id
        ) {
            my $ifdb_url = 'http://ifdb.tads.org/viewgame?id=' . $entry->ifdb_id;
            $res = [
                301,
                [ Location => $ifdb_url ],
                [ "<p>This work is no longer hosted on the IFComp website. "
                  . "Please visit its permanent entry in the IFDB, at "
                  . qq{<a href="$ifdb_url">$ifdb_url</a>.</p>}
                  ,
                ],
            ];
        }
    }

    $res = $self->app->($env) unless $res;

    return $res;
}

1;
