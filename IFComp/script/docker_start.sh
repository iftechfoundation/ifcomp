#! /bin/bash

export CATALYST_CONFIG_LOCAL_SUFFIX=docker

echo "waiting on mysql" 1>&2
mysql -h mariadb < /dev/null
while [ $? != 0 ]
do
    sleep 1
    mysql -h mariadb < /dev/null
done

echo "Checking that the db exists"
mysql -h mariadb -e "use ifcomp; select count(*) from user;" > /dev/null 2>&1
if [ $? != 0 ]
then
    echo "building database"
    script/ifcomp_deploy_db.pl
fi


echo "starting server" 1>&2
script/ifcomp_server.pl -r
