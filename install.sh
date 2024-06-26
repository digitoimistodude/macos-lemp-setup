# Crucial paths
HOMEBREW_PATH='/opt/homebrew'
PHP_VERSION='8.3'

# Helper variables
TXTBOLD=$(tput bold)
BOLDGREEN=${TXTBOLD}$(tput setaf 2)
YELLOW=$(tput setaf 3)
GREEN=$(tput setaf 2)
TXTRESET=$(tput sgr0)

echo "${YELLOW}Getting dependencies...${TXTRESET}"

# Attempt to install Xcode Command Line Tools
xcode-select --install

# Get Homebrew
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# Inspect Homebrew installation
brew doctor

# Update Homebrew
brew update && brew upgrade
echo "${BOLDGREEN}Dependencies installed and up to date.${TXTRESET}"

# Install the latest nginx version
echo "${YELLOW}Installing nginx.${TXTRESET}"
brew tap homebrew/nginx
brew install nginx
sudo brew services start nginx
curl -IL http://127.0.0.1:80
echo "${BOLDGREEN}nginx installed and running.${TXTRESET}"

# Set up nginx and paths
echo "${YELLOW}Setting up nginx...${TXTRESET}"

# Chec if /etc/nginx exists
if [ -d "/etc/nginx" ]; then
  echo "${YELLOW}Directory /etc/nginx exists.${TXTRESET}"
else
  echo "${YELLOW}Directory /etc/nginx does not exist. Symlinking homebrew installation to it.${TXTRESET}"
  sudo ln -sfnv "${HOMEBREW_PATH}/etc/nginx" "/etc/nginx"

  # Creating the necessary directories
  sudo mkdir -p "${HOMEBREW_PATH}/etc/nginx/global"
  sudo mkdir -p "${HOMEBREW_PATH}/etc/nginx/sites-enabled"
  sudo mkdir -p "${HOMEBREW_PATH}/etc/nginx/sites-available"
  sudo mkdir -p "${HOMEBREW_PATH}/etc/nginx/global"

  # Setting permissions
  sudo chmod -R 775 "${HOMEBREW_PATH}/etc/nginx/global"
  sudo chmod -R 775 "${HOMEBREW_PATH}/etc/nginx/sites-enabled"
  sudo chmod -R 775 "${HOMEBREW_PATH}/etc/nginx/sites-available"
  sudo chmod -R 775 "${HOMEBREW_PATH}/etc/nginx/global"
fi

echo "${YELLOW}Creating default nginx configurations...${TXTRESET}"

# Create default nginx configuration
sudo echo "user $(whoami) staff;

worker_processes 18;

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
  client_body_buffer_size 128k;
  client_max_body_size 10m;
  client_header_buffer_size 1k;
  large_client_header_buffers 4 32k;
  output_buffers 1 32k;
  postpone_output 1460;

  server_names_hash_max_size 1024;
  #server_names_hash_bucket_size 64;
  # server_name_in_redirect off;

  include ${HOMEBREW_PATH}/etc/nginx/mime.types;
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

  include ${HOMEBREW_PATH}/etc/nginx/sites-enabled/*;
}" > "${HOMEBREW_PATH}/etc/nginx/nginx.conf"

echo "${YELLOW}Creating locations for logs...${TXTRESET}"

# Check if nginx log dir exists
if [ -d "/var/log/nginx" ]; then
  echo "${YELLOW}Directory /var/log/nginx exists.${TXTRESET}"
else
  echo "${YELLOW}Directory /var/log/nginx does not exist. Creating it and the access.log and error.log files.${TXTRESET}"
  sudo mkdir -p /var/log/nginx
  sudo touch /var/log/nginx/access.log
  sudo chmod 777 /var/log/nginx/access.log
  sudo touch /var/log/nginx/error.log
  sudo chmod 777 /var/log/nginx/error.log
fi

echo "${YELLOW}Creating default PHP/nginx configurations...${TXTRESET}"

# Create default php configuration
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
}" > "${HOMEBREW_PATH}/etc/nginx/php.conf"

echo "${YELLOW}Creating default WordPress-related nginx configurations...${TXTRESET}"

# Create default WordPress-related nginx configuration
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
  access_log off;
  log_not_found off;
  expires max;
}" > "${HOMEBREW_PATH}/etc/nginx/global/wordpress.conf"

echo "${YELLOW}Creating default site vhost...${TXTRESET}"

# Create default site configuration
sudo echo "server {
  listen 80 default_server;
  root /var/www;
  index index.html index.htm index.php;
  server_name localhost;
  include php.conf;
  include global/wordpress.conf;
}" > "${HOMEBREW_PATH}/etc/nginx/sites-available/default"

echo "${YELLOW}Symlinking the default vhost...${TXTRESET}"

# Symlink the default site configuration
sudo ln -sfnv ${HOMEBREW_PATH}/etc/nginx/sites-available/default ${HOMEBREW_PATH}/etc/nginx/sites-enabled/default

echo "${YELLOW}Making sure /var/www exists and is linked to project directory...${TXTRESET}"

# Check if /var/www exists
if [ -d "/var/www" ]; then
  echo "${YELLOW}Directory /var/www exists.${TXTRESET}"
else
  echo "${YELLOW}Directory /var/www does not exist. Symlinking $HOME/Projects to it.${TXTRESET}"
  sudo ln -sfnv $HOME/Projects /var/www
fi

echo "${YELLOW}Copying default nginx index to the project dir...${TXTRESET}"

# Figure out the nginx correct installation path
NGINX_VERSION=$(nginx -v 2>&1 | grep -o '[0-9.]*')
NGINX_HOMEBREW_PATH=$(find $HOMEBREW_PATH -name "nginx" -type d -maxdepth 3)
NGINX_HOMEBREW_VERSION_PATH=$(find $NGINX_HOMEBREW_PATH -name $NGINX_VERSION -type d -maxdepth 1)

# Copy the default index.html to the nginx root
sudo cp "${NGINX_HOMEBREW_VERSION_PATH}/html/index.html /var/www/"

echo "${YELLOW}Setting permissions...${TXTRESET}"

# Set the correct permissions
sudo chown -R $(whoami):staff /var/www

# Install PHP
echo "${YELLOW}Installing PHP...${TXTRESET}"

# This part is the same than in here:
# Install and use PHP $PHP_VERSION in your local macos-lemp-setup environment
# https://app.gitbook.com/o/PedExJWZmbCiZe4gDwKC/s/VVikkYgIZ9miBzwYDCYh/how-tos/install-and-use-php-8.3-in-your-local-macos-lemp-setup-environment

# Add the PHP and PHP Extension taps
brew tap shivammathur/php
brew tap shivammathur/extensions

# Install the PHP we need
brew install shivammathur/php/php@${PHP_VERSION}

# Link PHP CLI executable as `php`
brew link --overwrite --force shivammathur/php/php@${PHP_VERSION}

# Test installation, should display PHP 8.3.x (cli)
php -v

# Test php-fpm
lsof -Pni4 | grep LISTEN | grep php

# Symlink the PHP configuration
sudo ln -s $HOMEBREW_PATH/etc/php /etc/php

# Add PHP path to the PATH
sudo echo "export PATH=\"\$(brew --prefix php@${PHP_VERSION})/bin:\$PATH\"" >> ~/.bash_profile

# Restart
sudo brew services stop php@${PHP_VERSION}
sudo brew services start php@${PHP_VERSION}
echo "${BOLDGREEN}PHP installed and running.${TXTRESET}"

# Install MariaDB
echo "${YELLOW}Installing MariaDB...${TXTRESET}"
brew install mariadb
brew services start mariadb
echo "${BOLDGREEN}MariaDB installed and running.${TXTRESET}"

# Install MailHog
echo "${YELLOW}Installing MailHog...${TXTRESET}"
brew update && brew install mailhog
echo "${BOLDGREEN}MailHog installed (run mailhog to start mail server).${TXTRESET}"

# Install DNSmasq
echo "${YELLOW}Installing DNSmasq...${TXTRESET}"
brew install dnsmasq
curl -L https://gist.githubusercontent.com/dtomasi/ab76d14338db82ec24a1fc137caff75b/raw/550c84393c4c1eef8a3e68bb720df561b5d3f175/dnsmasq.conf -o /usr/local/etc/dnsmasq.conf
sudo curl -L https://gist.githubusercontent.com/dtomasi/ab76d14338db82ec24a1fc137caff75b/raw/550c84393c4c1eef8a3e68bb720df561b5d3f175/dev -o /etc/resolver/dev
sudo brew services stop dnsmasq
sudo brew services start dnsmasq
echo "${BOLDGREEN}DNSmasq installed and configured.${TXTRESET}"

# Restart all services
echo "${YELLOW}Restarting services....${TXTRESET}"

# These need to be running as root, because of the port 80 and other privileges.
sudo brew services stop dnsmasq
sudo brew services start dnsmasq
sudo brew services stop nginx
sudo brew services start nginx
sudo brew services stop php@${PHP_VERSION}
sudo brew services start php@${PHP_VERSION}
brew services stop mariadb
brew services start mariadb
sudo brew services list

# All done
echo "${BOLDGREEN}You should now be able to use http://localhost. If not, test with commands sudo nginx -t and sudo php-fpm -t and fix errors. Add new vhosts to /opt/homebrew/etc/nginx/sites-available and symlink them just like you would do in production. Have fun!${TXTRESET}"
