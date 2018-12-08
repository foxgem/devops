#!/bin/bash -e

sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt xenial-pgdg main" >> /etc/apt/sources.list'

sed -i "s/archive.ubuntu.com/mirrors.aliyun.com/g" /etc/apt/sources.list

wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -

mkdir -p /var/provisions

apt update

PG_VERSION=10

echo "Changing timezone to Asia/Shanghai..."
cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

if [ ! -f /var/provisions/postgresql ]; then
    echo "Installing Postgresql and setting it up..."
    apt install -y postgresql-10
    touch /var/provisions/postgresql

    # set dirs for data and log
    mkdir -p /var/lib/pgsql/data
    export PGDATA=/var/lib/pgsql/data
    mkdir -p /var/log/pgsql
    export PGLOG=/var/log/pgsql

    # make client in host can connect pg in vm.
    PG_CONF="/etc/postgresql/$PG_VERSION/main/postgresql.conf"
    PG_HBA="/etc/postgresql/$PG_VERSION/main/pg_hba.conf"
    sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" "$PG_CONF"
    echo "host    all             all             all                     md5" >> "$PG_HBA"
    echo "client_encoding = utf8" >> "$PG_CONF"
fi

if [ ! -f /var/provisions/postgis ]; then
    echo "Installing postgis and setting it up..."
    apt install -y postgresql-10-postgis-2.4
    apt install -y postgresql-10-postgis-scripts
    touch /var/provisions/postgis
fi

if [ ! -f /var/provisions/pgrouting ]; then
    echo "Installing pgrouting and setting it up..."
    apt install -y postgresql-10-pgrouting
    touch /var/provisions/pgrouting
fi

service postgresql restart

echo "Provision is done!"