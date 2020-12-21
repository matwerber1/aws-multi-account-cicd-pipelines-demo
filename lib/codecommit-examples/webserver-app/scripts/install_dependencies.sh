#!/bin/bash

# Install PHP 7.4:
# https://computingforgeeks.com/how-to-install-php-on-ubuntu/
sudo apt-get update
sudo apt -y install software-properties-common
sudo add-apt-repository ppa:ondrej/php -y
sudo apt -y install php7.4

# Web server and MariaDB
sudo apt install -y apache2
sudo apt install -y mariadb-server
sudo apt-get install -y php7.4-fpm