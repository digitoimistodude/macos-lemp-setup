### 1.0.8: 2024-04-12

* Add unit tests (GitHub actions) for macOS, Homebrew and install.sh
* Add build status badge
* Rewrite install.sh for PHP 8.3, use variables instead of hardcoded paths and versions
* PHP 8.3 support

### 1.0.7: 2023-05-12

* Fix duplicate symlink for nginx folder
* Add php-fpm user, group and listen to PHP post installation instructions

### 1.0.6: 2022-11-28

* Remove derepcated homebrew/dupes and homebrew/versions taps (part of homebrew/core)
* Remove deprecated LaunchAgents
* Change deprecated homebrew/homebrew-php to shivammathur/php
* Fix install commands for php@7.4

### 1.0.5: 2022-08-16

* Change xdebug.mode from debug to develop so var_dump will be shown correctly
* Fixes and clean ups for macOS M1

### 1.0.4: 2021-11-13

* Fix installer oneliner syntax, change to curl for better reliability

### 1.0.3: 2021-09-23

* Add MailHog for local email testing

### 1.0.2: 2021-03-24

* Start public versioning
