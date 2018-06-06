# phptars项目
https://github.com/Tencent/Tars/tree/phptars

# phptars_shell

记得使用 root 账户
```bush
git clone https://github.com/solely/phptars_shell.git
cd phptars_shell
```

下载 java  jdk-8u172-linux-x64.tar.gz放在此文件同目录下 <Br>
【下载地址：http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html】

```bush
chmod u+x install.sh && ./install.sh
```


### config.conf
machine_ip 不要填写 127.0.0.1


此文件的配置参数均可自由设置，详见配置说明


### other
建议使用源码编译 MySQL，使用yum安装 MySQL 在编译 phptars 时会提示找不到 mysql.sh 文件

安装完成后，在web管理平台发布包失败时：

1.查看 resin、rsync 服务起来没有

```bush
ps -ef | grep resin     
ps -ef | grep rsync
ps -ef | grep tars //可以看到tars的主要服务
```


2.如果第一步有服务均未启动

```bash
${resin_install_dir}/bin/resin.sh start
/bin/bash /usr/local/app/tars/tarspatch/util/init.sh
```


3.如果第一步服务均已启动，删掉 ${phptars_install_dir}，手动按步骤执行 phptars.sh 脚本代码

4.服务器记得开启8080端口
```bash
iptables -I INPUT -p tcp --dport 8080 -j ACCEPT
```
