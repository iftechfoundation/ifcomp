IFComp
======

_The software behind the Interactive Fiction Competition._

[![Build Status](https://api.travis-ci.org/iftechfoundation/ifcomp.svg?branch=master)](https://travis-ci.org/iftechfoundation/ifcomp)

This is the software that runs [the Interactive Fiction Competition](http://ifcomp.org), a.k.a. the IFComp, an annual celebration of independently authored, text-based video games that [began in 1995](http://www.ifcomp.org/history/).

The organization of the IFComp changed hands after its 2013 iteration, and the new organizer elected to come at the role with, among other things, a wholly refreshed, public-facing web application. The software found in this repository resulted. We created its first draft over the course of the 2014 IFComp, and it has served the competition annually since then.

## Installation and setup

### Installing dependencies

#### Perl libraries

To install this project's CPAN dependencies, run the following command from the IFComp/ directory of your cloned repository (the directory that contains the file called "cpanfile"):

    curl -fsSL https://cpanmin.us | perl - --installdeps .
    
(If you already have _cpanm_ installed, you can just run `cpanm --installdeps .` instead.)

This should crunch though the installation of a bunch of Perl modules. It'll take a few minutes.

If you're planning on contributing to the project, you'll want some additional modules. Use the `--with-develop` option with the _cpanm_ command. eg.

    curl -fsSL https://cpanmin.us | perl - --installdeps --with-develop .

### Application configuration

Copy `conf/ifcomp_local.conf-dist` to `conf/ifcomp_local.conf` and then update the database pointers therein as appropriate.

### Database configuration

Run script/ifcomp_deploy_db.pl to construct the database tables (having first
created the database, user, and password, and set up the application
configuration appropriately). Note this script won't fill in the role table,
the comp table, or the federated_site table. The last of these isn't required
for most operation, but the first two do need to be manually filled in once
the tables are created.

### Making it go

It's a Catalyst application, and works as any other. See [the Catalyst documentation](https://metacpan.org/pod/Catalyst::Manual) for more details.

The application's central control script is `ifcomp.psgi`, found at the top level within the `IFComp` directory. A basic way to launch the application from the command line, for the sake of local testing:

```
plackup ifcomp.psgi
```

Assuming that you have all the necessary prerequisites (including the `plackup` program!) installed and available to your local Perl, this should launch the web application and bind it to localhost, port 5000, and write out access and error logs to the terminal. See the `plackup` manpage for various command-line configuration options (such as changing the port to use, or having the script automatically reload when it detects code changes).

## Contributors

The project maintainer is Jason McIntosh (<jmac@jmac.org>).

Other contributors to this repository include:

* Jacqueline Ashwell
* Dan Fabulich
* Adam Herzog
* Joe Johnston
* Mark Musante
* Dan Shiovitz
* Amy Swartz
* Dannii Willis

For a list of contributors to the larger IFComp project, see [the IFComp credits page](http://www.ifcomp.org/about/contact).

## Copyright and license information

Except where otherwise noted, the software found in this repository is copyright © 2017-2020 [Interactive Fiction Technology Foundation](http://iftechfoundation.org). INTERACTIVE FICTION TECHNOLOGY FOUNDATION, IFCOMP and the IFTF trademarks are property of the Interactive Fiction Technology Foundation, a Delaware nonprofit corporation.

This repository contains, in whole or in part, a number of third-party open-source IF-related tools. See the file LICENSE.md for further information.
