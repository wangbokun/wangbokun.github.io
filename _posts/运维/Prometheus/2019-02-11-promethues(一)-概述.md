---
layout: post
category: 运维
---

> Prometheus 

# 1 概述

# 2 Prometheus
## 2.1  结构图
![](/assets/img//15679999747642.jpg)





## 2.2 Loach告警配置页面
![-w2870](/assets/img//15647297434241.jpg)
- Rule 配置
![-w1361](/assets/img//15647297709661.jpg)
- Record 配置
![-w876](/assets/img//15647297869262.jpg)
- Target托管
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
>Grafana 6.x Docker部署，Nginx ip_hash 实现 HA

![-w631](/assets/img//15498795212775.jpg)

## 2.6 AlertDashboard、Oncall Dashboard
- 1.0版本
![-w1384](/assets/img//15680001587371.jpg)
- Oncall Ui 2.0版本
- 卡片式
![-w1386](/assets/img//15680002448461.jpg)

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

# 参考资料

> https://www.ctolib.com/docs/sfile/prometheus-book/
> https://aleiwu.com/post/prometheus-bp/#%E4%B8%8D%E8%A6%81%E4%BD%BF%E7%94%A8-nfs-%E5%81%9A%E5%AD%98%E5%82%A8