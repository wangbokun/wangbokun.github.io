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

# 2 NIO Prometheus架构图
![](/assets/img//15499383143327.jpg)



OMS告警配置页面
![-w1209](/assets/img//15498793579795.jpg)

Wechat:
![-w458](/assets/img//15498794149501.jpg)
![-w461](/assets/img//15498794361449.jpg)

Email：
![-w449](/assets/img//15498794560249.jpg)
![-w452](/assets/img//15498804096912.jpg)


Grafana:
![-w631](/assets/img//15498795212775.jpg)
AlertDashboard:
![-w1429](/assets/img//15498819533654.jpg)
