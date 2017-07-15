## Install local LEMP for Mac OS X

For *Front End development*, a full Vagrant box is not always needed. If you have a new Macbook Pro, you can install local LEMP (Linux, nginx, MariaDB and PHP) with this single liner (if wget is not installed, run `brew install wget` first):

```` bash
wget -O - https://raw.githubusercontent.com/digitoimistodude/osx-lemp-setup/master/install.sh | bash
````

**Please note:** Don't trust blindly to the script, use only if you know what you are doing. You can view the file [here](https://github.com/digitoimistodude/osx-lemp-setup/blob/master/install.sh) if having doubts what commands are being run. However, script is tested working many times and should be safe to run even if you have some or all of the components already installed.

### Background

Read the full story by [@ronilaukkarinen](https://github.com/ronilaukkarinen): **[Moving from Vagrant to a LEMP stack directly on a Macbook Pro (for WordPress development)](https://medium.com/@rolle/moving-from-vagrant-to-a-lemp-stack-directly-on-a-macbook-pro-e935b1bc5a38)**

### Dependencies

- [Homebrew](https://brew.sh/)
- Mac OS X, preferably 10.12.5

### Post install

You may want to add your user and group correctly to `/usr/local/etc/php/7.0/php-fpm.d/www.conf` and set these to the bottom:

```` nginx
catch_workers_output = yes
php_flag[display_errors] = On
php_admin_value[error_log] = /var/log/fpm7.0-php.www.log 
slowlog = /var/log/fpm7.0-php.slow.log 
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
    server_name example.dev www.example.dev;
    include php7.conf;
    include global/wordpress.conf;
}
````

For mysql, remember to run `mysql_secure_installation`.

After that, get to know [dudestack](https://github.com/digitoimistodude/dudestack) to get everything up and running smoothly. Current version of dudestack supports OS X LEMP stack.

You should remember to add vhosts to your /etc/hosts file, for example: `127.0.0.1 site.dev`. Also, consider adding these bash aliases for easy stopping and starting services:

```` bash
alias nginx.start='sudo brew services start nginx'
alias nginx.stop='sudo brew services stop nginx'
alias nginx.restart='nginx.stop && nginx.start'
alias php-fpm.start='sudo brew services start php70'
alias php-fpm.stop='sudo brew services stop php70'
alias php-fpm.restart='php-fpm.stop && php-fpm.start'
alias mysql.start='brew services start mariadb'
alias mysql.stop='brew services stop mariadb'
alias mysql.restart='mysql.stop && mysql.start'
alias localserver.stop='mysql.stop && nginx.stop && php-fpm.stop'
alias localserver.start='mysql.start && nginx.start && php-fpm.start'
````
