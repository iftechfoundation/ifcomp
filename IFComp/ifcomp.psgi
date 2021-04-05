use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/lib";

use IFComp;
use Plack::Builder;

use File::MimeInfo;

builder {
    enable "IFComp";
    enable "Plack::Middleware::Static",
        path => qr{^/static/},
        root => "root";
    enable "Plack::Middleware::Static",
        path         => qr{^/\d+/},
        root         => "entries",
        content_type => sub {
        Plack::MIME->mime_type( $_[0] ) || mimetype( $_[0] );
        },
        ;

    my $app = IFComp->apply_default_middlewares( IFComp->psgi_app );
    $app;
};

