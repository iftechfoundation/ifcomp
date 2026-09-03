#!/bin/sh

docker compose exec app perl ./script/build_zip_of_zips.pl --docker
