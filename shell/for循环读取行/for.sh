#!/bin/sh
IFS=$'\n\n'
for a in `cat 1.sql`
do
        time=`date +%Y%m%d%H%M%S`
        mysql -h$1 -u$2 -p$3 $4 -e "$a" > 2.txt
        \cp 2.txt 1.txt
        sed -i 's/,/ /g;s/\t/\t,/g;s/$/\t/g' 1.txt
        iconv -f utf8 -t gbk -c 1.txt >  1.csv
        sleep 1
        cp 1.csv /usr/local/nginx/html/$time.csv
        sleep 1
        echo "http://127.0.0.1/$time.csv"
done
