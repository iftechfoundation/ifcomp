So you want to be a developer
=============================

## Setup

Assuming you've already installed [Docker](https://www.docker.com/), you
should be able to just use `docker-compose build` to set things up and then
`docker-compose up` to start the environment running. You can access the
development environment on your localhost port 3000.

The docker compose file starts three containers:

 * `mariadb` runs the database

 * `selenium-chrome-standalone` runs a headless chrome browser for testing selenium

 * `web` runs the [Catalyst](http://www.catalystframework.org/) server, which automatically restarts when you save changes

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

## Testing

### Unit tests and Tidyall

There are a number of unit tests under the `IFComp/t` subdirectory which all pass. When making changes to the code, try to add a test for it.

As mentioned above, run your source through `tidyall` before submitting a PR. There is a script which will also do this under the `IFComp/xt` subdirectory.

### Running the tests

There is a script called `IFComp/script/run_test.sh`

* If run with 0 arguments, it runs both the unit tests and tidyall

* If run with the argument `t` or `xt` it runs just those subdirectories

* If run with the name of a specific test (e.g. t/controller_Entry.t) then it
will run just those unit test, in verbose mode.

