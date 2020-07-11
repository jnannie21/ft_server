upstream php-fpm
{
	# PHP5-FPM сервер
	server unix:/var/run/php/php7.3-fpm.sock;
}

server
{
	listen 80;
	server_name ftserver.com www.ftserver.com;
	return 301  https://$server_name$request_uri;
}

server
{
	listen	80;
	listen	443	ssl;	# использовать шифрование для этого порта
	root	/var/www/ftserver.com;
	index	index.php index.html index.htm;
	server_name		ftserver.com www.ftserver.com;
	ssl_certificate /etc/ssl/certs/ftserver.com_nginx.crt;      # сертификат (можно свободно распространять)
	ssl_certificate_key /etc/ssl/private/ftserver.com_nginx.key;    # приватный ключ (секретный файл - НИКОМУ НЕ ПОКАЗЫВАТЬ)

location ~ \.php$
{
	try_files	$uri $uri/ =404;
	fastcgi_pass php-fpm;
	include fastcgi_params;
	fastcgi_param	SCRIPT_FILENAME		/var/www/ftserver.com/$fastcgi_script_name;
	fastcgi_param	PATH_TRANSLATED		/var/www/ftserver.com/$fastcgi_script_name;
	fastcgi_index	index.php;
	#fastcgi_pass unix:/var/run/php/php7.3-fpm.sock;
}

location ~
{
    autoindex   on;
}
}
