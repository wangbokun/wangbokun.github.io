---
layout: post
category: 大数据
---

>CDH
# 1 源码编译

## 1.1 源码下载
```
#本文采用5.15.1
下载地址:
http://archive.cloudera.com/cdh5/cdh/5/
http://archive.cloudera.com/cdh5/cdh/5/hadoop-2.6.0-cdh5.15.1-src.tar.gz
```

![](/assets/img//15717364634272.jpg)


![](/assets/img//15725153283575.jpg)
## 1.2 编译
> ...
> 
# 2 hadoop-common-project(fs)
## 2.1 fs
![](/assets/img//15725152751074.jpg)
## 2.2 Hadoop-auth
![](/assets/img//15725279055494.jpg)
## 2.3 hadoop conf
![](/assets/img//15725279616143.jpg)
## 2.4 crypto
![](/assets/img//15725279874206.jpg)
## 2.5 permission
![](/assets/img//15725280665126.jpg)

## 2.6 fs.ftp/local-fs 

- 这个版本看到hdfs直接支持ftp.可在配置文件中配置ftp相关信息.
- localfs 就不必废话

![](/assets/img//15725153885611.jpg)

## 2.7  hadoop fs command
-  2.7.1 findCommand

![](/assets/img//15725281543769.jpg)
-  2.7.2 ACLCommand

![](/assets/img//15725281805894.jpg)
-  2.7.3 copyCommand

![](/assets/img//15725282121823.jpg)
-  2.7.4 countCommand

![](/assets/img//15725282397489.jpg)
- 2.7.5 deleteCommand

![](/assets/img//15725282658517.jpg)
- 2.7.6 displayCommand

![](/assets/img//15725282831203.jpg)
- 2.7.7 fsUsageCommand

![](/assets/img//15725283117862.jpg)
- 2.7.8 LsCommand

![](/assets/img//15725283487533.jpg)
- 2.7.9 make/moveCommand

![](/assets/img//15725283883754.jpg)
- 2.7.10 setReplicationCommand

![](/assets/img//15725284111098.jpg)
- 2.7.11 snapshotCommand

![](/assets/img//15725284466695.jpg)
- 2.7.12 statCommand

![](/assets/img//15725284813482.jpg)
- 2.7.13 tailCommand

![](/assets/img//15725284990121.jpg)
- 2.7.14 test/touchz Command

![](/assets/img//15725285359543.jpg)
- 2.7.15 viewFS

## 2.8 NameNode HA

```
hadoop-2.6.0-cdh5.15.1/hadoop-hdfs-project/hadoop-hdfs/src/main/java/org/apache/hadoop/hdfs/server/namenode/ha
```
![](/assets/img//15725987288113.jpg)

```
hadoop-2.6.0-cdh5.15.1/hadoop-common-project/hadoop-common/src/main/java/org/apache/hadoop/ha
```

![](/assets/img//15725987757454.jpg)


![](/assets/img//15729413517820.jpg)

![](/assets/img//15729416644741.jpg)

```
#主备切换过程DFSZKFailoverController进程,由三个组件完成ZKFailoverController、HealthMonitor 和 ActiveStandbyElector
1. HealthMonitor dowhile check健康状态
2. SERVICE_UNHEALTHY && SERVICE_NOT_RESPONDING 结果出现这两中状态时机械能给你下一步
3. quitElection会关闭zk链接，(watcher退出) 
4. zkFailoverController会delete zk中的节点ActiveStandbyElectorLock，active zk关闭链接
5. standby节点可以坚挺听到delete事件，会马上创建ActiveStandbyElectorLock节点
6. 创建成功，namenode开始切换为active状态

## zk 目录
[zk: localhost:2181(CONNECTED) 3]get /hadoop-ha/test/ActiveBreadCrumb
test
namenode83#cdh-nn-002.test.com �>(�>
cZxid = 0x100000057
ctime = Thu Dec 27 15:51:02 CST 2018
mZxid = 0x10002086d6
mtime = Thu Oct 31 18:28:45 CST 2019
pZxid = 0x100000057
cversion = 0
dataVersion = 41
aclVersion = 0
ephemeralOwner = 0x0
dataLength = 64
numChildren = 0
```

- HealthMonitor 这个组件是检测namenode健康状态，主要检查点是以下五个

![](/assets/img//15729391839334.jpg)


```
#org/apache/hadoop/ha/hea;thMonitor.java 197 Line
循环检测健康状态.返回状态
doHealthChecks(){
    while(){
       try{ 
        proxy.monitorHealth();
        healthy = true;
        } catch{
            if(){
                SERVICE_UNHEALTHY
            }else{
            enterState(State.SERVICE_NOT_RESPONDING)
            }
        }
    }
}
```

-  HA commands

![](/assets/img//15729392764482.jpg)

- ActionStandbyElector 

![](/assets/img//15729419556927.jpg)


```
ha.zookeeper.parent-znode(默认/hadoop-ha) / ActiveStandbyElectorLock  锁路径
ha.zookeeper.parent-znode(默认/hadoop-ha) /ActiveBreadCrumb  数据路径
State.SERVICE_NOT_RESPONDING 后会进入callbacks 断开zk的链接

#在zk里面创建路径
createLockNodeAsync(){
    zkClient.create(zkLockFilePath, appData, zkAcl, CreateMode.EPHEMERAL, this, zkClient)
}
```

- failOverController

![](/assets/img//15729424716843.jpg)

## 2.9 http
> 这个包就比较简单了，web服务+路由注册

![](/assets/img//15729429942724.jpg)

## 3.10 io


![](/assets/img//15729436142883.jpg)

