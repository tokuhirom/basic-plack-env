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

sudo mkdir -p /usr/local/webapp/

sudo useradd --gid app --create-home --skel `pwd`/home/ --password `perl -le 'use Time::HiRes qw/gettimeofday/;use Digest::MD5 qw/md5_hex/; print md5_hex(rand().gettimeofday())'` --shell /bin/bash --home /usr/local/webapp/$USER/ $USER
PORT=`perl -e 'print scalar(getpwnam(shift))+5000' $USER`
sudo PL_USER=$USER PL_PORT=$PORT perl -pe 's/<USER>/$ENV{PL_USER}/g; s/<PORT>/$ENV{PL_PORT}/g' < supervisord.tmpl | sudo tee /etc/supervisor/conf.d/$USER.conf > /dev/null
sudo PL_USER=$USER PL_PORT=$PORT PL_DOMAIN=$DOMAIN perl -pe 's/<([A-Z_]+)>/$ENV{"PL_$1"}/ge' < site-nginx.tmpl | sudo tee /etc/nginx/sites-enabled/$USER.conf > /dev/null

sudo -H -u $USER git init --bare /usr/local/webapp/$USER/repo/

cd /usr/local/webapp/$USER/
sudo -H -u $USER cpanm --no-man-pages --local-lib /usr/local/webapp/$USER/perl5/ --notest Plack Starlet Linux::Inotify2 HTTP::Parser::XS

sudo mkdir -p /var/log/nginx/$DOMAIN/

sudo supervisorctl reread
sudo supervisorctl update
sudo supervisorctl start all

sudo /etc/init.d/nginx reload
