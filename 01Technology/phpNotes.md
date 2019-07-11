# php notes

## Code

### Comment

// one line comment

/* */ mutiple line comment

### [500 internal server error, how to debug](https://stackoverflow.com/questions/22170864/500-internal-server-error-how-to-debug)

turn on your PHP errors with error_reporting:

``` php

error_reporting(E_ALL);
ini_set('display_errors', 'on');
```

## [How To Install Linux, Nginx, MySQL, PHP (LEMP stack) in Ubuntu 16.04](https://www.digitalocean.com/community/tutorials/how-to-install-linux-nginx-mysql-php-lemp-stack-in-ubuntu-16-04)

the main php-fpm configuration file `/etc/php/7.0/fpm/php.ini`
show version `php -v`  
show configuration file path: `php -i | grep php.ini` reload `nginx -s reload` make it effective after edit php.ini
log path: `/var/log/php`

`php -r 'phpinfo()';`
`php-fpm restart`;
restart PHP processor: `sudo systemctl restart php7.0-fpm`

Configure Nginx: `sudo vi /etc/nginx/sites-enabled/default`

Enable Nginx and PHP-FPM on system boot:

`sudo systemctl enable nginx.service`  
`sudo systemctl enable php7.1-fpm.service`  

``` nginx
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

``` php
<?php
phpinfo();
?>
```

`php -r 'mysql_connect();'` 测试MySQL连接成功
`php -r 'phpinfo()';`
`mysql_config --socket` check mysql socket path