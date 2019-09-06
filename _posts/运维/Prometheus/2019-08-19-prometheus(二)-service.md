---
layout: post
category: 运维
---

> Prometheus 


# 1 Prometheus
# 2 configure
# 3 cql
## 3.1  increase
- increase(abc{})[1m]
  意思第一值和最后一个值的差值的增长率.
increase(v range-vector)函数是PromQL中提供的众多内置函数之一。其中参数v是一个区间向量，increase函数获取区间向量中的第一个后最后一个样本并返回其增长量。因此，可以通过以下表达式Counter类型指标的增长率/斜率

```
increase(node_cpu[2m]) / 120
```
这里通过node_cpu[2m]获取时间序列最近两分钟的所有样本，increase计算出最近两分钟的增长量，最后除以时间120秒得到node_cpu样本在最近两分钟的平均增长率。并且这个值也近似于主机节点最近两分钟内的平均CPU使用率。
![-w678](/assets/img//15662175211886.jpg)

![-w684](/assets/img//15662175680359.jpg)

## 3.2 rate
rate会取指定时间范围内所有数据点，算出一组速率，然后取平均值作为结果，rate适合缓慢变化的计数器
## 3.3 irate
irate取的是在指定时间范围内的最近两个数据点来算速率，irate适合快速变化的计数器

- 如图.等时间变成1分钟的时候两条线重合了

```
rate(cpu_iowait{instance="10.10.10.1:9100"}[10m])
irate(cpu_iowait{instance="10.10.10.1:9100"}[10m])
```
![-w679](/assets/img//15662174258478.jpg)
![-w671](/assets/img//15662174398479.jpg)
![-w668](/assets/img//15662174537996.jpg)
![-w676](/assets/img//15662174664234.jpg)


## 3.4 absent
> nodata的意思，如果数据上报失败(可能exporter当掉，可能这条指标没产生数据)，absent默认补点1

## 3.5 predict_linear 

predict_linear(v range-vector, t scalar)
predict_linear函数可以预测时间序列v在t秒后的值。它基于简单线性回归的方式(最小二乘法)，对时间窗口内的样本数据进行统计，从而可以对时间序列的变化趋势做出预测

例如，基于2小时的样本数据，来预测主机可用磁盘空间的是否在4个小时候被占满，可以使用如下表达式：

```
predict_linear(node_filesystem_free{job="node"}[2h], 4 * 3600) < 0
```
## 3.6 label_replace 动态替换标签

```
hadoop_NameNodeInfo_Free
hadoop_NameNodeInfo_Free{instance="10.10.10.1:8080",job="loach_cuntom_sd"}	123

##query relabel
label_replace(hadoop_NameNodeInfo_Free, "ip", "$1", "instance",  "(.*):.*")

hadoop_NameNodeInfo_Free{instance="10.10.10.1:8080",job="loach_cuntom_sd",ip="10.10.10.1"}	123
```
# 4.Q&&A
## 4.1
```
#“坏指标”报警出来之后，就可以用 metric_relabel_config 的 drop 操作删掉有问题的 label（比如 userId、email 这些一看就是问题户），这里的配置方式可以查阅文档
# 统计每个指标的时间序列数，超出 10000 的报警
count by (__name__)({__name__=~".+"}) > 10000
```
## 4.2
先 rate() 再 sum()，不能 sum() 完再 rate()
  
