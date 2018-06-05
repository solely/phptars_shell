#!/bin/bash

installResin(){
    if [ ! -d ${resin_install_dir} ]; then
        echo 'install resin'
        [ ! -f "resin-4.0.56.tar.gz" ] && wget -c --tries=5 http://caucho.com/download/resin-4.0.56.tar.gz
        mkdir -p ${resin_install_dir}
        tar zxf resin-4.0.56.tar.gz
        pushd resin-4.0.56
        ./configure --prefix=${resin_install_dir}
#        mkdir m4
#        mkdir ../pro
        /bin/cp -r modules ../pro/
        make && make install
        popd
        if [ -d ${resin_install_dir}/bin ]; then
            echo "resin-4.0.56 installed successfully!"
            else
            echo "ERROR : resin-4.0.56 install fail!"
            rm -rf ${resin_install_dir}
            rm -rf resin-4.0.56
            kill -9 $$
        fi
    fi
}
