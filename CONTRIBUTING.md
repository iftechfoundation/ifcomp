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

## Configuration

### Overview

The docker compose file starts three containers:

 * `app` runs the [Catalyst](http://www.catalystframework.org/) server, which automatically restarts when you save changes

 * `web` runs Apache, which servers static files and proxies requests to the `app` service.
 
 * `db` runs the MariaDB database

Once the containers are up and running (`docker-compose up`) the `app` container will be available on port 8080. You should be able to point your browser at http://localhost:8080/ and see the IFComp homepage.

### Connecting to the database

Connecting to the database manually will allow you to create a new user (or add columns/tables if the schema changed since you last rebased). You'll need to bea ble to do this too, there is no user you can log in with. Because the docker config does not support sending email, the easiest way to add a user is by accessing the database manually.

First, run a shell inside the ifcomp_app container:

```
$ ./script/shell.sh
```

Inside the container, you can run the mysql command to connect to the database:

```
root@<CONTAINER ID>:/opt/IFComp# mysql -h db ifcomp
```

From there, you can create a user:

```
MariaDB [ifcomp]> insert into user (name,password_md5,email,verified) values('test',MD5('test'),'test@example.com',1);
```

You should then be able to connect to http://localhost:8080/ and login with username `test@example.com` and password `test`. Note that you'll get a warning saying that your password is not secure (because we're using the md5 variant), but you can ignore that as nobody else but you are going to access the development environment. If you want to avoid this warning you'll need to create a bcrypt-encoded password and put that in the `password` field instead of the `password_md5` field.

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

There is a script called `IFComp/script/run_test.sh`. It will find the current `web` docker container, and issue it the appropriate test command based on the arguments. This way the unit tests are run inside the same docker container that the ifcomp server is running in.

* If run with 0 arguments, it runs both the unit tests and tidyall

* If run with the argument `t` or `xt` it runs just those subdirectories

* If run with the name of a specific test (e.g. `run_test.sh controller_Entry.t`) then it will run just that unit test, but in verbose mode.
