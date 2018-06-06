#!/bin/bash

installPHPTars(){
    if [ ! -d ${phptars_install_dir} ]; then
        echo 'install phptars'
        if [ ! -f "phptars.tar.gz" ]; then
            
            git clone https://github.com/Tencent/Tars.git
            pushd Tars
            git checkout phptars
            git clone https://github.com/Tencent/rapidjson.git
            /bin/cp -r rapidjson cpp/thirdparty/
            popd
            tar zcf phptars.tar.gz Tars
            else
            tar zxf phptars.tar.gz
        fi
        mkdir -p ${phptars_install_dir}
        /bin/mv Tars ${phptars_install_dir}
        cd ${phptars_install_dir}/Tars
        cd java
        mvn clean install
        mvn clean install -f core/client.pom.xml
        mvn clean install -f core/server.pom.xml
        cd -
        cd cpp/build
        chmod u+x build.sh
        /bin/bash build.sh all
        /bin/bash build.sh install
        cd -

        service mysql restart
        ${mysql_install_dir}/bin/mysql -uroot -p${mysql_root_pwd} -e "grant all privileges on *.* to 'tars'@'%' identified by 'tars2015' with grant option;"
        ${mysql_install_dir}/bin/mysql -uroot -p${mysql_root_pwd} -e "grant all privileges on *.* to 'tars'@'localhost' identified by 'tars2015' with grant option;"
        ${mysql_install_dir}/bin/mysql -uroot -p${mysql_root_pwd} -e "grant all privileges on *.* to 'tars'@'${machine_name}' identified by 'tars2015' with grant option;"
        ${mysql_install_dir}/bin/mysql -uroot -p${mysql_root_pwd} -e "flush privileges;"
        ${mysql_install_dir}/bin/mysql -uroot -p${mysql_root_pwd} -e "drop database if exists db_tars;"
        ${mysql_install_dir}/bin/mysql -uroot -p${mysql_root_pwd} -e "drop database if exists tars_property;"
        ${mysql_install_dir}/bin/mysql -uroot -p${mysql_root_pwd} -e "drop database if exists tars_stat;"

        cd cpp/framework/sql
        sed -i "s/192.168.2.131/${machine_ip}/g" `grep 192.168.2.131 -rl ./*`
        sed -i "s/db.tars.com/${machine_ip}/g" `grep db.tars.com -rl ./*`
        sed -i "s/root@appinside/${mysql_root_pwd}/g" exec-sql.sh
        chmod u+x exec-sql.sh
        /bin/bash exec-sql.sh
        cd -
        cd cpp/build
        make framework-tar
        make tarsstat-tar
        make tarsnotify-tar
        make tarsproperty-tar
        make tarslog-tar
        make tarsquerystat-tar
        make tarsqueryproperty-tar

        [ ! -d "/usr/local/app/tars" ] && mkdir -p /usr/local/app/tars/
        /bin/cp -f framework.tgz /usr/local/app/tars/
        cd -
        cd /usr/local/app/tars
        tar zxf framework.tgz
        sed -i "s/192.168.2.131/${machine_ip}/g" `grep 192.168.2.131 -rl ./*`
        sed -i "s/db.tars.com/${machine_ip}/g" `grep db.tars.com -rl ./*`
        sed -i "s/registry.tars.com/${machine_ip}/g" `grep registry.tars.com -rl ./*`
        sed -i "s/web.tars.com/${machine_ip}/g" `grep web.tars.com -rl ./*`
        chmod u+x tars_install.sh
        chmod u+x tarspatch/util/init.sh
        /bin/bash tars_install.sh
        /bin/bash tarspatch/util/init.sh
        cd -

        cd web
        sed -i "s/db.tars.com/${machine_ip}/g" `grep db.tars.com -rl ./src/main/resources/*`
        sed -i "s/registry1.tars.com/${machine_ip}/g" `grep registry1.tars.com -rl ./src/main/resources/*`
        sed -i "s/registry2.tars.com/${machine_ip}/g" `grep registry2.tars.com -rl ./src/main/resources/*`
        mvn clean package
        /bin/cp -f ./target/tars.war ${resin_install_dir}/webapps/
        cd -

        [ ! -d "/data/log/tars" ] && mkdir -p /data/log/tars/
        /bin/cp -f build/conf/resin.xml ${resin_install_dir}/conf/
        ${resin_install_dir}/bin/resin.sh start
        iptables -I INPUT -p tcp --dport 8080 -j ACCEPT
    fi
}