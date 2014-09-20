use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/lib";

use IFComp;
use Plack::Builder;

builder {
    enable "Plack::Middleware::Static",
          path => qr{^/static/}, root => "$FindBin::Bin/root";
    enable "Plack::Middleware::Static",
          path => qr{^/\d+/}, root => "$FindBin::Bin/entries";

    my $app = IFComp->apply_default_middlewares(IFComp->psgi_app);
    $app;
};

