#!/bin/sh
sed -i "s/autoindex	on/autoindex	$AUTOINDEX/g" /etc/nginx/sites-available/ftserver.com
service php7.3-fpm start
service nginx start
service mysql start
/bin/sh
