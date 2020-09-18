---
layout: post
category: 运维
---
> mac-win双系统安装
# 1  macbook安装win双系统
## 1.1 下载镜像

http://micrisoft.com/zh-cn/software-download/windows10ISO

# 2 报错拷贝windows安装文件出错
## 2.1 修改镜像
```
注意install.win文件大小默认大于4G，因为fat32不支持大于4G的文件，需要精简下
```

![-w988](/assets/img//15942190237474.jpg)

![-w557](/assets/img//15942190409070.jpg)

![-w705](/assets/img//15942191039595.jpg)


![-w555](/assets/img//15942191454920.jpg)

![-w558](/assets/img//15942192685330.jpg)

![-w707](/assets/img//15942193581589.jpg)

![-w553](/assets/img//15942193775567.jpg)

![-w350](/assets/img//15942196729836.jpg)

![-w577](/assets/img//15942197330326.jpg)


```
导出文件3.9G，小于4G.然后替换原来的文件
cd Downloads/Win10_2004_Chinese/sources
sudo rm -rf install.wim
sudo mv ~/Desktop/install.wim .
```
## 2.2  打包iso

```
本文使用ultraiso.
```

![-w774](/assets/img//15942201126619.jpg)


![-w774](/assets/img//15942202832971.jpg)

![-w705](/assets/img//15942203125218.jpg)


![-w766](/assets/img//15942206943809.jpg)

![-w772](/assets/img//15942215762873.jpg)


![-w362](/assets/img//15942215373053.jpg)

![-w492](/assets/img//15942216031705.jpg)

# 3 没有足够空间来进行分区
## 3.1



