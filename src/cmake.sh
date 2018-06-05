#!/bin/bash

installCmake(){
    if ! [ -x "$(command -v cmake)"  ];then
        echo 'install cmake'
        [ ! -f "cmake-3.11.2.tar.gz" ] && wget -c --tries=5 https://cmake.org/files/v3.11/cmake-3.11.2.tar.gz
        tar zxf cmake-3.11.2.tar.gz
        cd cmake-3.11.2
        ./bootstrap && make && make install
        cd ..
    fi
}