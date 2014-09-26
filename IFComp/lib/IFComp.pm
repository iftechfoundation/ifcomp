package IFComp;
use Moose;
use namespace::autoclean;

use Catalyst::Runtime 5.80;

# Set flags and add plugins for the application.
#
# Note that ORDERING IS IMPORTANT here as plugins are initialized in order,
# therefore you almost certainly want to keep ConfigLoader at the head of the
# list if you're using it.
#
#         -Debug: activates the debug mode for very useful log messages
#   ConfigLoader: will load the configuration from a Config::General file in the
#                 application's home directory
# Static::Simple: will serve static files from the application's root
#                 directory

use Catalyst qw/
    ConfigLoader
    Static::Simple
    Authentication
    Session
    Session::Store::FastMmap
    Session::State::Cookie
    Cache
    PageCache
/;

extends 'Catalyst';

our $VERSION = '0.01';

# Configure the application.
#
# Note that settings in ifcomp.conf (or other external
# configuration file that you set up manually) take precedence
# over this when using ConfigLoader. Thus configuration
# details given here can function as a default configuration,
# with an external configuration file acting as an override for
# local deployment.

__PACKAGE__->config(
    name => 'IFComp',
    # Disable deprecated behavior needed by old applications
    disable_component_resolution_regex_fallback => 1,
    enable_catalyst_header => 1, # Send X-Catalyst header
    encoding => 'UTF-8',
    'Plugin::ConfigLoader' => {file => "conf/" }, # Load configs from the conf dir
    'Plugin::Authentication' => {
        default_realm => "default",
        default => {
            credential => {
                class => "Password",
                password_field => "password",
                password_type => "self_check",
            },
            store => {
                class => "DBIx::Class",
                user_model => "IFCompDB::User",
                store_user_class => 'IFComp::UserStore',
            },
        },
    },
    'Plugin::Session' => {
        'expires' => 31536000, # Year
        'rewrite' => 0,
        'storage' => '/tmp/ifcomp.session',
    },
    'Plugin::Static::Simple' => {
        dirs => [
            'static',
        ],
        include_path => [
            IFComp->config->{root} . '/../entries',
            IFComp->config->{root},
        ],
        ignore_extensions => [
            'tt2',
            'tt',
        ],
    },
    'Model::Covers' => {
        root_dir => __PACKAGE__->path_to('file_store')
    },
    'Plugin::Cache' => {
        'backend' => {
            class   => "Cache::FastMmap",
        },
    },
    'Plugin::PageCache' => {
        disable_index => 1,
        auto_check_user => 1,
        auto_cache => [
            '/rules/?',
            '/comp/.+',
            '/history/?',
            '/about/.*',
            '/ballot.*',
            '/',
        ],
    },
);

# Start the application
__PACKAGE__->setup();

=encoding utf8

=head1 NAME

IFComp - Catalyst based application

=head1 SYNOPSIS

    script/ifcomp_server.pl

=head1 DESCRIPTION

[enter your description here]

=head1 SEE ALSO

L<IFComp::Controller::Root>, L<Catalyst>

=head1 AUTHOR

Jason McIntosh

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
