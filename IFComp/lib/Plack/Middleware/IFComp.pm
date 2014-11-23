package Plack::Middleware::IFComp;

use Moose;
extends 'Plack::Middleware';

use IFComp::Schema;

has 'schema' => (
    is => 'ro',
    isa => 'IFComp::Schema',
    lazy_build => 1,
);

# XXX This should read from the config. Oh well! Maybe next year!!
sub _build_schema {
    my $schema = IFComp::Schema->connect( 'dbi:mysql:ifcomp', 'root', '' );
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
