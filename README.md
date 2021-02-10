## Install local LEMP for Mac OS X

For *Front End development*, a full Vagrant box is not always needed. If you have a new Macbook Pro, you can install local LEMP (Linux, nginx, MariaDB and PHP) with this single liner below. Please see [installation steps](#installation-steps).

```` bash
wget -O - https://raw.githubusercontent.com/digitoimistodude/macos-lemp-setup/master/install.sh | bash
````

**Please note:** Don't trust blindly to the script, use only if you know what you are doing. You can view the file [here](https://github.com/digitoimistodude/osx-lemp-setup/blob/master/install.sh) if having doubts what commands are being run. However, script is tested working many times and should be safe to run even if you have some or all of the components already installed.

### Background

Read the full story by [@ronilaukkarinen](https://github.com/ronilaukkarinen): **[Moving from Vagrant to a LEMP stack directly on a Macbook Pro (for WordPress development)](https://medium.com/@rolle/moving-from-vagrant-to-a-lemp-stack-directly-on-a-macbook-pro-e935b1bc5a38)**

### Dependencies

- [Homebrew](https://brew.sh/)
- macOS, preferably 10.14.2 (Mojave)
- wget

### Installation steps

1. Install wget, `brew install wget`
2. Run oneliner installation script `wget -O - https://raw.githubusercontent.com/digitoimistodude/macos-lemp-setup/master/install.sh | bash`
3. Link executables like this:

Run: `sudo find / -name 'php'`. When you spot link that looks like this (yours might be different version) */usr/local/Cellar/php@7.2/7.2.24/bin/php*, symlink it to correct location to override MacOS's own file:

`sudo ln -s /usr/local/Cellar/php@7.2/7.2.24/bin/php /usr/local/bin/php`

Check the version with `php --version`, it should match the linked file.

Then link other executables like mysql that are needed:

`sudo find / -name 'mysql'`
`sudo ln -s /usr/local/Cellar/mariadb/10.4.6/include/mysql /usr/local/bin/mysql`

Then nginx:

`sudo find / -name 'nginx'`
`sudo ln -s /usr/local/Cellar/nginx/1.17.1/bin/nginx /usr/local/bin/nginx`

Then php-fpm:

`sudo find / -name 'php-fpm'`
`sudo ln -s /usr/local/Cellar/php@7.2/7.2.24/sbin/php-fpm /usr/local/bin/php-fpm`

4. Add `export PATH="$(brew --prefix php@7.2)/bin:$PATH"` to .bash_profile (or to your zsh profile or to whatever term profile you are currently using)

5. Enjoy! If you use [dudestack](https://github.com/digitoimistodude/dudestack), please check instructions from [its own repo](https://github.com/digitoimistodude/dudestack).

### Post install

You may want to add your user and group correctly to `/usr/local/etc/php/7.2/php-fpm.d/www.conf` and set these to the bottom:

```` nginx
catch_workers_output = yes
php_flag[display_errors] = On
php_admin_value[error_log] = /var/log/fpm7.2-php.www.log 
slowlog = /var/log/fpm7.2-php.slow.log 
php_admin_flag[log_errors] = On
php_admin_value[memory_limit] = 1024M
request_slowlog_timeout = 10
php_admin_value[upload_max_filesize] = 100M
php_admin_value[post_max_size] = 100M
````

Default vhost could be something like:

```` nginx
server {
    listen 80;
    root /var/www/example;
    index index.html index.htm index.php;
    server_name example.test www.example.test;
    include php7.conf;
    include global/wordpress.conf;
}
````

Default my.cnf would be something like this (already added by install.sh in `/usr/local/etc/my.cnf`:

````
#
# This group is read both both by the client and the server
# use it for options that affect everything
#
[client-server]

#
# include all files from the config directory
#
!includedir /usr/local/etc/my.cnf.d

[mysqld]
innodb_log_file_size = 32M
innodb_buffer_pool_size = 1024M
innodb_log_buffer_size = 4M
slow_query_log = 1
query_cache_limit = 512K
query_cache_size = 128M
skip-name-resolve
````

For mysql, remember to run `sudo mysql_secure_installation`. Your logs can be found at `/usr/local/var/mysql/yourcomputername.err` (where yourcomputername is obviously your hostname).

After that, get to know [dudestack](https://github.com/digitoimistodude/dudestack) to get everything up and running smoothly. Current version of dudestack supports macOS LEMP stack.

You should remember to add vhosts to your /etc/hosts file, for example: `127.0.0.1 site.test`. Also, consider adding these bash aliases for easy stopping and starting services:

```` bash
alias nginx.start='sudo brew services start nginx'
alias nginx.stop='sudo brew services stop nginx'
alias nginx.restart='nginx.stop && nginx.start'
alias php-fpm.start='sudo brew services start php@7.2'
alias php-fpm.stop='sudo brew services stop php@7.2'
alias php-fpm.restart='php-fpm.stop && php-fpm.start'
alias mysql.start='brew services start mariadb'
alias mysql.stop='brew services stop mariadb'
alias mysql.restart='mysql.stop && mysql.start'
alias localserver.stop='mysql.stop && nginx.stop && php-fpm.stop'
alias localserver.start='mysql.start && nginx.start && php-fpm.start'
````

Even better, add this to */usr/local/bin/service* and chmod it +x:

```` bash
#!/bin/bash
# Alias for unix type of commands
brew services "$2" "$1";
````

Now you are able to restart nginx and mysql unix style like this:

```` bash
sudo service nginx restart
sudo service mariadb restart
````

### File sizes

You might want to increase file sizes for development environment in case you need to test compression plugins and other stuff in WordPress. To do so, edit `/usr/local/etc/php/7.2/php-fpm.d/www.conf` and `/usr/local/etc/php/7.2/php.ini` and change all **memory_limit**, **post_max_size** and **upload_max_filesize** to something that is not so limited, for example **500M**.

Please note, you also need to change **client_max_body_size** to the same amount in `/etc/nginx/nginx.conf`. After this, restart php-fpm with `sudo brew services restart php@7.2` and nginx with `sudo brew services restart nginx`.

### Certificates for localhost

Generating certificates for dev environment is easiest with [mkcert](https://github.com/FiloSottile/mkcert). After installing mkcert, just run:

```` bash
mkdir -p /var/www/certs && cd /var/www/certs && mkcert "project.test"
````

Then edit your vhost as following:

```` nginx
server {
    listen 443 ssl http2;
    root /var/www/dude;
    index index.php;    
    server_name project.test;

    include php7.conf;
    include global/wordpress.conf;

    ssl_certificate /var/www/certs/dude.test.pem;
    ssl_certificate_key /var/www/certs/dude.test-key.pem;
    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
    ssl_prefer_server_ciphers on;
    ssl_dhparam /etc/ssl/certs/dhparam.pem;
    ssl_ciphers 'ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:kEDH+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-DSS-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:DHE-RSA-AES256-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:AES:CAMELLIA:DES-CBC3-SHA:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!MD5:!PSK:!aECDH:!EDH-DSS-DES-CBC3-SHA:!EDH-RSA-DES-CBC3-SHA:!KRB5-DES-CBC3-SHA';
    ssl_session_timeout 1d;
    ssl_session_cache shared:SSL:50m;
    ssl_stapling_verify on;
    add_header Strict-Transport-Security max-age=15768000;
}

server {
    listen 80;
    server_name project.test;
    return 301 https://$host$request_uri;
}
````

Test with `sudo nginx -t` and if everything is OK, restart nginx.

### Troubleshooting

If you have something like this in your /var/log/nginx/error.log:

```
2019/08/12 14:09:04 [crit] 639#0: *129 open() "/usr/local/var/run/nginx/client_body_temp/0000000005" failed (13: Permission denied), client: 127.0.0.1, server: project.test, request: "POST /wp/wp-admin/async-upload.php HTTP/1.1", host: "project.test", referrer: "http://project.test/wp/wp-admin/upload.php"
```

Make sure you run nginx on your root user. Stop nginx from running on your default user by `brew services stop nginx` and run it with sudo `sudo brew services start nginx`.
