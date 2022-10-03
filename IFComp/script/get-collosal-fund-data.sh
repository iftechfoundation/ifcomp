#! /bin/bash

rm /var/results/2021-cf-data.csv
mysql -u root ifcomp -e 'select e.place,e.title,u.name,u.email,u.paypal from entry e, user u where e.place is not null and e.author=u.id and e.comp=31 order by place into outfile "/var/results/2021-cf-data.csv" fields terminated by "," enclosed by "\""'
