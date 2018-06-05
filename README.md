# phptars_shell
`
git clone https://github.com/solely/phptars_shell.git`

`cd phptars_shell
`

`下载java  jdk-8u172-linux-x64.tar.gz放在此文件同目录下 
【下载地址：http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html】
`

`chmod u+x install.sh && ./install.sh
`
### config.conf
`machine_ip 不要填写 127.0.0.1
`

`此文件的配置参数均可自由设置，详见配置说明
`

### other
`安装完成后，在web管理平台发布包失败时：
`

`1.查看 resin、rsync 服务起来没有
`

`ps -ef | grep resin     ps -ef | grep rsync
`

`2.如果第一步有服务均未启动
`

`${resin_install_dir}/bin/resin.sh start
`

`/bin/bash /usr/local/app/tars/tarspatch/util/init.sh
`

`3.如果第一步服务均已启动，删掉 ${phptars_install_dir}，手动按步骤执行 phptars.sh 脚本代码
`