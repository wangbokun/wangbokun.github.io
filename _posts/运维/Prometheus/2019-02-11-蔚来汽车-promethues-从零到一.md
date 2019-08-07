---
layout: post
category: 运维
---

> 蔚来汽车Monitor 

# 1 概述
> NIO 蔚来汽车监控2.0 Prometheus从0到1

# 1.1  从zabbix/openfalcon 到Promethues
历经zabbix && openfalcon && ganglia && nagios 等监控系统.而接触到Prometheus的时候，它的易用性以及新的理念.已经无法让我退回其他监控平台上了，下面会进一步说明各个优点.

> 第一个老梗,为什么要引入Prometheus.就不多说了.用过的人都知道.另一方面是集中式平台化，总之一句话."给用户更好的体验.给使用者更便捷的构建"

* 后端多环境多服务,前端统一展示.
* 告警从短信切换到微信接收，更好的显示告警.用短信发送告警信息你懂得.一坨文字展示.
* AlertDashboard 告警集中化.为Oncall提供统一、清晰、直观的面板展示.
* 各类exporter自动化部署.每类更加通用化的部署方案.提取公共变量.使用ansible-playbooks一键安装脚本

# 2 NIO Prometheus
## 2.1  结构图
![-w1179](/assets/img//15651885403703.jpg)







## 2.2 Loach告警配置页面
![-w2870](/assets/img//15647297434241.jpg)
- Rule 配置
![-w1361](/assets/img//15647297709661.jpg)
- Record 配置
![-w876](/assets/img//15647297869262.jpg)
-Target托管
 > Target部分使用console_sd
 > 以下是custom sd【http sd】转file sd实现 (Prometheus默认没有http sd)
 
![-w1221](/assets/img//15647298380449.jpg)

## 2.3 Wechat

![-w458](/assets/img//15498794149501.jpg)
![-w461](/assets/img//15498794361449.jpg)

## 2.4 Email

![-w449](/assets/img//15498794560249.jpg)
![-w452](/assets/img//15498804096912.jpg)


## 2.5 Grafana

![-w631](/assets/img//15498795212775.jpg)

## 2.6 AlertDashboard、Oncall Dashboard
- 1.0版本
![-w1429](/assets/img//15498819533654.jpg)
- Oncall Ui 2.0版本
- 卡片式
![-w1421](/assets/img//15631866134936.jpg)
- 表格式
![-w1425](/assets/img//15635428061945.jpg)

- 配置yml

```
1：支持配置Oncall人员对应，并且支持多人周期轮训排班
待补充
2：支持自定义颜色，使用视觉分类法，不同业务配置不同颜色，总体共支持256中颜色
```
## 2.7 告警报表-数据化运维-让你的系统群360°无死角.
> 告警数据全部打入Hive，使用Zeppelin展示
### 2.7.1 告警总体趋势
![-w1429](/assets/img//15501564518390.jpg)
### 2.7.1 告警周同比上涨下降
![-w1346](/assets/img//15501565103437.jpg)
### 2.7.3 告警按照告警类型罗列具体的服务器地址，可以用来做服务器扩容依据,反之也可以去使用率低的服务器做降配【利用率低另外有一张page专门显示详情】.
![-w1339](/assets/img//15501565949229.jpg)
### 2.7.4 告警类型维度总体分析,【同样我上报了指标所属部门、项目、服务等】可按照每个维度来出告警报表，让你的整体系统健康状态轻松展示，
![-w1336](/assets/img//15501568443885.jpg)
### 2.7.5 机器上运行的服务展示，让你的集群再无黑服务.
- 基础信息，首先先采集数据
![-w1335](/assets/img//15501572494297.jpg)

- 使用promehtues查询语句可以查询，按维度分析服务信息，比如，有开发自己搭建了一个kafka服务，非平台的黑服务.一套Sql查询就可以将其全部暴露,细节在这里就不展示了.

![-w573](/assets/img//15536825442998.jpg)
![-w558](/assets/img//15536825863899.jpg)
![-w526](/assets/img//15536826746917.jpg)
- 可点击下钻查看数据详情
![-w403](/assets/img//15536827211154.jpg)

### 2.7.6 资源使用率
- 一个很多人都能遇到的问题，减配，省钱，依据是什么？有一种叫做业务说. (DEV:我的服务很重要不能动，不能降配,你动了就影响收入...)
- 废话少说.哥不和你斗嘴皮子.直接上数据,先拉三个月历史数据给你看.并制定降配规则公式.
>一下是整体使用率情况，当然也可以安装tag，做不通维度报表(此处省略不截图)，
![-w1344](/assets/img//15501577055279.jpg)
![-w1330](/assets/img//15501577544989.jpg)

![-w1352](/assets/img//15501577744932.jpg)
![](/assets/img//15535123157292.jpg)

# 3 Exporter
> 已实现各类Exporter自动化安装(ansible-playbooks big house)
## 3.1 Druid exporter
> Version druid 0.12.1
> 参考:
> http://tinohean.com/2017/10/16/%E7%9B%91%E6%8E%A7%E7%B3%BB%E7%BB%9F-druid/
> https://github.com/wikimedia/operations-software-druid_exporter

### 3.1.1 安装
关于监控metrics的说明
http://druid.io/docs/0.12.1/operations/metrics.html
关于monitors及metrics配置相关的说明
http://druid.io/docs/latest/configuration/index.html

```
git clone https://github.com/wangbokun/druid-exporter

pip install prometheus_client

nohup python exporter.py&
```
### 3.1.2 Druid配置

```
#common
druid.emitter=composing
druid.emitter.composing.emitters=["logging","http"]
druid.emitter.http.recipientBaseUrl=http://druid-exporter.xxx.com/
druid.emitter.logging.logLevel=info

#break
druid.monitoring.monitors=["io.druid.java.util.metrics.JvmMonitor", "io.druid.server.metrics.QueryCountStatsMonitor"]

#coordinator
druid.monitoring.monitors=["io.druid.java.util.metrics.JvmMonitor"]

#historical
druid.monitoring.monitors=["io.druid.java.util.metrics.JvmMonitor", "io.druid.server.metrics.QueryCountStatsMonitor"]
```
###  3.1.3 Prometheus 采集数据Grafna展示

```

```
## 3.2 cloudwatch_exporter
> https://github.com/prometheus/cloudwatch_exporter


```
git clone https://github.com/prometheus/cloudwatch_exporter.git

cd cloudwatch_exporter
mvn package

[INFO] META-INF/maven/org.eclipse.jetty/ already added, skipping
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time: 23.285s
[INFO] Finished at: Wed Sep 05 10:40:21 CST 2018
[INFO] Final Memory: 30M/471M
[INFO] ------------------------------------------------------------------------

[root@prometheus]# java -jar target/cloudwatch_exporter-*-SNAPSHOT-jar-with-dependencies.jar 9106 example.yml
2018-09-05 10:41:30.444:INFO:oejs.Server:jetty-8.y.z-SNAPSHOT
2018-09-05 10:41:30.469:INFO:oejs.AbstractConnector:Started SelectChannelConnector@0.0.0.0:9106
```



```
curl 127.0.0.1:9106/metrics

# HELP aws_elb_healthy_host_count_average CloudWatch metric AWS/ELB HealthyHostCount Dimensions: [AvailabilityZone, LoadBalancerName] Statistic: Average Unit: Count
# TYPE aws_elb_healthy_host_count_average gauge
aws_elb_healthy_host_count_average{job="aws_elb",instance="",load_balancer_name="xxxx-elb",availability_zone="xxxx",} 2.0 1536114600000
```


```
问题记录：
默认采集指标带了时间戳，导致采集不到数据，解决过程如下：
采集原始值： 最后一列带了一个时间戳
aws_elasticache_network_bytes_out_average{job="aws_elasticache",instance="",cache_cluster_id="xxxxx",} 310207.0 1536117720000

【解决办法】
查到源代码
src/main/java/io/prometheus/cloudwatch/CloudWatchCollector.java
```
![](/assets/img/15361200139343.jpg)

然后修改配置文件，改变默认值

![](/assets/img/15361200693387.jpg)


## 3.3 port exporter
### 3.3.1 install
```
 git clone https://github.com/wangbokun/port_exporter.git
 cd port_exporter/
 chmod 755 gradlew
 gradlew shadowJar
```
![](/assets/img//15456486442247.jpg)
![](/assets/img//15456492578593.jpg)

### 3.3.2 配置文件格式(yml):

```
checkInterval: 30000 #端口检查 间隔  单位 ms 默认10秒
host: 0.0.0.0
port: 9333
targets:  #检查端口列表
 -
  name: name1    名称
  addr: localhost:8080
 -
  name: name2    名称
  addr: localhost:8080
```
### 3.3.3 run

```
java -jar {buildName}.jar -c [config_path]
#curl http://localhost:9333/metrics
```
### 3.3.4 Fix Host不显示问题

![-w999](/assets/img//15458112298417.jpg)

## 3.4 JMX exporter

```
git clone https://github.com/prometheus/jmx_exporter.git
cd jmx_exporter
mvn package

#run
java -javaagent:./jmx_prometheus_javaagent-0.3.1.jar=8080:config.yaml -jar yourJar.jar

#已写好common ansible-playbooks一键部署.后续提交public 仓库
```
## 3.4 Spark sink push metrices

> 参考http://rokroskar.github.io/monitoring-spark-on-hadoop-with-prometheus-and-grafana.html


```
vim $SPARK_HOME/conf/metrics.properties
#开始配置
*.sink.jmx.class=org.apache.spark.metrics.sink.JmxSink

#exporter:
https://github.com/prometheus/jmx_exporter 修改源代码将指标push到pushgateway
```


# 4 Prometheus配置
# 5 Alert Manager配置


