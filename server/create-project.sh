#!/bin/sh

export PERL_BADLANG=0

if [ $# -le 1 ]; then
    echo "Usage: create.sh user [domain]"
    exit
fi

USER=$1
if [ $# -eq 2 ]; then
    DOMAIN=$2
else
    DOMAIN="$USER.64p.org"
fi
BASEDIR=`pwd`
PL_HOME="/usr/local/webapp/$USER/"
HOME="/usr/local/webapp/$USER/"

sudo mkdir -p /usr/local/webapp/

sudo useradd --gid app --create-home --skel `pwd`/home/ --password `perl -le 'use Time::HiRes qw/gettimeofday/;use Digest::MD5 qw/md5_hex/; print md5_hex(rand().gettimeofday())'` --shell /bin/bash --home $PL_HOME $USER
PORT=`perl -e 'print scalar(getpwnam(shift))+5000' $USER`

# /etc/supervisor/conf.d/$USER.conf
sudo PL_USER=$USER PL_PORT=$PORT PL_DOMAIN=$DOMAIN PL_HOME=$PL_HOME perl -pe 's/<([A-Z_]+)>/$ENV{"PL_$1"}/ge' < parent-supervisord.tmpl | sudo tee /etc/supervisor/conf.d/$USER.conf > /dev/null

# $HOME/supervisord.conf
sudo PL_USER=$USER PL_PORT=$PORT PL_DOMAIN=$DOMAIN PL_HOME=$PL_HOME perl -pe 's/<([A-Z_]+)>/$ENV{"PL_$1"}/ge' < child-supervisord.tmpl | sudo -u $USER tee $HOME/supervisord.conf > /dev/null

#/etc/nginx/sites-enabled/$USER.conf
sudo PL_USER=$USER PL_PORT=$PORT PL_DOMAIN=$DOMAIN PL_HOME=$PL_HOME perl -pe 's/<([A-Z_]+)>/$ENV{"PL_$1"}/ge' < site-nginx.tmpl | sudo tee /etc/nginx/sites-enabled/$USER.conf > /dev/null

sudo -H -u $USER mkdir -p $HOME/log/nginx/
sudo -H -u $USER mkdir -p $HOME/log/supervisor/
sudo -H -u $USER mkdir -p $HOME/run/
sudo -H -u $USER mkdir -p $HOME/tmp/
sudo -H -u $USER mkdir -p $HOME/code/
sudo -H -u $USER cpanm Starlet

# reload parent supervisorctl process
sudo -H supervisorctl reread
sudo -H supervisorctl update
sudo -H supervisorctl start all

sudo -H -u $USER supervisorctl -c $HOME/supervisord.conf reread
sudo -H -u $USER supervisorctl -c $HOME/supervisord.conf update
sudo -H -u $USER supervisorctl -c $HOME/supervisord.conf start all

sudo /etc/init.d/nginx reload

