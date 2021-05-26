#!/bin/sh

docker-compose exec app ./script/ifcomp_deploy_db.pl -d
docker-compose exec app ../IFComp-Dev/script/load_test_data.pl
