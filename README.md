# LEMP: Local Environment Made Powerful 
[![Build](https://github.com/digitoimistodude/macos-lemp-setup/actions/workflows/build.yml/badge.svg)](https://github.com/digitoimistodude/macos-lemp-setup/actions/workflows/build.yml) [![GitHub release](https://img.shields.io/github/tag/digitoimistodude/macos-lemp-setup.svg)](https://github.com/digitoimistodude/macos-lemp-setup/releases) ![GitHub contributors](https://img.shields.io/github/contributors/digitoimistodude/macos-lemp-setup.svg) ![PHP](https://img.shields.io/badge/PHP-8.3-7a86b8)

Just kidding, it's really **Linux + nginx [engine x] + MySQL + PHP-FPM**, that's where the LEMP comes from. MacOS LEMP Setup is just like Local by Flywheel or XAMPP, WAMP, Hammer, Anvil etc. tools like this, but it concentrates on the native way of running a web server just by using native Linux packages ported for macOS via Homebrew. It's always fast, always on.

## LEMP on other systems

- [Windows version](https://github.com/digitoimistodude/windows-lemp-setup)
- [Linux version](https://github.com/raikasdev/pop-lemp-setup)

## Still the best way to locally develop WordPress.

![macos-lemp](https://user-images.githubusercontent.com/1534150/159696251-1b8adbee-f752-4107-9183-78107ffb4969.png)

**macOS LEMP Setup is Mac only!**

### Other platforms

- Windows: [Setting up a local server on Windows 10 for WordPress theme development (or any web development for that matter)](https://rolle.design/local-server-on-windows-10-for-wordpress-theme-development).
- Linux: [Pop!_OS LEMP setup instructions](https://github.com/raikasdev/pop-lemp-setup) by [raikasdev](https://github.com/raikasdev).

## Minimum requirements

* Latest [Homebrew](https://brew.sh/)
* MacBook Pro M1 (if you like to install this on Intel mac, refer to [this tutorial](https://kevdees.com/macos-12-monterey-nginx-setup-multiple-php-versions/))
* macOS Monterey 12.3 or later

## Install local LEMP for macOS

For *Front End development*, a full Vagrant box, docker container per site or Local by Flywheel is not really needed. If you have a Macbook Pro, you can install local LEMP (Linux, nginx, MariaDB and PHP) with this single liner below. 

Please see [installation steps](#installation) instructions first.

```` bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/digitoimistodude/macos-lemp-setup/master/install.sh)"
````

Oneliner may not go through in macOS Big Sur and macOS Monterey, in that caes you need to copy and paste commands manually from [install.sh](https://raw.githubusercontent.com/digitoimistodude/macos-lemp-setup/master/install.sh).

**Please note:** Don't trust blindly to the script, use only if you know what you are doing. You can view the file [here](https://github.com/digitoimistodude/osx-lemp-setup/blob/master/install.sh) if having doubts what commands are being run. However, script is tested working many times and should be safe to run even if you have some or all of the components already installed.

## Table of contents

1. [Background](#background)
2. [Features](#features)
3. [Requirements](#requirements)
4. [Installation](#installation)
5. [Post installations](#post-installations)
   1. [Mailhog](#MailHog)
6. [Use Linux-style aliases](#use-linux-style-aliases)
7. [File sizes](#file-sizes)
8. [XDebug](#xdebug)
9. [Redis](#redis)
10. [Troubleshooting](#troubleshooting)

### Background

Read the full story by [@ronilaukkarinen](https://github.com/ronilaukkarinen): **[Moving from Vagrant to a LEMP stack directly on a Macbook Pro (for WordPress development)](https://medium.com/@rolle/moving-from-vagrant-to-a-lemp-stack-directly-on-a-macbook-pro-e935b1bc5a38)**

### Features

- PHP 8.3
- nginx 1.25.3
- Super lightweight
- Native packages
- Always on system service
- HTTPS support
- Consistent with production setup

### Requirements

- [Homebrew](https://brew.sh/)
- macOS, preferably 14.2.1 (Sonoma)
- wget
- [mkcert](https://github.com/FiloSottile/mkcert)

### Installation

1. Run oneliner installation script `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/digitoimistodude/macos-lemp-setup/master/install.sh)"`
2. Link PHP executable like this: **Run:** `sudo find / -name 'php'`. When you spot link that looks like this (yours might be different version) */usr/local/Cellar/php@8.3/8.3.3/bin/php*, symlink it to correct location to override MacOS's own file: `sudo ln -s /usr/local/Cellar/php@8.3/8.3.3/bin/php /usr/local/bin/php`
3. Use PHP path from correct location by adding to your ~/.bash_profile file, `sudo nano ~/.bash_profile` (change your PHP version accordingly)
   ``` shell
   export PATH="$(brew --prefix php@8.3)/bin:$PATH"
   ```
4. Check the version with `php --version`, it should match the linked file.
5. Brew should have already handled other links, you can test the correct versions with `sudo mysql --version` (if it's something like _mysql  Ver 15.1 Distrib 10.5.5-MariaDB, for osx10.15 (x86_64) using readline 5.1_ it's the correct one) and `sudo nginx -v` (if it's something like nginx version: nginx/1.19.3 it's the correct one)
6. Add `export PATH="$(brew --prefix php@8.3)/bin:$PATH"` to .bash_profile (or to your zsh profile or to whatever term profile you are currently using)
7. Go through [post installations](#post-installations)
8. Enjoy! If you use [dudestack](https://github.com/digitoimistodude/dudestack), please check instructions from [its own repo](https://github.com/digitoimistodude/dudestack).

### Post installations

#### PHP config

You may want to add your user and group correctly to `/opt/homebrew/etc/php/8.3/php-fpm.d/www.conf` (or wherever your www.conf is, find with `sudo find / -name 'www.conf'`) and set these to the bottom:

````
catch_workers_output = yes
php_flag[display_errors] = On
php_admin_value[error_log] = /var/log/fpm-php.www.log 
slowlog = /var/log/fpm-php.slow.log 
php_admin_flag[log_errors] = On
php_admin_value[memory_limit] = 1024M
request_slowlog_timeout = 10
php_admin_value[upload_max_filesize] = 100M
php_admin_value[post_max_size] = 100M
````

Please note, if the file is not found (as the location may also be something like `/System/Volumes/Data/opt/homebrew/etc/php/8.3/php-fpm.d/www.conf`), you can find the correct location with:

```
sudo find / -name 'www.conf'
```

#### Make sure the PHP runs on correct permissions

Make sure you have your user and group defined, use these as base (only change `rolle` to your own Mac username):

````config
; Unix user/group of processes
; Note: The user is mandatory. If the group is not set, the default user's group
;       will be used.
user = rolle
group = admin
````

Also make sure you have listen set up properly

````config
; The address on which to accept FastCGI requests.
; Valid syntaxes are:
;   'ip.add.re.ss:port'    - to listen on a TCP socket to a specific IPv4 address on
;                            a specific port;
;   '[ip:6:addr:ess]:port' - to listen on a TCP socket to a specific IPv6 address on
;                            a specific port;
;   'port'                 - to listen on a TCP socket to all addresses
;                            (IPv6 and IPv4-mapped) on a specific port;
;   '/path/to/unix/socket' - to listen on a unix socket.
; Note: This value is mandatory.
listen = 127.0.0.1:9000
````

#### Default nginx config

Make sure you have default vhost for your site (`/etc/nginx/sites-enabled/sitename.test`) could be something like:

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

#### Default MySQL my.cnf

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

Again, if the correct file cannot be found, you can find it with:

```
sudo find / -name 'my.cnf'
```

For mysql, <b>remember to run `sudo mysql_secure_installation`</b>, answer as suggested, add/change root password, remove test users etc. <b>Only exception!</b> Answer with <kbd>n</kbd> to the question <code>Disallow root login remotely? [Y/n]</code>. Your logs can be found at `/usr/local/var/mysql/yourcomputername.err` (where yourcomputername is obviously your hostname).

After that, get to know [dudestack](https://github.com/digitoimistodude/dudestack) to get everything up and running smoothly. Current version of dudestack supports macOS LEMP stack.

You should remember to add vhosts to your /etc/hosts file, for example: `127.0.0.1 site.test`.

### Symlinks

You should find the correct files and link them like in Linux. This helps you to remember the correct paths.

For example (please note, this is just an example):

```bash
sudo mkdir -p /usr/local/bin
sudo ln -s /opt/homebrew/Cellar/php@8.3/8.3.3/bin/php /usr/local/bin/php
sudo ln -s /opt/homebrew/Cellar/php@8.3/8.3.3/sbin/php-fpm /usr/local/bin/php-fpm
sudo ln -s /opt/homebrew/Cellar/php@8.3/8.3.3/sbin/php-fpm /usr/local/bin/php-fpm
sudo ln -s /opt/homebrew/etc/php /etc/php
sudo ln -s /opt/homebrew/etc/nginx /etc/nginx
sudo ln -s /opt/homebrew/etc/my.cnf /etc/my.cnf
```

### Use Linux-style aliases

Add this to */usr/local/bin/service* and chmod it +x:

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

#### MailHog

E-mails won't be sent on local environment because there is no email server configured. This is where [MailHog](https://github.com/mailhog/MailHog) comes in.

MailHog should be pre-installed but if not, run following:

``` bash
brew update && brew install mailhog
```

Ensure you have the latest [air-helper](https://github.com/digitoimistodude/air-helper) or [MailHog for WordPress](https://wordpress.org/plugins/wp-mailhog-smtp/) activated to enable MailHog routing for local environment.

Then just run:

``` bash
mailhog
```

You should now get a log in command line and web interface is available in http://0.0.0.0:8025/.

### File sizes

You might want to increase file sizes for development environment in case you need to test compression plugins and other stuff in WordPress. To do so, edit `/usr/local/etc/php/8.3/php-fpm.d/www.conf` and `/usr/local/etc/php/8.3/php.ini` and change all **memory_limit**, **post_max_size** and **upload_max_filesize** to something that is not so limited, for example **500M**.

Please note, you also need to change **client_max_body_size** to the same amount in `/etc/nginx/nginx.conf`. After this, restart php-fpm with `sudo brew services restart php@8.3` and nginx with `sudo brew services restart nginx`.

### Certificates for localhost

First things first, if you haven't done it yet, generate general dhparam:

```` bash
sudo su -
cd /etc/ssl/certs
sudo openssl dhparam -dsaparam -out dhparam.pem 4096
````

Generating certificates for dev environment is easiest with [mkcert](https://github.com/FiloSottile/mkcert). After installing mkcert, just run:

```` bash
mkdir -p /var/www/certs && cd /var/www/certs && mkcert "project.test"
````

Then edit your vhost as following (change all from *project* to your project name):

```` nginx
server {
    listen 443 ssl;
    http2 on;
    root /var/www/project;
    index index.php;    
    server_name project.test;

    include php7.conf;
    include global/wordpress.conf;

    ssl_certificate /var/www/certs/project.test.pem;
    ssl_certificate_key /var/www/certs/project.test-key.pem;
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

### XDebug

1. Check your PHP version with `php --version` and location with `which php`. If the location points to `/usr/bin/php`, you are mistakenly using macOS built-in PHP. Change PHP path to correct location by adding to your ~/.bash_profile file, `sudo nano ~/.bash_profile` (change your PHP version accordingly):
   ``` shell
   export PATH="$(brew --prefix php@8.3)/bin:$PATH"
   ```
2. Install xdebug

```bash
brew install shivammathur/extensions/xdebug@8.3
```

``` shell
$ php --version
PHP 8.3.3 (cli) (built: Feb 13 2024 15:41:14) (NTS)
Copyright (c) The PHP Group
Zend Engine v4.3.3, Copyright (c) Zend Technologies
    with Xdebug v3.3.1, Copyright (c) 2002-2023, by Derick Rethans
    with Zend OPcache v8.3.3, Copyright (c), by Zend Technologies
```

7. Check where your php.ini file is with `php --ini`
8. Edit php.ini, for example `sudo nano `
9. Make sure these are on the first lines:

```
xdebug.mode=develop
xdebug.client_port=9003
xdebug.client_host=127.0.0.1
xdebug.remote_handler=dbgp
xdebug.start_with_request=yes
xdebug.discover_client_host=0
xdebug.show_error_trace = 1
xdebug.max_nesting_level=250
xdebug.var_display_max_depth=10
xdebug.log=/var/log/xdebug.log
```

10. Save and close with <kbd>ctrl</kbd> + <kbd>O</kbd> and <kbd>ctrl</kbd> + <kbd>X</kbd>
11. Make sure the log exists `sudo touch /var/log/xdebug.log && sudo chmod 777 /var/log/xdebug.log`
12. Restart services (requires [Linux-style aliases](#use-linux-style-aliases)) `sudo service php@8.3 restart && sudo service nginx restart`
13. Install [PHP Debug VSCode plugin](https://marketplace.visualstudio.com/items?itemName=felixfbecker.php-debug)
14. Add following to launch.json (<kbd>cmd</kbd> + + <kbd>shift</kbd> + <kbd>P</kbd>, "Open launch.json"):

``` json
{
  "version": "0.2.0",
  "configurations": [
    {
      //"debugServer": 4711, // Uncomment for debugging the adapter
      "name": "Listen for Xdebug",
      "type": "php",
      "request": "launch",
      "port": 9003,
      "log": true
    },
    {
      //"debugServer": 4711, // Uncomment for debugging the adapter
      "name": "Launch",
      "request": "launch",
      "type": "php",
      "program": "${file}",
      "cwd": "${workspaceRoot}",
      "externalConsole": false
    }
  ]
}
```
15. Xdebug should now work on your editor
16. PHPCS doesn't need xdebug but will warn about it not working... this causes error in [phpcs-vscode](https://marketplace.visualstudio.com/items?itemName=ikappas.phpcs) because it depends on outputted phpcs json that is not valid with the warning _"Xdebug: [Step Debug] Could not connect to debugging client. Tried: 127.0.0.1:9003 (through xdebug.client_host/xdebug.client_port) :-(_". This can be easily fixed by installing a bash "wrapper":
17. Rename current phpcs with `sudo mv /usr/local/bin/phpcs /usr/local/bin/phpcs.bak`
18. Install new with `sudo nano /usr/local/bin/phpcs`:

``` bash
#!/bin/bash
XDEBUG_MODE=off /Users/rolle/Projects/phpcs/bin/phpcs "$@"
```

19. Add permissions `sudo chmod +x /usr/local/bin/phpcs`
20. Make sure VSCode settings.json has this setting:

``` json
"phpcs.executablePath": "/usr/local/bin/phpcs",
```

### Redis

Redis is an open source, in-memory data structure store, used as a database, cache. We are going to install Redis and php-redis.

Before installation, make sure you do not use PHP provided by macOS. You should be using PHP installed by homebrew. If you are having problems with testing php-redis after installation, it is most probably caused bacuse of using wrong PHP. See [Troubleshooting: Testing which version of PHP you run](#testing-which-version-of-php-you-run) for more information.

1. Check that `pecl` command works
2. Run `brew update` first
3. Install Redis, `brew install redis`
4. Start Redis `brew services start redis`, this will also make sure that Redis is always started on reboot
5. Test if Redis server is running `redis-cli ping`, expected response is `PONG`
6. Install PHP Redis extension `pecl install redis`.
7. Restart nginx and php-redis should be available, you can test it with `php -r "if (new Redis() == true){ echo \"\r\n OK \r\n\"; }"` command, expected response is `OK`

### Troubleshooting

#### PHP Warning:  PHP Startup: Unable to load dynamic library 'redis.so

If you get something like this:

```shell
PHP Warning:  PHP Startup: Unable to load dynamic library 'redis.so' (tried: /opt/homebrew/lib/php/pecl/20190902/redis.so (dlopen(/opt/homebrew/lib/php/pecl/20190902/redis.so, 0x0009): tried: '/opt/homebrew/lib/php/pecl/20190902/redis.so' (no such file), '/System/Volumes/Preboot/Cryptexes/OS/opt/homebrew/lib/php/pecl/20190902/redis.so' (no such file), '/opt/homebrew/lib/php/pecl/20190902/redis.so' (no such file)), /opt/homebrew/lib/php/pecl/20190902/redis.so.so (dlopen(/opt/homebrew/lib/php/pecl/20190902/redis.so.so, 0x0009): tried: '/opt/homebrew/lib/php/pecl/20190902/redis.so.so' (no such file), '/System/Volumes/Preboot/Cryptexes/OS/opt/homebrew/lib/php/pecl/20190902/redis.so.so' (no such file), '/opt/homebrew/lib/php/pecl/20190902/redis.so.so' (no such file))) in Unknown on line 0
```

Install [phpredis](https://github.com/phpredis/phpredis) from source:

```
git clone https://www.github.com/phpredis/phpredis.git
cd phpredis
phpize && ./configure && make && sudo make install
```

Then take copy the outputted library path, it will be something like this: `/opt/homebrew/Cellar/php@8.3/8.3.3/pecl/20190902/`.

Run `php --ini` and modify your php.ini with `nano -w /path/to/php.ini`.

Replace `extension="redis.so"` with `extension="/opt/homebrew/Cellar/php@8.3/8.3.3/pecl/20190902/redis.so"` where the path is the one you copied. Restart nginx just in case. After this phpredis should work.

#### Testing which version of PHP you run

Test with `php --version` what version of PHP you are using, if the command returns something like `PHP is included in macOS for compatibility with legacy software` and especially when `which php` is showing /usr/bin/php then you are using macOS built-in version (which will be removed in the future anyway) and things most probably won't work as expected.

To fix this, first find the PHP:

```bash
sudo find / -name 'php'
```

Look for the bin under Cellar or homebrew dirs. Then run command with your php bin, for example: `sudo ln -s /usr/local/Cellar/php@8.3/8.3.3/bin/php /usr/local/bin/php`. This symlinks the homebrew version to be used instead of macOS version OR use bashrc export as defined [here in step 4](https://github.com/digitoimistodude/macos-lemp-setup#installation).

#### PHP or mysql not working at all

If you have something like this in your /var/log/nginx/error.log:

```
2019/08/12 14:09:04 [crit] 639#0: *129 open() "/usr/local/var/run/nginx/client_body_temp/0000000005" failed (13: Permission denied), client: 127.0.0.1, server: project.test, request: "POST /wp/wp-admin/async-upload.php HTTP/1.1", host: "project.test", referrer: "http://project.test/wp/wp-admin/upload.php"
```

If you cannot login to mysql from other than localhost, please answer with <kbd>n</kbd> to the question <code>Disallow root login remotely? [Y/n]</code> when running <code>sudo mysql_secure_installation</code>.

**Make sure you run nginx and php-fpm on your root user and mariadb on your regular user**. This is important. Stop nginx from running on your default user by `brew services stop nginx` and run it with sudo `sudo brew services start nginx`.

<code>sudo brew services list</code> should look like this:

``` shell
~ sudo brew services list
Name       Status  User  Plist
dnsmasq    started root  /Library/LaunchDaemons/homebrew.mxcl.dnsmasq.plist
mariadb    started rolle /Users/rolle/Library/LaunchAgents/homebrew.mxcl.mariadb.plist
nginx      started root  /Library/LaunchDaemons/homebrew.mxcl.nginx.plist
php        started root  /Library/LaunchDaemons/homebrew.mxcl.php@8.3.plist
```

You may have "unknown" or "error" as status or different PHP version, that is not a problem if ther server runs. **User** should be like in the list above. Then everything should work.

#### MySQL/MariaDb issues

If you get problems like:

```
ERROR 2002 (HY000): Can't connect to MySQL server on '127.0.0.1' (36)
```

It seems you have messed up with your root password. Try resetting root password with by adding this to your home directory (for example /Users/rolle/mysql-init):

Try resetting root password with (add new password in place of _YOUR_NEW_PASSWORD_):

```
ALTER USER 'root'@'localhost' IDENTIFIED BY 'YOUR_NEW_PASSWORD';
```

Then kill all mysql processes:


```
sudo ps xa |grep mysql
kill -9 <pid>
```


Then run:

```
mysqld --init-file=/Users/rolle/mysql-init &
```

After this:

```
sudo mysql_secure_installation
```

Answer:

```
NOTE: RUNNING ALL PARTS OF THIS SCRIPT IS RECOMMENDED FOR ALL MariaDB
      SERVERS IN PRODUCTION USE!  PLEASE READ EACH STEP CAREFULLY!

In order to log into MariaDB to secure it, we'll need the current
password for the root user. If you've just installed MariaDB, and
haven't set the root password yet, you should just press enter here.

Enter current password for root (enter for none): 
OK, successfully used password, moving on...

Setting the root password or using the unix_socket ensures that nobody
can log into the MariaDB root user without the proper authorisation.

You already have your root account protected, so you can safely answer 'n'.

Switch to unix_socket authentication [Y/n] n
 ... skipping.

You already have your root account protected, so you can safely answer 'n'.

Change the root password? [Y/n] n
 ... skipping.

By default, a MariaDB installation has an anonymous user, allowing anyone
to log into MariaDB without having to have a user account created for
them.  This is intended only for testing, and to make the installation
go a bit smoother.  You should remove them before moving into a
production environment.

Remove anonymous users? [Y/n] y
 ... Success!

Normally, root should only be allowed to connect from 'localhost'.  This
ensures that someone cannot guess at the root password from the network.

Disallow root login remotely? [Y/n] n
 ... skipping.

By default, MariaDB comes with a database named 'test' that anyone can
access.  This is also intended only for testing, and should be removed
before moving into a production environment.

Remove test database and access to it? [Y/n] y
 - Dropping test database...
 ... Success!
 - Removing privileges on test database...
 ... Success!

Reloading the privilege tables will ensure that all changes made so far
will take effect immediately.

Reload privilege tables now? [Y/n] y
 ... Success!

Cleaning up...

All done!  If you've completed all of the above steps, your MariaDB
installation should now be secure.

Thanks for using MariaDB!
```

If you are still having problems connecting with WordPress and prompting `Access denied for user 'root'@'127.0.0.1'`, try this in `mysql -u root -p`:

``` sql
GRANT ALL PRIVILEGES ON *.* TO root@localhost IDENTIFIED BY 'YOUR_MYSQL_ROOT_PASSWORD' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON *.* TO root@127.0.0.1 IDENTIFIED BY 'YOUR_MYSQL_ROOT_PASSWORD' WITH GRANT OPTION;
```

#### *2 open() "/var/www/test.txt" failed (13: Permission denied), client: 127.0.0.1

If you are getting permission denied by nginx, you need to make sure your php-fpm and nginx are running on the same user. This is stricter on MacBook Pro M1.

Open `/opt/homebrew/etc/php/8.3/php-fpm.d/www.conf` and change the user, group and listen to following:

```ini
user = your_username
group = staff
listen = 127.0.0.1:9074
```

Open `/opt/homebrew/etc/nginx/nginx.conf` and add to first line:

```ini
user your_username staff;
```

#### "Primary script unknown" error in nginx log or "File not found." in browser

This is caused by php-fpm not running properly. Please [make sure the PHP runs on correct permissions](#make-sure-the-php-runs-on-correct-permissions) section.
