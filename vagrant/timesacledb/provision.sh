#!/bin/bash -e

sed -i "s/archive.ubuntu.com/mirrors.aliyun.com/g" /etc/apt/sources.list

echo "deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main" > /etc/apt/sources.list.d/pgdg.list

wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -

add-apt-repository -y ppa:timescale/timescaledb-ppa

mkdir -p /var/provisions

apt-get update

if [ ! -f /var/provisions/postgresql ]; then
    echo "Installing Postgresql and setting it up..."
    apt-get install -y postgresql-10
    touch /var/provisions/postgresql

    mkdir -p /var/lib/pgsql/data
    export PGDATA=/var/lib/pgsql/data
    mkdir -p /var/log/pgsql
    export PGLOG=/var/log/pgsql
fi

if [ ! -f /var/provisions/timescaledb ]; then
    echo "Installing timescaledb and setting it up..."
    apt-get install -y timescaledb-postgresql-10
    touch /var/provisions/timescaledb

    echo "shared_preload_libraries = 'timescaledb'" >> /etc/postgresql/10/main/postgresql.conf
    service postgresql restart
fi

echo "Provision is done!"