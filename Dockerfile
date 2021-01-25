FROM centos:centos7

# oracle client: https://www.oracle.com/cn/database/technologies/instant-client/linux-x86-64-downloads.html#ic_x64_inst
ENV ORACLE_HOME=/oracle_client/instantclient_12_1  \
	TNS_ADMIN=/oracle_client/instantclient_12_1  \
	LD_LIBRARY_PATH=/oracle_client/instantclient_12_1  \
	PATH=/oracle_client/instantclient_12_1:$PATH  \
    NLS_LANG=AMERICAN 
# 中文提示：NLS_LANG=SIMPLIFTED_CHINESE_CHINA_ZHS16GBK
	
# add files: instantclient_12_1 docker-entrypoint.sh
# fixbug: automated build not support .tar.gz, but i can.
COPY instantclient_12_1.tar.gz /
COPY ["docker-entrypoint.sh", "/usr/bin/"]
	
# install agent2
# Maybe you need the official link: https://repo.zabbix.com/zabbix/5.2/rhel/7/x86_64/zabbix-agent2-5.2.1-1.el7.x86_64.rpm
RUN yum localinstall -y https://mirrors.aliyun.com/zabbix/zabbix/5.2/rhel/7/x86_64/zabbix-agent2-5.2.1-1.el7.x86_64.rpm && \
# install instantclient_12_1 sqlplus
    yum install -y libaio && \
	mkdir -p /oracle_client && \
	tar -xvf /instantclient_12_1.tar.gz -C /oracle_client && \
	rm -rf /instantclient_12_1.tar.gz && \
	cd /oracle_client/instantclient_12_1 && \
	ln -s libclntsh.so.12.1 libclntsh.so && \
	ln -s libocci.so.12.1 libocci.so && \
	yum clean all && \
	rm -rf /var/cache/yum/*

EXPOSE 10050/TCP

WORKDIR /var/lib/zabbix

VOLUME ["/var/lib/zabbix/enc"]

ENTRYPOINT ["/bin/bash", "/usr/bin/docker-entrypoint.sh"]

CMD ["/usr/sbin/zabbix_agent2", "--foreground", "-c", "/etc/zabbix/zabbix_agent2.conf"]