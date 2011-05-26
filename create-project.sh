#!/bin/sh

if [ $# -ne 1 ]; then
    echo "Usage: create.sh user"
    exit
fi

USER=$0
BASEDIR=`pwd`

sudo useradd --create-home --skel `pwd`/home/ --password `perl -le 'use Time::HiRes qw/gettimeofday/;use Digest::MD5 qw/md5_hex/; print md5_hex(rand().gettimeofday())'` --shell /bin/zsh $USER
sudo -u $USER -s -H

cpanm Plack Starlet Linux::Inotify2

