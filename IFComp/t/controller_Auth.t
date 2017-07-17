use strict;
use warnings;
use Test::More;

unless ( eval q{use Test::WWW::Mechanize::Catalyst 0.55; 1} ) {
    plan skip_all => 'Test::WWW::Mechanize::Catalyst >= 0.55 required';
    exit 0;
}

use FindBin;
use lib ("$FindBin::Bin/lib");
use IFCompTest;
my $schema = IFCompTest->init_schema();

ok( my $mech =
        Test::WWW::Mechanize::Catalyst->new( catalyst_app => 'IFComp' ),
    'Created mech object'
);

test_login_and_logout( 'nobody@example.com', 'fool', 'user1' );
{
    my @emails;
    @emails = Email::Sender::Simple->default_transport->deliveries;
    is( @emails, 0 );

    $mech->get_ok('http://localhost/user/register');

    #diag ( $mech->content );

    $mech->submit_form_ok(
        {   form_number => 2,
            fields      => {
                email                 => 'somebody@example.com',
                password              => 'blarg',
                password_confirmation => 'blarg',
                name                  => 'Some Body',
            },
        },
        'Submitted registration form'
    );

    #diag ( $mech->content );
    $mech->content_like(qr/somebody\@example.com/);

    @emails = Email::Sender::Simple->default_transport->deliveries;
    is( @emails, 1 );
    my $email_text = $emails[0]->{email}->as_string;
    my ($url) = $email_text =~ /(http:\S+)/;

    # XXX Hack - we should remove the hardocded 'ifcomp.org' from the mail's URL
    $url =~ s/ifcomp.org/localhost/;

    $mech->get_ok($url);
    $mech->content_like(qr/Registration complete/i);
    test_login_and_logout( 'somebody@example.com', 'blarg', 'Some Body' );
}

{
    $mech->get_ok('http://localhost/user/request_password_reset');
    $mech->submit_form_ok(
        {   form_number => 2,
            fields      => { email => 'somebody@example.com', },
        },
        'Submitted password-change request'
    );
    my @emails = Email::Sender::Simple->default_transport->deliveries;
    my ($url) = $emails[1]->{email}->as_string =~ /(http:\S+)/;

    # XXX Hack - we should remove the hardocded 'ifcomp.org' from the mail's URL
    $url =~ s/ifcomp.org/localhost/;

    $mech->get_ok($url);

    $mech->submit_form_ok(
        {   form_number => 2,
            fields      => {
                password              => 'blargh',
                password_confirmation => 'blargh',
            },
        },
        'Submitted changed passwords'
    );
    test_login_and_logout( 'somebody@example.com', 'blargh', 'Some Body' );
}

done_testing();

sub test_login_and_logout {
    my ( $username, $password, $name ) = @_;

    $mech->get_ok('http://localhost/auth/login');
    $mech->submit_form_ok(
        {   fields => {
                email    => $username,
                password => $password,
            },
        },
        'Submitted the login form'
    );

    $mech->content_like( qr/$name/, 'Login successful' );

    $mech->get_ok('http://localhost/auth/logout');
    $mech->content_unlike( qr/$name/, 'Logout successful' );
}

