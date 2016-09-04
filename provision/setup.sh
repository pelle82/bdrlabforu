#!/bin/sh

echo "###########################################"

echo "Updating OS"

echo "###########################################"

apt-get update; apt-get upgrade -y; apt-get dist-upgrade -y; apt-get autoremove -y; apt-get install vim wget ca-certificates -y

echo "###########################################"


echo "###########################################"

echo "Add APT Repository for BDR"

echo "###########################################"

sh -c 'echo "deb http://packages.2ndquadrant.com/bdr/apt/ $(lsb_release -cs)-2ndquadrant main" > /etc/apt/sources.list.d/2ndquadrant.list'
wget --quiet -O - http://packages.2ndquadrant.com/bdr/apt/AA7A6805.asc | sudo apt-key add -
sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
apt-get update

echo "###########################################"


echo "###########################################"

echo "Install the BDR packages"

echo "###########################################"

sudo apt-get install -y postgresql-bdr-9.4-bdr-plugin

echo "###########################################"


echo "###########################################"

echo "Add postgres to path"

echo "###########################################"

echo "PATH=/usr/pgsql-9.4/bin:$PATH" >> /etc/profile

echo "###########################################"


echo "###########################################"

echo "Config BDR"

echo "###########################################"

echo "" >> /etc/postgresql/9.4/main/postgresql.conf
echo "#### BDR Configuration ####" >> /etc/postgresql/9.4/main/postgresql.conf
echo "listen_addresses = '*'" >> /etc/postgresql/9.4/main/postgresql.conf
echo "shared_preload_libraries = 'bdr'" >> /etc/postgresql/9.4/main/postgresql.conf
echo "wal_level = 'logical'" >> /etc/postgresql/9.4/main/postgresql.conf
echo "track_commit_timestamp = on" >> /etc/postgresql/9.4/main/postgresql.conf
echo "max_wal_senders = 10" >> /etc/postgresql/9.4/main/postgresql.conf
echo "max_replication_slots = 10" >> /etc/postgresql/9.4/main/postgresql.conf
echo "max_worker_processes = 10" >> /etc/postgresql/9.4/main/postgresql.conf
echo "log_error_verbosity = verbose" >> /etc/postgresql/9.4/main/postgresql.conf
echo "log_min_messages = debug1" >> /etc/postgresql/9.4/main/postgresql.conf
echo "log_line_prefix = 'd=%d p=%p a=%a%q '" >> /etc/postgresql/9.4/main/postgresql.conf
echo "bdr.default_apply_delay=2000" >> /etc/postgresql/9.4/main/postgresql.conf
echo "bdr.log_conflicts_to_table=on" >> /etc/postgresql/9.4/main/postgresql.conf

echo "" >> /etc/postgresql/9.4/main/pg_hba.conf
echo "host    all             all             0.0.0.0/0               trust" >> /etc/postgresql/9.4/main/pg_hba.conf
echo "local   replication   postgres                  trust" >> /etc/postgresql/9.4/main/pg_hba.conf
echo "host    replication   postgres     0.0.0.0/0 trust" >> /etc/postgresql/9.4/main/pg_hba.conf
echo "host    replication   postgres     ::1/128      trust" >> /etc/postgresql/9.4/main/pg_hba.conf
sed -i -e 's/peer/trust/g' /etc/postgresql/9.4/main/pg_hba.conf

/etc/init.d/postgresql stop
/etc/init.d/postgresql start

createdb -U postgres bdrpelle
psql -U postgres bdrpelle -c "CREATE EXTENSION btree_gist;"
psql -U postgres bdrpelle -c "CREATE EXTENSION bdr;"

if [ "`hostname`" = devnode01 ]; then psql -U postgres bdrpelle -c "SELECT bdr.bdr_group_create(local_node_name := 'node1', node_external_dsn := 'dbname=bdrpelle host=10.10.0.201');"; fi
if [ "`hostname`" = devnode01 ]; then psql -U postgres bdrpelle -c "SELECT bdr.bdr_node_join_wait_for_ready();"; fi

if [ "`hostname`" = devnode02 ]; then psql -U postgres bdrpelle -c "SELECT bdr.bdr_group_join(local_node_name := 'node2', node_external_dsn := 'dbname=bdrpelle host=10.10.0.202', join_using_dsn := 'dbname=bdrpelle host=10.10.0.201');"; fi
if [ "`hostname`" = devnode02 ]; then psql -U postgres bdrpelle -c "SELECT bdr.bdr_node_join_wait_for_ready();"; fi

echo "###########################################"
