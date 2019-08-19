---
layout: post
category: 大数据
---

# 1 Overview
# 2 Install
## 2.1 Running in docker

```
docker pull  hadoopsubmarine/mini-submarine:0.2.0
docker run -it -h submarine-dev --net=bridge --privileged hadoopsubmarine/mini-submarine:0.2.0  /bin/bash

# In the container, use root user to bootstrap hdfs and yarn
/tmp/hadoop-config/bootstrap.sh
```
![](/assets/img//15657007723669.jpg)


```
 yarn node -list -showDetails
19/08/13 12:53:02 INFO client.RMProxy: Connecting to ResourceManager at /0.0.0.0:8032
Total Nodes:1
         Node-Id	     Node-State	Node-Http-Address	Number-of-Running-Containers
submarine-dev:44461	        RUNNING	submarine-dev:8042	                           0
Detailed Node Information :
	Configured Resources : <memory:8192, vCores:16>
	Allocated Resources : <memory:0, vCores:0>
	Resource Utilization by Node : PMem:1573 MB, VMem:1577 MB, VCores:0.06990679
	Resource Utilization by Containers : PMem:0 MB, VMem:0 MB, VCores:0.0
	Node-Labels :
	
	
hdfs dfs -ls /user
Found 1 items
drwxr-xr-x   - yarn supergroup          0 2019-08-13 12:52 /user/yarn

su yarn
cd && cd submarine && ./run_submarine_minist_tony.sh
```
![](/assets/img//15657008990692.jpg)

![-w1330](/assets/img//15657016266974.jpg)
