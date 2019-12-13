---
layout: post
category: 运维
---

> AlertManager

# 1 Overview
 ![](/assets/img//15662147290801.jpg)

# 2 configure
## 2.1 基本配置

```
global:
  resolve_timeout: 30m
templates:
  - './templates/*.tmpl'

route:
  group_by: ['alertname']
  #group 等待时间
  group_wait: 30s
  #每个多长时间group一次
  group_interval: 1m
  #同样告警四个小时候再发送
  repeat_interval: 4h

```

## 2.2 webhook

```
#AlertManager webhook 配置
  receiver: 'default'
  routes:
    - receiver: 'sender_default'
      group_interval: 30s
      group_by: ['alertname','instance','job']
      continue: true
  receivers:
    webhook_configs:
      - url: 'http://xxxx.com/api/v1/alert?token=xxxx'
        send_resolved: true
```
## 2.3 inhibit

```
inhibit_rules:
- source_match:
    level: P0
  target_match_re:
    level: P1
  equal: [alertname,instance,job,Project,method,module]

- source_match:
    level: P0
  target_match_re:
    level: P2
  equal: [alertname,instance,job,Project,method,module]

- source_match:
    level: P0
  target_match_re:
    level: P3
  equal: [alertname,instance,job,Project,method,module]

- source_match:
    level: P0
  target_match_re:
    level: P4
  equal: [alertname,instance,job,Project,method,module]

- source_match:
    level: P1
  target_match_re:
    level: P2
  equal: [alertname,instance,job,Project,method,module]

- source_match:
    level: P1
  target_match_re:
    level: P3
  equal: [alertname,instance,job,Project,method,module]

- source_match:
    level: P1
  target_match_re:
    level: P4
  equal: [alertname,instance,job,Project,method,module]


- source_match:
    level: P2
  target_match_re:
    level: P3
  equal: [alertname,instance,job,Project,method,module]

- source_match:
    level: P2
  target_match_re:
    level: P4
  equal: [alertname,instance,job,Project,method,module]

- source_match:
    level: P3
  target_match_re:
    level: P4
  equal: [alertname,instance,job,Project,method,module]


# 测试结果
规则1: p0 > 100
规则2: p3 > 5

模拟一:
value 300
只发送p0
value 50
p0 恢复，发送p3
value 0
p3 恢复

模拟二：
value：300
只发送p0
value：0
p0恢复，p3恢复

```

# 3 告警统计-作业流程

> Pipline 1：alertManager webhook->flume->kafka->flume->hdfs->oozie parrtion
> Pipline 2本文采用oozie->spark sql-> output Mysql ->grafana

![-w910](/assets/img//15741344627447.jpg)


## 3.1 Pipline 1

  -  golang自己写sender服务，接收AlertManager Post过来的告警数据，
   Output： 微信、Email、SMS、csv File
   
```
#AlertManager webhook 配置见上文，2.2 webhook
#一下两条线，这次先不写细节
#Flume->kafka->flume->hdfs
#oozie job hive parttion
```

## 3.2 Pipline 2
- oozie + spark sql 做数据统计出报表
![](/assets/img//15741336321448.jpg)


![-w1429](/assets/img//15740599414500.jpg)

![](/assets/img//15740602285242.jpg)


Mysql 数据格式
![](/assets/img//15741334922651.jpg)

grafana告警数据自动化展示

```
SELECT
  UNIX_TIMESTAMP(day) as time_sec,
  total as value,
  'total' as metric

FROM prom_alerts.loach_alert_total_1d
WHERE $__timeFilter(day)
ORDER BY day asc

```
![](/assets/img//15741335267251.jpg)

# 4 数据化运维之告警统计
## 4.1 告警总数. 统计/天 报表
![](/assets/img//15741345414661.jpg)
## 4.2 告警级别、环境、项目、部门、机器、告警类型

![-w369](/assets/img//15746699010337.jpg)

![-w1349](/assets/img//15746698666712.jpg)

![-w1342](/assets/img//15746700693169.jpg)

![-w1368](/assets/img//15746699305545.jpg)

![-w388](/assets/img//15746699815042.jpg)

![-w718](/assets/img//15746700297796.jpg)

![-w836](/assets/img//15746701157776.jpg)

![-w1345](/assets/img//15746701789679.jpg)

![-w1357](/assets/img//15746702305199.jpg)
