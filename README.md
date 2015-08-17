IFComp
======

_The software behind the Interactive Fiction Competition (as of 2014)._

This is the software that runs [the Interactive Fiction Competition](http://ifcomp.org), a.k.a. the IFComp, an annual celebration of independently authored, text-based video games that [began in 1995](http://www.ifcomp.org/history/).

The organization of the IFComp changed hands after its 2013 iteration, and the new organizer elected to come at the role with, among other things, a wholly refreshed, public-facing web application. The software found in this repository resulted. We created its first draft over the course of the 2014 IFComp, and it has served the competition annually since then.

# Repository info

## Basics

This is a LAMP application whose server-side business logic is implemented in Perl, using a modern, Moose-based dialect, by way of the Catalyst web application framework.

Note that the software additionally performs some goofy business involving system calls to a couple of custom PHP scripts (found in the `scripts/` directory) based on HTTP endpoints defined in `IFComp::Controller::Profile`. These are necessary to support a custom API for secure, federated logins used by a handful of other sites in the IF community. This controller and these scripts are otherwise not used by the IFComp itself; forks of this repository may feel free to disregard them.

## Branches

* `master` is what's running at http://www.ifcomp.org right now.

* `dev` is the shared development branch, corresponding to a (restricted-access) project staging server.

# Installation and setup

## Installing dependencies

To install this project's CPAN dependencies, run the following command from the IFComp/ directory of your cloned repository (the directory that contains the file called "cpanfile"):

    curl -fsSL https://cpanmin.us | perl - --installdeps .
    
(If you already have _cpanm_ installed, you can just run `cpanm --installdeps .` instead.)

This should crunch though the installation of a bunch of Perl modules. It'll take a few minutes.

## Database configuration

I hear rumors that one can construct a database based on the provided `IFComp::Schema` library, but that is magic presently beyond my ken.

Otherwise, this information will appear someday...

## Application configuration

Copy `conf/ifcomp_local.conf-dist` to `conf/ifcomp.local` and then update the database pointers therein as appropriate.

## Making it go

It's a Catalyst application, and works as any other. See [the Catalyst documentation](https://metacpan.org/pod/Catalyst::Manual) for more details.

# Other links

The project has [a public Pivotal Tracker](https://www.pivotaltracker.com/n/projects/1001548).

# Contributors

The project maintainer is Jason McIntosh ([jmac@jmac.org](jmac@jmac.org)).

Contributors to this codebase include Joe Johnston ([joe.johnston@gmail.com](joe.johnston@gmail.com)) and Jason McIntosh ([jmac@jmac.org](jmac@jmac.org)).

For a list of contributors to the larger IFComp project, see [the IFComp credits page](http://www.ifcomp.org/about/contact).
