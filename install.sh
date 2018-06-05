#!/bin/bash

current_dir=`pwd`
soft_dir=${current_dir}/software

yum -y update
yum -y install gcc gcc-c++ make libtool autoconf patch unzip automake libxml2 libxml2-devel ncurses ncurses-devel libtool-ltdl-devel libtool-ltdl curl curl-devel
yum -y install glibc-devel flex bison screen git zlib-devel wget pcre pcre-devel openssl openssl-devel

[ ! -d ${soft_dir} ] && mkdir -p ${soft_dir}
. ./config.conf
. ./src/cmake.sh
. ./src/mysql.sh
. ./src/java_jdk.sh
. ./src/maven.sh
. ./src/resin.sh
. ./src/phptars.sh



pushd ${soft_dir}
    installCmake | tee ../install.log
    installMySql56 | tee -a ../install.log
    installJavaJdk | tee -a ../install.log
    installMaven | tee -a ../install.log
    installResin | tee -a ../install.log
    installPHPTars | tee -a ../install.log
popd
