#!/bin/sh

echo "Waiting for mysql" 1>&2
mysql -h db < /dev/null
while [ $? != 0 ]
do
    sleep 1
    mysql -h db < /dev/null
done

echo "Checking that the db exists"
mysql -h db -e "use ifcomp; select count(*) from user;" > /dev/null 2>&1
if [ $? != 0 ]
then
    echo "Deploying database"
    /opt/IFComp/script/ifcomp_deploy_db.pl
fi

echo "Starting IFComp server"
/opt/IFComp/script/ifcomp_server.pl -r -d
