---
layout: post
category: 运维
---

> cassandra操作手册https://www.w3cschool.cn/cassandra/cassandra_drop_keyspace.html
> http://zqhxuyuan.github.io/tags/cassandra/

# 1 概述
 

## 1.1 

## 1.2 墓碑
关于墓碑【1-5】: https://zhaoyanblog.com/archives/964.html
## 1.3 写数据过程


# 2 操作手册
## 2.1 权限管理
* 开启用户权限认证配置

```
#配置文件 cassandra.yaml

authenticator: "PasswordAuthenticator"
authorizer: "CassandraAuthorizer"
```
* 用户登录
  
```
[root@~]# ./cqlsh  `hostname -i` -ucassandra -pcassandra
Connected to Uds 'Test Cluster' at 10.125.224.109:9042.
[cqlsh 5.0.1 | Cassandra 3.11.2 | CQL spec 3.4.4 | Native protocol v4]
Use HELP for help. 
cassandra@cqlsh> use system_auth;
cassandra@cqlsh:system_auth> select * from role_permissions;

```

* 创建用户

```
cassandra@cqlsh:system_auth>create user user_prod with password 'xxxxxxx';
```
* 用户添加权限

```
#给所有权限
GRANT ALL PERMISSIONS ON KEYSPACE test TO  user_prod;

#只读用户
GRANT select on KEYSPACE test   to user_prod;

#权限列表 ALL，ALTER，AUTHORIZE，CREATE，DROP， MODIFY，SELECT
```
* OP常用命令

| 名称 | 命令 |备注  |
| --- | --- | --- |
|  手动触发compact| bin/nodetool compact -- ${keyspace} |  |
|查看keyspace状态|bin/nodetool tablestats -- ${keyspace}||
|删除节点| ./nodetool removenode host_id force||
|关闭自动压缩|nodetool disableautocompaction|
|停止正在执行的压缩|nodetool stop COMPACTION|当新节点启动之后，也要执行nodetool disableautocompaction。在数据迁移完毕之后，再放开即可nodetool enableautocompaction|
|限制所有节点数据迁移流量|nodetool setstreamthroughput 32mbps|限制为32mbps 假设你的集群有10个机器，那么你的新节点的流量大约是32*10mbps。你可以根据数据迁移的进度，完成的节点个数，慢慢调大这个值|



## 2.2 CQL基本操作
> https://blog.csdn.net/zhuwinmin/article/details/76063203

| 名称 | CQL |备注  |
| --- | --- | --- |
| 查询keyspaces |  describe keyspaces;|  |
|创建keyspace|CREATE KEYSPACE IF NOT EXISTS myCas WITH REPLICATION = {'class': 'SimpleStrategy','replication_factor':3};|replication_factor副本数|
|选择keyspace|use mycas;|
|新建表| create table kunTest(id int,user_name varchar, primary key(id) );||
|向表中添加数据|INSERT INTO user (id,user_name) VALUES (2,'bokun.wang');|
|从表中查询数据|select * from user;||
||select * from user where id=1;
|删除表中数据|delete from user where id=1;|
|创建索引|create index on user(user_name);|

### 2.2.1 数据修复 
```
在当前节点,顺序修复所有的keyspaces
./nodetool repair -seq

只修复range落在该节点的master数据
./nodetool repair -pr
```
### 2.2.2 数据导出
```
    COPY $keyspace.$table  TO '/data/xxxx.csv' WITH  HEADER = true ;
```

### 2.2.3 replication_factor repair 1 system_auth


```
# 不知道什么原因，system_auth 默认replication_factor 1 修改为:replication_factor 3
 ALTER  KEYSPACE system_auth WITH replication = {'class': 'SimpleStrategy', 'replication_factor': '3'};
 
 修改后执行repair
 
 ./nodetool repair --full system_auth
```

### 2.2.4 集群rename

```
UPDATE system.local SET cluster_name = 'dev-cvs-cluster' where key='local';
./nodetool flush
```
### 2.2.5 TRUNCATE table 清空表数据

```
cqlsh:tp> select * from student;

 s_id | s_aggregate | s_branch | s_name
------+-------------+----------+--------
    1 |          70 |       IT | ram
    2 |          75 |      EEE | rahman
    3 |          72 |     MECH | robbin

(3 rows)

cqlsh:tp> TRUNCATE student;

cqlsh:tp> select * from student;

 s_id | s_aggregate | s_branch | s_name
------+-------------+----------+--------

(0 rows)
```
## 2.3 GC CMS to G1
Cassandra默认gc方式是CMS，使用过程中出现很多问题，经常老年代打爆，频繁Full GC，而cassandra在做Full GC期间，不再接受读写操作.所以切换至G1后效果非常显著,记录下切换的方法

```
#!/bin/bash -eux

MEM_USE=0
#机器的百分之40内存给jvm，在cassandra.yml中在配置一些offheap是的性能更高
cassandra_mem_pc=40

if /usr/bin/test "$MEM_USE" = "" -o "$MEM_USE" -eq 0
  then
  MEM_USE="$(($(grep '^MemTotal:[[:space:]]' /proc/meminfo|awk '{print $2}')*$cassandra_mem_pc/100))"
else
  MEM_USE="$(($MEM_USE * 1024 * 1024))"
  fi

export MEM_USE
#export LOCAL_ADDR="{{ hostvars[inventory_hostname]['ansible_' + cassandra_node_iface_ext]['ipv4']['address'] }}"

JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk

CASSANDRA_HOME="/data/services/cassandra"
CASSANDRA_CONF="$CASSANDRA_HOME/conf"

cassandra_bin="$CASSANDRA_HOME/build/classes/main"
cassandra_bin="$cassandra_bin:$CASSANDRA_HOME/build/classes/thrift"
#cassandra_bin="$cassandra_home/build/cassandra.jar"

cassandra_parms="-Dlogback.configurationFile=logback.xml"
cassandra_parms="$cassandra_parms -Dcassandra.logdir=/data/services/cassandra/logs/"

cassandra_parms="$cassandra_parms -Dcassandra-foreground=yes"

CLASSPATH="$CASSANDRA_CONF:$cassandra_bin"

for jar in "$CASSANDRA_HOME"/lib/*.jar; do
    CLASSPATH="$CLASSPATH:$jar"
done

JMX_PORT="7199"
JVM_OPTS="-Djava.awt.headless=true"
JVM_OPTS="$JVM_OPTS -javaagent:$CASSANDRA_HOME/lib/jamm-0.3.0.jar"
JVM_OPTS="$JVM_OPTS -XX:+CMSClassUnloadingEnabled"
JVM_OPTS="$JVM_OPTS -XX:+UseThreadPriorities"
JVM_OPTS="$JVM_OPTS -XX:ThreadPriorityPolicy=42"
JVM_OPTS="$JVM_OPTS -Xmx${MEM_USE}K -Xms${MEM_USE}K"
JVM_OPTS="$JVM_OPTS -XX:+HeapDumpOnOutOfMemoryError"
JVM_OPTS="$JVM_OPTS -Xss256k"
JVM_OPTS="$JVM_OPTS -XX:StringTableSize=1000003"

JVM_OPTS="$JVM_OPTS -XX:+UseG1GC"

JVM_OPTS="$JVM_OPTS -XX:+CMSParallelInitialMarkEnabled -XX:+CMSEdenChunksRecordAlways -XX:CMSWaitDuration=10000"
JVM_OPTS="$JVM_OPTS -XX:+UseCondCardMark"

JVM_OPTS="$JVM_OPTS -Djava.net.preferIPv4Stack=true"

JVM_OPTS="$JVM_OPTS -Dcom.sun.management.jmxremote.port=7199"
JVM_OPTS="$JVM_OPTS -Dcom.sun.management.jmxremote.rmi.port=7199"
JVM_OPTS="$JVM_OPTS -Dcom.sun.management.jmxremote.ssl=false"
JVM_OPTS="$JVM_OPTS -Dcom.sun.management.jmxremote.authenticate=false"
JVM_OPTS="$JVM_OPTS -Xloggc:${CASSANDRA_HOME}/logs/gc.log"

exec /usr/bin/java $JVM_OPTS $cassandra_parms -cp "$CLASSPATH" org.apache.cassandra.service.CassandraDaemon
```

##2.4 systemd start cassandra
```
[cassandra@bin]$ cat /etc/systemd/system/cassandra.service
[Unit]
Description=Cassandra

[Service]
User=cassandra
Group=cassandra
ExecStart=/data/services/cassandra/bin/start.sh
ExecReload=/data/services/cassandra/bin/nodetool stopdaemon
KillMode=process
KillSignal=3
StandardOutput=journal
StandardError=journal
LimitNOFILE=1000000
LimitMEMLOCK=infinity
LimitNPROC=1000000
LimitAS=infinity
Restart=always


[Install]
WantedBy=multi-user.target
```

## 2.5 cassandra 配置[待完善]

```
#cassandra.yml

cluster_name: 'Cluster'
num_tokens:  256
hinted_handoff_enabled: true
max_hint_window_in_ms: 10800000 # 3 hours
hinted_handoff_throttle_in_kb: 1024
max_hints_delivery_threads: 2
hints_directory: /data/datum/cassandra/hints
hints_flush_period_in_ms: 10000
max_hints_file_size_in_mb: 128
batchlog_replay_throttle_in_kb: 1024
authenticator: AllowAllAuthenticator
authorizer: AllowAllAuthorizer
role_manager: CassandraRoleManager
roles_validity_in_ms: 2000
permissions_validity_in_ms: 2000
credentials_validity_in_ms: 2000
partitioner: org.apache.cassandra.dht.Murmur3Partitioner
data_file_directories:
    - /data/datum/cassandra/data
commitlog_directory: /data/datum/cassandra/commitlog
cdc_enabled: false
cdc_raw_directory: /data/datum/cassandra/cdc_raw
disk_failure_policy: stop
commit_failure_policy: stop
prepared_statements_cache_size_mb:
thrift_prepared_statements_cache_size_mb:
key_cache_size_in_mb:
key_cache_save_period: 14400
row_cache_size_in_mb: 0
row_cache_save_period: 0
counter_cache_size_in_mb:
counter_cache_save_period: 7200
saved_caches_directory: /data/datum/cassandra/saved_caches
commitlog_sync: periodic
commitlog_sync_period_in_ms: 10000
commitlog_segment_size_in_mb: 32
seed_provider:
    # Addresses of hosts that are deemed contact points.
    # Cassandra nodes use this list of hosts to find each other and learn
    # the topology of the ring.  You must change this if you are running
    # multiple nodes!
    - class_name: org.apache.cassandra.locator.SimpleSeedProvider
      parameters:
          # seeds is actually a comma-delimited list of addresses.
          # Ex: "<ip1>,<ip2>,<ip3>"
          - seeds: "xxxxxxx"
concurrent_reads: 16
concurrent_writes: 16
concurrent_counter_writes: 16
concurrent_materialized_view_writes: 16
memtable_allocation_type: offheap_objects
index_summary_capacity_in_mb:
index_summary_resize_interval_in_minutes: 60
trickle_fsync: false
trickle_fsync_interval_in_kb: 10240
storage_port: 7000
ssl_storage_port: 7001
listen_interface: "eth0"
start_native_transport: true
native_transport_port: 9042
start_rpc: false
rpc_interface: "eth0"
rpc_port: 9160
rpc_keepalive: true
rpc_server_type: sync
thrift_framed_transport_size_in_mb: 15
incremental_backups: false
snapshot_before_compaction: false
auto_snapshot: true
column_index_size_in_kb: 64
column_index_cache_size_in_kb: 2
concurrent_compactors: 2
compaction_throughput_mb_per_sec: 16
sstable_preemptive_open_interval_in_mb: 50
read_request_timeout_in_ms:  60000
range_request_timeout_in_ms: 60000
write_request_timeout_in_ms: 60000
counter_write_request_timeout_in_ms: 5000
cas_contention_timeout_in_ms: 60000
truncate_request_timeout_in_ms: 60000
request_timeout_in_ms: 10000
slow_query_log_timeout_in_ms: 500
cross_node_timeout: false
endpoint_snitch: SimpleSnitch
dynamic_snitch_update_interval_in_ms: 100
dynamic_snitch_reset_interval_in_ms: 600000
dynamic_snitch_badness_threshold: 0.1
request_scheduler: org.apache.cassandra.scheduler.NoScheduler
server_encryption_options:
    internode_encryption: none
    keystore: conf/.keystore
    keystore_password: cassandra
    truststore: conf/.truststore
    truststore_password: cassandra
    # More advanced defaults below:
    # protocol: TLS
    # algorithm: SunX509
    # store_type: JKS
    # cipher_suites: [TLS_RSA_WITH_AES_128_CBC_SHA,TLS_RSA_WITH_AES_256_CBC_SHA,TLS_DHE_RSA_WITH_AES_128_CBC_SHA,TLS_DHE_RSA_WITH_AES_256_CBC_SHA,TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA,TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA]
    # require_client_auth: false
    # require_endpoint_verification: false
client_encryption_options:
    enabled: false
    # If enabled and optional is set to true encrypted and unencrypted connections are handled.
    optional: false
    keystore: conf/.keystore
    keystore_password: cassandra
    # require_client_auth: false
    # Set trustore and truststore_password if require_client_auth is true
    # truststore: conf/.truststore
    # truststore_password: cassandra
    # More advanced defaults below:
    # protocol: TLS
    # algorithm: SunX509
    # store_type: JKS
    # cipher_suites: [TLS_RSA_WITH_AES_128_CBC_SHA,TLS_RSA_WITH_AES_256_CBC_SHA,TLS_DHE_RSA_WITH_AES_128_CBC_SHA,TLS_DHE_RSA_WITH_AES_256_CBC_SHA,TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA,TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA]
internode_compression: dc
inter_dc_tcp_nodelay: false
tracetype_query_ttl: 86400
tracetype_repair_ttl: 604800
enable_user_defined_functions: false
enable_scripted_user_defined_functions: false
enable_materialized_views: true
windows_timer_interval: 1
transparent_data_encryption_options:
    enabled: false
    chunk_length_kb: 64
    cipher: AES/CBC/PKCS5Padding
    key_alias: testing:1
    # CBC IV length for AES needs to be 16 bytes (which is also the default size)
    # iv_length: 16
    key_provider:
      - class_name: org.apache.cassandra.security.JKSKeyProvider
        parameters:
          - keystore: conf/.keystore
            keystore_password: cassandra
            store_type: JCEKS
            key_password: cassandra
tombstone_warn_threshold: 1000
tombstone_failure_threshold: 100000
batch_size_warn_threshold_in_kb: 5
batch_size_fail_threshold_in_kb: 50
unlogged_batch_across_partitions_warn_threshold: 10
compaction_large_partition_warning_threshold_mb: 100
gc_warn_threshold_in_ms: 1000
back_pressure_enabled: false
back_pressure_strategy:
    - class_name: org.apache.cassandra.net.RateBasedBackPressure
      parameters:
        - high_ratio: 0.90
          factor: 5
          flow: FAST
```

# 3 数据迁移

* 步骤一
  
```
#所有节点执行flush
sudo -u cassandra $CASSANDRA_HOME/bin/nodetool flush
```
* 步骤二

```
#导出表结构
bin/cqlsh  `hostname -i`  -e 'desc keyspace  {{keyspace}}' > /tmp/{{keyspace}}.cql
```
* 步骤三

```
#新集群倒入表结构
bin/cqlsh  `hostname -i`  -f  /tmp/{{keyspace}}.cql

#DESCRIBE验证是否倒入成功

```
* 步骤四

```
#找到数据存储的目录，并记录keyspace的目录，如果数据是三个副本的话三个节点，
在老集群一台机器上执行便可，如果只有一个副本，需要在三台机器上都执行一下命令

bin/sstableloader -d 10.10.10.1 /data/{{keyspace}}/

脚本如下
```


```
#/bin/bash
path=$1
#path="/data/cassandra/apache-cassandra/data/data/$keyspaces_name"


for i  in  `ls $path`

do
	$CASSANDRA_HOME/bin/sstableloader -d 10.10.10.1,10.10.10.2     $path/$i

done
```

# 4 升级集群

# 5 Q&&A
## 5.1.1 集群节点错误串连
- 集群A节点，错误连接到集群B
- ./nodetool removenode $NODE_ID
- ./nodetool -h $IP disablegossip

## 5.1.2 Couldn't find table for cfId
> 参考 http://blog.imaou.com/opensource/2015/08/01/cassandra_column_family_id_mismatch.html


```
org.apache.cassandra.db.UnknownColumnFamilyException: Couldn't find table for cfId 622b0d90-956e-11e8-a8a9-75fabe9527fa. If a table was just created, this is likely due to the schema not being fully propa
gated.  Please wait for schema agreement on table creation.
        at org.apache.cassandra.config.CFMetaData$Serializer.deserialize(CFMetaData.java:1517) ~[apache-cassandra-3.11.2.jar:3.11.2]
```

官方文章写采用轮询重启服务后，不再报错



