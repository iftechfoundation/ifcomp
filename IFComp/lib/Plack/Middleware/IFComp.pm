package Plack::Middleware::IFComp;

use Moose;
extends 'Plack::Middleware';

use IFComp::Schema;
use Config::Any;
use FindBin;
use Plack::Request;
use MIME::Base64;
use Storable qw( thaw );

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
            use_ext => 1,
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
        elsif (
            $entry
            && ( $entry->comp->status ne 'open_for_judging' )
            && ( $entry->comp->status ne 'processing_votes' )
            && ( $entry->comp->status ne 'over' )
        ) {
            # Peek into the current user's session data to make sure they're not
            # the owner of this entry (and thus authorized to see it early)
            # XXX This is fragile and rude. It was implemented quickly due to
            #     a discovered security flaw. This should ideally use the same
            #     objects used elsewhere for session & cookie management,
            #     rather than these manual, literal peeks.
            my $req = Plack::Request->new($env);
            my $session_id = $req->cookies->{ ifcomp_session };
            my $current_user_can_see_this_game = 0;
            if ( $session_id ) {
                my $session_row =
                    $self->schema->resultset( 'Session' )->find( "session:$session_id" );
                if ( $session_row ) {
                    my $session_ref = thaw( decode_base64( $session_row->session_data ) );
                    if ( $session_ref->{ __user } ) {
                        my $user_id = $session_ref->{ __user }->{ id };
                        if ( $user_id == $entry->author->id ) {
                            $current_user_can_see_this_game = 1;
                        }
                    }
                }
            }

            unless ( $current_user_can_see_this_game ) {
                $res = [
                    301,
                    [ Location => '/' ],
                    [ "<p>This work is not visible to the public at this time.</p>" ],
                ];
            }
        }
    }

    $res = $self->app->($env) unless $res;

    return $res;
}

1;
