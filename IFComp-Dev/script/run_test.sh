#! /bin/bash

#
# Convenience script to make it easy to run the unit tests from within
# the docker environment.
#
# Start docker (for example 'docker-compose up'), and then execute
# this script from the command line. It will locate the web container 
# and run a bash shell within it which will execute the tests.
#
# You can also specify a test name, which it will look for under
# the IFComp/t subdirectory and run just that one in verbose mode.
#
# Options:
#
#       run_test.sh             Run all the tests, both unit and tidy.
#
#       run_test.sh xt          Run just the tidy tests
#
#       run_test.sh t           Run just the unit tests
#
#       run_test.sh $TESTNAME   Run just the test $TESTNAME in verbose mode
#
#

container=$(docker ps | grep ifcomp-dev_app | awk '{print $1}')

if [ -z "$container" ]
then
    echo Unable to find web container
    exit 1
fi

topdir=$(git rev-parse --show-toplevel)
if [ $? != 0 ]
then
    exit 1
fi

if [ -n "$1" -a "$1" != "xt" ]
then
    if [ ! -f "$topdir/t/$1" ]
    then
        echo test "$1" not found
        exit 1
    fi
fi

cmd="cd /opt/IFComp"
if [ -z "$1" -o "$1" = "xt" ]
then
    if [ -z "$1" ]
    then
        cmd="$cmd && prove -l t xt"
    else
        cmd="$cmd && prove -l xt"
    fi
else
    cmd="$cmd && prove -vl t/$1"
fi

docker exec -t "$container" bash -c "$cmd"
