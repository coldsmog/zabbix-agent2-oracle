# zabbix-agent2-oracle
基于centos7,安装了zabbix-agent2、instantclient_12_1和sqlplus
因为东方的神秘力量导致访问速度太慢，所以使用的阿里源。
阿里源如果下载全部仓库的话，还是会被定位到官方仓库，所以只下载agent2的rpm
instantclient_12_1 支持版本: 19c, 18c, 12.2.0, 12.1.0, 11.2.0
instantclient_12_1.tar.gz是下载oracle官方的instantclient-sqlplus-linux.x64-12.1.0.2.zip和instantclient-basic-linux.x64-12.1.0.2.0.zip 解压后重新用tar压缩.

![logo](https://assets.zabbix.com/img/logo/zabbix_logo_500x131.png)

# 什么是Zabbix?

Zabbix是企业级的开源分布式监视解决方案。

Zabbix是监视网络众多参数以及服务器运行状况和完整性的软件。Zabbix使用灵活的通知机制，允许用户为几乎任何事件配置基于电子邮件的警报。这样可以快速响应服务器问题。Zabbix根据存储的数据提供出色的报告和数据可视化功能。这使得Zabbix非常适合容量规划。

有关Zabbix组件的更多信息和相关下载，请访问https://hub.docker.com/u/zabbix/和https://zabbix.com

# 什么是 Zabbix agent 2?

Zabbix agent 2 部署在监视的目标上，可主动监控本地资源和应用程序（硬盘，内存，处理器统计信息等）

# zabbix-agent2-oracle 镜像

因为官方alpine版本对运维不友好，且没有oracle客户端。故简单弄个可以直接监控数据库镜像

基于centos7,安装了zabbix-agent2、instantclient_12_1和sqlplus。instantclient_12_1 支持Oracle版本: 19c, 18c, 12.2.0, 12.1.0, 11.2.0

因为东方的神秘力量导致访问速度太慢，所以使用的阿里源。阿里源如果下载全部仓库的话，还是会被定位到官方仓库，所以只下载agent2的rpm

instantclient_12_1.tar.gz是下载oracle官方的instantclient-sqlplus-linux.x64-12.1.0.2.zip和instantclient-basic-linux.x64-12.1.0.2.0.zip 解压后重新用tar压缩，需要更换的话自行克隆压缩吧.其余的看GitHub[coldsmog/zabbix-agent2-oracle](https://github.com/coldsmog/zabbix-agent2-oracle)

# 如何使用这个镜像？和官方alpine-4.4-latest使用方式一致。
[https://hub.docker.com/r/zabbix/zabbix-agent2](https://hub.docker.com/r/zabbix/zabbix-agent2)

也许你需要一个docker-compose.yml文件参考？

```
version: '3'
services:
  zabbix-agent:
    image: 'coldsmog/zabbix-agent2-oracle:latest'
    restart: always
    container_name: zabbix-agent2
    privileged: true # 因为是监控软件，需要开启特权
    environment:
      - ZBX_HOSTNAME=zabbix_hostname   # 自行修改为agent2的IP
      - ZBX_METADATAITEM=system.uname  # 自行修改为agent2的hostname
      - ZBX_SERVER_HOST=172.16.255.255 # 自行修改为Server的IP
    ports:
      - '10050:10050'
    volumes:
      - /etc/zabbix/zabbix_agentd.d:/etc/zabbix/zabbix_agentd.d
      - /var/lib/zabbix/enc:/var/lib/zabbix/enc
      - /var/lib/zabbix/modules:/var/lib/zabbix/modules
```

## 环境变量

启动zabbix-agent2映像时，可以通过在docker run命令行上传递一个或多个环境变量来调整Zabbix代理2的配置。

### `ZBX_HOSTNAME`

此变量是唯一的，区分大小写的主机名。默认情况下，值是hostname容器的值。是zabbix_agent2.conf中的Hostname参数

### `ZBX_SERVER_HOST`

该变量是Zabbix服务器或Zabbix代理的IP或DNS名称。默认情况下，值为zabbix-server。是中的Server参数zabbix_agent2.conf。允许使用ZBX_SERVER_PORT变量指定Zabbix服务器或Zabbix代理端口号。在非默认端口进行主动检查的情况下，这是有意义的

### `ZBX_PASSIVE_ALLOW`

此变量为boolean（true或false），启用或禁用被动检查功能。默认情况下，值为true

### `ZBX_PASSIVESERVERS`

该变量是逗号分隔的允许连接到Zabbix代理2容器的Zabbix服务器或代理主机的列表。

### `ZBX_ACTIVE_ALLOW`

此变量为布尔值（true或false），启用或禁用活动检查功能。默认情况下，值为true。

### `ZBX_ACTIVESERVERS`

该变量是逗号分隔的允许连接到Zabbix代理2容器的Zabbix服务器或代理主机的列表。您可以在这种语法指定的zabbix服务器或代理的zabbix端口：zabbix-server:10061,zabbix-proxy:10072。

### `ZBX_DEBUGLEVEL`

该变量用于指定调试级别。默认情况下，值为3。是zabbix_agent2.conf中的DebugLevel参数。允许的值如下所示：
- ``0`` - 有关启动和停止Zabbix进程的基本信息
- ``1`` - 重要信息
- ``2`` - 错误信息
- ``3`` - 警告
- ``4`` - 用于调试（产生大量信息）
- ``5`` - 扩展调试（产生更多信息）



### `ZBX_TIMEOUT`

该变量用于指定处理检查的超时时间。默认情况下，值为3。

### 其他变量

此外，该映像还可以指定下面列出的许多其他环境变量，参考[zabbix_agent2.conf](https://www.zabbix.com/documentation/current/manual/appendix/config/zabbix_agent2)：

```
ZBX_ENABLEPERSISTENTBUFFER=false # Available since 5.0.0
ZBX_PERSISTENTBUFFERPERIOD=1h # Available since 5.0.0
ZBX_ENABLESTATUSPORT=
ZBX_SOURCEIP=
ZBX_ENABLEREMOTECOMMANDS=0 # Deprecated since 5.0.0
ZBX_LOGREMOTECOMMANDS=0
ZBX_STARTAGENTS=3
ZBX_HOSTNAMEITEM=system.hostname
ZBX_METADATA=
ZBX_METADATAITEM=
ZBX_REFRESHACTIVECHECKS=120
ZBX_BUFFERSEND=5
ZBX_BUFFERSIZE=100
ZBX_MAXLINESPERSECOND=20
ZBX_LISTENIP=
ZBX_UNSAFEUSERPARAMETERS=0
ZBX_TLSCONNECT=unencrypted
ZBX_TLSACCEPT=unencrypted
ZBX_TLSCAFILE=
ZBX_TLSCRLFILE=
ZBX_TLSSERVERCERTISSUER=
ZBX_TLSSERVERCERTSUBJECT=
ZBX_TLSCERTFILE=
ZBX_TLSKEYFILE=
ZBX_TLSPSKIDENTITY=
ZBX_TLSPSKFILE=
ZBX_DENYKEY=system.run[*] # Available since 5.0.0
ZBX_ALLOWKEY= # Available since 5.0.0
```

## Zabbix agent 2容器允许持久化的volumes

### ``/etc/zabbix/zabbix_agentd.d``

该卷允许包含*.conf文件并使用UserParameter功能扩展Zabbix代理2 

### ``/var/lib/zabbix/enc``

该卷用于存储TLS相关文件。这些文件的名称使用规定ZBX_TLSCAFILE，ZBX_TLSCRLFILE，ZBX_TLSKEY_FILE和ZBX_TLSPSKFILE变量。

### ``/var/lib/zabbix/buffer``

该卷用于存储文件，Zabbix Agent2应该在其中保存SQLite数据库。要启用该功能，请指定ZBX_ENABLEPERSISTENTBUFFER=true。自5.0.0起可用。

# The image variants

The `zabbix-agent2` images come in many flavors, each designed for a specific use case.
