set -x

servers=4;
dir=`pwd`

cp ~/build-scripts/test/multiple_servers.cnf $dir
sudo rm -rf /data/mysql/*
sudo rm -rf /var/log/mysql/*
sudo mkdir -p /data/mysql
sudo chown mysql:mysql -R /data
sudo mkdir -p /var/run/mysqld
sudo chown mysql:mysql -R /var/run/mysqld
sudo killall mysqld
sudo killall mysql_install_db

for i in `seq 1 $servers`;
do
    sudo mysql_install_db --defaults-file=$dir/multiple_servers.cnf --user=mysql --datadir=/data/mysql/mysql$i 
done

sudo mysqld_multi  --defaults-file=$dir/multiple_servers.cnf  start --no-log --verbose &

running_servers=0
while [ $running_servers != $servers ] ; do
   running_servers=`mysqld_multi --defaults-file=$dir/multiple_servers.cnf report | grep "is running" | wc -l`
done


for i in `seq 1 $servers`;
do
    sudo mysql --socket=/var/run/mysqld/mysqld$i.sock < ~/build-scripts/test-setup-scripts/create_repl_user.sql
    sudo mysql --socket=/var/run/mysqld/mysqld$i.sock < ~/build-scripts/test-setup-scripts/create_skysql_user.sql
done
