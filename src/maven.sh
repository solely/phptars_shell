#!/bin/bash

installMaven(){
    if [ ! -d ${maven_install_dir} ]; then
        echo 'install maven'
        [ ! -f "apache-maven-3.5.3-bin.tar.gz" ] && wget -c --tries=5 http://mirrors.hust.edu.cn/apache/maven/maven-3/3.5.3/binaries/apache-maven-3.5.3-bin.tar.gz
        mkdir -p ${maven_install_dir}
        tar zxf apache-maven-3.5.3-bin.tar.gz -C ${maven_install_dir}
        MAVEN_PATH=${maven_install_dir}/apache-maven-3.5.3
        if [ -d "${MAVEN_PATH}" ]; then
            [ -z "`grep ^'export MAVEN_HOME=' /etc/profile`" ] && echo 'export MAVEN_HOME='${MAVEN_PATH} >> /etc/profile
            [ -z "`grep ^'export PATH=' /etc/profile | grep ${MAVEN_PATH}'/bin'`" ] && echo 'export PATH='${MAVEN_PATH}'/bin:$PATH' >> /etc/profile
            source /etc/profile
            echo "apache-maven-3.5.3 installed successfully!"
            else
            echo 'ERROR : apache-maven-3.5.3 install fail'
            rm -rf ${maven_install_dir}
            kill -9 $$
        fi
    fi
}