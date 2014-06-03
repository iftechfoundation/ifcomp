IFComp
======

_The software behind the Interactive Fiction Competition (as of 2014)._

This is the software that runs [the Interactive Fiction Competition](http://ifcomp.org), a.k.a. the IFComp, an annual celebration of independently authored, text-based video games that [began in 1995](http://www.ifcomp.org/history/).

As of mid-2014, this project is under active development. The organization of the IFComp changed hands after its 2013 iteration, and the new organizer elected to come at the role with, among other things, a wholly refreshed, public-facing web application.

# Repository info

## Basics

This is a LAMP application whose server-side business logic is implemented in Perl, using a modern, Moose-based dialect, by way of the Catalyst web application framework.

## What's up with the PHP?

The software performs some goofy business involving system calls to a couple of custom PHP scripts (found in the `scripts/` directory) based on HTTP endpoints defined in `IFComp::Controller::Profile`. These are necessary to support a custom API for secure, federated logins used by a handful of other sites in the IF community. This controller and these scripts are otherwise not used by the IFComp itself; forks of this repository may feel free to disregard them.

## Branches

* `master` is what's running at http://www.ifcomp.org right now.

* `dev` is the shared development branch, corresponding to a (restricted-access) project staging server.

# Other links

The project has [a public Pivotal Tracker](https://www.pivotaltracker.com/n/projects/1001548).

# Contributors

The project maintainer is Jason McIntosh (jmac@jmac.org).

Contributors to this codebase include Joe Johnston (joe.johnston@gmail.com) and Jason McIntosh (jmac@jmac.org).

For a list of contributors to the larger IFComp project, see http://www.ifcomp.org/about/contact. (Or, indeed, https://github.com/jmacdotorg/ifcomp/blob/master/IFComp/root/src/about/contact.tt).
