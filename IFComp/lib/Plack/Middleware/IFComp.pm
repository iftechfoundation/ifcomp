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
    my $self         = shift;
    my @config_files = (
        "$FindBin::Bin/conf/ifcomp.conf",
        "$FindBin::Bin/conf/ifcomp_local.conf",
    );
    my $file_data = Config::Any->load_files(
        {   files           => \@config_files,
            use_ext         => 1,
            flatten_to_hash => 1,
        },
    );
    my %final_config;
    for my $config_file (@config_files) {
        my $config_data = $file_data->{$config_file};
        foreach ( keys %$config_data ) {
            $final_config{$_} = $config_data->{$_};
        }
    }

    return \%final_config;
}

sub _build_schema {
    my $self = shift;

    my $connect_info_ref;
    my $config_ref = $self->config;
    if ( $config_ref->{'Model::IFCompDB'} ) {
        $connect_info_ref = $config_ref->{'Model::IFCompDB'}->{connect_info};
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
            # Check for an encrypted 'user_id' cookie value to see if the
            # current user is either the author of this entry or an IFComp
            # curator. If so, then they're allowed to see the entry early.
            my $req = Plack::Request->new($env);
            my $key = $self->config->{user_id_cookie_key};

            my $current_user_can_see_this_game = 0;
            my $encrypted_user_id              = $req->cookies->{user_id};

            # See IFComp::Controller::Auth for how the user id gets encrypted
            # (and why it's decrypted the way it is, below).
            if ( $key && $encrypted_user_id ) {
                my $user_id =
                    Crypt::Eksblowfish::Blowfish->new($key)
                    ->decrypt( decode_base64($encrypted_user_id) );
                $user_id =~ s/^0+//;
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
                    403,
                    [],
                    [   "<p>This IFComp entry is not visible to the public at this time.</p>"
                    ],
                ];
            }
        }
    }

    $res = $self->app->($env) unless $res;

    return $res;
}

1;
