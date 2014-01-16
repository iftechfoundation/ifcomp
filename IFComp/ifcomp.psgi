use strict;
use warnings;

use IFComp;

my $app = IFComp->apply_default_middlewares(IFComp->psgi_app);
$app;

