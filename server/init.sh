#!/bin/sh

# NOTE: supervisord in ubuntu is too old and it doesn't parse "environment" parameter correctly.
#       I need to install supervisor from pypi.

# You need uwsgi binary and install it to /usr/local/bin/ manually.
# Since it is not deb-ized.
# Build it with 'python uwsgiconfig.py --build psgi'

# libxml2-dev and libperl-dev is required by uwsgi.
sudo aptitude install -y nginx build-essential curl git-core python-setuptools
sudo aptitude install -y libxml2-dev libperl-dev libdb-dev
sudo curl -o /usr/local/bin/cpanm -L http://cpanmin.us/
sudo chmod +x /usr/local/bin/cpanm
sudo cp nginx.conf /etc/nginx/nginx.conf
sudo /etc/init.d/nginx start
sudo groupadd app
sudo -H cpanm Starlet Plack

echo "@@SUPERVISORD"
sudo easy_install supervisor
sudo cp supervisord-init.d /etc/init.d/supervisor
sudo mkdir -p /etc/supervisor/conf.d/
sudo cp master-supervisord.conf /etc/supervisord.conf
sudo mkdir -p /var/log/supervisor
sudo ln -f -s /etc/init.d/supervisor /etc/rc2.d/S99supervisor
sudo /etc/init.d/supervisor start
