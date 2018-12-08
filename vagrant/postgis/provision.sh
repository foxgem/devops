#!/bin/bash -e

sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt xenial-pgdg main" >> /etc/apt/sources.list'

sed -i "s/archive.ubuntu.com/mirrors.aliyun.com/g" /etc/apt/sources.list

wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -

mkdir -p /var/provisions

apt update

echo "Changing timezone to Asia/Shanghai..."
cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

if [ ! -f /var/provisions/postgresql ]; then
    echo "Installing Postgresql and setting it up..."
    apt install -y postgresql-10
    touch /var/provisions/postgresql

    mkdir -p /var/lib/pgsql/data
    export PGDATA=/var/lib/pgsql/data
    mkdir -p /var/log/pgsql
    export PGLOG=/var/log/pgsql
fi

if [ ! -f /var/provisions/postgis ]; then
    echo "Installing postgis and setting it up..."
    apt install -y postgresql-10-postgis-2.4
    apt install -y postgresql-10-postgis-scripts
    apt install -y postgis
    touch /var/provisions/postgis
fi

if [ ! -f /var/provisions/pgrouting ]; then
    echo "Installing pgrouting and setting it up..."
    apt install -y postgresql-10-pgrouting
    touch /var/provisions/pgrouting
fi

service postgresql restart

echo "Provision is done!"