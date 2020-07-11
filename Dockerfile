FROM debian:buster
RUN apt-get -y update; \
apt-get -y install nginx; \
apt-get -y install php7.3-fpm php7.3-common php7.3-mysql php7.3-gmp php7.3-curl php7.3-intl php7.3-mbstring php7.3-xmlrpc php7.3-gd php7.3-xml php7.3-cli php7.3-zip php7.3-soap php7.3-imap; \
apt-get -y install mariadb-server; \
apt-get -y install curl;
# phpmyadmin
RUN curl -fsSL -o /tmp/phpMyAdmin.tar.xz https://files.phpmyadmin.net/phpMyAdmin/5.0.2/phpMyAdmin-5.0.2-all-languages.tar.xz; \
mkdir /var/www/ftserver.com; \
mkdir /var/www/ftserver.com/phpmyadmin; \
tar -xf /tmp/phpMyAdmin.tar.xz --strip-components=1 --directory=/var/www/ftserver.com/phpmyadmin/; \
rm /tmp/phpMyAdmin.tar.xz;
COPY srcs/config.sample.inc.php /var/www/ftserver.com/phpmyadmin/config.inc.php
# mysql
RUN service mysql start; \
echo "CREATE DATABASE wordpress;" | mysql -u root --skip-password; \
echo "GRANT ALL PRIVILEGES ON wordpress.* TO 'root'@'localhost' WITH GRANT OPTION;" | mysql -u root --skip-password; \
echo "update mysql.user set plugin='mysql_native_password' where user='root';" | mysql -u root --skip-password; \
echo "FLUSH PRIVILEGES;" | mysql -u root --skip-password;
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
RUN curl -fsSL -o /tmp/wordpress.tar.gz https://wordpress.org/latest.tar.gz; \
tar -xf /tmp/wordpress.tar.gz --strip-components=1 --directory=/var/www/ftserver.com/; \
rm /tmp/wordpress.tar.gz;
COPY srcs/wp-config-sample.php /var/www/ftserver.com/wp-config.php
RUN chown -R www-data /var/www/*; \
chmod -R 755 /var/www/*;
# test folder
RUN mkdir /var/www/ftserver.com/test;
COPY srcs/start.sh /tmp/
ENV AUTOINDEX="on"
EXPOSE 80
EXPOSE 443
CMD /tmp/start.sh
