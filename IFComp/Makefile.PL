#!/usr/bin/env perl
# IMPORTANT: if you delete this file your app will not work as
# expected.  You have been warned.
use inc::Module::Install 1.02;
use Module::Install::Catalyst; # Complain loudly if you don't have
                               # Catalyst::Devel installed or haven't said
                               # 'make dist' to create a standalone tarball.
use Module::Install::CPANfile; # Same as above, for cpanfile support

name 'IFComp';
perl_version '5.030002';
all_from 'lib/IFComp.pm';

cpanfile;

catalyst;

install_script glob('script/*.pl');
auto_install;
WriteAll;
