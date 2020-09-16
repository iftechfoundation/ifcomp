package Plack::Middleware::IFComp;

use Moose;
extends 'Plack::Middleware';

use IFComp::Schema;
use Config::Any;
use FindBin;
use Plack::Request;
use MIME::Base64;
use Storable qw( thaw );
use Crypt::Eksblowfish::Blowfish;

has 'schema' => (
    is         => 'ro',
    isa        => 'IFComp::Schema',
    lazy_build => 1,
);

has 'config' => (
    is         => 'rw',
    isa        => 'HashRef',
    lazy_build => 1,
);

sub _build_config {
    my $self       = shift;
    my $config_ref = Config::Any->load_files(
        {   files => [
                "$FindBin::Bin/conf/ifcomp_local.conf",
                "$FindBin::Bin/conf/ifcomp.conf",
            ],
            flatten_to_hash => 1,
            use_ext         => 1,
        },
    );
    return $config_ref;
}

sub _build_schema {
    my $self = shift;

    my $connect_info_ref;
    my $config_ref = $self->config;
    for my $file ( keys %$config_ref ) {
        if ( $config_ref->{$file}->{'Model::IFCompDB'} ) {
            $connect_info_ref =
                $config_ref->{$file}->{'Model::IFCompDB'}->{connect_info};
            last if $connect_info_ref;
        }
    }

    unless ($connect_info_ref) {
        die "Can't find any DB connect info in the app's config files?";
    }

    my $schema = IFComp::Schema->connect($connect_info_ref);
    return $schema;
}

sub call {
    my ( $self, $env ) = @_;

    my $res;
    if ( $env->{PATH_INFO} =~ m{^/(\d+)} ) {
        my $entry_id = $1;
        my $entry    = $self->schema->resultset('Entry')->find($entry_id);

        # If this game is from a previous comp, then we don't host it any more.
        # Forward to its IFDB page instead.
        my $current_comp = $self->schema->resultset('Comp')->current_comp;
        if (   $entry
            && ( $entry->comp->id ne $current_comp->id )
            && $entry->ifdb_id )
        {
            my $ifdb_url =
                'http://ifdb.tads.org/viewgame?id=' . $entry->ifdb_id;
            $res = [
                301,
                [ Location => $ifdb_url ],
                [   "<p>This work is no longer hosted on the IFComp website. "
                        . "Please visit its permanent entry in the IFDB, at "
                        . qq{<a href="$ifdb_url">$ifdb_url</a>.</p>},
                ],
            ];
        }
        elsif ($entry
            && ( $entry->comp->status ne 'open_for_judging' )
            && ( $entry->comp->status ne 'processing_votes' )
            && ( $entry->comp->status ne 'over' ) )
        {
            # Peek into the current user's session data to make sure they're not
            # the owner of this entry (and thus authorized to see it early)
            # XXX This is fragile and rude. It was implemented quickly due to
            #     a discovered security flaw. This should ideally use the same
            #     objects used elsewhere for session & cookie management,
            #     rather than these manual, literal peeks.
            my $req = Plack::Request->new($env);
            my $key = $self->config->{blowfish_key};

            my $current_user_can_see_this_game = 0;
            my $encrypted_user_id              = $req->cookies->{user_id};

            # See IFComp::Controller::Auth for how the user id gets encrypted
            # (and why it's decrypted the way it is, below).
            if ( $key && $encrypted_user_id ) {

                my $user_id =
                    Crypt::Eksblowfish::Blowfish->new($key)
                    ->decrypt( join q{},
                    unpack( 'CCCCCCCC', $encrypted_user_id ) );
                my $user = $self->schema->resultset('User')->find($user_id);
                if ( defined $user ) {
                    if ( $user_id == $entry->author->id ) {
                        $current_user_can_see_this_game = 1;
                    }
                    elsif ( grep { $_->name eq 'curator' } $user->roles->all )
                    {
                        $current_user_can_see_this_game = 1;
                    }
                }
            }

            unless ($current_user_can_see_this_game) {
                $res = [
                    301,
                    [ Location => '/' ],
                    [   "<p>This work is not visible to the public at this time.</p>"
                    ],
                ];
            }
        }
    }

    $res = $self->app->($env) unless $res;

    return $res;
}

1;
