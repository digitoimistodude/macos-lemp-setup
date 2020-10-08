## Install local LEMP for macOS

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
3. Link PHP executable like this: **Run:** `sudo find / -name 'php'`. When you spot link that looks like this (yours might be different version) */usr/local/Cellar/php@7.2/7.2.24/bin/php*, symlink it to correct location to override MacOS's own file: `sudo ln -s /usr/local/Cellar/php@7.2/7.2.24/bin/php /usr/local/bin/php`
4. Check the version with `php --version`, it should match the linked file.
5. Brew should have already handled other links, you can test the correct versions with `sudo mysql --version` (if it's something like _mysql  Ver 15.1 Distrib 10.5.5-MariaDB, for osx10.15 (x86_64) using readline 5.1_ it's the correct one) and `sudo nginx -v` (if it's something like nginx version: nginx/1.19.3 it's the correct one)
6. Add `export PATH="$(brew --prefix php@7.2)/bin:$PATH"` to .bash_profile (or to your zsh profile or to whatever term profile you are currently using)
7. Run [Post install](#post-install)
8. Enjoy! If you use [dudestack](https://github.com/digitoimistodude/dudestack), please check instructions from [its own repo](https://github.com/digitoimistodude/dudestack).

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

Default vhost for your site (/etc/nginx/sites-enabled/sitename.test) could be something like:

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

You should remember to add vhosts to your /etc/hosts file, for example: `127.0.0.1 site.test`.

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

### File sizes

You might want to increase file sizes for development environment in case you need to test compression plugins and other stuff in WordPress. To do so, edit `/usr/local/etc/php/7.2/php-fpm.d/www.conf` and `/usr/local/etc/php/7.2/php.ini` and change all **memory_limit**, **post_max_size** and **upload_max_filesize** to something that is not so limited, for example **500M**.

Please note, you also need to change **client_max_body_size** to the same amount in `/etc/nginx/nginx.conf`. After this, restart php-fpm with `sudo brew services restart php@7.2` and nginx with `sudo brew services restart nginx`.

### Certificates for localhost

Based on [this tutorial](https://nickolaskraus.org/articles/how-to-create-a-self-signed-certificate-for-nginx-on-macos/), you can create a project based certificates for yourself for macos-lemp.

If you haven't generated any local certs before, run this command first. You only need to do this once.

```` bash
mkdir -p ~/certs && cd ~/certs && openssl genrsa -des3 -out localhost.key 2048 && openssl req -x509 -new -nodes -key localhost.key -sha256 -days 1825 -out localhost.pem
````

Add some password, for example the same you have on your Mac. Add some unique name when **Common Name (e.g. server FQDN or YOUR name) []:**, to see which one is yours in the following step. You can ignore other questions.

Open **Keychain Access** app and import your key from *File > Import Items...* by navigating to your file. Select your key, click *Get Info*, open *Trust* and select *When using this certificate:* to *Always Trust*.

Then run project based commands (these you will need for every project in the future) (replace project.test with your specific project TLD):

```` bash
cd ~/certs && openssl genrsa -out project.test.key 2048 && openssl req -new -key project.test.key -out project.test.csr
````

Create a new filed `project.test.ext` (with your real project TLD, naturally) and add these to it (you can leave localhost out if you don't need to use browsersync):

```` nginx
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = project.test
DNS.2 = localhost
````

After this, generate the certificate with this command:

```` bash
cd ~/certs && openssl x509 -req -in project.test.csr -CA localhost.pem -CAkey localhost.key -CAcreateserial \
-out project.test.crt -days 1825 -sha256 -extfile project.test.ext
````

Edit your vhost file as follows (again, replace project.test with your specific project TLD and yourusername with your actual Mac username):

```` nginx
server {
    listen 443 ssl http2;
    include php7.conf;
    include global/wordpress.conf;
    root /var/www/project;
    index index.html index.htm index.php;
    server_name project.test www.project.test;

    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
    ssl_prefer_server_ciphers on;
    ssl_ciphers "EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH";
    ssl_ecdh_curve secp384r1;
    ssl_session_tickets off;
    resolver 8.8.8.8 8.8.4.4 valid=300s;
    resolver_timeout 5s;
    add_header Strict-Transport-Security "max-age=63072000; includeSubdomains";
    add_header X-Frame-Options DENY;
    add_header X-Content-Type-Options nosniff;
    ssl_certificate /Users/rolle/certs/project.test.crt;
    ssl_certificate_key /Users/rolle/certs/project.test.key;
    ssl_dhparam /private/etc/ssl/certs/dhparam.pem;
}
````

Generate your dhparam.pem file with:

````
openssl dhparam -out /private/etc/ssl/certs/dhparam.pem 2048
````

Test with `sudo nginx -t` and if everything is OK, restart nginx.

Link cert files to browsersync configuration

```` js
browsersync.init(files, {
    proxy: "https://project.test",
    browser: "Google Chrome",
    open: false,
    notify: true,
    reloadDelay: 1000,
    plugins: ['bs-eslint-message'],
    https: {
        key: "/Users/rolle/certs/project.test.ext",
        cert: "/Users/rolle/certs/project.test.crt"
    }
  });
````

### Troubleshooting

If you have something like this in your /var/log/nginx/error.log:

```
2019/08/12 14:09:04 [crit] 639#0: *129 open() "/usr/local/var/run/nginx/client_body_temp/0000000005" failed (13: Permission denied), client: 127.0.0.1, server: project.test, request: "POST /wp/wp-admin/async-upload.php HTTP/1.1", host: "project.test", referrer: "http://project.test/wp/wp-admin/upload.php"
```

Make sure you run nginx on your root user. Stop nginx from running on your default user by `brew services stop nginx` and run it with sudo `sudo brew services start nginx`.
