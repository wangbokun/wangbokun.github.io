---
layout: post
category: 运维
---
> exporter

# 1  OverView

# 2 Open source Exporter
> 已实现各类Exporter自动化安装(ansible-playbooks big house)
## 2.1 Druid exporter
> Version druid 0.12.1
> 参考:
> http://tinohean.com/2017/10/16/%E7%9B%91%E6%8E%A7%E7%B3%BB%E7%BB%9F-druid/
> https://github.com/wikimedia/operations-software-druid_exporter

### 2.1.1 安装
关于监控metrics的说明
http://druid.io/docs/0.12.1/operations/metrics.html
关于monitors及metrics配置相关的说明
http://druid.io/docs/latest/configuration/index.html

```
git clone https://github.com/wangbokun/druid-exporter

pip install prometheus_client

nohup python exporter.py&
```
### 2.1.2 Druid配置

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
###  2.1.3 Prometheus 采集数据Grafna展示

```

```
## 2.2 cloudwatch_exporter
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


## 2.3 port exporter
### 2.3.1 install
```
 git clone https://github.com/wangbokun/port_exporter.git
 cd port_exporter/
 chmod 755 gradlew
 gradlew shadowJar
```
![](/assets/img//15456486442247.jpg)
![](/assets/img//15456492578593.jpg)

### 2.3.2 配置文件格式(yml):

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
### 2.3.3 run

```
java -jar {buildName}.jar -c [config_path]
#curl http://localhost:9333/metrics
```
### 2.3.4 Fix Host不显示问题

![-w999](/assets/img//15458112298417.jpg)

## 2.4 JMX exporter

```
git clone https://github.com/prometheus/jmx_exporter.git
cd jmx_exporter
mvn package

#run
java -javaagent:./jmx_prometheus_javaagent-0.3.1.jar=8080:config.yaml -jar yourJar.jar

#已写好common ansible-playbooks一键部署.后续提交public 仓库
```
## 2.5 Spark sink push metrices

> 参考http://rokroskar.github.io/monitoring-spark-on-hadoop-with-prometheus-and-grafana.html


```
vim $SPARK_HOME/conf/metrics.properties
#开始配置
*.sink.jmx.class=org.apache.spark.metrics.sink.JmxSink

#exporter:
https://github.com/prometheus/jmx_exporter 修改源代码将指标push到pushgateway
```
## 2.6 Mysql Exporter
## 2.7 Redis Exporter
## 2.8 Kafka Exporter
## 2.9 Hdfs Exporter
## 2.10 Yarn Exporter
## 2.11 Process exporter
```
https://github.com/ncabatoff/process-exporter
```

## 2.12 Blackbox exporter