#!/usr/bin/env perl

#
# Skeleton for a selenium test script
#
# TODO:
# - separate out the DB setup, as it really needs to just be done once
# - create a framework that makes it easy to log in & perform actions
# - similar to the "prove" tests: make it easy to switch the comp phase

use Selenium::Remote::Driver;
use Test::More;
use DBI;

my $dsn = "DBI:mysql:database=ifcomp;host=db";
my $dbh = DBI->connect( $dsn, "root", "" );

my $search =
    $dbh->prepare('SELECT name FROM user WHERE name like "Joe Example"');
if ( $search->execute() ) {
    if ( $search->rows() != 1 ) {
        my $insert =
            $dbh->prepare( "INSERT INTO user "
                . "(name, password, email, verified) VALUES"
                . "('Joe Example', '\$2a\$08\$HrLRfNKNxeJcsKshuMQMq.iWCFALkWBLfb.Y8i6lPl2OdYEkshX4W', 'joe\@example.com', 1);"
            );
        $insert->execute() or die "Could not insert user: $dbh->errorstr()";
        $insert->finish();
    }
}
$search->finish();

my $driver = Selenium::Remote::Driver->new(
    remote_server_addr => "selenium-chrome-standalone",
    browser_name       => "chrome",
);

$driver->set_implicit_wait_timeout(3000);

ok( $driver->get("http://web/") );
is( $driver->get_title(), "The Interactive Fiction Competition" );

# $driver->capture_screenshot("/home/ifcomp/selenium/00welcome.png");

ok( $signin = $driver->find_element_by_id("signin-button") );
is( $signin->get_text(), "Sign in / Register" );
ok( $signin->click() );

# $driver->capture_screenshot("/home/ifcomp/selenium/01login.png");

ok( $email = $driver->find_element_by_id("email") );
ok( $email->click() );
ok( $email->send_keys("joe\@example.com") );

# $driver->capture_screenshot("/home/ifcomp/selenium/02email.png");

ok( $passwd = $driver->find_element_by_id("password") );
ok( $passwd->click() );
ok( $passwd->send_keys("id10t") );

# $driver->capture_screenshot("/home/ifcomp/selenium/03passwd.png");

ok( $submission = $driver->find_element_by_id("submit") );
ok( $submission->click() );

# $driver->capture_screenshot("/home/ifcomp/selenium/04done.png");

ok( $signout = $driver->find_element_by_id("signout-button") );
is( $signout->get_text(), "Sign out" );
ok( $signout->click() );

ok( $signin = $driver->find_element_by_id("signin-button") );
is( $signin->get_text(), "Sign in / Register" );

done_testing();
