#!/usr/bin/env perl

use Catalyst::ScriptRunner;
Catalyst::ScriptRunner->run( 'IFComp', 'Test' );

1;

=head1 NAME

ifcomp_test.pl - Catalyst Test

=head1 SYNOPSIS

ifcomp_test.pl [options] uri

 Options:
   --help    display this help and exits

 Examples:
   ifcomp_test.pl http://localhost/some_action
   ifcomp_test.pl /some_action

 See also:
   perldoc Catalyst::Manual
   perldoc Catalyst::Manual::Intro

=head1 DESCRIPTION

Run a Catalyst action from the command line.

=head1 AUTHORS

Catalyst Contributors, see Catalyst.pm




=cut
