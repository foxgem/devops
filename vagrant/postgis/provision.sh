#!/bin/bash -e

cat > /etc/apt/sources.list <<EOF
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ $(lsb_release -sc) main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ $(lsb_release -sc)-updates main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ $(lsb_release -sc)-backports main restricted universe multiverse
deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ $(lsb_release -sc)-security main restricted universe multiverse
EOF

cat > /etc/apt/sources.list.d/pgdg.list <<EOF
deb https://mirrors.tuna.tsinghua.edu.cn/postgresql/repos/apt/ $(lsb_release -sc)-pgdg main
EOF

curl -s https://mirrors.tuna.tsinghua.edu.cn/postgresql/repos/apt/ACCC4CF8.asc | apt-key add -

apt update

PG_VERSION=10

echo "Changing timezone to Asia/Shanghai..."
timedatectl set-timezone Asia/Shanghai

echo "Installing Postgresql and setting it up..."
apt install -y postgresql-${PG_VERSION}
systemctl enable postgresql

# make client in host can connect pg in vm.
PG_CONF="/etc/postgresql/$PG_VERSION/main/postgresql.conf"
PG_HBA="/etc/postgresql/$PG_VERSION/main/pg_hba.conf"
cat > "${PG_HBA}" <<EOF
local  all   all                peer
host   all   postgres   all     trust
host   all   all        all     md5
EOF
cat > "${PG_CONF}" <<EOF
data_directory = '/var/lib/postgresql/${PG_VERSION}/main'
hba_file = '/etc/postgresql/${PG_VERSION}/main/pg_hba.conf'
ident_file = '/etc/postgresql/${PG_VERSION}/main/pg_ident.conf'
external_pid_file = '/var/run/postgresql/${PG_VERSION}-main.pid'
listen_addresses = '*'
port = 5432
unix_socket_directories = '/var/run/postgresql'
ssl = on
ssl_cert_file = '/etc/ssl/certs/ssl-cert-snakeoil.pem'
ssl_key_file = '/etc/ssl/private/ssl-cert-snakeoil.key'
dynamic_shared_memory_type = posix
log_line_prefix = '%m [%p] %q%u@%d '
log_timezone = 'PRC'
cluster_name = '${PG_VERSION}/main'
stats_temp_directory = '/var/run/postgresql/${PG_VERSION}-main.pg_stat_tmp'
datestyle = 'iso, ymd'
timezone = 'PRC'
lc_messages = 'en_US.UTF-8'
lc_monetary = 'en_US.UTF-8'
lc_numeric = 'en_US.UTF-8'
lc_time = 'en_US.UTF-8'
default_text_search_config = 'pg_catalog.simple'
include_dir = 'conf.d'
max_connections = 50
shared_buffers = 512MB
maintenance_work_mem = 256MB
checkpoint_completion_target = 0.7
wal_buffers = 16MB
default_statistics_target = 100
random_page_cost = 4
effective_io_concurrency = 2
work_mem = 20971kB
max_worker_processes = 2
max_parallel_workers_per_gather = 1
max_parallel_workers = 2
client_encoding = utf8
EOF

echo "Installing postgis and pgrouting..."
apt install -y postgresql-${PG_VERSION}-postgis-2.4 postgresql-${PG_VERSION}-postgis-scripts postgresql-${PG_VERSION}-pgrouting

service postgresql restart

echo "Provision is done!"
