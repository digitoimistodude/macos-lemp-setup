#!/bin/bash
# Install script for LEMP on OS X - by ronilaukkarinen.

# Helpers:
currentfile=`basename $0`
txtbold=$(tput bold)
boldyellow=${txtbold}$(tput setaf 3)
boldgreen=${txtbold}$(tput setaf 2)
boldwhite=${txtbold}$(tput setaf 7)
yellow=$(tput setaf 3)
red=$(tput setaf 1)
green=$(tput setaf 2)
white=$(tput setaf 7)
txtreset=$(tput sgr0)
LOCAL_IP=$(ifconfig | grep -Eo "inet (addr:)?([0-9]*\.){3}[0-9]*" | grep -Eo "([0-9]*\.){3}[0-9]*" | grep -v "127.0.0.1")
YEAR=$(date +%y)

echo "${yellow}Getting dependencies.${txtreset}"
xcode-select --install
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew doctor
brew update && brew upgrade
echo "${boldgreen}Dependencies installed and up to date.${txtreset}"
echo "${yellow}Installing nginx.${txtreset}"
brew tap homebrew/nginx
brew install nginx
sudo brew services start nginx
curl -IL http://127.0.0.1:8080
echo "${boldgreen}nginx installed and running.${txtreset}"
echo "${yellow}Setting up nginx.${txtreset}"
sudo ln -sfnv /usr/local/etc/nginx /etc/nginx
sudo mkdir -p /etc/nginx/sites-enabled
sudo mkdir -p /etc/nginx/sites-available
sudo mkdir -p /etc/nginx/global
sudo echo "worker_processes 8;
  
events {  
        multi_accept on;
        accept_mutex on;
        worker_connections 1024;
}

http {  

        ##  
        # Optimization  
        ##  
  
        sendfile on;
        sendfile_max_chunk 512k;
        tcp_nopush on;  
        tcp_nodelay on;  
        keepalive_timeout 120;
        keepalive_requests 100000;  
        types_hash_max_size 2048;
        server_tokens off;
        client_body_buffer_size      128k;  
        client_max_body_size         10m;  
        client_header_buffer_size    1k;  
        large_client_header_buffers  4 32k;  
        output_buffers               1 32k;  
        postpone_output              1460;
  
        server_names_hash_max_size 1024;  
        #server_names_hash_bucket_size 64;  
        # server_name_in_redirect off;  
  
        include /etc/nginx/mime.types;  
        default_type application/octet-stream;  

        ##
        # Logging Settings
        ##
        access_log off;
        access_log /var/log/nginx/access.log combined;
        error_log /var/log/nginx/error.log;

        ##
        # Virtual Host Configs
        ##
        
        include /etc/nginx/sites-enabled/*;
}" > "/etc/nginx/nginx.conf"
sudo echo "location ~ \.php\$ {
  proxy_intercept_errors on;
  try_files \$uri /index.php;
  fastcgi_split_path_info ^(.+\.php)(/.+)\$;
  include fastcgi_params;
  fastcgi_read_timeout 300;
  fastcgi_buffer_size 128k;
  fastcgi_buffers 8 128k;
  fastcgi_busy_buffers_size 128k;
  fastcgi_temp_file_write_size 128k;
  fastcgi_index index.php;
  fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
  fastcgi_pass 127.0.0.1:9000;
}" > "/etc/nginx/php7.conf"
sudo echo "# WordPress single site rules.
# Designed to be included in any server {} block.
# Upstream to abstract backend connection(s) for php
location = /favicon.ico {
        log_not_found off;
        access_log off;
}

location = /robots.txt {
        allow all;
        log_not_found off;
        access_log off;
}

location / {
        # This is cool because no php is touched for static content.
        # include the "?\$args" part so non-default permalinks doesn't break when using query string
        try_files \$uri \$uri/ /index.php?\$args;
}

# Add trailing slash to */wp-admin requests.
rewrite /wp-admin\$ \$scheme://\$host\$uri/ permanent;

# Directives to send expires headers and turn off 404 error logging.
location ~* ^.+\.(ogg|ogv|svg|svgz|eot|otf|woff|mp4|ttf|rss|atom|jpg|jpeg|gif|png|ico|zip|tgz|gz|rar|bz2|doc|xls|exe|ppt|tar|mid|midi|wav|bmp|rtf)\$ {
       access_log off; log_not_found off; expires max;
}" > "/etc/nginx/global/wordpress.conf"
sudo echo "server {
        listen 80 default_server;
        root html;
        index index.html index.htm index.php;
        server_name localhost;
        include php7.conf;
        #include global/wordpress.conf;
}" > "/etc/nginx/sites-available/default"
sudo ln -sfnv /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default
echo "${yellow}Installing PHP.${txtreset}"
brew tap homebrew/dupes
brew tap homebrew/versions
brew tap homebrew/homebrew-php
brew install php70
mkdir -p ~/Library/LaunchAgents
cp /usr/local/opt/php70/homebrew.mxcl.php70.plist ~/Library/LaunchAgents/
launchctl load -w ~/Library/LaunchAgents/homebrew.mxcl.php70.plist
lsof -Pni4 | grep LISTEN | grep php
sudo touch /var/log/fpm7.0-php.slow.log
sudo chmod 775 /var/log/fpm7.0-php.slow.log
sudo chown "$USER":staff /var/log/fpm7.0-php.slow.log
sudo touch /var/log/fpm7.0-php.www.log
sudo chmod 775 /var/log/fpm7.0-php.www.log
sudo chown "$USER":staff /var/log/fpm7.0-php.www.log
echo "${boldgreen}PHP installed and running.${txtreset}"
echo "${yellow}Installing MariaDB.${txtreset}"
brew install mariadb
brew services start mariadb
echo "${boldgreen}MariaDB installed and running.${txtreset}"
echo "${yellow}Installing DNSmasq.${txtreset}"
brew install dnsmasq
curl -L https://gist.githubusercontent.com/dtomasi/ab76d14338db82ec24a1fc137caff75b/raw/550c84393c4c1eef8a3e68bb720df561b5d3f175/dnsmasq.conf -o /usr/local/etc/dnsmasq.conf
sudo curl -L https://gist.githubusercontent.com/dtomasi/ab76d14338db82ec24a1fc137caff75b/raw/550c84393c4c1eef8a3e68bb720df561b5d3f175/dev -o /etc/resolver/dev
sudo brew services stop dnsmasq
sudo brew services start dnsmasq
echo "${boldgreen}DNSmasq installed and configured.${txtreset}"
echo "${yellow}Restarting services....${txtreset}"
# These need to be running as root, because of the port 80 and other privileges.
sudo brew services stop dnsmasq
sudo brew services start dnsmasq
sudo brew services stop nginx
sudo brew services start nginx
sudo brew services stop php70
sudo brew services start php70
brew services stop mariadb
brew services start mariadb
sudo brew services list
echo "${boldgreen}You should now be able to use http://localhost. Add new vhosts to /etc/nginx/sites-available and symlink them just like you would do in production. Have fun!${txtreset}"