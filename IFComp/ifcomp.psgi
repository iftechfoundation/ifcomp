use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/lib";

use IFComp;

my $app = IFComp->apply_default_middlewares(IFComp->psgi_app);
$app;

