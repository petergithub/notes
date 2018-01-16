

[How To Install Linux, Nginx, MySQL, PHP (LEMP stack) in Ubuntu 16.04](https://www.digitalocean.com/community/tutorials/how-to-install-linux-nginx-mysql-php-lemp-stack-in-ubuntu-16-04)    

the main php-fpm configuration file `/etc/php/7.0/fpm/php.ini`
show version `php -v`  
restart PHP processor: `sudo systemctl restart php7.0-fpm` 

Configure Nginx: `sudo vi /etc/nginx/sites-enabled/default`

Enable Nginx and PHP-FPM on system boot:

`sudo systemctl enable nginx.service`  
`sudo systemctl enable php7.1-fpm.service`  

```
	
	server {
	    listen 80 default_server;
	    listen [::]:80 default_server;
	
	    root /var/www/html;
	    index index.php index.html index.htm index.nginx-debian.html;
	
	    server_name server_domain_or_IP;
	
	    location / {
	        try_files $uri $uri/ =404;
	    }
	
	    location ~ \.php$ {
	        include snippets/fastcgi-php.conf;
            fastcgi_index  index.php;
	        fastcgi_pass unix:/run/php/php7.0-fpm.sock;
            #fastcgi_pass   127.0.0.1:9000;
	    }
	
	    location ~ /\.ht {
	        deny all;
	    }
	}
```

Create a PHP File to Test Configuration
`sudo vi /var/www/html/info.php` and visit with `http://localhost/info.php`

```

	<?php
	phpinfo();
	?>
```