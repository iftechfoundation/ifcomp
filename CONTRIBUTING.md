So you want to be a developer
=============================

## Docker

We use [Docker](https://www.docker.com/) for our development environment. That link provides details on how to get docker up and running, but the basic steps are:

* Go to Docker's [getting started](https://www.docker.com/get-started) page and downlaod the Docker Desktop for your OS
* Install the docker desktop and start it running
* Clone the ifcomp repo into a folder on your computer
* From your shell, change to the directory `IFComp-Dev` and run `docker-compose build` which will create the docker images and install perl and the ifcomp's dependencies
* Run `docker-compose up` which will start the docker images

Note that you can also [set up a development environment by hand](https://github.com/iftechfoundation/ifcomp/wiki/Manual-Installation-and-Setup), if you don't want to use Docker for some reason.

## Developer Environment

### Overview

The docker compose file starts three containers:

 * `app` runs the [Catalyst](http://www.catalystframework.org/) server, which automatically restarts when you save changes

 * `web` runs Apache, which servers static files and proxies requests to the `app` service.
 
 * `db` runs the MariaDB database

Once the containers are up and running (`docker-compose up`) the `app` container will be available on port 8080. You should be able to point your browser at http://localhost:8080/ and see the IFComp homepage.

### Executing Commands

You can execute commands directly on the app service by running `docker-compose exec app COMMAND`.

There are a number of convenience scripts in `IFcomp-Dev/script` as well.

 * shell.sh
 
   This script will get you a bash shell in the app instance.
 
 * tidyall.sh
 
   This script will execute `tidyall -a`, ensuring that the codebase confirms to the projects coding style. See below for additional information.
 
 * prove.sh
  
   Execute `prove` on the app instance. Any arguments will be passed through, so can run `./script/prove.sh -s` to shuffle the tests, or `./script/prove.sh t/test.t` to run just the test.t file.
  
 * load_test_data.sh
 
   Resets the development database and test files. See below for additional information.

### Test Data and Files

The first time you run `docker-compose up`, a new database will be deployed, test data will be installed, and test files will be copied into place.

The database data and test files are the same data and files used by the tests in IFComp/t.

At any time, you can completely reset your database and test files by running `./script/load_test_data.sh`. *WARNING*: This will completely reset your database, and replace _all_ of the files in your `entries` directory.

Additional data can be added by editing IFComp/t/lib/IFCompTestData.

Additional test entries can be added by placing the files into IFComp/t/test_files/entries.

It's necessary to run `./script/load_test_data.sh` after adding data or test entries.

## Repository info

### Basics

This is a LAMP application whose server-side business logic is implemented in Perl, using a modern, Moose-based dialect, by way of the Catalyst web application framework.

Note that the software additionally performs some goofy business involving system calls to a couple of custom PHP scripts (found in the `scripts/` directory) based on HTTP endpoints defined in `IFComp::Controller::Profile`. These are necessary to support a custom API for secure, federated logins used by a handful of other sites in the IF community. This controller and these scripts are otherwise not used by the IFComp itself; forks of this repository may feel free to disregard them.

### Branches

* `master` is what's running at http://www.ifcomp.org right now.

* `dev` is the shared development branch, corresponding to a (restricted-access) project staging server.

### Code style

We maintain a standard code style by way of [tidyall](https://metacpan.org/pod/distribution/Code-TidyAll/bin/tidyall). Note the presence of a `.tidyallrc` file in the IFComp directory.

Before pushing up any new work on this repository, whether proposed or hotfix, please pass it through `tidyall` first.

## Testing

### Unit tests and Tidyall

There are a number of unit tests under the `IFComp/t` subdirectory which all pass. When making changes to the code, try to add a test for it.

As mentioned above, run your source through `tidyall` before submitting a PR. There is a test that all code conforms to the code style as well. If this test fails, you'll need to run `./script/tidyall.sh` to format the code appropriately.

### Running the tests

There is a script called `IFComp-Dev/script/prove.sh`. It will execute `prove` on the app service, which will execute all of the tests in the `IFComp/t` directory.

Any arguments will be passed through, so you can, for example, run `./script/prove.sh -s` to shuffle the tests, or `./script/prove.sh t/test.t` to run just the test.t file.
