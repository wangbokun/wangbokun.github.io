---
layout: post
category: 大数据
---

>Hadoop Commands

# 1 OverView
> 记录hadoop常用命令集

# 2 Commands
## 2.1 查看压缩文件

```
#lzo
hadoop fs -cat /user/xxx/xxx.lzo | lzop -dc | head -1

#gz压缩 
hadoop fs -cat /tmp/xxx.gz | gzip -d​ 
hadoop fs -cat /tmp/xxx.gz | zcat​
```