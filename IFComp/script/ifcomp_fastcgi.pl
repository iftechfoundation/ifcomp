#!/usr/bin/env perl

use Catalyst::ScriptRunner;
Catalyst::ScriptRunner->run( 'IFComp', 'FastCGI' );

1;

=head1 NAME

ifcomp_fastcgi.pl - Catalyst FastCGI

=head1 SYNOPSIS

ifcomp_fastcgi.pl [options]

 Options:
   -? --help      display this help and exit
   -l --listen   socket path to listen on
                 (defaults to standard input)
                 can be HOST:PORT, :PORT or a
                 filesystem path
   -n --nproc    specify number of processes to keep
                 to serve requests (defaults to 1,
                 requires --listen)
   -p --pidfile  specify filename for pid file
                 (requires --listen)
   -d --daemon   daemonize (requires --listen)
   -M --manager  specify alternate process manager
                 (FCGI::ProcManager sub-class)
                 or empty string to disable
   -e --keeperr  send error messages to STDOUT, not
                 to the webserver
   --proc_title  Set the process title (if possible)

=head1 DESCRIPTION

Run a Catalyst application as FastCGI.

=head1 AUTHORS

Catalyst Contributors, see Catalyst.pm




=cut
