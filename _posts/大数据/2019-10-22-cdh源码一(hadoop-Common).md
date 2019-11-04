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

# 3 hadoop fs command
-  3.1 findCommand
![](/assets/img//15725281543769.jpg)
-  3.2 ACLCommand
![](/assets/img//15725281805894.jpg)
-  3.3 copyCommand
![](/assets/img//15725282121823.jpg)
-  3.4 countCommand
![](/assets/img//15725282397489.jpg)
- 3.5 deleteCommand
![](/assets/img//15725282658517.jpg)
- 3.6 displayCommand
![](/assets/img//15725282831203.jpg)
- 3.7 fsUsageCommand
![](/assets/img//15725283117862.jpg)
- 3.8 LsCommand
![](/assets/img//15725283487533.jpg)
- 3.9 make/moveCommand
![](/assets/img//15725283883754.jpg)
- 3.10 setReplicationCommand
![](/assets/img//15725284111098.jpg)
- 3.11 snapshotCommand
![](/assets/img//15725284466695.jpg)
- 3.12 statCommand
![](/assets/img//15725284813482.jpg)
- 3.13 tailCommand
![](/assets/img//15725284990121.jpg)
- 3.14 test/touchz Command
![](/assets/img//15725285359543.jpg)
- 3.15 viewFS

# 4 NameNode HA

```
hadoop-2.6.0-cdh5.15.1/hadoop-hdfs-project/hadoop-hdfs/src/main/java/org/apache/hadoop/hdfs/server/namenode/ha
```
![](/assets/img//15725987288113.jpg)

```
hadoop-2.6.0-cdh5.15.1/hadoop-common-project/hadoop-common/src/main/java/org/apache/hadoop/ha
```

![](/assets/img//15725987757454.jpg)
