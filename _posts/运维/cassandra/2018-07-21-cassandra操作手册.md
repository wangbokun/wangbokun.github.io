---
layout: post
category: 运维
---

> cassandra操作手册

# 1 概述
## 1.1
## 1.2
关于墓碑【1-5】: https://zhaoyanblog.com/archives/964.html
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
![](/assets/img/15321464483629.jpg)


* 创建用户

```
cassandra@cqlsh:system_auth>create user user_prod with password 'gEQhXhrhLhQAAAPDBFSDrB';
```
* 用户添加权限

```
#给所有权限
GRANT ALL PERMISSIONS ON KEYSPACE test TO  user_prod;

#只读用户
GRANT select on PERMISSIONS test   to user_prod;

#权限列表 ALL，ALTER，AUTHORIZE，CREATE，DROP， MODIFY，SELECT
```
* 常用命令

| 名称 | 命令 |备注  |
| --- | --- | --- |
|  手动触发compact| bin/nodetool compact -- ${keyspace} |  |
|查看keyspace状态|bin/nodetool tablestats -- ${keyspace}||


## 2.2 基本操作

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

#3 数据迁移

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

bin/sstableloader -d 10.128.128.128 /data/{{keyspace}}/


"for i in `ls  /data/cassandra/apache-cassandra/data/data/data_collection_stg/`; do  sudo -u cassandra /data/cassandra/apache-cassandra/bin/sstableloader -d 10.128.237.39,10.128.236.230,10.128.239.173     /data/cassandra/apache-cassandra/data/data/data_collection_stg/$i ;done"
```


