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
`
    COPY $keyspace.$table  TO '/data/xxxx.csv' WITH  HEADER = true ;
`

### 2.3.3 replication_factor repair 1 system_auth


```
# 不知道什么原因，system_auth 默认replication_factor 1 修改为:replication_factor 3
 ALTER  KEYSPACE system_auth WITH replication = {'class': 'SimpleStrategy', 'replication_factor': '3'};
 
 修改后执行repair
 
 ./nodetool repair --full system_auth
```
## 2.3 集群rename

```
UPDATE system.local SET cluster_name = 'dev-cvs-cluster' where key='local';
./nodetool flush
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



