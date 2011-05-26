#!/bin/sh
sudo aptitude install -y nginx w3m build-essential git cvs curl screen supervisor git-core wget
sudo curl -o /usr/local/bin/cpanm -L http://cpanmin.us/
sudo chmod +x /usr/local/bin/cpanm
sudo cp nginx.conf /etc/nginx/nginx.conf
sudo /etc/init.d/nginx start
