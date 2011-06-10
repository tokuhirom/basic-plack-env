#!/bin/sh

if [ $# -ne 1 ]; then
    echo "Usage: create.sh user [domain]"
    exit
fi

USER=$1

sudo userdel --remove $USER
sudo rm /etc/supervisor/conf.d/$USER.conf
sudo rm /etc/nginx/sites-enabled/$USER.conf

