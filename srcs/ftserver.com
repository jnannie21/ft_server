server
{
	listen 80;
	server_name ftserver.com www.ftserver.com;
	return 301  https://$server_name$request_uri;
}

server
{
	listen	80;
	listen	443	ssl;
	root	/var/www/;
	index	index.php index.html index.htm;
	server_name		ftserver.com www.ftserver.com;
	ssl_certificate /etc/ssl/certs/ftserver.com_nginx.crt;
	ssl_certificate_key /etc/ssl/private/ftserver.com_nginx.key;

location ~\.php$
{
	try_files	$uri $uri/ =404;
	fastcgi_pass unix:/var/run/php/php7.3-fpm.sock;
	include fastcgi_params;
	fastcgi_param	SCRIPT_FILENAME		/var/www/$fastcgi_script_name;
	fastcgi_param	PATH_TRANSLATED		/var/www/$fastcgi_script_name;
	fastcgi_index	index.php;
}

location "/"
{
    autoindex	on;
}
}
