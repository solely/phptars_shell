#!/bin/bash

installMySql56(){
    if [ ! -d "${mysql_install_dir}" -a ! -x "$(command -v mysql)" ]; then
        echo 'install mysql'
        id -u mysql > /dev/null 2>&1
        [ $? -ne 0 ] && useradd -M -s /sbin/nologin mysql
        mkdir -p ${mysql_install_dir}
        mkdir -p ${mysql_data_dir}
        chown mysql.mysql -R ${mysql_data_dir}
        [ ! -f "${mysql_version}.tar.gz" ] && wget -c --tries=5 http://mirrors.163.com/mysql/Downloads/MySQL-5.6/${mysql_version}.tar.gz
        tar zxf ${mysql_version}.tar.gz
        cd ${mysql_version}
        cmake . -DCMAKE_INSTALL_PREFIX=${mysql_install_dir} \
            -DMYSQL_DATADIR=${mysql_data_dir} \
            -DSYSCONFDIR=/etc \
            -DWITH_INNOBASE_STORAGE_ENGINE=1 \
            -DWITH_PARTITION_STORAGE_ENGINE=1 \
            -DWITH_FEDERATED_STORAGE_ENGINE=1 \
            -DWITH_BLACKHOLE_STORAGE_ENGINE=1 \
            -DWITH_MYISAM_STORAGE_ENGINE=1 \
            -DWITH_EMBEDDED_SERVER=1 \
            -DENABLE_DTRACE=0 \
            -DENABLED_LOCAL_INFILE=1 \
            -DDEFAULT_CHARSET=utf8mb4 \
            -DDEFAULT_COLLATION=utf8mb4_general_ci \
            -DEXTRA_CHARSETS=all \
            -DENABLE_DOWNLOADS=1

        make && make install
        cd ..

        if [ -d "${mysql_install_dir}/support-files"  ]; then
            echo "MySQL installed successfully!"
        else
            rm -rf ${mysql_install_dir}
            echo "ERROR : MySQL installed fail!"
            kill -9 $$
        fi

        /bin/cp ${mysql_install_dir}/support-files/mysql.server /etc/init.d/mysqld
        sed -i "s@^basedir=.*@basedir=${mysql_install_dir}@" /etc/init.d/mysqld
        sed -i "s@^datadir=.*@datadir=${mysql_data_dir}@" /etc/init.d/mysqld
        chmod +x /etc/init.d/mysqld
        chkconfig --add mysqld; chkconfig mysqld on;

        # my.cnf
        cat > /etc/my.cnf << EOF
[client]
port = 3306
socket = /tmp/mysql.sock
default-character-set = utf8mb4
[mysql]
prompt="MySQL [\\d]> "
no-auto-rehash
[mysqld]
port = 3306
socket = /tmp/mysql.sock
basedir = ${mysql_install_dir}
datadir = ${mysql_data_dir}
pid-file = ${mysql_data_dir}/mysql.pid
user = mysql
bind-address = 0.0.0.0
server-id = 1
init-connect = 'SET NAMES utf8mb4'
character-set-server = utf8mb4
skip-name-resolve
#skip-networking
back_log = 300
max_connections = 1000
max_connect_errors = 6000
open_files_limit = 65535
table_open_cache = 128
max_allowed_packet = 500M
binlog_cache_size = 1M
max_heap_table_size = 8M
tmp_table_size = 16M
read_buffer_size = 2M
read_rnd_buffer_size = 8M
sort_buffer_size = 8M
join_buffer_size = 8M
key_buffer_size = 4M
thread_cache_size = 8
query_cache_type = 1
query_cache_size = 8M
query_cache_limit = 2M
ft_min_word_len = 4
log_bin = mysql-bin
binlog_format = mixed
expire_logs_days = 7
log_error = ${mysql_data_dir}/mysql-error.log
slow_query_log = 1
long_query_time = 1
slow_query_log_file = ${mysql_data_dir}/mysql-slow.log
performance_schema = 0
explicit_defaults_for_timestamp
#lower_case_table_names = 1
skip-external-locking
default_storage_engine = InnoDB
innodb_file_per_table = 1
innodb_open_files = 500
innodb_buffer_pool_size = 64M
innodb_write_io_threads = 4
innodb_read_io_threads = 4
innodb_thread_concurrency = 0
innodb_purge_threads = 1
innodb_flush_log_at_trx_commit = 2
innodb_log_buffer_size = 2M
innodb_log_file_size = 32M
innodb_log_files_in_group = 3
innodb_max_dirty_pages_pct = 90
innodb_lock_wait_timeout = 120
bulk_insert_buffer_size = 8M
myisam_sort_buffer_size = 8M
myisam_max_sort_file_size = 10G
myisam_repair_threads = 1
interactive_timeout = 28800
wait_timeout = 28800
[mysqldump]
quick
max_allowed_packet = 500M
[myisamchk]
key_buffer_size = 8M
sort_buffer_size = 8M
read_buffer = 4M
write_buffer = 4M
EOF
        ${mysql_install_dir}/scripts/mysql_install_db --user=mysql --basedir=${mysql_install_dir} --datadir=${mysql_data_dir}
        [ -d "/etc/mysql" ] && /bin/mv /etc/mysql{,_bk}
        service mysqld start
        [ -z "$(grep ^'export PATH=' /etc/profile)" ] && echo "export PATH=${mysql_install_dir}/bin:\$PATH" >> /etc/profile
        [ -n "$(grep ^'export PATH=' /etc/profile)" -a -z "$(grep ${mysql_install_dir} /etc/profile)" ] && sed -i "s@^export PATH=\(.*\)@export PATH=${mysql_install_dir}/bin:\1@" /etc/profile
        source /etc/profile

        ${mysql_install_dir}/bin/mysql -e "grant all privileges on *.* to root@'127.0.0.1' identified by \"${mysql_root_pwd}\" with grant option;"
        ${mysql_install_dir}/bin/mysql -e "grant all privileges on *.* to root@'localhost' identified by \"${mysql_root_pwd}\" with grant option;"
        ${mysql_install_dir}/bin/mysql -uroot -p${mysql_root_pwd} -e "delete from mysql.user where Password='';"
        ${mysql_install_dir}/bin/mysql -uroot -p${mysql_root_pwd} -e "delete from mysql.db where User='';"
        ${mysql_install_dir}/bin/mysql -uroot -p${mysql_root_pwd} -e "delete from mysql.proxies_priv where Host!='localhost';"
        ${mysql_install_dir}/bin/mysql -uroot -p${mysql_root_pwd} -e "drop database test;"
        ${mysql_install_dir}/bin/mysql -uroot -p${mysql_root_pwd} -e "reset master;"
        rm -rf /etc/ld.so.conf.d/{mysql,mariadb,percona,alisql}*.conf
        [ -e "${mysql_install_dir}/my.cnf" ] && rm -f ${mysql_install_dir}/my.cnf
        echo "${mysql_install_dir}/lib" > /etc/ld.so.conf.d/mysql.conf
        ldconfig
        service mysqld stop
    fi
}