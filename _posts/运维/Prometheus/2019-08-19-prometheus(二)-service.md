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

总结: rate(增长速率)= [last - frist]/时间(s)
      increase(增长量) = rate * 时间
举个例子:
原始值： 09:12:57 =  30
        09:11:57 =  24
![](/assets/img//15718443447542.jpg)


![](/assets/img//15718442894612.jpg)

rate(xxx)[1m] = (30-24)/1*60= 0.1
如图所示需要找下一个点的值:09:13:27~=0.1
![](/assets/img//15718444723415.jpg)

increase = rate * 时间 = 0.1333 * 60= 7.998 ~=8
![](/assets/img//15718445850553.jpg)
当然这个是约等于计算方式，具体计算函数比较复杂，可以看一下原始的代码


```
func extrapolatedRate(vals []Value, args Expressions, enh *EvalNodeHelper, isCounter bool, isRate bool) Vector {
    ms := args[0].(*MatrixSelector)

    var (
        matrix     = vals[0].(Matrix)
        rangeStart = enh.ts - durationMilliseconds(ms.Range+ms.Offset)
        rangeEnd   = enh.ts - durationMilliseconds(ms.Offset)
    )
    // 遍历多个vector，分别求解delta/increase/rate。
    for _, samples := range matrix {
        // 忽略少于两个点的vector。
        if len(samples.Points) < 2 {
            continue
        }
        var (
            counterCorrection float64
            lastValue         float64
        )
        // 由于counter存在reset的可能性，因此可能会出现0, 10, 5, ...这样的序列，
        // Prometheus认为从0到5实际的增值为10 + 5 = 15，而非5。
        // 这里的代码逻辑相当于将10累计到了couterCorrection中，最后补偿到总增值中。
        for _, sample := range samples.Points {
            if isCounter && sample.V < lastValue {
                counterCorrection += lastValue
            }
            lastValue = sample.V
        }
        resultValue := lastValue - samples.Points[0].V + counterCorrection

        // 采样序列与用户请求的区间边界的距离。
        // durationToStart表示第一个采样点到区间头部的距离。
        // durationToEnd表示最后一个采样点到区间尾部的距离。
        durationToStart := float64(samples.Points[0].T-rangeStart) / 1000
        durationToEnd := float64(rangeEnd-samples.Points[len(samples.Points)-1].T) / 1000
        // 采样序列的总时长。
        sampledInterval := float64(samples.Points[len(samples.Points)-1].T-samples.Points[0].T) / 1000
        // 采样序列的平均采样间隔，一般等于scrape interval。
        averageDurationBetweenSamples := sampledInterval / float64(len(samples.Points)-1)

        if isCounter && resultValue > 0 && samples.Points[0].V >= 0 {
            // 由于counter不能为负数，这里对零点位置作一个线性估计，
            // 确保durationToStart不会超过durationToZero。
            durationToZero := sampledInterval * (samples.Points[0].V / resultValue)
            if durationToZero < durationToStart {
                durationToStart = durationToZero
            }
        }

        // *************** extrapolation核心部分 *****************
        // 将平均sample间隔乘以1.1作为extrapolation的判断间隔。
        extrapolationThreshold := averageDurationBetweenSamples * 1.1
        extrapolateToInterval := sampledInterval
        // 如果采样序列与用户请求的区间在头部的距离不超过阈值的话，直接补齐；
        // 如果超过阈值的话，只补齐一般的平均采样间隔。这里解决了上述的速率爆炸问题。
        if durationToStart < extrapolationThreshold {
            // 在scrape interval不发生变化、数据不缺失的情况下，
            // 基本都进入这个分支。
            extrapolateToInterval += durationToStart
        } else {
            // 基本不会出现，除非scrape interval突然变很大，或者数据缺失。
            extrapolateToInterval += averageDurationBetweenSamples / 2
        }
        // 同理，参上。
        if durationToEnd < extrapolationThreshold {
            extrapolateToInterval += durationToEnd
        } else {
            extrapolateToInterval += averageDurationBetweenSamples / 2
        }
        // 对增值进行等比放大。
        resultValue = resultValue * (extrapolateToInterval / sampledInterval)
        // 如果是求解rate，除以总的时长。
        if isRate {
            resultValue = resultValue / ms.Range.Seconds()
        }

        enh.out = append(enh.out, Sample{
            Point: Point{V: resultValue},
        })
    }
    return enh.out
}
```

> 参考: https://lotabout.me/2019/QQA-Why-Prometheus-increase-return-float/
> https://ihac.xyz/2018/12/11/Prometheus-Extrapolation%E5%8E%9F%E7%90%86%E8%A7%A3%E6%9E%90/
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
# 4 内置变量
# 4.1 cunstom target http

```
# 默认是不支持http sd的，通过file_sd 变相实现http sd，方便配置
#首先配置一个file sd
- job_name: loach_cuntom_sd
  honor_timestamps: true
  scrape_interval: 30s
  scrape_timeout: 10s
  metrics_path: /metrics
  scheme: http
  file_sd_configs:
  - files:
    - /etc/prometheus/test/loach/targets/*.json
    refresh_interval: 2m
#第二部：自己服务添加配置后将文件落地到这个目录，每个两分钟prometheus服务自动刷新目录下的json文件
```

![](/assets/img//15756139673537.jpg)



# 5.Q&&A
## 5.1
```
#“坏指标”报警出来之后，就可以用 metric_relabel_config 的 drop 操作删掉有问题的 label（比如 userId、email 这些一看就是问题户），这里的配置方式可以查阅文档
# 统计每个指标的时间序列数，超出 10000 的报警
count by (__name__)({__name__=~".+"}) > 10000
sort_desc(count by (__name__)({__name__=~".+"}))
```
## 5.2
先 rate() 再 sum()，不能 sum() 完再 rate()
  
## 5.3 __metrics_path__

```
targets metrics path自定义问题
默认path为motrics，动态便跟需要和job平级添加metrics_path来改变

第二种方法是通过labels写入内置变量来实现覆盖
__metrics_path__ : /prometheus
```
![](/assets/img//%E4%BC%81%E4%B8%9A%E5%BE%AE%E4%BF%A1%E6%88%AA%E5%9B%BE_5e7eee53-e16a-4989-914d-c370b7a7f642.png)
![](/assets/img//15756142310224.jpg)

## 5.4 删除历数据

```
#按条件删除
$ curl -X POST -g 'http://localhost:9090/api/v1/admin/tsdb/delete_series?match[]={kubernetes_name="redis"}'
#按条件删除
curl -X POST -g 'http://localhost:9090/api/v1/admin/tsdb/delete_series?match[]=servicemap{}'

#删除所有数据
curl -X POST -g 'http://localhost:9090/api/v1/admin/tsdb/delete_series?match[]={__name__=~".+"}'
```