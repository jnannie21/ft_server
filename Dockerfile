FROM debian:buster
RUN apt-get -y update; \
apt-get -y install nginx; \
apt-get -y install php php-fpm php-cli php-mysql; \
apt-get -y install mariadb-server; \
apt-get -y install curl;

# phpmyadmin
RUN curl -fsSL -o /tmp/phpMyAdmin.tar.xz https://files.phpmyadmin.net/phpMyAdmin/5.0.2/phpMyAdmin-5.0.2-all-languages.tar.xz; \
mkdir /var/www/phpmyadmin; \
tar -xf /tmp/phpMyAdmin.tar.xz --strip-components=1 --directory=/var/www/phpmyadmin/; \
rm /tmp/phpMyAdmin.tar.xz;
COPY srcs/config.sample.inc.php /var/www/phpmyadmin/config.inc.php

# mysql
RUN service mysql start; \
echo "CREATE DATABASE ftserver;" | mysql -u root; \
echo "GRANT ALL PRIVILEGES ON ftserver.* TO 'root'@'localhost';" | mysql -u root; \
echo "update mysql.user set plugin='mysql_native_password' where user='root';" | mysql -u root; \
echo "FLUSH PRIVILEGES;" | mysql -u root;

# ssl
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/ftserver.com_nginx.key -out /etc/ssl/certs/ftserver.com_nginx.crt -subj "/C=RU/ST=KZ/L=Kazan/O=21School/OU=21kazan/CN=ftserver.com"; \
chown www-data:www-data /etc/ssl/private/ftserver.com_nginx.key; \
chmod 400 /etc/ssl/private/ftserver.com_nginx.key;

# copy nginx config
COPY srcs/ftserver.com /etc/nginx/sites-available/ftserver.com
RUN ln -s /etc/nginx/sites-available/ftserver.com /etc/nginx/sites-enabled/; \
rm /etc/nginx/sites-available/default; \
rm /etc/nginx/sites-enabled/default;

# wp
RUN mkdir /var/www/wordpress; \
curl -fsSL -o /tmp/wordpress.tar.gz https://wordpress.org/latest.tar.gz; \
tar -xf /tmp/wordpress.tar.gz --strip-components=1 --directory=/var/www/wordpress/; \
rm /tmp/wordpress.tar.gz;
COPY srcs/wp-config-sample.php /var/www/wordpress/wp-config.php

RUN chmod -R 755 /var/www/;

# script to start services
COPY srcs/start.sh /tmp/
ENV AUTOINDEX="on"
EXPOSE 80
EXPOSE 443
CMD /tmp/start.sh
