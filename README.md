IFComp
======

_The software behind the Interactive Fiction Competition._

This is the software that runs [the Interactive Fiction Competition](http://ifcomp.org), a.k.a. the IFComp, an annual celebration of independently authored, text-based video games that [began in 1995](http://www.ifcomp.org/history/).

The organization of the IFComp changed hands after its 2013 iteration, and the new organizer elected to come at the role with, among other things, a wholly refreshed, public-facing web application. The software found in this repository resulted. We created its first draft over the course of the 2014 IFComp, and it has served the competition annually since then.

## Repository info

### Basics

This is a LAMP application whose server-side business logic is implemented in Perl, using a modern, Moose-based dialect, by way of the Catalyst web application framework.

Note that the software additionally performs some goofy business involving system calls to a couple of custom PHP scripts (found in the `scripts/` directory) based on HTTP endpoints defined in `IFComp::Controller::Profile`. These are necessary to support a custom API for secure, federated logins used by a handful of other sites in the IF community. This controller and these scripts are otherwise not used by the IFComp itself; forks of this repository may feel free to disregard them.

### Branches

* `master` is what's running at http://www.ifcomp.org right now.

* `dev` is the shared development branch, corresponding to a (restricted-access) project staging server.

### Code style

We maintain a standard code style by way of [tidyall](https://metacpan.org/pod/distribution/Code-TidyAll/bin/tidyall). Note the presence of a `.tidyallrc` file at the top level of this repository.

Before pushing up any new work on this repository, whether proposed or hotfix, please pass it through `tidyall` first.

## Installation and setup

### Installing dependencies

#### Perl libraries

To install this project's CPAN dependencies, run the following command from the IFComp/ directory of your cloned repository (the directory that contains the file called "cpanfile"):

    curl -fsSL https://cpanmin.us | perl - --installdeps .
    
(If you already have _cpanm_ installed, you can just run `cpanm --installdeps .` instead.)

This should crunch though the installation of a bunch of Perl modules. It'll take a few minutes.

If you're planning on contributing to the project, you'll want some additional modules. Use the `--with-develop` option with the _cpanm_ command. eg.

    curl -fsSL https://cpanmin.us | perl - --installdeps --with-develop .

#### PHP libraries

You'll need to install both PHP and the PHP MCrypt module. Both should be available through your package manager of choice. (E.g. on Debian, `sudo apt-get install php5-mcrypt` will do the trick.)

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

## Contributors

The project maintainer is Jason McIntosh ([jmac@jmac.org](jmac@jmac.org)).

Major contributors to this codebase include:

* Adam Herzog ([adam@adamherzog.com](mailto:adam@adamherzog.com))
* Joe Johnston ([joe.johnston@gmail.com](mailto:joe.johnston@gmail.com))
* Jason McIntosh ([jmac@jmac.org](mailto:jmac@jmac.org)).
* Dan Shiovitz ([dans@drizzle.com](mailto:dans@drizzle.com))

For a list of contributors to the larger IFComp project, see [the IFComp credits page](http://www.ifcomp.org/about/contact).

## Copyright and license information

Except where otherwise noted, the software found in this repository is copyright © 2017 [Interactive Fiction Technology Foundation](http://iftechfoundation.org). INTERACTIVE FICTION TECHNOLOGY FOUNDATION, IFCOMP and the IFTF trademarks are property of the Interactive Fiction Technology Foundation, a Delaware nonprofit corporation.

This repository contains, in whole or in part, a number of third-party open-source IF-related tools. See the file LICENSE.md for further information.
