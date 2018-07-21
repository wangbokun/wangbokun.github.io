---
layout: post
category: 运维
---

> Prometheus exporter libs

## 1 JAVA类型
### 1.1 JMX exportr
### 1.2 Druid exporter
> Version druid 0.12.1

#### 安装

```
git clone https://github.com/wangbokun/druid-exporter

pip install prometheus_client

nohup python exporter.py&
```
#### Druid配置

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
####  Prometheus 采集数据Grafna展示



