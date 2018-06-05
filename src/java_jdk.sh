#!/bin/bash

installJavaJdk(){
    if [ ! -d ${java_jdk_install_dir} ]; then
        echo 'install java jdk'
        [ ! -f "${java_jdk_dir}/jdk-8u172-linux-x64.tar.gz" ] && echo 'ERROR : please download jdk-8u172-linux-x64.tar.gz' && kill -9 $$
        mkdir -p ${java_jdk_install_dir}
        pushd ${java_jdk_dir}
        tar zxf jdk-8u172-linux-x64.tar.gz -C ${java_jdk_install_dir}
        JDK_PATH=${java_jdk_install_dir}/jdk1.8.0_172
        popd
        if [ -d "${JDK_PATH}" ]; then
            [ -z "`grep ^'export JAVA_HOME=' /etc/profile`" ] && { [ -z "`grep ^'export PATH=' /etc/profile`" ] && echo  "export JAVA_HOME=${JDK_PATH}" >> /etc/profile || sed -i "s@^export PATH=@export JAVA_HOME=${JDK_PATH}\nexport PATH=@" /etc/profile; } || sed -i "s@^export JAVA_HOME=.*@export JAVA_HOME=${JDK_PATH}@" /etc/profile
            [ -z "`grep ^'export CLASSPATH=' /etc/profile`" ] && sed -i "s@export JAVA_HOME=\(.*\)@export JAVA_HOME=\1\nexport CLASSPATH=\$JAVA_HOME/lib/tools.jar:\$JAVA_HOME/lib/dt.jar:\$JAVA_HOME/lib@" /etc/profile
            [ -n "`grep ^'export PATH=' /etc/profile`" -a -z "`grep '$JAVA_HOME/bin' /etc/profile`" ] && sed -i "s@^export PATH=\(.*\)@export PATH=\$JAVA_HOME/bin:\1@" /etc/profile
            [ -z "`grep ^'export PATH=' /etc/profile | grep '$JAVA_HOME/bin'`" ] && echo 'export PATH=$JAVA_HOME/bin:$PATH' >> /etc/profile
            source /etc/profile
            echo "jdk-8u172-linux-x64 installed successfully!"
          else
            echo "ERROR : jdk-8u172-linux-x64 install fail!"
            rm -rf ${java_jdk_install_dir}
            kill -9 $$
        fi
    fi
}