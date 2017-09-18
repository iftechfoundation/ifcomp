package IFComp::View::HTML;

use strict;
use base 'Catalyst::View::TT';

__PACKAGE__->config(
    {   INCLUDE_PATH => [
            IFComp->path_to( 'root', 'src' ),
            IFComp->path_to( 'root', 'lib' ),
        ],
        TEMPLATE_EXTENSION => '.tt',
        PRE_PROCESS        => 'config/main',
        WRAPPER            => 'site/wrapper',
        ERROR              => 'error.tt2',
        TIMER              => 0,
        render_die         => 1,
        ENCODING           => 'utf8',
    }
);

=head1 NAME

IFComp::View::HTML - Catalyst TT Twitter Bootstrap View

=head1 SYNOPSIS

See L<IFComp>

=head1 DESCRIPTION

Catalyst TTSite View.

=head1 AUTHOR

Jason McIntosh



=cut

1;

