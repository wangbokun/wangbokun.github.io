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



