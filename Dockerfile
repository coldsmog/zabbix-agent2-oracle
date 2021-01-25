FROM centos:centos7 as build-env
COPY ["instantclient_12_1.zip", "/tmp"]
RUN yum install -y unzip && \
    mkdir -p /oracle_client/ && \
    unzip /tmp/instantclient_12_1.zip -d /oracle_client && \
    cd /oracle_client/instantclient_12_1 && \
	ln -s libclntsh.so.12.1 libclntsh.so && \
	ln -s libocci.so.12.1 libocci.so 

FROM centos:centos7

# oracle client: https://www.oracle.com/cn/database/technologies/instant-client/linux-x86-64-downloads.html#ic_x64_inst
ENV ORACLE_HOME=/oracle_client/instantclient_12_1  \
	TNS_ADMIN=/oracle_client/instantclient_12_1  \
	LD_LIBRARY_PATH=/oracle_client/instantclient_12_1  \
	PATH=/oracle_client/instantclient_12_1:$PATH  \
    NLS_LANG=AMERICAN 
# 中文提示：NLS_LANG=SIMPLIFTED_CHINESE_CHINA_ZHS16GBK
	
# install agent2
# Maybe you need the official link: https://repo.zabbix.com/zabbix/5.2/rhel/7/x86_64/zabbix-agent2-5.2.1-1.el7.x86_64.rpm
RUN yum localinstall -y https://mirrors.aliyun.com/zabbix/zabbix/5.2/rhel/7/x86_64/zabbix-agent2-5.2.1-1.el7.x86_64.rpm && \
# install instantclient_12_1 sqlplus
    mkdir -p /oracle_client/instantclient_12_1 && \
    yum install -y libaio && \
	yum clean all && \
	rm -rf /var/cache/yum/*
    
# add files: instantclient_12_1 docker-entrypoint.sh
# fixbug: automated build not support .tar.gz,  use Multi-stage construction.
COPY --from=build-env /oracle_client/instantclient_12_1/* /oracle_client/instantclient_12_1/
COPY ["docker-entrypoint.sh", "/usr/bin/"]
	
EXPOSE 10050/TCP

WORKDIR /var/lib/zabbix

VOLUME ["/var/lib/zabbix/enc"]

ENTRYPOINT ["/bin/bash", "/usr/bin/docker-entrypoint.sh"]

CMD ["/usr/sbin/zabbix_agent2", "--foreground", "-c", "/etc/zabbix/zabbix_agent2.conf"]