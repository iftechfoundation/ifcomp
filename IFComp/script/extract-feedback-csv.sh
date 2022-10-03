#! /bin/bash

rm /var/results/2021-author-feedback.csv
mysql -u root ifcomp -e 'select e.title,f.text from user u, entry e, feedback f where f.entry=e.id and f.judge=u.id and e.comp=31 into outfile "/var/results/2021-author-feedback.csv" fields terminated by "," enclosed by "\""'
