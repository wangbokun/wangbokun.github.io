---
layout: post
category: 运维
---

> Prometheus exporter libs
> https://wiki.lnd.bz/display/LFTC/Node+Exporter

# 1 JAVA类型
## 1.1 go exportr

## 1.2 Druid exporter
> Version druid 0.12.1
> 参考:
> http://tinohean.com/2017/10/16/%E7%9B%91%E6%8E%A7%E7%B3%BB%E7%BB%9F-druid/
> https://github.com/wikimedia/operations-software-druid_exporter

### 安装
关于监控metrics的说明
http://druid.io/docs/0.12.1/operations/metrics.html
关于monitors及metrics配置相关的说明
http://druid.io/docs/latest/configuration/index.html

```
git clone https://github.com/wangbokun/druid-exporter

pip install prometheus_client

nohup python exporter.py&
```
### Druid配置

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
###  Prometheus 采集数据Grafna展示

```

```
## 1.3 cloudwatch_exporter
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


