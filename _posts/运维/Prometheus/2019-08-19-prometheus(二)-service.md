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
  意思是当前值和最后一个值的差值.
increase(v range-vector)函数是PromQL中提供的众多内置函数之一。其中参数v是一个区间向量，increase函数获取区间向量中的第一个后最后一个样本并返回其增长量。因此，可以通过以下表达式Counter类型指标的增长率/斜率

```
increase(node_cpu[2m]) / 120
```
这里通过node_cpu[2m]获取时间序列最近两分钟的所有样本，increase计算出最近两分钟的增长量，最后除以时间120秒得到node_cpu样本在最近两分钟的平均增长率。并且这个值也近似于主机节点最近两分钟内的平均CPU使用率。

## 3.2 rate
## 3.3 irate
## 3.4 absent
## 3.5 predict_linear
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
  
