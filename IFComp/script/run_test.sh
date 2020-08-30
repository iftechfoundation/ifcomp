#! /bin/bash

container=$(docker ps | grep ifcomp_web | awk '{print $1}')

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
    if [ ! -f "$topdir/IFComp/t/$1" ]
    then
        echo test "$1" not found
        exit 1
    fi
fi

cmd="cd /home/ifcomp/IFComp"
if [ -z "$1" -o "$1" = "xt" ]
then
    cmd="$cmd && cpanm -qn Perl::Tidy Code::TidyAll Test::Code::TidyAll"
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
